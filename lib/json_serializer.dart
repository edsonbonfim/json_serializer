/// This library provides JSON deserialization functionality using a [JsonSerializer].
library json_serialization;

import 'src/exception.dart';
import 'src/json_serializer_base.dart';

export 'src/converter.dart' show JsonConverter;
export 'src/exception.dart' show JsonDeserializationException;
export 'src/json_serializer_base.dart'
    show JsonSerializer, JsonSerializerOptions;
export 'src/user_type.dart' show UserType;

/// Deserialize JSON into an object of type `T`.
///
/// Takes a JSON [String] and returns an object of type `T` by utilizing the
/// [JsonSerializer.deserialize] method.
///
/// Throws a [JsonDeserializationException] if there is an issue with the
/// deserialization process, such as invalid JSON format or incompatible types.
///
/// If the input JSON is `null`, and `T` is not nullable, an error will be thrown.
///
/// Example usage:
///
/// ```dart
/// final jsonString = '{"name": "John", "age": 30}';
/// final person = deserialize<Person>(jsonString);
/// print(person.name); // Output: John
/// print(person.age); // Output: 30
/// ```
T deserialize<T>(String? json) {
  return JsonSerializer.deserialize<T>(json);
}
