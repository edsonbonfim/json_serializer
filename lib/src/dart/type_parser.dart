import '../errors/exception.dart';
import '../utils/string_view.dart';

/// Represents the different types of tokens in the Dart lexer.
enum TokenType {
  identifier,
  colon,
  lParen,
  rParen,
  comma,
  lCurlyBracket,
  rCurlyBracket,
  lSquareBracket,
  rSquareBracket,
  questionMark,
  equals,
  greaterThan,
  lessThan,
  eof
}

/// Represents a token in the Dart lexer.
///
/// A token consists of a type and the actual text (lexeme) that was matched.
class Token {
  /// The type of the token.
  final TokenType type;

  /// The lexeme of the token (the actual text matched).
  final String lexeme;

  /// Creates a new instance of the [Token] class.
  ///
  /// @param [type] The type of the token.
  /// @param [lexeme] The lexeme (text) of the token.
  Token(this.type, this.lexeme);

  @override
  String toString() => lexeme;
}

/// A map of symbol tokens used in the Dart lexer.
///
/// Maps single-character symbols to their corresponding token types.
/// Optimized to use byte codes for faster lookup.
final symbolTokens = <String, Token>{
  ':': Token(TokenType.colon, ':'),
  '(': Token(TokenType.lParen, '('),
  ')': Token(TokenType.rParen, ')'),
  ',': Token(TokenType.comma, ','),
  '{': Token(TokenType.lCurlyBracket, '{'),
  '}': Token(TokenType.rCurlyBracket, '}'),
  '[': Token(TokenType.lSquareBracket, '['),
  ']': Token(TokenType.rSquareBracket, ']'),
  '?': Token(TokenType.questionMark, '?'),
  '=': Token(TokenType.equals, '='),
  '>': Token(TokenType.greaterThan, '>'),
  '<': Token(TokenType.lessThan, '<'),
};

/// Byte code lookup table for symbol tokens (optimized for performance).
///
/// Maps byte codes directly to token types for O(1) lookup.
final _symbolByteCodes = <int, TokenType>{
  58: TokenType.colon,   // ':'
  40: TokenType.lParen,  // '('
  41: TokenType.rParen,  // ')'
  44: TokenType.comma,   // ','
  123: TokenType.lCurlyBracket,  // '{'
  125: TokenType.rCurlyBracket,  // '}'
  91: TokenType.lSquareBracket,  // '['
  93: TokenType.rSquareBracket,  // ']'
  63: TokenType.questionMark,    // '?'
  61: TokenType.equals,          // '='
  62: TokenType.greaterThan,      // '>'
  60: TokenType.lessThan,        // '<'
};

/// Tokenizes Dart-like type strings into a stream of [Token]s.
///
/// Uses `StringView` with `ByteData`/`Uint16List` views to avoid copies and
/// operate directly on UTF-16 code units, making it suitable for hot paths in
/// the parser.
class DartLexer {
  /// Character code constants for character classification.
  static const int _newlineCode = 10; // \n
  static const int _carriageReturnCode = 13; // \r
  static const int _tabCode = 9; // \t
  static const int _spaceCode = 32; // ' '
  static const int _uppercaseA = 65; // A
  static const int _uppercaseZ = 90; // Z
  static const int _lowercaseA = 97; // a
  static const int _lowercaseZ = 122; // z
  static const int _underscoreCode = 95; // _
  static const int _digitZero = 48; // 0
  static const int _digitNine = 57; // 9
  static const int _printableCharMin = 32;
  static const int _printableCharMax = 126;
  static const int _contextSize = 20;
  static const int _ellipsisLength = 3; // "..."
  static const int _hexRadix = 16;

  final String input;

  late final StringView _inputView;

  late final int _inputLength;

  var _position = 0;

  /// Creates a lexer with zero-copy typed views over [input].
  ///
  /// @param [input] Raw source to tokenize.
  /// @returns A lexer ready to emit tokens from the provided input.
  DartLexer(this.input) {
    // Cria uma view tipada única (ByteData/Uint16/Uint8) para reuso sem cópia.
    _inputView = StringView(input);
    _inputLength = _inputView.length;
  }

  /// Retrieves the next token from the stream.
  ///
  /// @returns The next [Token], or an EOF token when input ends.
  /// @throws [FormatException] When an unrecognized character is found.
  Token getNextToken() {
    while (_position < _inputLength) {
      final codeUnit = _inputView.codeUnitAt(_position);

      if (_isWhiteSpaceCodeUnit(codeUnit)) {
        _position++;
        continue;
      }

      // Lookup direto em byte code (apenas ASCII).
      if (codeUnit < 128) {
        final tokenType = _symbolByteCodes[codeUnit];
        if (tokenType != null) {
          _position++;
          return Token(
            tokenType,
            _inputView.singleCodeUnitString(codeUnit),
          );
        }
      }

      if (_isIdentifierStartCodeUnit(codeUnit)) {
        final startPos = _position++;

        // Escaneia via ByteData sem tocar na String original.
        while (_position < _inputLength &&
            _isIdentifierPartCodeUnit(_inputView.codeUnitAt(_position))) {
          _position++;
        }

        return Token(
          TokenType.identifier,
          _inputView.sliceToString(startPos, _position),
        );
      }

      throw FormatException(_formatLexerError(codeUnit));
    }

    return Token(TokenType.eof, '');
  }

  /// Builds a formatted lexer error message with local context.
  ///
  /// @param [codeUnit] The offending code unit.
  /// @returns A detailed error string containing context and pointer.
  String _formatLexerError(int codeUnit) {
    final context = _getContext();
    final charInfo = codeUnit >= _printableCharMin && codeUnit <= _printableCharMax
        ? "'${String.fromCharCode(codeUnit)}'"
        : "0x${codeUnit.toRadixString(_hexRadix).toUpperCase()}";

    return 'Unrecognized token $charInfo at position $_position.\n'
        'Context: $context\n'
        '         ${' ' * _getContextOffset()}^';
  }

  /// Extracts a context window around the current position.
  ///
  /// @returns A substring showing nearby characters for diagnostics.
  String _getContext() {
    final start = _position > _contextSize ? _position - _contextSize : 0;
    final end = _position + _contextSize < _inputLength
        ? _position + _contextSize
        : _inputLength;

    var context = _inputView.sliceToString(start, end);

    if (start > 0) {
      context = '...$context';
    }
    if (end < _inputLength) {
      context = '$context...';
    }

    return context;
  }

  /// Computes the offset for the diagnostic pointer within the context window.
  ///
  /// @returns The zero-based offset where the pointer should be placed.
  int _getContextOffset() {
    final start = _position > _contextSize ? _position - _contextSize : 0;
    var offset = _position - start;

    if (start > 0) {
      offset += _ellipsisLength;
    }

    return offset;
  }

  /// Determines whether a code unit represents whitespace.
  ///
  /// @param [codeUnit] The value to test.
  /// @returns True when the code unit is whitespace.
  bool _isWhiteSpaceCodeUnit(int codeUnit) {
    return codeUnit == _newlineCode ||
        codeUnit == _carriageReturnCode ||
        codeUnit == _tabCode ||
        codeUnit == _spaceCode;
  }

  /// Determines whether a character is whitespace.
  ///
  /// @param [character] Single-character string to test.
  /// @returns True when the character is whitespace.
  bool isWhiteSpace(String character) {
    return _isWhiteSpaceCodeUnit(character.codeUnitAt(0));
  }

  /// Checks if a code unit is a valid identifier start.
  ///
  /// @param [codeUnit] The value to test.
  /// @returns True when it can start an identifier.
  bool _isIdentifierStartCodeUnit(int codeUnit) {
    return (codeUnit >= _uppercaseA && codeUnit <= _uppercaseZ) ||
        (codeUnit >= _lowercaseA && codeUnit <= _lowercaseZ) ||
        (codeUnit == _underscoreCode);
  }

  /// Checks if a character can start an identifier.
  ///
  /// @param [character] Single-character string to test.
  /// @returns True when it can start an identifier.
  bool isIdentifierStart(String character) {
    return _isIdentifierStartCodeUnit(character.codeUnitAt(0));
  }

  /// Checks if a code unit is valid inside an identifier.
  ///
  /// @param [codeUnit] The value to test.
  /// @returns True when it can appear in an identifier.
  bool _isIdentifierPartCodeUnit(int codeUnit) {
    return _isIdentifierStartCodeUnit(codeUnit) || _isDigitCodeUnit(codeUnit);
  }

  /// Checks if a character is valid inside an identifier.
  ///
  /// @param [character] Single-character string to test.
  /// @returns True when it can appear in an identifier.
  bool isIdentifierPart(String character) {
    return _isIdentifierPartCodeUnit(character.codeUnitAt(0));
  }

  /// Checks if a code unit represents a digit.
  ///
  /// @param [codeUnit] The value to test.
  /// @returns True when it is in [0-9].
  bool _isDigitCodeUnit(int codeUnit) {
    return codeUnit >= _digitZero && codeUnit <= _digitNine;
  }

  /// Checks if the given character is a digit character.
  ///
  /// @param [character] The character to check.
  /// @returns True if the character is a digit (0-9).
  bool isDigit(String character) {
    return _isDigitCodeUnit(character.codeUnitAt(0));
  }
}

/// Represents the parameters of a function.
///
/// This class groups together positional, optional, and named parameters.
class Parameters {
  /// The positional parameters.
  final List<TypeInfo> positional;

  /// The optional parameters.
  final List<TypeInfo> optional;

  /// The named parameters.
  final List<PropertyInfo> named;

  /// Creates a new instance of the [Parameters] class.
  ///
  /// @param [positional] The list of positional parameters.
  /// @param [optional] The list of optional parameters.
  /// @param [named] The list of named parameters.
  Parameters(this.positional, this.optional, this.named);
}

/// Represents information about a function signature.
///
/// This class contains the return type and all parameter information for a function.
class FunctionInfo {
  /// The return type of the function.
  final TypeInfo type;

  /// The positional parameters of the function.
  final List<TypeInfo> positional;

  /// The optional parameters of the function.
  final List<TypeInfo> optional;

  /// The named parameters of the function.
  final List<PropertyInfo> named;

  /// Creates a new instance of the [FunctionInfo] class.
  ///
  /// @param [type] The return type of the function.
  /// @param [positional] The list of positional parameters.
  /// @param [optional] The list of optional parameters.
  /// @param [named] The list of named parameters.
  FunctionInfo(this.type, this.positional, this.optional, this.named);
}

/// Represents information about a property or parameter.
///
/// This class contains type information, name, and whether the property is required.
class PropertyInfo {
  /// The type of the property.
  final TypeInfo type;

  /// The name of the property.
  final String name;

  /// Indicates if the property is required.
  final bool isRequired;

  /// Creates a new instance of the [PropertyInfo] class.
  ///
  /// @param [type] The type of the property.
  /// @param [name] The name of the property.
  /// @param [isRequired] Whether the property is required.
  PropertyInfo(this.type, this.name, this.isRequired);
}

/// Represents information about a Dart type.
///
/// This class contains the type name, nullability information, generic arguments,
/// and flags indicating if the type is a Map, List, or generic type.
class TypeInfo {
  /// Type name constants.
  static const String _mapTypeName = 'Map';
  static const String _mapInternalTypeName = '_Map';
  static const String _listTypeName = 'List';
  static const String _listInternalTypeName = '_List';
  static const int _mapGenericCount = 2;
  static const int _listGenericCount = 1;

  /// The name of the type.
  final String name;

  /// Indicates if the type is nullable.
  final bool isNullable;

  /// Indicates if the type is a map.
  final bool isMap;

  /// Indicates if the type is a list.
  final bool isList;

  /// Indicates if the type is a generic type.
  final bool isGeneric;

  /// The generic type arguments of the type.
  final List<TypeInfo> generics;

  /// Creates a new instance of the [TypeInfo] class.
  ///
  /// @param [name] The name of the type.
  /// @param [isNullable] Whether the type is nullable.
  /// @param [generics] The list of generic type arguments.
  TypeInfo(this.name, this.isNullable, this.generics)
      : isMap = (name == _mapTypeName || name == _mapInternalTypeName) &&
            generics.length == _mapGenericCount,
        isList = (name == _listTypeName || name == _listInternalTypeName) &&
            generics.length == _listGenericCount,
        isGeneric = generics.isNotEmpty;
}

/// The Dart parser responsible for parsing Dart type and function signatures.
///
/// This class parses string representations of Dart types and function signatures
/// into structured [TypeInfo] and [FunctionInfo] objects.
class DartParser {
  // Dependencies (injected via constructor)
  /// The lexer used to tokenize the input.
  final DartLexer _lexer;

  /// The original input string.
  final String _input;

  // Public properties
  /// The current token being processed.
  late Token _currentToken;

  // Private static properties
  /// Cache for parsed types to avoid re-parsing the same type strings.
  static final _typesCache = <String, TypeInfo>{};

  // Constants
  /// Keyword constants.
  static const String _requiredKeyword = 'required';

  /// Assertion messages.
  static const String _assertionMessageInput = 'Input string cannot be empty';
  static const String _assertionMessageTypeName = 'Type name cannot be empty';

  /// Creates a new instance of the [DartParser] class.
  ///
  /// @param [input] The input string to parse.
  /// @throws [AssertionError] if [input] is empty in debug mode.
  DartParser(String input)
      : assert(input.isNotEmpty, _assertionMessageInput),
        _lexer = DartLexer(input),
        _input = input {
    _currentToken = _lexer.getNextToken();
  }

  /// Parses a function signature and returns its information.
  ///
  /// @param [function] The function to parse.
  /// @returns A [FunctionInfo] object containing the parsed function information.
  static FunctionInfo parseFunction(Function function) {
    final constructorString = function.runtimeType.toString();
    return DartParser(constructorString)._parseFunction();
  }

  /// Parses a type string and returns its information.
  ///
  /// Uses caching to avoid re-parsing the same type strings.
  ///
  /// @param [typeName] The type string to parse.
  /// @returns A [TypeInfo] object containing the parsed type information.
  /// @throws [AssertionError] if [typeName] is empty in debug mode.
  static TypeInfo parseType(String typeName) {
    assert(typeName.isNotEmpty, _assertionMessageTypeName);

    if (_typesCache.containsKey(typeName)) {
      return _typesCache[typeName]!;
    }

    final typeInfo = DartParser(typeName)._parseType();
    _typesCache[typeName] = typeInfo;

    return typeInfo;
  }

  /// Parses a function signature and returns its information.
  ///
  /// @returns A [FunctionInfo] object containing the parsed function information.
  FunctionInfo _parseFunction() {
    final parameters = _parseParameters();

    _eat(TokenType.equals);
    _eat(TokenType.greaterThan);

    final returnType = _parseType();

    return FunctionInfo(
      returnType,
      parameters.positional,
      parameters.optional,
      parameters.named,
    );
  }

  /// Parses the parameters of a function and returns their information.
  ///
  /// @returns A [Parameters] object containing all parameter information.
  Parameters _parseParameters() {
    _eat(TokenType.lParen);

    if (_peek(TokenType.rParen)) {
      _eat(TokenType.rParen);
      return Parameters([], [], []);
    }

    if (_peek(TokenType.lCurlyBracket)) {
      _eat(TokenType.lCurlyBracket);

      final namedParameters = _parseNamedParameters();

      _eat(TokenType.rCurlyBracket);
      _eat(TokenType.rParen);

      return Parameters([], [], namedParameters);
    }

    if (_peek(TokenType.lSquareBracket)) {
      _eat(TokenType.lSquareBracket);

      final optionalParameters = _parseOptionalParameters();

      _eat(TokenType.rSquareBracket);
      _eat(TokenType.rParen);

      return Parameters([], optionalParameters, []);
    }

    final positionalParameters = _parsePositionalParameters();

    List<TypeInfo> optionalParameters = [];

    if (_peek(TokenType.lSquareBracket)) {
      _eat(TokenType.lSquareBracket);

      optionalParameters = _parseOptionalParameters();

      _eat(TokenType.rSquareBracket);
    }

    List<PropertyInfo> namedParameters = [];

    if (_peek(TokenType.lCurlyBracket)) {
      _eat(TokenType.lCurlyBracket);

      namedParameters = _parseNamedParameters();

      _eat(TokenType.rCurlyBracket);
    }

    _eat(TokenType.rParen);

    return Parameters(
      positionalParameters,
      optionalParameters,
      namedParameters,
    );
  }

  /// Parses the positional parameters of a function and returns their information.
  ///
  /// @returns A list of [TypeInfo] objects representing the positional parameters.
  List<TypeInfo> _parsePositionalParameters() {
    final parameters = [_parseType()];

    while (_peek(TokenType.comma)) {
      _eat(TokenType.comma);

      if (_peek(TokenType.lCurlyBracket) || _peek(TokenType.lSquareBracket)) {
        continue;
      }

      parameters.add(_parseType());
    }

    return parameters;
  }

  /// Parses the optional parameters of a function and returns their information.
  ///
  /// @returns A list of [TypeInfo] objects representing the optional parameters.
  List<TypeInfo> _parseOptionalParameters() {
    final parameters = [_parseType()];

    while (_peek(TokenType.comma)) {
      _eat(TokenType.comma);
      parameters.add(_parseType());
    }

    return parameters;
  }

  /// Parses the named parameters of a function and returns their information.
  ///
  /// @returns A list of [PropertyInfo] objects representing the named parameters.
  List<PropertyInfo> _parseNamedParameters() {
    final parameters = [_parseNamedParameter()];

    while (_peek(TokenType.comma)) {
      _eat(TokenType.comma);
      parameters.add(_parseNamedParameter());
    }

    return parameters;
  }

  /// Parses a named parameter and returns its information.
  ///
  /// @returns A [PropertyInfo] object representing the named parameter.
  PropertyInfo _parseNamedParameter() {
    var isRequired = false;

    if (_peek(TokenType.identifier, _requiredKeyword)) {
      _eat(TokenType.identifier, _requiredKeyword);
      isRequired = true;
    }

    final type = _parseType();
    final identifier = _parseIdentifier();

    return PropertyInfo(
      type,
      identifier,
      isRequired,
    );
  }

  /// Parses a type and returns its information.
  ///
  /// @returns A [TypeInfo] object representing the parsed type.
  TypeInfo _parseType() {
    final identifier = _parseIdentifier();

    if (_peek(TokenType.questionMark)) {
      _eat(TokenType.questionMark);
      return TypeInfo(identifier, true, []);
    }

    if (_peek(TokenType.lessThan)) {
      _eat(TokenType.lessThan);
      final genericArguments = _parseGenericArguments();
      _eat(TokenType.greaterThan);

      if (_peek(TokenType.questionMark)) {
        _eat(TokenType.questionMark);
        return TypeInfo(identifier, true, genericArguments);
      }

      return TypeInfo(identifier, false, genericArguments);
    }

    return TypeInfo(identifier, false, []);
  }

  /// Parses the generic arguments of a type and returns their information.
  ///
  /// @returns A list of [TypeInfo] objects representing the generic arguments.
  List<TypeInfo> _parseGenericArguments() {
    final types = [_parseType()];

    while (_peek(TokenType.comma)) {
      _eat(TokenType.comma);
      types.add(_parseType());
    }

    return types;
  }

  /// Parses an identifier and returns its value.
  ///
  /// @returns The identifier string.
  String _parseIdentifier() {
    final token = _currentToken;
    _eat(TokenType.identifier);
    return token.lexeme;
  }

  /// Checks if the current token matches the specified type and optional lexeme.
  ///
  /// @param [type] The expected token type.
  /// @param [lexeme] The expected lexeme (optional, for exact matching).
  /// @returns True if the current token matches, false otherwise.
  bool _peek(TokenType type, [String? lexeme]) {
    return _currentToken.type == type &&
        (lexeme == null || _currentToken.lexeme == lexeme);
  }

  /// Consumes the current token if it matches the specified type and optional lexeme.
  ///
  /// Advances to the next token if the match is successful.
  ///
  /// @param [type] The expected token type.
  /// @param [lexeme] The expected lexeme (optional, for exact matching).
  /// @throws [DartParserException] if the token doesn't match.
  void _eat(TokenType type, [String? lexeme]) {
    if (!_peek(type, lexeme)) {
      throw DartParserException(
        _formatParserError(type, lexeme),
      );
    }

    _currentToken = _lexer.getNextToken();
  }

  /// Formats a parser error message with detailed information.
  ///
  /// @param [expectedType] The expected token type.
  /// @param [expectedLexeme] The expected lexeme (optional).
  /// @returns A formatted error message.
  String _formatParserError(TokenType expectedType, [String? expectedLexeme]) {
    final expected = expectedLexeme != null
        ? "'$expectedLexeme' (${_getTokenTypeName(expectedType)})"
        : _getTokenTypeName(expectedType);

    final found = _currentToken.type == TokenType.eof
        ? 'end of input'
        : _currentToken.type == TokenType.identifier
            ? "identifier '${_currentToken.lexeme}'"
            : "'${_currentToken.lexeme}' (${_getTokenTypeName(_currentToken.type)})";

    return 'Syntax error while parsing: $_input\n'
        'Expected: $expected\n'
        'Found: $found';
  }

  /// Gets a human-readable name for a token type.
  ///
  /// @param [type] The token type.
  /// @returns A human-readable string representation of the token type.
  String _getTokenTypeName(TokenType type) {
    switch (type) {
      case TokenType.identifier:
        return 'identifier';
      case TokenType.colon:
        return 'colon (:)';
      case TokenType.lParen:
        return 'left parenthesis (';
      case TokenType.rParen:
        return 'right parenthesis )';
      case TokenType.comma:
        return 'comma (,)';
      case TokenType.lCurlyBracket:
        return 'left curly bracket {';
      case TokenType.rCurlyBracket:
        return 'right curly bracket }';
      case TokenType.lSquareBracket:
        return 'left square bracket [';
      case TokenType.rSquareBracket:
        return 'right square bracket ]';
      case TokenType.questionMark:
        return 'question mark (?)';
      case TokenType.equals:
        return 'equals (=)';
      case TokenType.greaterThan:
        return 'greater than (>)';
      case TokenType.lessThan:
        return 'less than (<)';
      case TokenType.eof:
        return 'end of file';
    }
  }
}
