import 'package:json_serializer/src/utils/string_view.dart';
import 'package:test/test.dart';

void main() {
  group('StringView', () {
    test('creates view with correct length', () {
      final view = StringView('hello');
      expect(view.length, equals(5));
    });

    test('codeUnitAt returns correct code unit', () {
      final view = StringView('ABC');
      expect(view.codeUnitAt(0), equals(65)); // 'A'
      expect(view.codeUnitAt(1), equals(66)); // 'B'
      expect(view.codeUnitAt(2), equals(67)); // 'C'
    });

    test('codeUnitSlice creates zero-copy view', () {
      final view = StringView('hello world');
      final slice = view.codeUnitSlice(0, 5);
      expect(slice.length, equals(5));
      expect(String.fromCharCodes(slice), equals('hello'));
    });

    test('byteSlice creates correct byte view', () {
      final view = StringView('AB');
      final bytes = view.byteSlice(0, 2);
      expect(bytes.length, equals(4)); // 2 UTF-16 code units = 4 bytes
    });

    test('sliceToString creates string from slice', () {
      final view = StringView('hello world');
      expect(view.sliceToString(0, 5), equals('hello'));
      expect(view.sliceToString(6, 11), equals('world'));
    });

    test('singleCodeUnitString converts code unit to string', () {
      final view = StringView('A');
      expect(view.singleCodeUnitString(65), equals('A'));
    });

    test('handles empty string', () {
      final view = StringView('');
      expect(view.length, equals(0));
      expect(() => view.codeUnitAt(0), throwsA(isA<RangeError>()));
    });

    test('handles unicode characters', () {
      final view = StringView('🚀');
      expect(view.length, equals(2)); // Surrogate pair
      expect(view.sliceToString(0, 2), equals('🚀'));
    });

    test('byteData provides ByteData view', () {
      final view = StringView('AB');
      final byteData = view.byteData;
      expect(byteData, isNotNull);
      expect(byteData.lengthInBytes, equals(4));
    });

    test('codeUnitsView provides Uint16List view', () {
      final view = StringView('hello');
      final codeUnits = view.codeUnitsView;
      expect(codeUnits.length, equals(5));
      expect(codeUnits[0], equals(104)); // 'h'
    });

    test('bytesView provides Uint8List view', () {
      final view = StringView('AB');
      final bytes = view.bytesView;
      expect(bytes.length, equals(4)); // 2 code units * 2 bytes
    });
  });

  group('StringUtils', () {
    test('toUtf8Bytes handles ASCII strings', () {
      final bytes = StringUtils.toUtf8Bytes('hello');
      expect(bytes.length, equals(5));
      expect(bytes[0], equals(104)); // 'h'
    });

    test('toUtf8Bytes handles unicode strings', () {
      final bytes = StringUtils.toUtf8Bytes('🚀');
      expect(bytes.length, greaterThan(1));
    });

    test('viewOf creates StringView', () {
      final view = StringUtils.viewOf('test');
      expect(view, isA<StringView>());
      expect(view.length, equals(4));
    });
  });
}
