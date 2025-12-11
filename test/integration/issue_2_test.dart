import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

void main() {
  group('https://github.com/edsonbonfim/json_serializer/issues/2', () {
    setUp(() {
      JsonSerializer.options = JsonSerializerOptions(types: [
        UserType<Person>(Person.new),
      ]);
    });

    test('https://github.com/edsonbonfim/json_serializer/issues/2', () {
      var json = '''{"first_name": "Foo","last_name": "Bar"}''';
      var result = deserialize<Person>(json);

      expect(result.firstName, equals('Foo'));
      expect(result.lastName, equals('Bar'));
    });
  });
}

class Person implements Serializable {
  final String firstName;
  final String lastName;

  const Person({required this.firstName, required this.lastName});

  @override
  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}
