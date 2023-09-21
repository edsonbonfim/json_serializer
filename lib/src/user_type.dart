import 'package:fake_reflection/fake_reflection.dart';

// Define a default user-defined type class.
class DefaultUserType {}

/// A list of default user-defined types.
final defaultUserTypes = <UserType>[
  BigIntType(),
  BoolType(),
  DoubleType(),
  IntType(),
  NumType(),
  StringType(),
  DateTimeType(),
  UriType(),
  ObjectType(),
  DynamicType(),
  MapType(),
  ListType(),
];

/// A generic user-defined type class.
class UserType<T> {
  /// Class metadata (reflection data).
  final ClassData classData;

  /// Constructor function.
  final Function constructor;

  /// Name of the user-defined type.
  final String name;

  /// Constructor for UserType.
  UserType(this.constructor)
      : name = T.toString(),
        classData = constructor.reflection();

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

/// User-defined type for BigInt.
class BigIntType extends UserType<BigInt> {
  BigIntType() : super(DefaultUserType.new);
}

/// User-defined type for bool.
class BoolType extends UserType<bool> {
  BoolType() : super(DefaultUserType.new);
}

/// User-defined type for double.
class DoubleType extends UserType<double> {
  DoubleType() : super(DefaultUserType.new);
}

/// User-defined type for int.
class IntType extends UserType<int> {
  IntType() : super(DefaultUserType.new);
}

/// User-defined type for num.
class NumType extends UserType<num> {
  NumType() : super(DefaultUserType.new);
}

/// User-defined type for String.
class StringType extends UserType<String> {
  StringType() : super(DefaultUserType.new);
}

/// User-defined type for DateTime.
class DateTimeType extends UserType<DateTime> {
  DateTimeType() : super(DefaultUserType.new);
}

/// User-defined type for Uri.
class UriType extends UserType<Uri> {
  UriType() : super(DefaultUserType.new);
}

/// User-defined type for Object.
class ObjectType extends UserType<Object> {
  ObjectType() : super(DefaultUserType.new);
}

/// User-defined type for dynamic.
class DynamicType extends UserType<dynamic> {
  DynamicType() : super(DefaultUserType.new);
}

/// User-defined type for Map.
class MapType extends UserType<Map<String, dynamic>> {
  MapType() : super(DefaultUserType.new);

  @override
  String get name => "Map";
}

/// User-defined type for List.
class ListType extends UserType<List> {
  ListType() : super(DefaultUserType.new);

  @override
  String get name => "List";
}
