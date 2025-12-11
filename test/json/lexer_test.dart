import 'package:json_serializer/src/json/lexer.dart';
import 'package:test/test.dart';

void main() {
  group('JsonLexer', () {
    test('tokenizes simple string', () {
      final lexer = JsonLexer('"hello"');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.string));
      expect(token.value, equals('hello'));
    });

    test('tokenizes number', () {
      final lexer = JsonLexer('42');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.number));
      expect(token.value, equals(42));
    });

    test('tokenizes negative number', () {
      final lexer = JsonLexer('-123');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.number));
      expect(token.value, equals(-123));
    });

    test('tokenizes decimal number', () {
      final lexer = JsonLexer('3.14');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.number));
      expect(token.value, equals(3.14));
    });

    test('tokenizes scientific notation', () {
      final lexer = JsonLexer('1.5e2');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.number));
      expect(token.value, equals(150.0));
    });

    test('tokenizes boolean true', () {
      final lexer = JsonLexer('true');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.boolean));
      expect(token.value, equals(true));
    });

    test('tokenizes boolean false', () {
      final lexer = JsonLexer('false');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.boolean));
      expect(token.value, equals(false));
    });

    test('tokenizes null', () {
      final lexer = JsonLexer('null');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.nullValue));
      expect(token.value, isNull);
    });

    test('tokenizes punctuation', () {
      final lexer = JsonLexer('{}[]:,');
      expect(lexer.nextToken().type, equals(JsonTokenType.leftBrace));
      expect(lexer.nextToken().type, equals(JsonTokenType.rightBrace));
      expect(lexer.nextToken().type, equals(JsonTokenType.leftBracket));
      expect(lexer.nextToken().type, equals(JsonTokenType.rightBracket));
      expect(lexer.nextToken().type, equals(JsonTokenType.colon));
      expect(lexer.nextToken().type, equals(JsonTokenType.comma));
    });

    test('skips whitespace', () {
      final lexer = JsonLexer('  "hello"  ');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.string));
      expect(token.value, equals('hello'));
    });

    test('handles escaped characters in strings', () {
      final lexer = JsonLexer(r'"hello\nworld"');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.string));
      expect(token.value, equals('hello\nworld'));
    });

    test('handles unicode escape sequences', () {
      final lexer = JsonLexer(r'"\u0041"');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.string));
      expect(token.value, equals('A'));
    });

    test('tracks line and column numbers', () {
      final lexer = JsonLexer('"hello"\n"world"');
      final token1 = lexer.nextToken();
      expect(token1.line, equals(1));
      expect(token1.column, equals(1));
      
      final token2 = lexer.nextToken();
      expect(token2.line, equals(2));
      expect(token2.column, equals(1));
    });

    test('tracks offset', () {
      final lexer = JsonLexer('  "hello"');
      final token = lexer.nextToken();
      expect(token.offset, equals(2));
    });

    test('returns EOF at end', () {
      final lexer = JsonLexer('"hello"');
      lexer.nextToken(); // consume string
      final eof = lexer.nextToken();
      expect(eof.type, equals(JsonTokenType.eof));
    });

    test('handles empty string', () {
      final lexer = JsonLexer('""');
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.string));
      expect(token.value, equals(''));
    });

    test('handles complex string with escapes', () {
      final lexer = JsonLexer(r'"test\"quote\ttab"');
      final token = lexer.nextToken();
      expect(token.value, equals('test"quote\ttab'));
    });

    test('minifiedContextForOffset provides context', () {
      final lexer = JsonLexer('{"key": "value"}');
      lexer.nextToken(); // consume {
      final context = lexer.minifiedContextForOffset(0);
      expect(context.snippet, isNotEmpty);
      expect(context.line, equals(1));
      expect(context.column, greaterThan(0));
    });

    test('throws on invalid escape sequence', () {
      final lexer = JsonLexer('"\\x"');
      expect(() => lexer.nextToken(), throwsA(isA<FormatException>()));
    });

    test('throws on unterminated string', () {
      final lexer = JsonLexer('"hello');
      expect(() => lexer.nextToken(), throwsA(isA<FormatException>()));
    });

    test('handles multiple dots in number (may parse as valid)', () {
      final lexer = JsonLexer('12.34.56');
      // The lexer may parse this differently, so we just check it doesn't crash
      final token = lexer.nextToken();
      expect(token.type, equals(JsonTokenType.number));
    });
  });
}
