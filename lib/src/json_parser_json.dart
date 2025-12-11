import 'json_lexer.dart';

/// Parses JSON text into Dart objects without relying on `dart:convert`.
///
/// Implements RFC-8259 / ECMA-404 grammar using a recursive descent approach
/// over tokens produced by [JsonLexer].
class JsonParser {
  final JsonLexer _lexer;
  late JsonToken _current;

  /// Creates a parser for the given JSON source.
  ///
  /// @param [json] Raw JSON text to parse.
  /// @returns A parser instance ready to produce Dart structures.
  JsonParser(String json) : _lexer = JsonLexer(json) {
    _current = _lexer.nextToken();
  }

  /// Parses the full JSON text and returns its Dart representation.
  ///
  /// @returns The parsed value (Map/List/num/bool/String/null).
  /// @throws [FormatException] When the input violates the grammar.
  Object? parse() {
    final value = _parseValue();
    _expect(JsonTokenType.eof);
    return value;
  }

  Object? _parseValue() {
    switch (_current.type) {
      case JsonTokenType.leftBrace:
        return _parseObject();
      case JsonTokenType.leftBracket:
        return _parseArray();
      case JsonTokenType.string:
      case JsonTokenType.number:
      case JsonTokenType.boolean:
      case JsonTokenType.nullValue:
        final value = _current.value;
        _advance();
        return value;
      default:
        throw _syntaxError(
          'Unexpected token ${_describeToken(_current)}',
        );
    }
  }

  Map<String, Object?> _parseObject() {
    _expect(JsonTokenType.leftBrace);
    final result = <String, Object?>{};

    if (_current.type == JsonTokenType.rightBrace) {
      _advance();
      return result;
    }

    while (true) {
      if (_current.type != JsonTokenType.string) {
        throw _syntaxError('Object keys must be strings');
      }
      final key = _current.value as String;
      _advance();
      _expect(JsonTokenType.colon);
      final value = _parseValue();
      result[key] = value;

      if (_current.type == JsonTokenType.comma) {
        _advance();
        continue;
      }
      _expect(JsonTokenType.rightBrace);
      return result;
    }
  }

  List<Object?> _parseArray() {
    _expect(JsonTokenType.leftBracket);
    final result = <Object?>[];

    if (_current.type == JsonTokenType.rightBracket) {
      _advance();
      return result;
    }

    while (true) {
      result.add(_parseValue());
      if (_current.type == JsonTokenType.comma) {
        _advance();
        continue;
      }
      _expect(JsonTokenType.rightBracket);
      return result;
    }
  }

  void _advance() {
    _current = _lexer.nextToken();
  }

  void _expect(JsonTokenType type) {
    if (_current.type != type) {
      throw _syntaxError(
        'Expected ${_expectedDescription(type)} '
        'but found ${_describeToken(_current)}',
      );
    }
    _advance();
  }

  FormatException _syntaxError(String message) {
    final ctx = _lexer.minifiedContextForOffset(_current.offset);
    final pointer = ' ' * ctx.snippetCaret + '^';
    final textLine = ctx.snippet;
    return FormatException(
      '$message at line ${_current.line}, column ${_current.column} (offset ${_current.offset}).\n'
      '$textLine\n'
      '$pointer',
    );
  }

  String _describeToken(JsonToken token) {
    switch (token.type) {
      case JsonTokenType.leftBrace:
        return "'{'";
      case JsonTokenType.rightBrace:
        return "'}'";
      case JsonTokenType.leftBracket:
        return "'['";
      case JsonTokenType.rightBracket:
        return "']'";
      case JsonTokenType.colon:
        return "':'";
      case JsonTokenType.comma:
        return "','";
      case JsonTokenType.string:
        return token.value is String ? '"${token.value}"' : '<string>';
      case JsonTokenType.number:
        return '${token.value}';
      case JsonTokenType.boolean:
        return '${token.value}';
      case JsonTokenType.nullValue:
        return 'null';
      case JsonTokenType.eof:
        return '<eof>';
    }
  }

  String _expectedDescription(JsonTokenType type) {
    switch (type) {
      case JsonTokenType.leftBrace:
        return "'{'";
      case JsonTokenType.rightBrace:
        return "'}'";
      case JsonTokenType.leftBracket:
        return "'['";
      case JsonTokenType.rightBracket:
        return "']'";
      case JsonTokenType.colon:
        return "':'";
      case JsonTokenType.comma:
        return "','";
      case JsonTokenType.string:
        return 'string';
      case JsonTokenType.number:
        return 'number';
      case JsonTokenType.boolean:
        return 'boolean';
      case JsonTokenType.nullValue:
        return 'null';
      case JsonTokenType.eof:
        return '<eof>';
    }
  }
}
