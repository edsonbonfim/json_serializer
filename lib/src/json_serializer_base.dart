import 'dart:convert';

import 'converter.dart';
import 'exception.dart';
import 'generic_type.dart';
import 'naming_convention.dart';
import 'parser.dart';
import 'user_type.dart';

/// Encodes the given value into JSON format using the provided type information and options.
///
/// This function retrieves the appropriate converter for the given type and uses it
/// to convert the value to a JSON-compatible format.
///
/// @param [value] The value to encode into JSON.
/// @param [type] The type information describing the value's type.
/// @param [options] The serializer options containing converters and configuration.
/// @returns The encoded JSON-compatible object.
Object? encode(
  Object? value,
  TypeInfo type,
  JsonSerializerOptions options,
) {
  final converter = options.getConverter(type);
  return converter.write(value, type, options);
}

/// Decodes the given value from JSON format using the provided type information and options.
///
/// This function validates nullability constraints and retrieves the appropriate converter
/// to convert the JSON value to the target type.
///
/// @param [value] The JSON value to decode.
/// @param [type] The type information describing the target type.
/// @param [options] The serializer options containing converters and configuration.
/// @returns The decoded object of the specified type.
/// @throws [JsonSerializerException] if a null value is provided for a non-nullable type.
Object? decode(
  Object? value,
  TypeInfo type,
  JsonSerializerOptions options,
) {
  final converter = options.getConverter(type);

  if (!type.isNullable && value == null) {
    throw JsonSerializerException(
      'Null value cannot be used for non-nullable type.\n'
      'Expected type: ${type.name}\n'
      'Received value: null\n'
      'Tip: Consider making the type nullable using "${type.name}?" or '
      'provide a valid value.',
    );
  }

  if (type.isNullable && value == null) {
    return converter.readNull(value, type, options);
  }

  return converter.read(value, type, options);
}

/// An abstract class that represents a serializable object.
///
/// Classes implementing this interface can be serialized to JSON format
/// by providing a [Map] representation of their data.
abstract class Serializable {
  /// Converts the object to a JSON-compatible [Map] representation.
  ///
  /// @returns A map containing the object's properties as key-value pairs.
  Map<String, dynamic> toMap();
}

/// Configuration options for the JSON serializer.
///
/// This class provides configuration for custom types, converters, and naming conventions
/// used during serialization and deserialization operations.
class JsonSerializerOptions {
  /// The list of user-defined types registered with the serializer.
  final List<GenericType> types;

  /// The list of registered converters for type conversion.
  final List<JsonConverter> converters;

  /// The list of supported naming conventions for property name conversion.
  final List<NamingConvention> namingConventions;

  /// The naming convention to use for JSON property names.
  ///
  /// If null, the convention will be auto-detected from the JSON structure.
  final NamingConvention? jsonNamingConvention;

  /// Creates a new instance of [JsonSerializerOptions].
  ///
  /// @param [types] The list of user-defined types. Defaults to an empty list.
  /// @param [converters] The list of custom converters. Defaults to an empty list.
  /// @param [namingConventions] The list of naming conventions to support.
  ///   If not provided, defaults to [defaultNamingConventions].
  /// @param [jsonNamingConvention] The specific naming convention to use for JSON.
  ///   If null, will be auto-detected.
  JsonSerializerOptions({
    this.types = const [],
    this.converters = const [],
    List<NamingConvention>? namingConventions,
    this.jsonNamingConvention,
  }) : namingConventions = namingConventions ?? defaultNamingConventions;

  /// Merges the current options with the provided options, creating a new instance.
  ///
  /// When merging, the provided options take precedence. Lists are concatenated,
  /// and the jsonNamingConvention from the provided options is used if available.
  ///
  /// @param [options] The options to merge with. If null, returns a copy of current options.
  /// @returns A new [JsonSerializerOptions] instance with merged configuration.
  JsonSerializerOptions merge(JsonSerializerOptions? options) {
    if (options == null) {
      return JsonSerializerOptions(
        types: [...types],
        converters: [...converters],
        namingConventions: [...namingConventions],
        jsonNamingConvention: jsonNamingConvention,
      );
    }

    return JsonSerializerOptions(
      types: [...types, ...options.types],
      converters: [...converters, ...options.converters],
      namingConventions: [...namingConventions, ...options.namingConventions],
      jsonNamingConvention:
          options.jsonNamingConvention ?? jsonNamingConvention,
    );
  }

  /// Retrieves the appropriate converter for the given type.
  ///
  /// First checks custom converters, then falls back to default converters.
  ///
  /// @param [type] The type information to find a converter for.
  /// @returns The [JsonConverter] that can handle the specified type.
  /// @throws [StateError] if no converter is found for the type.
  JsonConverter getConverter(TypeInfo type) {
    return converters.where((converter) => converter.canConvert(type)).firstOrNull ??
        defaultConverters.firstWhere((converter) => converter.canConvert(type));
  }

  /// Retrieves the appropriate generic type for the given type information.
  ///
  /// First checks custom types, then falls back to default user types.
  ///
  /// @param [type] The type information to find a generic type for.
  /// @returns The [GenericType] that matches the specified type.
  /// @throws [JsonSerializerException] if the type is not registered.
  GenericType getGenericType(TypeInfo type) {
    final genericType = types
            .where((userType) => userType.name == type.name)
            .firstOrNull ??
        defaultUserTypes
            .where((userType) => userType.name == type.name)
            .firstOrNull;

    if (genericType == null) {
      final registeredTypes = [...types, ...defaultUserTypes]
          .map((userType) => userType.name)
          .toList()
          .join(', ');

      throw JsonSerializerException(
        'Type "${type.name}" is not registered.\n'
        'You need to register this type using:\n'
        '  - UserType<${type.name}>() for custom types\n'
        '  - EnumType<${type.name}>() for enums\n'
        'Currently registered types: ${registeredTypes.isEmpty ? "(none)" : registeredTypes}',
      );
    }

    return genericType;
  }

  /// Detects the naming convention used in a JSON object by analyzing property names.
  ///
  /// This method scores each available naming convention based on how many property
  /// names match its pattern, then returns the convention with the highest score.
  ///
  /// @param [json] The JSON object to analyze for naming convention patterns.
  /// @returns The detected naming convention, or null if the JSON is empty or no match is found.
  NamingConvention? detectNamingConvention(Map<dynamic, dynamic> json) {
    if (json.isEmpty) return null;

    final scores = <NamingConvention, int>{};
    for (var convention in namingConventions) {
      scores[convention] = 0;
    }

    for (var key in json.keys) {
      if (key is! String) continue;

      for (var convention in namingConventions) {
        if (convention.matches(key)) {
          scores[convention] = (scores[convention] ?? 0) + 1;
        }
      }
    }

    var maxScore = 0;
    NamingConvention? bestConvention;
    scores.forEach((convention, score) {
      if (score > maxScore) {
        maxScore = score;
        bestConvention = convention;
      }
    });

    return bestConvention;
  }

  /// Converts a property name from JSON naming convention to camelCase.
  ///
  /// Uses the configured jsonNamingConvention or auto-detects from the JSON structure.
  ///
  /// @param [jsonPropertyName] The property name in JSON format.
  /// @param [json] The JSON object used for auto-detection if needed.
  /// @returns The property name converted to camelCase.
  String convertFromJson(String jsonPropertyName, Map<dynamic, dynamic> json) {
    final convention = jsonNamingConvention ?? detectNamingConvention(json);
    if (convention == null) return jsonPropertyName;
    return convention.toCamelCase(jsonPropertyName);
  }

  /// Converts a property name from camelCase to the configured JSON naming convention.
  ///
  /// Uses the configured jsonNamingConvention or defaults to camelCase.
  ///
  /// @param [camelCasePropertyName] The property name in camelCase format.
  /// @returns The property name converted to the JSON naming convention.
  String convertToJson(String camelCasePropertyName) {
    final convention = jsonNamingConvention ?? CamelCaseConvention();
    return convention.fromCamelCase(camelCasePropertyName);
  }
}

/// A utility class that provides JSON serialization and deserialization functionality.
///
/// This class offers static methods to convert Dart objects to JSON strings and vice versa,
/// with support for custom types, converters, and naming conventions.
class JsonSerializer {
  /// The default serializer options used when no options are provided.
  static var options = JsonSerializerOptions();

  /// Serializes the given object into a JSON string.
  ///
  /// Uses the provided options or merges them with the default options.
  /// The serialization process uses registered converters to handle type conversion.
  ///
  /// @param [object] The object to serialize to JSON.
  /// @param [options] Optional serializer options. If provided, will be merged with default options.
  /// @returns The JSON string representation of the object.
  static String serialize(Object? object, [JsonSerializerOptions? options]) {
    final mergedOptions = JsonSerializer.options.merge(options);

    return jsonEncode(object, toEncodable: (value) {
      final type = DartParser.parseType(value.runtimeType.toString());
      return encode(value, type, mergedOptions);
    });
  }

  /// Deserializes the given JSON string into an object of the specified type.
  ///
  /// Uses the provided options or merges them with the default options.
  /// The deserialization process uses registered converters to handle type conversion.
  ///
  /// @param [json] The JSON string to deserialize.
  /// @param [options] Optional serializer options. If provided, will be merged with default options.
  /// @returns The deserialized object of type [T].
  /// @throws [AssertionError] if [json] is empty in debug mode.
  static T deserialize<T>(String json, [JsonSerializerOptions? options]) {
    assert(json.isNotEmpty, 'JSON string cannot be empty');

    final className = T.toString();
    final mergedOptions = JsonSerializer.options.merge(options);
    final type = DartParser.parseType(className);
    return decode(jsonDecode(json), type, mergedOptions) as T;
  }
}
