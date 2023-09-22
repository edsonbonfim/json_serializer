import 'generic_type.dart';

class EnumType<T extends Enum> extends GenericType<T> {
  final List<T> values;

  EnumType(this.values);

  T parse(String value) {
    return values.byName(value);
  }
}
