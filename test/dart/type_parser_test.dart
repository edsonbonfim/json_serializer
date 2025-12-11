import 'package:json_serializer/src/dart/type_parser.dart';
import 'package:test/test.dart';

void main() {
  group('DartParser', () {
    test('parses simple type', () {
      final type = DartParser.parseType('String');
      expect(type.name, equals('String'));
      expect(type.isNullable, isFalse);
    });

    test('parses nullable type', () {
      final type = DartParser.parseType('String?');
      expect(type.name, equals('String'));
      expect(type.isNullable, isTrue);
    });

    test('parses generic type', () {
      final type = DartParser.parseType('List<String>');
      expect(type.name, equals('List'));
      expect(type.isGeneric, isTrue);
      expect(type.generics.length, equals(1));
      expect(type.generics[0].name, equals('String'));
    });

    test('parses nested generic type', () {
      final type = DartParser.parseType('List<List<String>>');
      expect(type.name, equals('List'));
      expect(type.generics.length, equals(1));
      expect(type.generics[0].name, equals('List'));
      expect(type.generics[0].generics[0].name, equals('String'));
    });

    test('parses map type', () {
      final type = DartParser.parseType('Map<String, int>');
      expect(type.name, equals('Map'));
      expect(type.generics.length, equals(2));
      expect(type.generics[0].name, equals('String'));
      expect(type.generics[1].name, equals('int'));
    });

    test('parses nullable generic type', () {
      final type = DartParser.parseType('List<String>?');
      expect(type.name, equals('List'));
      expect(type.isNullable, isTrue);
    });

    test('parses user-defined type', () {
      final type = DartParser.parseType('Person');
      expect(type.name, equals('Person'));
      expect(type.isGeneric, isFalse);
    });

    test('parses type with properties', () {
      final type = DartParser.parseType('Person');
      // Assuming Person has properties defined elsewhere
      expect(type.name, equals('Person'));
    });

    test('handles complex nested types', () {
      final type = DartParser.parseType('Map<String, List<int?>>?');
      expect(type.name, equals('Map'));
      expect(type.isNullable, isTrue);
      expect(type.generics.length, equals(2));
      expect(type.generics[0].name, equals('String'));
      expect(type.generics[1].name, equals('List'));
      expect(type.generics[1].generics[0].name, equals('int'));
      expect(type.generics[1].generics[0].isNullable, isTrue);
    });

    test('parses primitive types', () {
      expect(DartParser.parseType('int').name, equals('int'));
      expect(DartParser.parseType('double').name, equals('double'));
      expect(DartParser.parseType('bool').name, equals('bool'));
      expect(DartParser.parseType('num').name, equals('num'));
    });

    test('parses nullable primitives', () {
      expect(DartParser.parseType('int?').isNullable, isTrue);
      expect(DartParser.parseType('String?').isNullable, isTrue);
    });
  });
}
