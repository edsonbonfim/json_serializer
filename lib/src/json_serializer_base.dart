import 'dart:convert';

import 'converter.dart';
import 'exception.dart';
import 'generic_type.dart';
import 'parser.dart';
import 'user_type.dart';

/// Encodes the given [value] of type [Object] into JSON using the provided [type],
/// [options], and registered converters. Returns the encoded JSON object.
Object? encode(
  Object? value,
  TypeInfo type,
  JsonSerializerOptions options,
) {
  final converter = options.getConverter(type);
  return converter.write(value, type, options);
}

/// Decodes the given [value] of type [Object] from JSON using the provided [type],
/// [options], and registered converters. Returns the decoded object.
Object? decode(
  Object? value,
  TypeInfo type,
  JsonSerializerOptions options,
) {
  final converter = options.getConverter(type);

  if (!type.isNullable && value == null) {
    throw JsonSerializerException(
      "A null value cannot be used for a non-nullable type.",
    );
  }

  if (type.isNullable && value == null) {
    return converter.readNull(value, type, options);
  }

  return converter.read(value, type, options);
}

/// An abstract class that represents a serializable object.
abstract class Serializable {
  /// Converts the object to a JSON-compatible [Map] representation.
  Map<String, dynamic> toMap();
}

/// Options for the JSON serializer.
class JsonSerializerOptions {
  /// The list of user-defined types.
  final List<GenericType> types;

  /// The list of registered converters.
  final List<JsonConverter> converters;

  /// Creates a new instance of [JsonSerializerOptions].
  JsonSerializerOptions({
    this.types = const [],
    this.converters = const [],
  });

  /// Merges the current [JsonSerializerOptions] with the provided [options].
  /// Returns a new [JsonSerializerOptions] instance.
  JsonSerializerOptions merge(JsonSerializerOptions? options) {
    if (options == null) {
      return JsonSerializerOptions(
        types: [...types],
        converters: [...converters],
      );
    }

    return JsonSerializerOptions(
      types: [...types, ...options.types],
      converters: [...converters, ...options.converters],
    );
  }

  /// Retrieves the appropriate [JsonConverter] for the given [type].
  JsonConverter getConverter(TypeInfo type) {
    return converters.where((x) => x.canConvert(type)).firstOrNull ??
        defaultConverters.firstWhere((x) => x.canConvert(type));
  }

  /// Retrieves the appropriate [GenericType] for the given [type].
  GenericType getGenericType(TypeInfo type) {
    return types.where((x) => x.name == type.name).firstOrNull ??
        defaultUserTypes.firstWhere((x) => x.name == type.name);
  }
}

/// A class that provides JSON serialization and deserialization functionality.
class JsonSerializer {
  /// The default [JsonSerializerOptions].
  static var options = JsonSerializerOptions();

  /// Serializes the given [object] into a JSON string using the provided [options].
  /// Returns the serialized JSON string.
  static String serialize(Object? object, [JsonSerializerOptions? options]) {
    final opts = JsonSerializer.options.merge(options);

    return jsonEncode(object, toEncodable: (value) {
      final type = DartParser.parseType(value.runtimeType.toString());
      return encode(value, type, opts);
    });
  }

  /// Deserializes the given [json] string into an object of type [T] using the provided [options].
  /// Returns the deserialized object.
  static T deserialize<T>(String json, [JsonSerializerOptions? options]) {
    final className = T.toString();
    final opts = JsonSerializer.options.merge(options);
    final type = DartParser.parseType(className);
    return decode(jsonDecode(json), type, opts) as T;
  }
}
