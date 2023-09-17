import 'package:fake_reflection/fake_reflection.dart';

import 'json_serializer_options.dart';

/// Data transfer object that represents a context of conversion from the value
/// to param.
class JsonConverterContext {
  /// JSON serializer options
  final JsonSerializerOptions options;

  /// Target parameter
  final NamedParam param;

  /// Source value
  final dynamic value;

  final String typeToConvert;

  JsonConverterContext({
    required this.options,
    required this.param,
    required this.value,
    required this.typeToConvert
  });
}
