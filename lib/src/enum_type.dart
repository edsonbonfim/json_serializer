import 'generic_type.dart';

/// Represents an enumeration type for JSON serialization.
///
/// The `EnumType` class extends the `GenericType` class and provides additional functionality
/// for working with enumeration values. It allows parsing enum values from strings
/// and serializing them to their string names.
///
/// @typeparam [T] The enum type that this EnumType handles.
class EnumType<T extends Enum> extends GenericType<T> {
  /// The list of values of the enumeration type.
  final List<T> values;

  /// Creates a new instance of the `EnumType` class with the specified values.
  ///
  /// @param [values] The list of enum values. Must not be empty.
  /// @throws [AssertionError] if [values] is empty in debug mode.
  EnumType(this.values)
      : assert(values.isNotEmpty, 'Enum values cannot be empty');

  /// Parses the given value and returns the corresponding enumeration value.
  ///
  /// The value should be a string representation of one of the enumeration values.
  /// If the value does not match any of the enumeration values, an exception is thrown.
  ///
  /// @param [value] The string value to parse into an enum value.
  /// @returns The corresponding enum value.
  /// @throws [AssertionError] if [value] is empty in debug mode.
  /// @throws [ArgumentError] if the value does not match any enum value.
  T parse(String value) {
    assert(value.isNotEmpty, 'Value to parse cannot be empty');
    return values.byName(value);
  }
}
