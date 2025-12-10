import 'dart:convert';

import 'converter.dart';
import 'exception.dart';
import 'generic_type.dart';
import 'naming_convention.dart';
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

  /// The list of supported naming conventions.
  final List<NamingConvention> namingConventions;

  /// The naming convention to use for JSON property names.
  /// If null, the convention will be auto-detected from the JSON.
  final NamingConvention? jsonNamingConvention;

  /// Creates a new instance of [JsonSerializerOptions].
  JsonSerializerOptions({
    this.types = const [],
    this.converters = const [],
    List<NamingConvention>? namingConventions,
    this.jsonNamingConvention,
  }) : namingConventions = namingConventions ?? defaultNamingConventions;

  /// Merges the current [JsonSerializerOptions] with the provided [options].
  /// Returns a new [JsonSerializerOptions] instance.
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

  /// Detects the naming convention used in a JSON object.
  /// Returns the first matching convention, or null if no match is found.
  NamingConvention? detectNamingConvention(Map<dynamic, dynamic> json) {
    if (json.isEmpty) return null;

    // Count matches for each convention
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

    // Return the convention with the highest score
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
  String convertFromJson(String jsonPropertyName, Map<dynamic, dynamic> json) {
    final convention = jsonNamingConvention ?? detectNamingConvention(json);
    if (convention == null) return jsonPropertyName;
    return convention.toCamelCase(jsonPropertyName);
  }

  /// Converts a property name from camelCase to JSON naming convention.
  String convertToJson(String camelCasePropertyName) {
    final convention = jsonNamingConvention ?? CamelCaseConvention();
    return convention.fromCamelCase(camelCasePropertyName);
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
