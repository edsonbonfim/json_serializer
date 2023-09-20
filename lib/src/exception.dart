/// A custom exception class for handling JSON conversion errors.
///
/// Use this exception class when you encounter errors related to JSON conversion
/// operations, such as parsing JSON strings or serializing objects to JSON.
class JsonDeserializationException implements Exception {
  /// The error message associated with this exception.
  final String message;

  /// Creates a new instance of [JsonDeserializationException] with the specified [message].
  ///
  /// The [message] parameter should provide details about the JSON conversion error.
  JsonDeserializationException(this.message);

  /// Returns a string representation of this exception.
  ///
  /// The returned string includes the exception type and the associated error message.
  @override
  String toString() {
    return 'JsonConversionException: $message';
  }
}
