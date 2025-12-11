import 'package:json_serializer/src/serialization/converter.dart';
import 'package:json_serializer/src/serialization/serializer.dart';
import 'package:json_serializer/src/dart/type_parser.dart';
import 'package:json_serializer/src/errors/exception.dart';
import 'package:test/test.dart';

void main() {
  final options = JsonSerializerOptions();

  group('BoolConverter', () {
    final converter = BoolConverter();
    final type = DartParser.parseType('bool');

    test('canConvert returns true for bool', () {
      expect(converter.canConvert(type), isTrue);
    });

    test('write returns boolean value', () {
      expect(converter.write(true, type, options), equals(true));
      expect(converter.write(false, type, options), equals(false));
    });

    test('read parses boolean from string', () {
      expect(converter.read('true', type, options), equals(true));
      expect(converter.read('false', type, options), equals(false));
    });

    test('readNull handles null', () {
      expect(converter.readNull(null, type, options), isNull);
    });
  });

  group('StringConverter', () {
    final converter = StringConverter();
    final type = DartParser.parseType('String');

    test('canConvert returns true for String', () {
      expect(converter.canConvert(type), isTrue);
    });

    test('write returns string value', () {
      expect(converter.write('hello', type, options), equals('hello'));
    });

    test('read converts to string', () {
      expect(converter.read(42, type, options), equals('42'));
    });
  });

  group('IntConverter', () {
    final converter = IntConverter();
    final type = DartParser.parseType('int');

    test('canConvert returns true for int', () {
      expect(converter.canConvert(type), isTrue);
    });

    test('write returns int value', () {
      expect(converter.write(42, type, options), equals(42));
    });

    test('read parses int from string', () {
      expect(converter.read('42', type, options), equals(42));
    });

    test('read throws on invalid value', () {
      expect(() => converter.read('invalid', type, options), throwsA(isA<JsonSerializerException>()));
    });
  });

  group('DoubleConverter', () {
    final converter = DoubleConverter();
    final type = DartParser.parseType('double');

    test('canConvert returns true for double', () {
      expect(converter.canConvert(type), isTrue);
    });

    test('write returns double value', () {
      expect(converter.write(3.14, type, options), equals(3.14));
    });

    test('read parses double from string', () {
      expect(converter.read('3.14', type, options), equals(3.14));
    });
  });

  group('BigIntConverter', () {
    final converter = BigIntConverter();
    final type = DartParser.parseType('BigInt');

    test('canConvert returns true for BigInt', () {
      expect(converter.canConvert(type), isTrue);
    });

    test('write returns string representation', () {
      final bigInt = BigInt.parse('12345678901234567890');
      expect(converter.write(bigInt, type, options), equals('12345678901234567890'));
    });

    test('read parses BigInt from string', () {
      final result = converter.read('12345678901234567890', type, options);
      expect(result, equals(BigInt.parse('12345678901234567890')));
    });
  });

  group('DateTimeConverter', () {
    final converter = DateTimeConverter();
    final type = DartParser.parseType('DateTime');

    test('canConvert returns true for DateTime', () {
      expect(converter.canConvert(type), isTrue);
    });

    test('write returns ISO string', () {
      final dateTime = DateTime.utc(2023, 9, 19, 15, 30, 0);
      final result = converter.write(dateTime, type, options);
      expect(result, isA<String>());
      expect(result, contains('2023-09-19'));
    });

    test('read parses ISO string', () {
      final result = converter.read('2023-09-19T15:30:00.000Z', type, options);
      expect(result, equals(DateTime.utc(2023, 9, 19, 15, 30, 0)));
    });
  });

  group('UriConverter', () {
    final converter = UriConverter();
    final type = DartParser.parseType('Uri');

    test('canConvert returns true for Uri', () {
      expect(converter.canConvert(type), isTrue);
    });

    test('write returns string representation', () {
      final uri = Uri.parse('https://example.com');
      expect(converter.write(uri, type, options), equals('https://example.com'));
    });

    test('read parses URI from string', () {
      final result = converter.read('https://example.com', type, options);
      expect(result, equals(Uri.parse('https://example.com')));
    });
  });

  group('ListConverter', () {
    final converter = ListConverter();
    final type = DartParser.parseType('List<int>');

    test('canConvert returns true for List', () {
      expect(converter.canConvert(type), isTrue);
    });

    test('write returns list', () {
      final list = [1, 2, 3];
      expect(converter.write(list, type, options), equals([1, 2, 3]));
    });

    test('read converts list', () {
      final result = converter.read([1, 2, 3], type, options);
      expect(result, equals([1, 2, 3]));
    });
  });

  group('MapConverter', () {
    final converter = MapConverter();
    final type = DartParser.parseType('Map<String, int>');

    test('canConvert returns true for Map', () {
      expect(converter.canConvert(type), isTrue);
    });

    test('write returns map', () {
      final map = {'a': 1, 'b': 2};
      expect(converter.write(map, type, options), equals({'a': 1, 'b': 2}));
    });

    test('read converts map', () {
      final result = converter.read({'a': 1, 'b': 2}, type, options);
      expect(result, equals({'a': 1, 'b': 2}));
    });
  });
}
