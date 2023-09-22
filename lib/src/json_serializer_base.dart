import 'dart:convert';

import 'package:json_serializer/src/generic_type.dart';

import 'converter.dart';
import 'exception.dart';
import 'parser.dart';
import 'user_type.dart';

/// Parses a JSON value into an object based on its type.
///
/// Given the [value], this function determines the appropriate [JsonConverter]
/// to use for the conversion based on the provided [type] and [options]. If the
/// [value] is `null`, it behaves differently depending on the nullability of
/// the [type]: If [type] is non-nullable, a [JsonDeserializationException] is thrown
/// with the message "A null value cannot be used for a non-nullable type." If
/// [type] is nullable, the appropriate converter's `convertNull` method is
/// called.
///
/// Returns the converted object or `null` if [value] is `null` and [type] is
/// nullable.
Object? parse(Object? value, TypeInfo type, JsonSerializerOptions options) {
  final converter = options.getConverter(type);

  if (!type.isNullable && value == null) {
    throw JsonDeserializationException(
        "A null value cannot be used for a non-nullable type.");
  }

  if (type.isNullable && value == null) {
    return converter.convertNull(value, type, options);
  }

  return converter.convert(value, type, options);
}

/// A class representing options for JSON serialization/deserialization.
class JsonSerializerOptions {
  final List<GenericType> types = defaultUserTypes;

  final List<JsonConverter> converters = defaultConverters;

  JsonSerializerOptions({
    List<GenericType> types = const [],
    List<JsonConverter> converters = const [],
  }) {
    this.types.addAll(types);
    this.converters.addAll(converters);
  }

  /// Get the converter for a specific type.
  ///
  /// Returns the appropriate [JsonConverter] for the given [type] based on the
  /// registered converters in [converters].
  JsonConverter getConverter(TypeInfo type) {
    return converters.firstWhere((x) => x.canConvert(type));
  }

  /// Get the user-defined type information for a specific type.
  ///
  /// Returns the [UserType] information for the given [type] based on the
  /// registered user types in [types].
  GenericType getGenericType(TypeInfo type) {
    return types.firstWhere((x) => x.name == type.name);
  }
}

/// A class for serializing and deserializing JSON.
class JsonSerializer {
  static var options = JsonSerializerOptions();

  /// Deserialize JSON into an object of type T.
  ///
  /// Takes a [json] string as input, attempts to parse it using `jsonDecode`,
  /// and then uses [parse] to convert it into an object of type [T]. If any
  /// exceptions occur during this process, a [JsonDeserializationException] is
  /// thrown with the appropriate error message.
  ///
  /// Throws a [JsonDeserializationException] with the message "JSON string is null or empty" if
  /// [json] is `null` or an empty string.
  static T deserialize<T>(String? json) {
    if (json == null || json.isEmpty) {
      throw JsonDeserializationException("JSON string is null or empty.");
    }

    return parse(jsonDecode(json), parseType<T>(), options) as T;
  }
}
