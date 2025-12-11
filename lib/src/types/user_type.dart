import 'generic_type.dart';
import '../dart/type_parser.dart';

/// Default user-defined type class.
///
/// This class is used internally as a placeholder for default type constructors.
class DefaultUserType {}

/// Default user-defined types.
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

  /// Creates a new instance of [UserType].
  ///
  /// @param [function] The constructor function associated with the type.
  ///   This function will be called during deserialization with named parameters
  ///   extracted from the JSON.
  UserType(this.function) : info = DartParser.parseFunction(function);
}

/// User-defined type for [BigInt].
class BigIntType extends UserType<BigInt> {
  /// Creates a new instance of [BigIntType].
  BigIntType() : super(DefaultUserType.new);
}

/// User-defined type for [bool].
class BoolType extends UserType<bool> {
  /// Creates a new instance of [BoolType].
  BoolType() : super(DefaultUserType.new);
}

/// User-defined type for [double].
class DoubleType extends UserType<double> {
  /// Creates a new instance of [DoubleType].
  DoubleType() : super(DefaultUserType.new);
}

/// User-defined type for [int].
class IntType extends UserType<int> {
  /// Creates a new instance of [IntType].
  IntType() : super(DefaultUserType.new);
}

/// User-defined type for [num].
class NumType extends UserType<num> {
  /// Creates a new instance of [NumType].
  NumType() : super(DefaultUserType.new);
}

/// User-defined type for [String].
class StringType extends UserType<String> {
  /// Creates a new instance of [StringType].
  StringType() : super(DefaultUserType.new);
}

/// User-defined type for [DateTime].
class DateTimeType extends UserType<DateTime> {
  /// Creates a new instance of [DateTimeType].
  DateTimeType() : super(DefaultUserType.new);
}

/// User-defined type for [Uri].
class UriType extends UserType<Uri> {
  /// Creates a new instance of [UriType].
  UriType() : super(DefaultUserType.new);
}

/// User-defined type for [Object].
class ObjectType extends UserType<Object> {
  /// Creates a new instance of [ObjectType].
  ObjectType() : super(DefaultUserType.new);
}

/// User-defined type for [dynamic].
class DynamicType extends UserType<dynamic> {
  /// Creates a new instance of [DynamicType].
  DynamicType() : super(DefaultUserType.new);
}

/// User-defined type for [Map].
class MapType extends UserType<Map<String, dynamic>> {
  static const String _typeName = 'Map';

  /// Creates a new instance of [MapType].
  MapType() : super(DefaultUserType.new);

  @override
  String get name => _typeName;
}

/// User-defined type for [List].
class ListType extends UserType<List> {
  static const String _typeName = 'List';

  /// Creates a new instance of [ListType].
  ListType() : super(DefaultUserType.new);

  @override
  String get name => _typeName;
}
