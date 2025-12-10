import 'dart:typed_data';

import 'exception.dart';

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

/// The Dart lexer responsible for tokenizing input strings.
///
/// This class breaks down a string into a sequence of tokens that can be
/// parsed by the DartParser. Optimized using Uint8List and ByteData for
/// maximum performance with zero-copy views.
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

  /// The input string to be tokenized.
  final String input;

  /// The code units of the input string (cached for performance).
  /// Using Uint16List view for efficient zero-copy access to code units.
  late final Uint16List _inputCodeUnits;

  /// The current position in the input string.
  var _position = 0;

  /// Creates a new instance of the [DartLexer] class.
  ///
  /// @param [input] The input string to tokenize.
  DartLexer(this.input) {
    // Create a typed list from code units for efficient code unit-level processing
    // This avoids repeated codeUnitAt calls and provides direct array access
    final codeUnits = input.codeUnits;
    _inputCodeUnits = Uint16List.fromList(codeUnits);
  }

  /// Retrieves the next token from the input string.
  ///
  /// Optimized to use code unit-level operations for maximum performance.
  ///
  /// @returns The next token, or an EOF token if the end of input is reached.
  /// @throws [FormatException] if an unrecognized character is encountered.
  Token getNextToken() {
    if (_position >= _inputCodeUnits.length) {
      return Token(TokenType.eof, '');
    }

    final codeUnit = _inputCodeUnits[_position];

    if (_isWhiteSpaceCodeUnit(codeUnit)) {
      _position++;
      return getNextToken();
    }

    // Fast lookup using code unit (only for ASCII symbols)
    if (codeUnit < 128) {
      final tokenType = _symbolByteCodes[codeUnit];
      if (tokenType != null) {
        final symbol = String.fromCharCode(codeUnit);
        _position++;
        return Token(tokenType, symbol);
      }
    }

    if (_isIdentifierStartCodeUnit(codeUnit)) {
      final startPos = _position;
      
      // Fast scan using code units
      while (_position < _inputCodeUnits.length &&
          _isIdentifierPartCodeUnit(_inputCodeUnits[_position])) {
        _position++;
      }

      // Extract identifier using substring (optimized by Dart VM)
      final identifier = input.substring(startPos, _position);
      return Token(TokenType.identifier, identifier);
    }

    throw FormatException(_formatLexerError(codeUnit));
  }

  /// Formats a lexer error message with context information.
  ///
  /// @param [codeUnit] The unrecognized code unit that caused the error.
  /// @returns A formatted error message with context.
  String _formatLexerError(int codeUnit) {
    final context = _getContext();
    final charInfo = codeUnit >= _printableCharMin && codeUnit <= _printableCharMax
        ? "'${String.fromCharCode(codeUnit)}'"
        : "0x${codeUnit.toRadixString(_hexRadix).toUpperCase()}";

    return 'Unrecognized token $charInfo at position $_position.\n'
        'Context: $context\n'
        '         ${' ' * _getContextOffset()}^';
  }

  /// Gets the context around the current position for error messages.
  ///
  /// Uses zero-copy substring view for efficiency.
  ///
  /// @returns A substring of the input showing context around the current position.
  String _getContext() {
    final start = _position > _contextSize ? _position - _contextSize : 0;
    final end = _position + _contextSize < input.length
        ? _position + _contextSize
        : input.length;

    var context = input.substring(start, end);

    if (start > 0) {
      context = '...$context';
    }
    if (end < input.length) {
      context = '$context...';
    }

    return context;
  }

  /// Gets the offset for the error pointer in the context.
  ///
  /// @returns The offset position for displaying the error pointer.
  int _getContextOffset() {
    final start = _position > _contextSize ? _position - _contextSize : 0;
    var offset = _position - start;

    if (start > 0) {
      offset += _ellipsisLength;
    }

    return offset;
  }

  /// Checks if the given code unit represents a whitespace character.
  ///
  /// Optimized code unit-level check without string conversion.
  ///
  /// @param [codeUnit] The code unit to check.
  /// @returns True if the code unit represents whitespace.
  bool _isWhiteSpaceCodeUnit(int codeUnit) {
    return codeUnit == _newlineCode ||
        codeUnit == _carriageReturnCode ||
        codeUnit == _tabCode ||
        codeUnit == _spaceCode;
  }

  /// Checks if the given character is a whitespace character.
  ///
  /// @param [character] The character to check.
  /// @returns True if the character is whitespace (space, tab, newline, or carriage return).
  bool isWhiteSpace(String character) {
    return _isWhiteSpaceCodeUnit(character.codeUnitAt(0));
  }

  /// Checks if the given code unit represents a valid identifier start character.
  ///
  /// Optimized code unit-level check without string conversion.
  ///
  /// @param [codeUnit] The code unit to check.
  /// @returns True if the code unit can start an identifier.
  bool _isIdentifierStartCodeUnit(int codeUnit) {
    return (codeUnit >= _uppercaseA && codeUnit <= _uppercaseZ) ||
        (codeUnit >= _lowercaseA && codeUnit <= _lowercaseZ) ||
        (codeUnit == _underscoreCode);
  }

  /// Checks if the given character is a valid identifier start character.
  ///
  /// Valid start characters are uppercase letters (A-Z), lowercase letters (a-z), and underscore (_).
  ///
  /// @param [character] The character to check.
  /// @returns True if the character can start an identifier.
  bool isIdentifierStart(String character) {
    return _isIdentifierStartCodeUnit(character.codeUnitAt(0));
  }

  /// Checks if the given code unit represents a valid identifier part character.
  ///
  /// Optimized code unit-level check without string conversion.
  ///
  /// @param [codeUnit] The code unit to check.
  /// @returns True if the code unit can be part of an identifier.
  bool _isIdentifierPartCodeUnit(int codeUnit) {
    return _isIdentifierStartCodeUnit(codeUnit) || _isDigitCodeUnit(codeUnit);
  }

  /// Checks if the given character is a valid identifier part character.
  ///
  /// Valid part characters include identifier start characters plus digits (0-9).
  ///
  /// @param [character] The character to check.
  /// @returns True if the character can be part of an identifier.
  bool isIdentifierPart(String character) {
    return _isIdentifierPartCodeUnit(character.codeUnitAt(0));
  }

  /// Checks if the given code unit represents a digit character.
  ///
  /// Optimized code unit-level check without string conversion.
  ///
  /// @param [codeUnit] The code unit to check.
  /// @returns True if the code unit represents a digit (0-9).
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
  /// Cache for parsed types to avoid re-parsing the same type strings.
  static final _typesCache = <String, TypeInfo>{};

  /// The lexer used to tokenize the input.
  final DartLexer _lexer;

  /// The original input string.
  final String _input;

  /// The current token being processed.
  late Token _currentToken;

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
