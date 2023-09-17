import 'package:fake_reflection/fake_reflection.dart';

class UserType<T> {
  final Function constructor;
  final ClassData classData;

  UserType(this.constructor) : classData = constructor.reflection();

  List<T> castList(List<dynamic> list) {
    return list.cast<T>();
  }
}
