import 'exception.dart';

/// Utility function to parse type information.
///
/// Parses the type information from the given [typeName] or from the type [T] if
/// [typeName] is not provided. It returns a [TypeInfo] object representing the
/// parsed type information.
TypeInfo parseType<T>([String? typeName]) {
  final ast = Parser(typeName ?? T.toString()).parse();
  return TypeInfo.fromAst(ast);
}

/// Token class representing lexer tokens.
class Token {
  final TokenType type;
  final String lexeme;

  Token(this.type, this.lexeme);
}

/// Enum for token types.
enum TokenType {
  identifier,
  lessThan,
  greaterThan,
  comma,
  questionMark,
}

/// Dart lexer.
class Lexer {
  final String input;
  int currentPosition = 0;

  Lexer(this.input);

  /// Get the next token in the input.
  Token getNextToken() {
    if (currentPosition >= input.length) {
      return Token(TokenType.identifier, ''); // End of File (EOF)
    }

    final currentChar = input[currentPosition];

    // Check for token types
    if ([' ', '\r', '\n', '\t', '\s'].contains(currentChar)) {
      currentPosition++;
      return getNextToken();
    }
    if (currentChar == '<') {
      currentPosition++;
      return Token(TokenType.lessThan, '<');
    } else if (currentChar == '>') {
      currentPosition++;
      return Token(TokenType.greaterThan, '>');
    } else if (currentChar == ',') {
      currentPosition++;
      return Token(TokenType.comma, ',');
    } else if (currentChar == '?') {
      currentPosition++;
      return Token(TokenType.questionMark, '?');
    } else if (isIdentifierStart(currentChar)) {
      final start = currentPosition;
      while (currentPosition < input.length &&
          isIdentifierPart(input[currentPosition])) {
        currentPosition++;
      }
      final lexeme = input.substring(start, currentPosition);
      return Token(TokenType.identifier, lexeme);
    } else {
      throw JsonDeserializationException('Unexpected character: $currentChar');
    }
  }

  // Helper functions to check identifier characters
  bool isIdentifierStart(String char) {
    final codeUnit = char.codeUnitAt(0);
    return (codeUnit >= 65 && codeUnit <= 90) || // A-Z
        (codeUnit >= 97 && codeUnit <= 122) || // a-z
        (codeUnit == 95); // _
  }

  bool isIdentifierPart(String char) {
    return isIdentifierStart(char) || isDigit(char);
  }

  bool isDigit(String char) {
    final codeUnit = char.codeUnitAt(0);
    return codeUnit >= 48 && codeUnit <= 57; // 0-9
  }
}

/// Abstract base node for the AST.
abstract class AstNode {}

/// Node to represent a type.
class TypeNode extends AstNode {
  final AstNode typeName;
  final bool isNullable;
  final AstNode? typeArguments;

  TypeNode(this.typeName, this.isNullable, this.typeArguments);

  @override
  String toString() {
    final typeNameStr = typeName.toString();
    final typeArgumentsStr = typeArguments != null ? '$typeArguments' : '';
    return '$typeNameStr$typeArgumentsStr';
  }
}

/// Node to represent a type name.
class TypeNameNode extends AstNode {
  final String name;

  TypeNameNode(this.name);

  @override
  String toString() {
    return name;
  }
}

/// Node to represent a list of types.
class TypeListNode extends AstNode {
  final List<AstNode> types;

  TypeListNode(this.types);

  @override
  String toString() {
    final typeList = types.join(', ');
    return '<$typeList>';
  }
}

/// Dart parser for type expressions based on the following grammar:
///
/// type:
///   typeName
///   | typeName '?'
///   | typeName '<' typeList '>'
///   | typeName '<' typeList '>' '?'
///
/// typeName:
///   identifier
///
/// typeList:
///   type (',' type)*
class Parser {
  final Lexer lexer;
  late Token currentToken;

  Parser(String input) : lexer = Lexer(input) {
    // Initialize the parser by getting the first token
    currentToken = lexer.getNextToken();
  }

  /// Parse a type expression from the input.
  TypeNode parse() => parseType();

  /// Parse type.
  ///
  /// type:
  ///   typeName
  ///   | typeName '?'
  ///   | typeName '<' typeList '>'
  ///   | typeName '<' typeList '>' '?'
  TypeNode parseType() {
    final typeName = parseTypeName();

    if (match(TokenType.questionMark)) {
      consumeToken(TokenType.questionMark);
      return TypeNode(typeName, true, null);
    }

    if (match(TokenType.lessThan)) {
      consumeToken(TokenType.lessThan);
      final typeList = parseTypeList();
      consumeToken(TokenType.greaterThan);

      if (match(TokenType.questionMark)) {
        consumeToken(TokenType.questionMark);
        return TypeNode(typeName, true, typeList);
      }

      return TypeNode(typeName, false, typeList);
    }

    return TypeNode(typeName, false, null);
  }

  /// Parse a type name.
  ///
  /// typeName:
  ///   identifier
  AstNode parseTypeName() {
    if (match(TokenType.identifier)) {
      final name = currentToken.lexeme;
      consumeToken(TokenType.identifier);
      return TypeNameNode(name);
    } else {
      throw Exception('Expected a type name');
    }
  }

  /// Parse type list (generics).
  ///
  /// typeList:
  ///   type (',' type)*
  AstNode parseTypeList() {
    final argumentList = <AstNode>[];

    while (!match(TokenType.greaterThan)) {
      argumentList.add(parseType());

      if (match(TokenType.comma)) {
        consumeToken(TokenType.comma);
      }
    }

    return TypeListNode(argumentList);
  }

  // Helper method to match the current token type.
  bool match(TokenType expectedType) {
    return currentToken.type == expectedType;
  }

  // Helper method to consume the current token and advance to the next.
  void consumeToken(TokenType expectedType) {
    if (match(expectedType)) {
      currentToken = lexer.getNextToken();
    } else {
      throw JsonDeserializationException(
          'Expected token type $expectedType, but got ${currentToken.type}');
    }
  }
}

/// A class to represent type information.
class TypeInfo {
  final bool isNullable;
  final bool isList;
  final bool isMap;
  final bool isGeneric;
  final String name;
  final List<TypeInfo> genericArguments;
  final String type;

  /// Constructor to initialize TypeInfo.
  ///
  /// Initializes a [TypeInfo] object with the provided information.
  TypeInfo({
    required this.isNullable,
    required this.isList,
    required this.isMap,
    required this.isGeneric,
    required this.name,
    required this.genericArguments,
    required this.type,
  });

  /// Factory constructor to create TypeInfo from an AST node.
  ///
  /// Creates a [TypeInfo] object from the given [TypeNode] AST node.
  factory TypeInfo.fromAst(TypeNode ast) {
    final isNullable = ast.isNullable;

    final isList = ast.typeName is TypeNameNode &&
        (ast.typeName as TypeNameNode).name == 'List';

    final isMap = ast.typeName is TypeNameNode &&
        (ast.typeName as TypeNameNode).name == 'Map';

    final isGeneric = ast.typeArguments != null;

    String typeName;
    List<TypeInfo> genericArguments = [];

    if (ast.typeName is TypeNameNode) {
      typeName = (ast.typeName as TypeNameNode).name;
    } else {
      throw JsonDeserializationException('Unexpected type name');
    }

    if (isGeneric) {
      if (ast.typeArguments is TypeListNode) {
        genericArguments = (ast.typeArguments as TypeListNode)
            .types
            .map((arg) => TypeInfo.fromAst(arg as TypeNode))
            .toList();
      } else {
        throw JsonDeserializationException('Unexpected type arguments');
      }
    }

    return TypeInfo(
      isNullable: isNullable,
      isList: isList,
      isMap: isMap,
      isGeneric: isGeneric,
      name: typeName,
      genericArguments: genericArguments,
      type: ast.toString(),
    );
  }

  /// Get the number of list types in the hierarchy.
  int countListTypes() {
    int count = 0;

    if (isList) {
      count++;
      count += genericArguments[0].countListTypes();
    }

    return count;
  }

  /// Get a string representation of the type information.
  @override
  String toString() => type;
}
