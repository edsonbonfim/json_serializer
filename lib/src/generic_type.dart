/// Represents a generic type for JSON serialization.
///
/// The `GenericType` class provides a way to work with generic types in Dart.
/// It allows you to create empty lists and maps with specific type parameters,
/// making it easier to work with generic collections during serialization.
///
/// To use `GenericType`, simply instantiate it with the desired type parameter.
/// You can then use the provided methods to create empty lists and maps with
/// the specified type.
///
/// @typeparam [T] The type that this GenericType represents.
class GenericType<T> {
  /// The name of the generic type.
  ///
  /// This property returns the string representation of the type [T].
  final String name = T.toString();

  /// Creates an empty list of type [T].
  ///
  /// This method returns an empty list that can hold elements of type [T].
  ///
  /// @returns An empty list of type [T].
  List<T> createList() => [];

  /// Creates an empty map with keys of type [String] and values of type [T].
  ///
  /// This method returns an empty map with keys of type [String] and values of type [T].
  ///
  /// @returns An empty map with String keys and values of type [T].
  Map<String, T> createMapOfT() => {};

  /// Creates an empty map with keys of type [String] and nullable values of type [T].
  ///
  /// This method returns an empty map with keys of type [String] and nullable values of type [T].
  ///
  /// @returns An empty map with String keys and nullable values of type [T].
  Map<String, T?> createMapOfNullableT() => {};

  /// Creates an empty list of maps with keys of type [String] and values of type [T].
  ///
  /// This method returns an empty list of maps, where each map has keys of type [String]
  /// and values of type [T].
  ///
  /// @returns An empty list of maps with String keys and values of type [T].
  List<Map<String, T>> createListOfMapOfT() => [];

  /// Creates an empty map with keys of type [String] and values of type [List] of [T].
  ///
  /// This method returns an empty map with keys of type [String] and values of type [List] of [T].
  ///
  /// @returns An empty map with String keys and List<T> values.
  Map<String, List<T>> createMapOfListOfT() => {};

  /// Creates an empty map with keys of type [String] and nullable values of type [List] of [T].
  ///
  /// This method returns an empty map with keys of type [String] and nullable values
  /// of type [List] of [T].
  ///
  /// @returns An empty map with String keys and nullable List<T> values.
  Map<String, List<T>?> createMapOfListOfNullableT() => {};
}
