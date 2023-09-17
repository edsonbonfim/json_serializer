import '../json_serializer.dart';
import 'json_converter.dart';
import 'json_converter_context.dart';

class StringConverter extends JsonConverter<String> {
  @override
  String? convert(JsonConverterContext context) {
    return "${context.value}";
  }
}

class DateTimeConverter extends JsonConverter<DateTime> {
  @override
  DateTime? convert(JsonConverterContext context) {
    return DateTime.parse("${context.value}");
  }
}

class DynamicConverter extends JsonConverter<dynamic> {
  @override
  dynamic convert(JsonConverterContext context) {
    return context.value as dynamic;
  }
}

class IntConverter extends JsonConverter<int> {
  @override
  int? convert(JsonConverterContext context) {
    return int.parse("${context.value}");
  }
}

class BigIntConverter extends JsonConverter<BigInt> {
  @override
  BigInt? convert(JsonConverterContext context) {
    return BigInt.parse("${context.value}");
  }
}

class DoubleConverter extends JsonConverter<double> {
  @override
  double? convert(JsonConverterContext context) {
    return double.parse("${context.value}");
  }
}

class NumConverter extends JsonConverter<num> {
  @override
  num? convert(JsonConverterContext context) {
    return num.parse("${context.value}");
  }
}

class BoolConverter extends JsonConverter<bool> {
  @override
  bool? convert(JsonConverterContext context) {
    return bool.parse("${context.value}");
  }
}

class ObjectConverter extends JsonConverter<Object> {
  @override
  Object? convert(JsonConverterContext context) {
    return context.value as Object;
  }
}

class UriConverter extends JsonConverter<Uri> {
  @override
  Uri? convert(JsonConverterContext context) {
    return Uri.parse("${context.value}");
  }
}

class UserTypeConverter extends JsonConverter<dynamic> {
  @override
  bool canConvert(String typeToConvert, JsonSerializerOptions options) {
    return options.hasUserType(typeToConvert);
  }

  @override
  convert(JsonConverterContext context) {
    return JsonSerializer.deserialize(context.value, context.param.type);
  }
}

class UserTypeListConverter extends JsonConverter<dynamic> {
  @override
  bool canConvert(String typeToConvert, JsonSerializerOptions options) {
    var subtype = _getSybType(typeToConvert);

    if (subtype == null) {
      return false;
    }

    return options.hasUserType(subtype);
  }

  @override
  convert(JsonConverterContext context) {
    var list = context.value as List;
    var subTypeName = _getSybType(context.param.type)!;
    var subType = context.options.getUserType(subTypeName)!;

    var results =
        list.map((x) => JsonSerializer.deserialize(x, subTypeName)).toList();

    return subType.castList(results);
  }

  String? _getSybType(String type) {
    var match = RegExp(r"^List<(.+)>$").firstMatch(type);

    if (match == null || match.groupCount == 0) {
      return null;
    }

    return match.group(1);
  }
}
