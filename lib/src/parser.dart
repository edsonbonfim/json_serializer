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
class Token {
  /// The type of the token.
  final TokenType type;

  /// The lexeme of the token.
  final String lexeme;

  /// Creates a new instance of the [Token] class.
  Token(this.type, this.lexeme);

  @override
  String toString() => lexeme;
}

/// A map of symbol tokens used in the Dart lexer.
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

/// The Dart lexer responsible for tokenizing input strings.
class DartLexer {
  /// The input string to be tokenized.
  final String input;

  var _position = 0;

  /// Creates a new instance of the [DartLexer] class.
  DartLexer(this.input);

  /// Retrieves the next token from the input string.
  Token getNextToken() {
    if (_position >= input.length) {
      return Token(TokenType.eof, '');
    }

    final ch = input[_position];

    if (isWhiteSpace(ch)) {
      _position++;
      return getNextToken();
    }

    if (symbolTokens.containsKey(ch)) {
      _position++;
      return symbolTokens[ch]!;
    }

    if (isIdentifierStart(ch)) {
      var identifier = '';

      while (_position < input.length && isIdentifierPart(input[_position])) {
        identifier += input[_position++];
      }

      return Token(TokenType.identifier, identifier);
    }

    throw FormatException("Unrecognized token '$ch'");
  }

  /// Checks if the given character is a whitespace character.
  bool isWhiteSpace(String ch) {
    final codeUnit = ch.codeUnitAt(0);
    return codeUnit == 10 || // \n
        codeUnit == 13 || // /r
        codeUnit == 9 || // \t
        codeUnit == 32; // ' '
  }

  /// Checks if the given character is a valid identifier start character.
  bool isIdentifierStart(String ch) {
    final codeUnit = ch.codeUnitAt(0);
    return (codeUnit >= 65 && codeUnit <= 90) || // A-Z
        (codeUnit >= 97 && codeUnit <= 122) || // a-z
        (codeUnit == 95); // _
  }

  /// Checks if the given character is a valid identifier part character.
  bool isIdentifierPart(String ch) {
    return isIdentifierStart(ch) || isDigit(ch);
  }

  /// Checks if the given character is a digit character.
  bool isDigit(String ch) {
    final codeUnit = ch.codeUnitAt(0);
    return codeUnit >= 48 && codeUnit <= 57; // 0-9
  }
}

/// Represents the parameters of a function.
class Parameters {
  /// The positional parameters.
  final List<TypeInfo> positional;

  /// The optional parameters.
  final List<TypeInfo> optional;

  /// The named parameters.
  final List<PropertyInfo> named;

  /// Creates a new instance of the [Parameters] class.
  Parameters(this.positional, this.optional, this.named);
}

/// Represents information about a function.
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
  FunctionInfo(this.type, this.positional, this.optional, this.named);
}

/// Represents information about a property.
class PropertyInfo {
  /// The type of the property.
  final TypeInfo type;

  /// The name of the property.
  final String name;

  /// Indicates if the property is required.
  final bool isRequired;

  /// Creates a new instance of the [PropertyInfo] class.
  PropertyInfo(this.type, this.name, this.isRequired);
}

/// Represents information about a type.
class TypeInfo {
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
  TypeInfo(this.name, this.isNullable, this.generics)
      : isMap = name == 'Map' || name == '_Map' && generics.length == 2,
        isList = name == 'List' || name == '_List' && generics.length == 1,
        isGeneric = generics.isNotEmpty;
}

/// The Dart parser responsible for parsing Dart code.
class DartParser {
  static final _typesCache = <String, TypeInfo>{};

  final DartLexer _lexer;
  late Token _currentToken;

  /// Creates a new instance of the [DartParser] class.
  DartParser(String input) : _lexer = DartLexer(input) {
    _currentToken = _lexer.getNextToken();
  }

  /// Parses a function and returns its information.
  static FunctionInfo parseFunction(Function function) {
    return DartParser(function.toString())._parseFunction();
  }

  /// Parses a type and returns its information.
  static TypeInfo parseType(String typeName) {
    if (_typesCache.containsKey(typeName)) {
      return _typesCache[typeName]!;
    }

    final typeInfo = DartParser(typeName)._parseType();
    _typesCache[typeName] = typeInfo;

    return typeInfo;
  }

  /// Parses a function and returns its information.
  FunctionInfo _parseFunction() {
    _eat(TokenType.identifier, 'Closure');
    _eat(TokenType.colon);

    final parameters = _parseParameters();

    _eat(TokenType.equals);
    _eat(TokenType.greaterThan);

    final type = _parseType();

    return FunctionInfo(
      type,
      parameters.positional,
      parameters.optional,
      parameters.named,
    );
  }

  /// Parses the parameters of a function and returns their information.
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
  List<TypeInfo> _parseOptionalParameters() {
    final parameters = [_parseType()];

    while (_peek(TokenType.comma)) {
      _eat(TokenType.comma);
      parameters.add(_parseType());
    }

    return parameters;
  }

  /// Parses the named parameters of a function and returns their information.
  List<PropertyInfo> _parseNamedParameters() {
    final parameters = [_parseNamedParameter()];

    while (_peek(TokenType.comma)) {
      _eat(TokenType.comma);
      parameters.add(_parseNamedParameter());
    }

    return parameters;
  }

  /// Parses a named parameter and returns its information.
  PropertyInfo _parseNamedParameter() {
    var isRequired = false;

    if (_peek(TokenType.identifier, 'required')) {
      _eat(TokenType.identifier, 'required');
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
  List<TypeInfo> _parseGenericArguments() {
    var types = [_parseType()];

    while (_peek(TokenType.comma)) {
      _eat(TokenType.comma);
      types.add(_parseType());
    }

    return types;
  }

  /// Parses an identifier and returns its value.
  String _parseIdentifier() {
    final token = _currentToken;
    _eat(TokenType.identifier);
    return token.lexeme;
  }

  /// Checks if the current token matches the specified type and lexeme.
  bool _peek(TokenType type, [String? lexeme]) {
    return _currentToken.type == type &&
        (lexeme == null || _currentToken.lexeme == lexeme);
  }

  /// Consumes the current token if it matches the specified type and lexeme.
  _eat(TokenType type, [String? lexeme]) {
    if (!_peek(type, lexeme)) {
      throw DartParserException(
        'Expected $type, but found $_currentToken',
      );
    }

    _currentToken = _lexer.getNextToken();
  }
}
