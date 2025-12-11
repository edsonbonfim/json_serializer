import 'dart:convert';
import 'dart:typed_data';

/// Provides a zero-copy view over a [String] using `TypedData`.
///
/// Stores code units once in a `Uint16List` and exposes `ByteData`/`Uint8List`
/// views on the same `ByteBuffer`, enabling byte-level slicing without copies
/// for lexer and parser workloads.
class StringView {
  final String source;
  final Uint16List _codeUnits;
  final ByteData _byteData;
  final Uint8List _byteView;

  /// Creates a `StringView` backed by a single `Uint16List` buffer.
  ///
  /// @param [source] The original string to materialize into typed views.
  /// @returns A view that reuses the same buffer for `ByteData` and `Uint8List`.
  factory StringView(String source) {
    final codeUnits = Uint16List.fromList(source.codeUnits);
    final byteData = ByteData.view(
      codeUnits.buffer,
      codeUnits.offsetInBytes,
      codeUnits.lengthInBytes,
    );
    final byteView = Uint8List.view(
      codeUnits.buffer,
      codeUnits.offsetInBytes,
      codeUnits.lengthInBytes,
    );

    return StringView._(
      source,
      codeUnits,
      byteData,
      byteView,
    );
  }

  StringView._(
    this.source,
    this._codeUnits,
    this._byteData,
    this._byteView,
  );

  /// @returns The number of UTF-16 code units in the source string.
  int get length => _codeUnits.length;

  /// Reads a code unit in O(1) via `ByteData`, avoiding `String.codeUnitAt`.
  ///
  /// @param [index] The zero-based code-unit position.
  /// @returns The code unit value at [index].
  int codeUnitAt(int index) => _byteData.getUint16(index << 1, Endian.host);

  /// Creates a zero-copy slice of code units as a `Uint16List` view.
  ///
  /// @param [start] The inclusive start index in code units.
  /// @param [end] The exclusive end index in code units.
  /// @returns A `Uint16List` view over the backing buffer.
  Uint16List codeUnitSlice(int start, int end) => Uint16List.view(
        _codeUnits.buffer,
        _codeUnits.offsetInBytes + (start << 1),
        end - start,
      );

  /// Creates a zero-copy byte slice, useful for hashing or diagnostics.
  ///
  /// @param [start] The inclusive start index in code units.
  /// @param [end] The exclusive end index in code units.
  /// @returns A `Uint8List` view covering the requested byte range.
  Uint8List byteSlice(int start, int end) => Uint8List.sublistView(
        _byteView,
        start << 1,
        end << 1,
      );

  /// Builds a `String` from a slice without intermediate list allocations.
  ///
  /// @param [start] The inclusive start index in code units.
  /// @param [end] The exclusive end index in code units.
  /// @returns A new `String` composed from the slice.
  String sliceToString(int start, int end) =>
      String.fromCharCodes(codeUnitSlice(start, end));

  /// Builds a `String` from a single code unit.
  ///
  /// @param [codeUnit] The code unit to convert.
  /// @returns A one-character string for the provided code unit.
  String singleCodeUnitString(int codeUnit) => String.fromCharCode(codeUnit);

  /// @returns The `ByteData` view for byte-level access.
  ByteData get byteData => _byteData;

  /// @returns The `Uint16List` view of code units.
  Uint16List get codeUnitsView => _codeUnits;

  /// @returns The `Uint8List` view over the backing buffer.
  Uint8List get bytesView => _byteView;
}

/// Utility helpers for working with `TypedData` and strings.
class StringUtils {
  /// Encodes a string to UTF-8 minimizing copies when ASCII-only.
  ///
  /// @param [value] The string to encode.
  /// @returns A `Uint8List` containing the UTF-8 bytes.
  static Uint8List toUtf8Bytes(String value) {
    final ascii = value.codeUnits;
    final allAscii = ascii.every((unit) => unit < 0x80);

    return allAscii
        ? Uint8List.fromList(ascii)
        : Uint8List.fromList(utf8.encode(value));
  }

  /// Creates a `StringView` exposing zero-copy typed slices of the input.
  ///
  /// @param [value] The string to wrap in a typed view.
  /// @returns A `StringView` with shared buffer access.
  static StringView viewOf(String value) => StringView(value);
}
