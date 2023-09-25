/// Exception thrown when there is an error during parsing.
class DartParserException implements Exception {
  /// The error message associated with the exception.
  final String message;

  /// Creates a new instance of [DartParserException] with the given [message].
  DartParserException(this.message);

  @override
  String toString() {
    return 'ParserException: $message';
  }
}

/// Exception thrown when there is an error during JSON serialization.
class JsonSerializerException implements Exception {
  /// The error message associated with the exception.
  final String message;

  /// Creates a new instance of [JsonSerializerException] with the given [message].
  JsonSerializerException(this.message);

  @override
  String toString() {
    return 'JsonConversionException: $message';
  }
}
