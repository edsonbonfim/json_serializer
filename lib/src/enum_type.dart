import 'generic_type.dart';

/// Represents an enumeration type.
///
/// The `EnumType` class extends the `GenericType` class and provides additional functionality
/// for working with enumeration values.
class EnumType<T extends Enum> extends GenericType<T> {
  /// The list of values of the enumeration type.
  final List<T> values;

  /// Creates a new instance of the `EnumType` class with the specified [values].
  EnumType(this.values);

  /// Parses the given [value] and returns the corresponding enumeration value.
  ///
  /// The [value] should be a string representation of one of the enumeration values.
  /// If the [value] does not match any of the enumeration values, an exception is thrown.
  T parse(String value) {
    return values.byName(value);
  }
}
