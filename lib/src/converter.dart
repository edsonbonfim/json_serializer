import 'exception.dart';
import 'json_serializer_base.dart';
import 'parser.dart';

/// List of default JSON converters.
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
  UserTypeConverter(),
];

/// Abstract class defining the structure of a generic JSON converter.
abstract class JsonConverter<T> {
  /// Checks if the converter can handle the provided [type].
  bool canConvert(TypeInfo type);

  /// Converts the given [value] to type [T].
  T convert(dynamic value, TypeInfo type, JsonSerializerOptions options);

  /// Converts a null value of the provided [type] to type [T].
  T? convertNull(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    if (value == null) {
      return null;
    }

    return convert(value, type, options);
  }
}

/// Converter for the bool type.
class BoolConverter extends JsonConverter<bool> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'bool';

  @override
  bool convert(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return bool.parse("$value");
    } on FormatException catch (e) {
      throw JsonDeserializationException(
          'Error converting to bool: ${e.message}');
    }
  }
}

/// Converter for the String type.
class StringConverter extends JsonConverter<String> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'String';

  @override
  String convert(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString();
  }
}

/// Converter for the BigInt type.
class BigIntConverter extends JsonConverter<BigInt> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'BigInt';

  @override
  BigInt convert(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return BigInt.parse("$value");
    } on FormatException catch (e) {
      throw JsonDeserializationException(
          'Error converting to BigInt: ${e.message}');
    }
  }
}

/// Converter for the DateTime type.
class DateTimeConverter extends JsonConverter<DateTime> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'DateTime';

  @override
  DateTime convert(
      dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return DateTime.parse("$value");
    } on FormatException catch (e) {
      throw JsonDeserializationException(
          'Error converting to DateTime: ${e.message}');
    }
  }
}

/// Converter for the double type.
class DoubleConverter extends JsonConverter<double> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'double';

  @override
  double convert(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return double.parse("$value");
    } on FormatException catch (e) {
      throw JsonDeserializationException(
          'Error converting to double: ${e.message}');
    }
  }
}

/// Converter for the num type.
class NumConverter extends JsonConverter<num> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'num';

  @override
  num convert(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return num.parse("$value");
    } on FormatException catch (e) {
      throw JsonDeserializationException(
          'Error converting to num: ${e.message}');
    }
  }
}

/// Converter for the Uri type.
class UriConverter extends JsonConverter<Uri> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'Uri';

  @override
  Uri convert(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return Uri.parse("$value");
    } on FormatException catch (e) {
      throw JsonDeserializationException(
          'Error converting to Uri: ${e.message}');
    }
  }
}

/// Converter for the int type.
class IntConverter extends JsonConverter<int> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'int';

  @override
  int convert(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    try {
      return int.parse("$value");
    } on FormatException catch (e) {
      throw JsonDeserializationException(
          'Error converting to int: ${e.message}');
    }
  }
}

/// Converter for the Map type.
class MapConverter extends JsonConverter<Map> {
  @override
  bool canConvert(TypeInfo type) => type.isMap;

  @override
  Map convert(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    final map = _createGenericMap(type, options);

    value.forEach((k, v) {
      map[k] = parse(v, type.genericArguments[1], options);
    });

    return map;
  }

  Map _createGenericMap(TypeInfo type, JsonSerializerOptions options) {
    final mapGenericType = type.genericArguments[1];

    if (mapGenericType.isList) {
      final listGenericType = mapGenericType.genericArguments[0];
      final listGenericUserType = options.getUserType(listGenericType);

      if (listGenericType.isNullable) {
        return listGenericUserType.createMapOfListOfNullableT();
      }

      return listGenericUserType.createMapOfListOfT(1);
    }

    final mapGenericUserType = options.getUserType(mapGenericType);

    if (mapGenericType.isNullable) {
      return mapGenericUserType.createMapOfNullableT();
    }

    return mapGenericUserType.createMapOfT();
  }
}

/// Converter for the List type.
class ListConverter extends JsonConverter<List> {
  @override
  bool canConvert(TypeInfo type) => type.isList;

  @override
  List convert(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    final list = _createGenericList(type, options);

    for (var x in value) {
      list.add(parse(x, type.genericArguments[0], options));
    }

    return list;
  }

  List _createGenericList(TypeInfo type, JsonSerializerOptions options) {
    final listGenericType = type.genericArguments[0];

    if (listGenericType.isMap) {
      final mapGenericType = listGenericType.genericArguments[1];
      return options.getUserType(mapGenericType).createListOfMapOfT();
    }

    return options.getUserType(listGenericType).createList(1);
  }
}

/// Converter for the Object type.
class ObjectConverter extends JsonConverter<Object> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'Object';

  @override
  Object convert(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }
}

/// Converter for the dynamic type.
class DynamicConverter extends JsonConverter<dynamic> {
  @override
  bool canConvert(TypeInfo type) => type.name == 'dynamic';

  @override
  dynamic convert(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }
}

/// Converter for user-defined types.
class UserTypeConverter extends JsonConverter {
  @override
  bool canConvert(TypeInfo type) => true;

  @override
  convert(Object? value, TypeInfo type, JsonSerializerOptions options) {
    final values = value as Map;
    final userType = options.getUserType(type);
    final classData = userType.classData;
    final args = <Symbol, dynamic>{};

    for (var param in classData.namedParams) {
      if (param.required && !param.nullable && values[param.name] == null) {
        throw JsonDeserializationException(
            "Error converting user-defined type '${type}' for parameter '${param.name}' to type '${param.type}'");
      }

      if (values.containsKey(param.name)) {
        final rawValue = values[param.name];
        args[Symbol(param.name)] =
            parse(rawValue, parseType(param.type), options);
      }
    }

    return Function.apply(userType.constructor, null, args);
  }
}
