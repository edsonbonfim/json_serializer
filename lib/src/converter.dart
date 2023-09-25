/// This file contains the implementation of various JSON converters used in the JSON serialization process.
/// Each converter is responsible for converting a specific data type to and from JSON.
/// The converters are used by the `JsonSerializer` class to perform the serialization and deserialization operations.

import 'enum_type.dart';
import 'exception.dart';
import 'json_serializer_base.dart';
import 'parser.dart';
import 'user_type.dart';

/// The list of default converters used by the `JsonSerializer`.
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
/// A JSON converter is responsible for converting a specific data type to and from JSON.
abstract class JsonConverter<T> {
  /// Determines whether this converter can convert the specified [type].
  bool canConvert(TypeInfo type);

  /// Converts the [value] of type [T] to JSON.
  Object? write(T value, TypeInfo type, JsonSerializerOptions options);

  /// Converts the JSON [value] to type [T].
  T read(dynamic value, TypeInfo type, JsonSerializerOptions options);

  /// Converts a null JSON value to type [T].
  T? readNull(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    if (value == null) {
      return null;
    }

    return read(value, type, options);
  }
}

/// A JSON converter for the `bool` data type.
class BoolConverter extends JsonConverter<bool> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'bool';

  @override
  Object? write(bool value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }

  @override
  bool read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return bool.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException('Error converting to bool: ${e.message}');
    }
  }
}

/// A JSON converter for the `String` data type.
class StringConverter extends JsonConverter<String> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'String';

  @override
  Object? write(String value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }

  @override
  String read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }
}

/// A JSON converter for the `BigInt` data type.
class BigIntConverter extends JsonConverter<BigInt> {
  @override
  bool canConvert(TypeInfo type) =>
      ['BigInt', '_BigIntImpl'].contains(type.name);

  @override
  Object? write(BigInt value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }

  @override
  BigInt read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return BigInt.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException('Error converting to BigInt: ${e.message}');
    }
  }
}

/// A JSON converter for the `DateTime` data type.
class DateTimeConverter extends JsonConverter<DateTime> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'DateTime';

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
          'Error converting to DateTime: ${e.message}');
    }
  }
}

/// A JSON converter for the `double` data type.
class DoubleConverter extends JsonConverter<double> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'double';

  @override
  Object? write(double value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }

  @override
  double read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return double.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException('Error converting to double: ${e.message}');
    }
  }
}

/// A JSON converter for the `num` data type.
class NumConverter extends JsonConverter<num> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'num';

  @override
  Object? write(num value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }

  @override
  num read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return num.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException('Error converting to num: ${e.message}');
    }
  }
}

/// A JSON converter for the `Uri` data type.
class UriConverter extends JsonConverter<Uri> {
  @override
  bool canConvert(TypeInfo type) => ['Uri', '_SimpleUri'].contains(type.name);

  @override
  Object? write(Uri value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }

  @override
  Uri read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return Uri.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException('Error converting to Uri: ${e.message}');
    }
  }
}

/// A JSON converter for the `int` data type.
class IntConverter extends JsonConverter<int> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'int';

  @override
  Object? write(int value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }

  @override
  int read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return int.parse("$value");
    } on FormatException catch (e) {
      throw JsonSerializerException('Error converting to int: ${e.message}');
    }
  }
}

/// A JSON converter for the `Map` data type.
class MapConverter extends JsonConverter<Map> {
  @override
  bool canConvert(TypeInfo type) => type.isMap;

  @override
  Object? write(Map value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  Map read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    final map = _createGenericMap(type, options);

    value.forEach((k, v) {
      map[k] = decode(v, type.generics[1], options);
    });

    return map;
  }

  /// Creates a generic map based on the [type] and [options].
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
class ListConverter extends JsonConverter<List> {
  @override
  bool canConvert(TypeInfo type) => type.isList;

  @override
  Object? write(List value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  List read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    final list = _createGenericList(type, options);

    for (var x in value) {
      list.add(decode(x, type.generics[0], options));
    }

    return list;
  }

  /// Creates a generic list based on the [type] and [options].
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
  @override
  bool canConvert(TypeInfo type) => type.name == 'Object';

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
  @override
  bool canConvert(TypeInfo type) => type.name == 'dynamic';

  @override
  Object? write(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  dynamic read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }
}

/// A JSON converter for generic types.
/// This converter handles the serialization and deserialization of generic types.
class GenericTypeConverter extends JsonConverter {
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
      try {
        return genericType.parse("$value");
      } on ArgumentError catch (e) {
        throw JsonSerializerException(
          'Error converting to ${type.name}: ${e.message}',
        );
      }
    }

    if (genericType is UserType) {
      final values = value as Map;
      final args = <Symbol, dynamic>{};

      for (var param in genericType.info.named) {
        if (param.isRequired &&
            !param.type.isNullable &&
            values[param.name] == null) {
          throw JsonSerializerException(
            "Error converting user-defined type '$type' for parameter '${param.name}' to type '${param.type}'",
          );
        }

        if (values.containsKey(param.name)) {
          final rawValue = values[param.name];
          args[Symbol(param.name)] = decode(rawValue, param.type, options);
        }
      }

      return Function.apply(genericType.function, null, args);
    }

    throw JsonSerializerException(
      "Type $type is not described as user or enum type",
    );
  }
}
