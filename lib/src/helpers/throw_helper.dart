import '../exceptions/json_exception.dart';

abstract class ThrowHelper {
  static throwJsonExceptionDeserializeUnableToConvertValue(
    String typeToConvert,
    String propertyName,
  ) {
    throw JsonException(
      "type 'Null' is not a subtype of type '$typeToConvert' of '$propertyName",
    );
  }
}
