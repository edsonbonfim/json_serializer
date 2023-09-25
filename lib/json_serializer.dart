/// This library provides JSON serialization and deserialization functionality.
library json_serialization;

import 'src/json_serializer_base.dart';

export 'src/converter.dart' show JsonConverter;
export 'src/enum_type.dart' show EnumType;
export 'src/exception.dart' show JsonSerializerException;
export 'src/json_serializer_base.dart'
    show Serializable, JsonSerializer, JsonSerializerOptions;
export 'src/user_type.dart' show UserType;

/// Serializes the given [object] to a JSON string.
///
/// Optionally, you can provide [options] to customize the serialization process.
/// Returns the JSON string representation of the [object].
String serialize(Object? object, [JsonSerializerOptions? options]) {
  return JsonSerializer.serialize(object, options);
}

/// Deserializes the given [json] string to an object of type [T].
///
/// Optionally, you can provide [options] to customize the deserialization process.
/// Returns the deserialized object of type [T].
T deserialize<T>(String json, [JsonSerializerOptions? options]) {
  return JsonSerializer.deserialize<T>(json, options);
}
