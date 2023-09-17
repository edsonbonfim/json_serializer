import 'package:json_serializer/json_serializer.dart';

import 'json_converter_context.dart';
import 'helpers/throw_helper.dart';

/// Converts an object or value.
abstract class JsonConverter<T> {
  /// The type to convert.
  final String typeToConvert = T.toString();

  /// Does the converter want to be called when reading null values.
  bool handleNull = false;

  /// Determines whether the type can be converted.
  bool canConvert(String typeToConvert, JsonSerializerOptions options) {
    return this.typeToConvert == typeToConvert;
  }

  /// Convert the value to T.
  T? convert(JsonConverterContext context);

  /// Returns a constructor named param.
  Map<Symbol, dynamic> getParam(JsonConverterContext context) {
    return {Symbol(context.param.name): _tryConvert(context)};
  }

  T? _tryConvert(JsonConverterContext context) {
    // For perf and converter simplicity, handle null here instead of forwarding to the converter.
    if (context.value == null && !handleNull) {
      if (!context.param.nullable) {
        ThrowHelper.throwJsonExceptionDeserializeUnableToConvertValue(
          typeToConvert,
          context.param.name,
        );
      }

      return null;
    }

    return convert(context);
  }
}
