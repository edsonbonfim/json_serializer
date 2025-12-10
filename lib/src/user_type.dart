import 'generic_type.dart';
import 'parser.dart';

/// Define a default user-defined type class.
///
/// This class is used internally as a placeholder for default type constructors.
class DefaultUserType {}

/// A list of default user-defined types.
///
/// These types are automatically registered and available for JSON serialization
/// without requiring explicit registration.
final defaultUserTypes = <GenericType>[
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

/// Represents a user-defined type for JSON serialization.
///
/// This class allows you to register custom types with the JSON serializer.
/// The type is defined by a constructor function that will be called during
/// deserialization to create instances of the type.
///
/// @typeparam [T] The type that this UserType represents.
class UserType<T> extends GenericType<T> {
  /// The constructor function for this user type.
  final Function function;

  /// The parsed function information containing parameter details.
  final FunctionInfo info;

  /// Creates a new instance of the [UserType] class.
  ///
  /// @param [function] The constructor function associated with the type.
  ///   This function will be called during deserialization with named parameters
  ///   extracted from the JSON.
  UserType(this.function) : info = DartParser.parseFunction(function);
}

/// Represents a user-defined type for [BigInt].
class BigIntType extends UserType<BigInt> {
  /// Creates a new instance of the [BigIntType] class.
  BigIntType() : super(DefaultUserType.new);
}

/// Represents a user-defined type for [bool].
class BoolType extends UserType<bool> {
  /// Creates a new instance of the [BoolType] class.
  BoolType() : super(DefaultUserType.new);
}

/// Represents a user-defined type for [double].
class DoubleType extends UserType<double> {
  /// Creates a new instance of the [DoubleType] class.
  DoubleType() : super(DefaultUserType.new);
}

/// Represents a user-defined type for [int].
class IntType extends UserType<int> {
  /// Creates a new instance of the [IntType] class.
  IntType() : super(DefaultUserType.new);
}

/// Represents a user-defined type for [num].
class NumType extends UserType<num> {
  /// Creates a new instance of the [NumType] class.
  NumType() : super(DefaultUserType.new);
}

/// Represents a user-defined type for [String].
class StringType extends UserType<String> {
  /// Creates a new instance of the [StringType] class.
  StringType() : super(DefaultUserType.new);
}

/// Represents a user-defined type for [DateTime].
class DateTimeType extends UserType<DateTime> {
  /// Creates a new instance of the [DateTimeType] class.
  DateTimeType() : super(DefaultUserType.new);
}

/// Represents a user-defined type for [Uri].
class UriType extends UserType<Uri> {
  /// Creates a new instance of the [UriType] class.
  UriType() : super(DefaultUserType.new);
}

/// Represents a user-defined type for [Object].
class ObjectType extends UserType<Object> {
  /// Creates a new instance of the [ObjectType] class.
  ObjectType() : super(DefaultUserType.new);
}

/// Represents a user-defined type for [dynamic].
class DynamicType extends UserType<dynamic> {
  /// Creates a new instance of the [DynamicType] class.
  DynamicType() : super(DefaultUserType.new);
}

/// Represents a user-defined type for [Map].
class MapType extends UserType<Map<String, dynamic>> {
  static const String _typeName = 'Map';

  /// Creates a new instance of the [MapType] class.
  MapType() : super(DefaultUserType.new);

  @override
  String get name => _typeName;
}

/// Represents a user-defined type for [List].
class ListType extends UserType<List> {
  static const String _typeName = 'List';

  /// Creates a new instance of the [ListType] class.
  ListType() : super(DefaultUserType.new);

  @override
  String get name => _typeName;
}
