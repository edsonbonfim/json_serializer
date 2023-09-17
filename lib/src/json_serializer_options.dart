import 'default_converters.dart';
import 'json_converter.dart';
import 'user_type.dart';

class JsonSerializerOptions {
  final _userTypes = <UserType>[];

  final _converters = <JsonConverter>[
    StringConverter(),
    DateTimeConverter(),
    DynamicConverter(),
    IntConverter(),
    BigIntConverter(),
    DoubleConverter(),
    NumConverter(),
    BoolConverter(),
    ObjectConverter(),
    UriConverter(),
    UserTypeConverter(),
    UserTypeListConverter(),
  ];

  JsonSerializerOptions({
    List<UserType> userTypes = const [],
    List<JsonConverter> converters = const [],
  }) {
    _userTypes.addAll(userTypes);
    _converters.addAll(converters);
  }

  bool hasUserType(String type) {
    return getUserType(type) != null;
  }

  UserType? getUserType(String type) {
    return _userTypes.where((x) => x.classData.className == type).firstOrNull;
  }

  JsonConverter? getConverter(String type) {
    return _converters.where((x) => x.canConvert(type, this)).firstOrNull;
  }
}
