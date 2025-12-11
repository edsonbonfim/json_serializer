/// Serializes Dart objects to JSON text without `dart:convert`.
///
/// Supports RFC-8259 / ECMA-404 primitives: null, bool, num, String, List and
/// Map<String, Object?>. Throws [FormatException] for unsupported structures.
class JsonWriter {
  /// Encodes a Dart object into JSON text.
  ///
  /// @param [value] The value to serialize.
  /// @returns A JSON string representation.
  /// @throws [FormatException] When encountering unsupported types or invalid keys.
  static String encode(Object? value) {
    final buffer = StringBuffer();
    _writeValue(buffer, value);
    return buffer.toString();
  }

  /// Serializes a single value into the buffer, dispatching by type.
  ///
  /// @param [buffer] Target buffer to append serialized output.
  /// @param [value] Value to write (may be null).
  static void _writeValue(StringBuffer buffer, Object? value) {
    if (value == null) {
      buffer.write('null');
      return;
    }
    if (value is bool) {
      buffer.write(value ? 'true' : 'false');
      return;
    }
    if (value is num) {
      if (value.isNaN || value.isInfinite) {
        throw const FormatException('NaN and Infinity are not valid JSON numbers');
      }
      buffer.write(value.toString());
      return;
    }
    if (value is String) {
      buffer.write(_escapeString(value));
      return;
    }
    if (value is List) {
      _writeList(buffer, value);
      return;
    }
    if (value is Map) {
      _writeMap(buffer, value);
      return;
    }
    throw FormatException('Unsupported type for JSON serialization: ${value.runtimeType}');
  }

  /// Serializes a list into JSON array notation.
  ///
  /// @param [buffer] Target buffer to append serialized output.
  /// @param [list] Items to serialize recursively.
  static void _writeList(StringBuffer buffer, List<Object?> list) {
    buffer.write('[');
    for (var i = 0; i < list.length; i++) {
      if (i > 0) buffer.write(',');
      _writeValue(buffer, list[i]);
    }
    buffer.write(']');
  }

  /// Serializes a map into JSON object notation.
  ///
  /// @param [buffer] Target buffer to append serialized output.
  /// @param [map] Key/value pairs to serialize; keys must be strings.
  static void _writeMap(StringBuffer buffer, Map<Object?, Object?> map) {
    buffer.write('{');
    var first = true;
    map.forEach((key, value) {
      if (key is! String) {
        throw const FormatException('JSON object keys must be strings');
      }
      if (!first) buffer.write(',');
      first = false;
      buffer.write(_escapeString(key));
      buffer.write(':');
      _writeValue(buffer, value);
    });
    buffer.write('}');
  }

  /// Escapes a Dart string into a JSON string literal.
  ///
  /// @param [value] Raw string to escape.
  /// @returns The escaped JSON string (quoted).
  static String _escapeString(String value) {
    final buffer = StringBuffer('"');
    for (var i = 0; i < value.length; i++) {
      final codeUnit = value.codeUnitAt(i);
      switch (codeUnit) {
        case 0x08:
          buffer.write(r'\b');
          break;
        case 0x09:
          buffer.write(r'\t');
          break;
        case 0x0A:
          buffer.write(r'\n');
          break;
        case 0x0C:
          buffer.write(r'\f');
          break;
        case 0x0D:
          buffer.write(r'\r');
          break;
        case 0x22:
          buffer.write(r'\"');
          break;
        case 0x5C:
          buffer.write(r'\\');
          break;
        default:
          if (codeUnit < 0x20) {
            buffer.write(r'\u');
            buffer.write(codeUnit.toRadixString(16).padLeft(4, '0'));
          } else {
            buffer.writeCharCode(codeUnit);
          }
      }
    }
    buffer.write('"');
    return buffer.toString();
  }
}
