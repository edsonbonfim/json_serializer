/// Fornece métodos para criarmos instancias de listas e mapas para o tipo T
/// dinamicamente em tempo de execução
class GenericType<T> {
  final String name = T.toString();

  /// Create an empty list of type T.
  List<T> createList(int level) => [];

  /// Create an empty map of type T.
  Map<String, T> createMapOfT() => {};

  /// Create an empty map of nullable type T.
  Map<String, T?> createMapOfNullableT() => {};

  /// Create an empty list of maps with type T.
  List<Map<String, T>> createListOfMapOfT() => [];

  /// Create an empty map of lists with type T.
  Map<String, List<T>> createMapOfListOfT(int level) => {};

  /// Create an empty map of nullable lists with type T.
  Map<String, List<T>?> createMapOfListOfNullableT() => {};
}
