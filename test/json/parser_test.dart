import 'package:json_serializer/src/json/parser.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParser', () {
    test('parses simple object', () {
      final parser = JsonParser('{"key": "value"}');
      final result = parser.parse() as Map<String, Object?>;
      expect(result['key'], equals('value'));
    });

    test('parses empty object', () {
      final parser = JsonParser('{}');
      final result = parser.parse();
      expect(result, isA<Map<String, Object?>>());
      expect((result as Map).isEmpty, isTrue);
    });

    test('parses object with multiple properties', () {
      final parser = JsonParser('{"a": 1, "b": 2, "c": 3}');
      final result = parser.parse() as Map<String, Object?>;
      expect(result['a'], equals(1));
      expect(result['b'], equals(2));
      expect(result['c'], equals(3));
    });

    test('parses simple array', () {
      final parser = JsonParser('[1, 2, 3]');
      final result = parser.parse();
      expect(result, isA<List<Object?>>());
      expect(result, equals([1, 2, 3]));
    });

    test('parses empty array', () {
      final parser = JsonParser('[]');
      final result = parser.parse();
      expect(result, isA<List<Object?>>());
      expect((result as List).isEmpty, isTrue);
    });

    test('parses nested objects', () {
      final parser = JsonParser('{"a": {"b": {"c": 42}}}');
      final result = parser.parse() as Map<String, Object?>;
      final nested = result['a'] as Map<String, Object?>;
      final deeper = nested['b'] as Map<String, Object?>;
      expect(deeper['c'], equals(42));
    });

    test('parses nested arrays', () {
      final parser = JsonParser('[[1, 2], [3, 4]]');
      final result = parser.parse() as List<Object?>;
      expect(result[0], equals([1, 2]));
      expect(result[1], equals([3, 4]));
    });

    test('parses mixed structures', () {
      final parser = JsonParser('{"items": [1, 2, 3], "count": 3}');
      final result = parser.parse() as Map<String, Object?>;
      expect(result['items'], equals([1, 2, 3]));
      expect(result['count'], equals(3));
    });

    test('parses null value', () {
      final parser = JsonParser('null');
      final result = parser.parse();
      expect(result, isNull);
    });

    test('parses boolean values', () {
      final parser1 = JsonParser('true');
      expect(parser1.parse(), equals(true));
      
      final parser2 = JsonParser('false');
      expect(parser2.parse(), equals(false));
    });

    test('parses number values', () {
      final parser1 = JsonParser('42');
      expect(parser1.parse(), equals(42));
      
      final parser2 = JsonParser('3.14');
      expect(parser2.parse(), equals(3.14));
      
      final parser3 = JsonParser('-10');
      expect(parser3.parse(), equals(-10));
    });

    test('parses string values', () {
      final parser = JsonParser('"hello"');
      expect(parser.parse(), equals('hello'));
    });

    test('throws on missing comma in object', () {
      final parser = JsonParser('{"a": 1 "b": 2}');
      expect(() => parser.parse(), throwsA(isA<FormatException>()));
    });

    test('throws on missing comma in array', () {
      final parser = JsonParser('[1 2]');
      expect(() => parser.parse(), throwsA(isA<FormatException>()));
    });

    test('throws on missing colon', () {
      final parser = JsonParser('{"a" 1}');
      expect(() => parser.parse(), throwsA(isA<FormatException>()));
    });

    test('throws on invalid key type', () {
      final parser = JsonParser('{1: "value"}');
      expect(() => parser.parse(), throwsA(isA<FormatException>()));
    });

    test('throws on trailing comma in object', () {
      final parser = JsonParser('{"a": 1,}');
      expect(() => parser.parse(), throwsA(isA<FormatException>()));
    });

    test('throws on trailing comma in array', () {
      final parser = JsonParser('[1,]');
      expect(() => parser.parse(), throwsA(isA<FormatException>()));
    });

    test('throws on unexpected token', () {
      expect(() => JsonParser('invalid'), throwsA(isA<FormatException>()));
    });

    test('throws on incomplete JSON', () {
      final parser = JsonParser('{"key":');
      expect(() => parser.parse(), throwsA(isA<FormatException>()));
    });

    test('parses complex nested structure', () {
      final json = '''
        {
          "users": [
            {"name": "Alice", "age": 30},
            {"name": "Bob", "age": 25}
          ],
          "metadata": {
            "count": 2,
            "active": true
          }
        }
      ''';
      final parser = JsonParser(json);
      final result = parser.parse() as Map<String, Object?>;
      expect(result['users'], isA<List>());
      expect(result['metadata'], isA<Map>());
    });
  });
}
