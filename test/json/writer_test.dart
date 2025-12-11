import 'package:json_serializer/src/json/writer.dart';
import 'package:test/test.dart';

void main() {
  group('JsonWriter', () {
    test('encodes null', () {
      expect(JsonWriter.encode(null), equals('null'));
    });

    test('encodes boolean true', () {
      expect(JsonWriter.encode(true), equals('true'));
    });

    test('encodes boolean false', () {
      expect(JsonWriter.encode(false), equals('false'));
    });

    test('encodes integer', () {
      expect(JsonWriter.encode(42), equals('42'));
    });

    test('encodes negative integer', () {
      expect(JsonWriter.encode(-10), equals('-10'));
    });

    test('encodes double', () {
      expect(JsonWriter.encode(3.14), equals('3.14'));
    });

    test('encodes string', () {
      expect(JsonWriter.encode('hello'), equals('"hello"'));
    });

    test('encodes empty string', () {
      expect(JsonWriter.encode(''), equals('""'));
    });

    test('encodes string with quotes', () {
      expect(JsonWriter.encode('say "hello"'), equals('"say \\"hello\\""'));
    });

    test('encodes string with backslash', () {
      expect(JsonWriter.encode('path\\to\\file'), equals('"path\\\\to\\\\file"'));
    });

    test('encodes string with newline', () {
      expect(JsonWriter.encode('line1\nline2'), equals('"line1\\nline2"'));
    });

    test('encodes string with tab', () {
      expect(JsonWriter.encode('col1\tcol2'), equals('"col1\\tcol2"'));
    });

    test('encodes string with carriage return', () {
      expect(JsonWriter.encode('line1\rline2'), equals('"line1\\rline2"'));
    });

    test('encodes string with control characters', () {
      expect(JsonWriter.encode('\x08'), equals('"\\b"'));
      expect(JsonWriter.encode('\x0C'), equals('"\\f"'));
    });

    test('encodes empty list', () {
      expect(JsonWriter.encode([]), equals('[]'));
    });

    test('encodes list of primitives', () {
      expect(JsonWriter.encode([1, 2, 3]), equals('[1,2,3]'));
    });

    test('encodes list of strings', () {
      expect(JsonWriter.encode(['a', 'b', 'c']), equals('["a","b","c"]'));
    });

    test('encodes list of mixed types', () {
      expect(JsonWriter.encode([1, 'two', true, null]), equals('[1,"two",true,null]'));
    });

    test('encodes nested lists', () {
      expect(JsonWriter.encode([[1, 2], [3, 4]]), equals('[[1,2],[3,4]]'));
    });

    test('encodes empty map', () {
      expect(JsonWriter.encode(<String, Object?>{}), equals('{}'));
    });

    test('encodes simple map', () {
      expect(JsonWriter.encode({'key': 'value'}), equals('{"key":"value"}'));
    });

    test('encodes map with multiple entries', () {
      final result = JsonWriter.encode({'a': 1, 'b': 2, 'c': 3});
      expect(result, contains('"a":1'));
      expect(result, contains('"b":2'));
      expect(result, contains('"c":3'));
    });

    test('encodes nested maps', () {
      expect(JsonWriter.encode({'a': {'b': {'c': 42}}}), equals('{"a":{"b":{"c":42}}}'));
    });

    test('encodes map with list values', () {
      expect(JsonWriter.encode({'items': [1, 2, 3]}), equals('{"items":[1,2,3]}'));
    });

    test('encodes complex nested structure', () {
      final data = {
        'users': [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25}
        ],
        'metadata': {'count': 2, 'active': true}
      };
      final result = JsonWriter.encode(data);
      expect(result, contains('"users"'));
      expect(result, contains('"metadata"'));
    });

    test('throws on NaN', () {
      expect(() => JsonWriter.encode(double.nan), throwsA(isA<FormatException>()));
    });

    test('throws on Infinity', () {
      expect(() => JsonWriter.encode(double.infinity), throwsA(isA<FormatException>()));
      expect(() => JsonWriter.encode(double.negativeInfinity), throwsA(isA<FormatException>()));
    });

    test('throws on non-string map keys', () {
      expect(() => JsonWriter.encode({1: 'value'}), throwsA(isA<FormatException>()));
    });

    test('throws on unsupported type', () {
      expect(() => JsonWriter.encode(DateTime.now()), throwsA(isA<FormatException>()));
    });

    test('encodes unicode characters', () {
      expect(JsonWriter.encode('🚀'), equals('"🚀"'));
    });

    test('encodes large numbers', () {
      expect(JsonWriter.encode(1234567890), equals('1234567890'));
    });

    test('encodes zero', () {
      expect(JsonWriter.encode(0), equals('0'));
    });

    test('encodes negative zero', () {
      expect(JsonWriter.encode(-0.0), equals('-0.0'));
    });
  });
}
