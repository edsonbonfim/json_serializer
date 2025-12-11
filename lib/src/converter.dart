/// This file contains the implementation of various JSON converters used in the JSON serialization process.
/// Each converter is responsible for converting a specific data type to and from JSON.
/// The converters are used by the `JsonSerializer` class to perform the serialization and deserialization operations.

import 'enum_type.dart';
import 'exception.dart';
import 'json_serializer_base.dart';
import 'parser.dart';
import 'user_type.dart';

/// The list of default converters used by the `JsonSerializer`.
///
/// These converters handle the serialization and deserialization of built-in Dart types.
final defaultConverters = <JsonConverter>[
  StringConverter(),
  BoolConverter(),
  IntConverter(),
  BigIntConverter(),
  DateTimeConverter(),
  DoubleConverter(),
  NumConverter(),
  UriConverter(),
  MapConverter(),
  ListConverter(),
  ObjectConverter(),
  DynamicConverter(),
  GenericTypeConverter(),
];

/// The base class for all JSON converters.
///
/// A JSON converter is responsible for converting a specific data type to and from JSON format.
/// Implementations must provide methods to check if they can handle a type, and to read/write values.
///
/// @typeparam [T] The type that this converter handles.
abstract class JsonConverter<T> {
  /// Determines whether this converter can convert the specified type.
  ///
  /// @param [type] The type information to check.
  /// @returns True if this converter can handle the specified type, false otherwise.
  bool canConvert(TypeInfo type);

  /// Converts the value to JSON format.
  ///
  /// @param [value] The value of type [T] to convert to JSON.
  /// @param [type] The type information describing the value.
  /// @param [options] The serializer options containing configuration.
  /// @returns The JSON-compatible representation of the value.
  Object? write(T value, TypeInfo type, JsonSerializerOptions options);

  /// Converts the JSON value to type [T].
  ///
  /// @param [value] The JSON value to convert.
  /// @param [type] The type information describing the target type.
  /// @param [options] The serializer options containing configuration.
  /// @returns The converted value of type [T].
  T read(dynamic value, TypeInfo type, JsonSerializerOptions options);

  /// Converts a null JSON value to type [T].
  ///
  /// @param [value] The JSON value (may be null).
  /// @param [type] The type information describing the target type.
  /// @param [options] The serializer options containing configuration.
  /// @returns The converted value of type [T], or null if the input value is null.
  T? readNull(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    if (value == null) {
      return null;
    }

    return read(value, type, options);
  }
}

/// A JSON converter for the `bool` data type.
class BoolConverter extends JsonConverter<bool> {
  static const String _typeName = 'bool';

  @override
  bool canConvert(TypeInfo type) => type.name == _typeName;

  @override
  Object? write(bool value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  bool read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return bool.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException(
        'Error converting to bool.\n'
        'Received value: "$value" (type: ${value.runtimeType})\n'
        'Expected type: $_typeName\n'
        'Details: ${e.message}',
      );
    }
  }
}

/// A JSON converter for the `String` data type.
class StringConverter extends JsonConverter<String> {
  static const String _typeName = 'String';

  @override
  bool canConvert(TypeInfo type) => type.name == _typeName;

  @override
  Object? write(String value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  String read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }
}

/// A JSON converter for the `BigInt` data type.
class BigIntConverter extends JsonConverter<BigInt> {
  static const List<String> _supportedTypeNames = ['BigInt', '_BigIntImpl'];

  @override
  bool canConvert(TypeInfo type) => _supportedTypeNames.contains(type.name);

  @override
  Object? write(BigInt value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }

  @override
  BigInt read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return BigInt.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException(
        'Error converting to BigInt.\n'
        'Received value: "$value" (type: ${value.runtimeType})\n'
        'Expected type: BigInt\n'
        'Details: ${e.message}',
      );
    }
  }
}

/// A JSON converter for the `DateTime` data type.
///
/// Serializes DateTime values to ISO 8601 format strings.
class DateTimeConverter extends JsonConverter<DateTime> {
  static const String _typeName = 'DateTime';
  static const String _expectedFormat = 'ISO 8601 format';

  @override
  bool canConvert(TypeInfo type) => type.name == _typeName;

  @override
  Object? write(DateTime value, TypeInfo type, JsonSerializerOptions options) {
    return value.toIso8601String();
  }

  @override
  DateTime read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return DateTime.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException(
        'Error converting to DateTime.\n'
        'Received value: "$value" (type: ${value.runtimeType})\n'
        'Expected type: $_typeName ($_expectedFormat)\n'
        'Details: ${e.message}',
      );
    }
  }
}

/// A JSON converter for the `double` data type.
class DoubleConverter extends JsonConverter<double> {
  static const String _typeName = 'double';

  @override
  bool canConvert(TypeInfo type) => type.name == _typeName;

  @override
  Object? write(double value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  double read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return double.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException(
        'Error converting to double.\n'
        'Received value: "$value" (type: ${value.runtimeType})\n'
        'Expected type: $_typeName\n'
        'Details: ${e.message}',
      );
    }
  }
}

/// A JSON converter for the `num` data type.
class NumConverter extends JsonConverter<num> {
  static const String _typeName = 'num';

  @override
  bool canConvert(TypeInfo type) => type.name == _typeName;

  @override
  Object? write(num value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  num read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return num.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException(
        'Error converting to num.\n'
        'Received value: "$value" (type: ${value.runtimeType})\n'
        'Expected type: $_typeName\n'
        'Details: ${e.message}',
      );
    }
  }
}

/// A JSON converter for the `Uri` data type.
class UriConverter extends JsonConverter<Uri> {
  static const List<String> _supportedTypeNames = ['Uri', '_SimpleUri'];

  @override
  bool canConvert(TypeInfo type) => _supportedTypeNames.contains(type.name);

  @override
  Object? write(Uri value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }

  @override
  Uri read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return Uri.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException(
        'Error converting to Uri.\n'
        'Received value: "$value" (type: ${value.runtimeType})\n'
        'Expected type: Uri\n'
        'Details: ${e.message}',
      );
    }
  }
}

/// A JSON converter for the `int` data type.
class IntConverter extends JsonConverter<int> {
  static const String _typeName = 'int';

  @override
  bool canConvert(TypeInfo type) => type.name == _typeName;

  @override
  Object? write(int value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  int read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return int.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException(
        'Error converting to int.\n'
        'Received value: "$value" (type: ${value.runtimeType})\n'
        'Expected type: $_typeName\n'
        'Details: ${e.message}',
      );
    }
  }
}

/// A JSON converter for the `Map` data type.
///
/// Handles serialization and deserialization of Map objects with generic type parameters.
class MapConverter extends JsonConverter<Map> {
  static const int _minimumGenericArguments = 2;
  static const String _assertionMessageValue = 'Value must be a Map';
  static const String _assertionMessageGenerics =
      'Map type must have at least two generic arguments';

  @override
  bool canConvert(TypeInfo type) => type.isMap;

  @override
  Object? write(Map value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  Map read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    assert(value is Map, _assertionMessageValue);
    assert(
      type.generics.length >= _minimumGenericArguments,
      _assertionMessageGenerics,
    );

    final map = _createGenericMap(type, options);

    value.forEach((key, value) {
      map[key] = decode(value, type.generics[1], options);
    });

    return map;
  }

  /// Creates a generic map based on the type information and options.
  ///
  /// @param [type] The type information for the map.
  /// @param [options] The serializer options.
  /// @returns A new map instance with the appropriate generic type.
  Map _createGenericMap(TypeInfo type, JsonSerializerOptions options) {
    final mapGenericType = type.generics[1];

    if (mapGenericType.isList) {
      final listGenericType = mapGenericType.generics[0];
      final listGenericUserType = options.getGenericType(listGenericType);

      if (listGenericType.isNullable) {
        return listGenericUserType.createMapOfListOfNullableT();
      }

      return listGenericUserType.createMapOfListOfT();
    }

    final mapGenericUserType = options.getGenericType(mapGenericType);

    if (mapGenericType.isNullable) {
      return mapGenericUserType.createMapOfNullableT();
    }

    return mapGenericUserType.createMapOfT();
  }
}

/// A JSON converter for the `List` data type.
///
/// Handles serialization and deserialization of List objects with generic type parameters.
class ListConverter extends JsonConverter<List> {
  static const int _minimumGenericArguments = 1;
  static const String _assertionMessageValue = 'Value must be a List';
  static const String _assertionMessageGenerics =
      'List type must have at least one generic argument';

  @override
  bool canConvert(TypeInfo type) => type.isList;

  @override
  Object? write(List value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  List read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    assert(value is List, _assertionMessageValue);
    assert(
      type.generics.length >= _minimumGenericArguments,
      _assertionMessageGenerics,
    );

    final list = _createGenericList(type, options);

    for (var item in value) {
      list.add(decode(item, type.generics[0], options));
    }

    return list;
  }

  /// Creates a generic list based on the type information and options.
  ///
  /// @param [type] The type information for the list.
  /// @param [options] The serializer options.
  /// @returns A new list instance with the appropriate generic type.
  List _createGenericList(TypeInfo type, JsonSerializerOptions options) {
    final listGenericType = type.generics[0];

    if (listGenericType.isMap) {
      final mapGenericType = listGenericType.generics[1];
      return options.getGenericType(mapGenericType).createListOfMapOfT();
    }

    return options.getGenericType(listGenericType).createList();
  }
}

/// A JSON converter for the `Object` data type.
class ObjectConverter extends JsonConverter<Object> {
  static const String _typeName = 'Object';

  @override
  bool canConvert(TypeInfo type) => type.name == _typeName;

  @override
  Object? write(Object value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  Object read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }
}

/// A JSON converter for the `dynamic` data type.
class DynamicConverter extends JsonConverter<dynamic> {
  static const String _typeName = 'dynamic';

  @override
  bool canConvert(TypeInfo type) => type.name == _typeName;

  @override
  Object? write(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  dynamic read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }
}

/// Finds a value in a map by converting the parameter name using naming conventions.
///
/// This function attempts to find a value in the map by:
/// 1. Direct key lookup
/// 2. Using the configured JSON naming convention
/// 3. Trying all available naming conventions
///
/// @param [values] The map to search in.
/// @param [paramName] The parameter name to search for.
/// @param [options] The serializer options containing naming conventions.
/// @returns The value if found, or null otherwise.
dynamic _findValueInMap(
  Map values,
  String paramName,
  JsonSerializerOptions options,
) {
  if (values.containsKey(paramName)) {
    return values[paramName];
  }

  if (options.jsonNamingConvention != null) {
    final normalizedParamName = _normalizePropertyName(paramName, options);
    final jsonKey =
        options.jsonNamingConvention!.fromCamelCase(normalizedParamName);
    if (values.containsKey(jsonKey)) {
      return values[jsonKey];
    }
  }

  final normalizedParamName = _normalizePropertyName(paramName, options);

  for (var convention in options.namingConventions) {
    final jsonKey = convention.fromCamelCase(normalizedParamName);
    if (values.containsKey(jsonKey)) {
      return values[jsonKey];
    }
  }

  return null;
}

/// Normalizes a property name to camelCase using available naming conventions.
///
/// @param [propertyName] The property name to normalize.
/// @param [options] The serializer options containing naming conventions.
/// @returns The normalized property name in camelCase, or the original name if no match is found.
String _normalizePropertyName(
    String propertyName, JsonSerializerOptions options) {
  for (var convention in options.namingConventions) {
    if (convention.matches(propertyName)) {
      return convention.toCamelCase(propertyName);
    }
  }

  return propertyName;
}

/// A JSON converter for generic types.
///
/// This converter handles the serialization and deserialization of generic types,
/// including enums and user-defined types. It serves as a fallback converter for
/// types that don't match any specific converter.
class GenericTypeConverter extends JsonConverter {
  static const String _assertionMessageMap =
      'Value must be a Map for user-defined type conversion';

  @override
  bool canConvert(TypeInfo type) => true;

  @override
  Object? write(value, TypeInfo type, JsonSerializerOptions options) {
    final genericType = options.getGenericType(type);

    if (genericType is EnumType) {
      return (value as Enum).name;
    }

    if (value is Serializable) {
      return value.toMap();
    }

    return value;
  }

  @override
  read(Object? value, TypeInfo type, JsonSerializerOptions options) {
    final genericType = options.getGenericType(type);

    if (genericType is EnumType) {
      return _convertEnum(value, type, genericType);
    }

    if (genericType is UserType) {
      return _convertUserType(value, type, genericType, options);
    }

    throw JsonSerializerException(
      'Unsupported type: "${type.name}".\n'
      'The type is not registered as a user-defined type or enum.\n'
      'Make sure to register the type using UserType() or EnumType() '
      'in JsonSerializerOptions.',
    );
  }

  /// Converts a value to an enum type.
  ///
  /// @param [value] The value to convert.
  /// @param [type] The type information.
  /// @param [enumType] The enum type instance.
  /// @returns The converted enum value.
  /// @throws [JsonSerializerException] if the value cannot be converted to the enum.
  dynamic _convertEnum(
    Object? value,
    TypeInfo type,
    EnumType enumType,
  ) {
    try {
      return enumType.parse("$value");
    } on ArgumentError catch (e) {
      final enumValues = enumType.values.map((v) => "'$v'").join(', ');
      throw JsonSerializerException(
        'Error converting to enum ${type.name}.\n'
        'Received value: "$value" (type: ${value.runtimeType})\n'
        'Valid values: $enumValues\n'
        'Details: ${e.message}',
      );
    }
  }

  /// Converts a value to a user-defined type.
  ///
  /// @param [value] The value to convert (must be a Map).
  /// @param [type] The type information.
  /// @param [userType] The user type instance.
  /// @param [options] The serializer options.
  /// @returns The converted user-defined type instance.
  /// @throws [JsonSerializerException] if the conversion fails.
  dynamic _convertUserType(
    Object? value,
    TypeInfo type,
    UserType userType,
    JsonSerializerOptions options,
  ) {
    assert(value is Map, _assertionMessageMap);
    final values = value as Map;
    final args = <Symbol, dynamic>{};

    for (var param in userType.info.named) {
      final rawValue = _findValueInMap(values, param.name, options);

      if (param.isRequired && !param.type.isNullable && rawValue == null) {
        final availableKeys = values.keys.join(', ');
        throw JsonSerializerException(
          'Error converting user-defined type "${type.name}".\n'
          'Required parameter not found: "${param.name}"\n'
          'Expected type: ${param.type.name}\n'
          'Available keys in JSON: $availableKeys',
        );
      }

      if (rawValue == null) {
        if (param.isRequired) {
          // Required named parameters must be provided, even if the value is null.
          args[Symbol(param.name)] = null;
        }
        continue;
      }

      try {
        args[Symbol(param.name)] = decode(rawValue, param.type, options);
      } catch (e) {
        throw JsonSerializerException(
          'Error converting parameter "${param.name}" of type "${type.name}".\n'
          'Received value: "$rawValue" (type: ${rawValue.runtimeType})\n'
          'Expected type: ${param.type.name}\n'
          'Original error: $e',
        );
      }
    }

    return Function.apply(userType.function, null, args);
  }
}
