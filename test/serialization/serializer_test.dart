import 'package:json_serializer/src/serialization/serializer.dart';
import 'package:json_serializer/src/dart/type_parser.dart';
import 'package:json_serializer/src/errors/exception.dart';
import 'package:test/test.dart';

void main() {
  group('encode', () {
    test('encodes primitive string', () {
      final type = DartParser.parseType('String');
      final options = JsonSerializerOptions();
      final result = encode('hello', type, options);
      expect(result, equals('hello'));
    });

    test('encodes primitive int', () {
      final type = DartParser.parseType('int');
      final options = JsonSerializerOptions();
      final result = encode(42, type, options);
      expect(result, equals(42));
    });

    test('encodes primitive bool', () {
      final type = DartParser.parseType('bool');
      final options = JsonSerializerOptions();
      expect(encode(true, type, options), equals(true));
      expect(encode(false, type, options), equals(false));
    });

    test('encodes list', () {
      final type = DartParser.parseType('List<int>');
      final options = JsonSerializerOptions();
      final result = encode([1, 2, 3], type, options);
      expect(result, equals([1, 2, 3]));
    });

    test('encodes map', () {
      final type = DartParser.parseType('Map<String, int>');
      final options = JsonSerializerOptions();
      final result = encode({'a': 1, 'b': 2}, type, options);
      expect(result, equals({'a': 1, 'b': 2}));
    });
  });

  group('decode', () {
    test('decodes primitive string', () {
      final type = DartParser.parseType('String');
      final options = JsonSerializerOptions();
      final result = decode('hello', type, options);
      expect(result, equals('hello'));
    });

    test('decodes primitive int', () {
      final type = DartParser.parseType('int');
      final options = JsonSerializerOptions();
      final result = decode(42, type, options);
      expect(result, equals(42));
    });

    test('decodes nullable type with null value', () {
      final type = DartParser.parseType('String?');
      final options = JsonSerializerOptions();
      final result = decode(null, type, options);
      expect(result, isNull);
    });

    test('decodes nullable type with non-null value', () {
      final type = DartParser.parseType('String?');
      final options = JsonSerializerOptions();
      final result = decode('hello', type, options);
      expect(result, equals('hello'));
    });

    test('throws on null for non-nullable type', () {
      final type = DartParser.parseType('String');
      final options = JsonSerializerOptions();
      expect(() => decode(null, type, options), throwsA(isA<JsonSerializerException>()));
    });

    test('decodes list', () {
      final type = DartParser.parseType('List<int>');
      final options = JsonSerializerOptions();
      final result = decode([1, 2, 3], type, options);
      expect(result, equals([1, 2, 3]));
    });

    test('decodes map', () {
      final type = DartParser.parseType('Map<String, int>');
      final options = JsonSerializerOptions();
      final result = decode({'a': 1, 'b': 2}, type, options);
      expect(result, equals({'a': 1, 'b': 2}));
    });
  });

  group('JsonSerializerOptions', () {
    test('default options have empty lists', () {
      final options = JsonSerializerOptions();
      expect(options.types, isEmpty);
      expect(options.converters, isEmpty);
    });

    test('merge creates new options', () {
      final options1 = JsonSerializerOptions();
      final options2 = JsonSerializerOptions();
      final merged = options1.merge(options2);
      expect(merged, isNot(same(options1)));
      expect(merged, isNot(same(options2)));
    });

    test('getConverter returns default converter', () {
      final options = JsonSerializerOptions();
      final type = DartParser.parseType('String');
      final converter = options.getConverter(type);
      expect(converter, isNotNull);
    });

    test('detectNamingConvention detects snake_case', () {
      final options = JsonSerializerOptions();
      final json = {'first_name': 'John', 'last_name': 'Doe'};
      final convention = options.detectNamingConvention(json);
      expect(convention, isNotNull);
      expect(convention!.name, equals('snake_case'));
    });

    test('detectNamingConvention detects camelCase', () {
      final options = JsonSerializerOptions();
      final json = {'firstName': 'John', 'lastName': 'Doe'};
      final convention = options.detectNamingConvention(json);
      expect(convention, isNotNull);
      expect(convention!.name, equals('camelCase'));
    });

    test('convertFromJson converts property name', () {
      final options = JsonSerializerOptions();
      final json = {'first_name': 'John'};
      final result = options.convertFromJson('first_name', json);
      expect(result, equals('firstName'));
    });

    test('convertToJson converts property name', () {
      final options = JsonSerializerOptions();
      final result = options.convertToJson('firstName');
      expect(result, equals('firstName')); // defaults to camelCase
    });
  });
}
