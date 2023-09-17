import 'dart:convert';

import 'package:fake_reflection/fake_reflection.dart';
import 'package:json_serializer/json_serializer.dart';

import 'json_converter.dart';
import 'json_converter_context.dart';

final class JsonSerializer {
  static var options = JsonSerializerOptions();

  JsonSerializer._();

  static JsonSerializer? _instance;

  static T deserialize<T>(dynamic json, [String? typeToConvert]) {
    if (json == null) {
      throw JsonException("JsonExceptionJsonNull");
    }

    if (json is String) {
      return _getInstance()._fromJson(json, typeToConvert ?? T.toString());
    }

    if (json is Map<String, dynamic>) {
      return _getInstance()._fromMap(json, typeToConvert ?? T.toString());
    }

    throw JsonException("JsonExceptionInvalidJsonFormat");
  }

  static JsonSerializer _getInstance() {
    return _instance ??= JsonSerializer._();
  }

  _fromJson(String json, String typeToConvert) {
    return _fromMap(jsonDecode(json), typeToConvert);
  }

  _fromMap(Map<String, dynamic> values, String typeToConvert) {
    final userType = options.getUserType(typeToConvert)!;

    final args = <Symbol, dynamic>{};

    userType.classData.namedParams
        .where((param) => values.containsKey(param.name))
        .map((param) => _getParam(param, values, userType.classData.className))
        .forEach((arg) => args.addAll(arg));

    return Function.apply(userType.constructor, null, args);
  }

  Map<Symbol, dynamic> _getParam(
    NamedParam param,
    Map<String, dynamic> values,
    String typeToConvert,
  ) {
    return _getConverter(param.type)
        .getParam(_createContext(param, values, typeToConvert));
  }

  JsonConverter _getConverter(String typeToConvert) {
    var converter = options.getConverter(typeToConvert);

    if (converter == null) {
      throw FormatException(
        "Could not found a JSON converter for type '$typeToConvert'",
      );
    }

    return converter;
  }

  JsonConverterContext _createContext(
    NamedParam param,
    Map<String, dynamic> values,
    String typeToConvert,
  ) {
    return JsonConverterContext(
      param: param,
      value: values[param.name],
      options: options,
      typeToConvert: typeToConvert,
    );
  }
}
