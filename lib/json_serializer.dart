/// This library provides JSON serialization and deserialization functionality.
library json_serialization;

import 'src/json_serializer_base.dart';

export 'src/converter.dart' show JsonConverter;
export 'src/enum_type.dart' show EnumType;
export 'src/exception.dart' show JsonSerializerException;
export 'src/json_serializer_base.dart'
    show Serializable, JsonSerializer, JsonSerializerOptions;
export 'src/naming_convention.dart'
    show
        NamingConvention,
        CamelCaseConvention,
        SnakeCaseConvention,
        PascalCaseConvention,
        KebabCaseConvention,
        UpperCaseConvention,
        LowerCaseConvention;
export 'src/user_type.dart' show UserType;

/// Serializes the given object to a JSON string.
///
/// This function converts a Dart object into its JSON string representation
/// using the provided serializer options or default options.
///
/// @param [object] The object to serialize to JSON.
/// @param [options] Optional serializer options to customize the serialization process.
///   If not provided, default options will be used.
/// @returns The JSON string representation of the object.
String serialize(Object? object, [JsonSerializerOptions? options]) {
  return JsonSerializer.serialize(object, options);
}

/// Deserializes the given JSON string to an object of type [T].
///
/// This function converts a JSON string into a Dart object of the specified type
/// using the provided serializer options or default options.
///
/// @param [json] The JSON string to deserialize.
/// @param [options] Optional serializer options to customize the deserialization process.
///   If not provided, default options will be used.
/// @returns The deserialized object of type [T].
T deserialize<T>(String json, [JsonSerializerOptions? options]) {
  return JsonSerializer.deserialize<T>(json, options);
}
