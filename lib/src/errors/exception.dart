/// Exception thrown when there is an error during parsing.
///
/// This exception is used to indicate syntax errors or other parsing issues
/// in the Dart parser.
class DartParserException implements Exception {
  /// The error message associated with the exception.
  final String message;

  /// Creates a new instance of [DartParserException] with the given message.
  ///
  /// @param [message] The error message describing the parsing error.
  DartParserException(this.message);

  @override
  String toString() {
    return 'ParserException: $message';
  }
}

/// Exception thrown when there is an error during JSON serialization or deserialization.
///
/// This exception is used to indicate errors that occur during the conversion
/// of objects to or from JSON format.
class JsonSerializerException implements Exception {
  /// The error message associated with the exception.
  final String message;

  /// Creates a new instance of [JsonSerializerException] with the given message.
  ///
  /// @param [message] The error message describing the serialization error.
  JsonSerializerException(this.message);

  @override
  String toString() {
    return 'JsonConversionException: $message';
  }
}
