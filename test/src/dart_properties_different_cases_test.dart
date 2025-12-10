import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

void main() {
  group('Dart properties in different cases', () {
    setUp(() {
      JsonSerializer.options = JsonSerializerOptions(types: [
        UserType<PersonSnakeCase>(PersonSnakeCase.new),
        UserType<PersonPascalCase>(PersonPascalCase.new),
        UserType<PersonMixed>(PersonMixed.new),
      ]);
    });

    test('Dart property in snake_case, JSON in camelCase', () {
      var json = '''{"firstName": "John", "lastName": "Doe"}''';
      var result = deserialize<PersonSnakeCase>(json);

      expect(result.first_name, equals('John'));
      expect(result.last_name, equals('Doe'));
    });

    test('Dart property in snake_case, JSON in snake_case', () {
      var json = '''{"first_name": "Jane", "last_name": "Smith"}''';
      var result = deserialize<PersonSnakeCase>(json);

      expect(result.first_name, equals('Jane'));
      expect(result.last_name, equals('Smith'));
    });

    test('Dart property in PascalCase, JSON in camelCase', () {
      var json = '''{"firstName": "Bob", "lastName": "Johnson"}''';
      var result = deserialize<PersonPascalCase>(json);

      expect(result.FirstName, equals('Bob'));
      expect(result.LastName, equals('Johnson'));
    });

    test('Dart property in PascalCase, JSON in PascalCase', () {
      var json = '''{"FirstName": "Alice", "LastName": "Brown"}''';
      var result = deserialize<PersonPascalCase>(json);

      expect(result.FirstName, equals('Alice'));
      expect(result.LastName, equals('Brown'));
    });

    test('Dart properties mixed cases, JSON in snake_case', () {
      var json = '''{"first_name": "Charlie", "LastName": "Wilson"}''';
      var result = deserialize<PersonMixed>(json);

      expect(result.first_name, equals('Charlie'));
      expect(result.LastName, equals('Wilson'));
    });

    test('Dart snake_case property, JSON in PascalCase', () {
      var json = '''{"FirstName": "David", "LastName": "Taylor"}''';
      var result = deserialize<PersonSnakeCase>(json);

      expect(result.first_name, equals('David'));
      expect(result.last_name, equals('Taylor'));
    });

    test('Dart PascalCase property, JSON in snake_case', () {
      var json = '''{"first_name": "Emma", "last_name": "Davis"}''';
      var result = deserialize<PersonPascalCase>(json);

      expect(result.FirstName, equals('Emma'));
      expect(result.LastName, equals('Davis'));
    });

    test('Dart snake_case property, JSON in kebab-case', () {
      var json = '''{"first-name": "Frank", "last-name": "Miller"}''';
      var result = deserialize<PersonSnakeCase>(json);

      expect(result.first_name, equals('Frank'));
      expect(result.last_name, equals('Miller'));
    });

    test('Nested objects with different cases', () {
      JsonSerializer.options = JsonSerializerOptions(types: [
        UserType<PersonWithAddress>(PersonWithAddress.new),
        UserType<AddressSnakeCase>(AddressSnakeCase.new),
      ]);

      var json =
          '''{"first_name": "Grace", "home_address": {"street_name": "Main St", "city_name": "Springfield"}}''';
      var result = deserialize<PersonWithAddress>(json);

      expect(result.first_name, equals('Grace'));
      expect(result.home_address.street_name, equals('Main St'));
      expect(result.home_address.city_name, equals('Springfield'));
    });

    test('List with different cases', () {
      JsonSerializer.options = JsonSerializerOptions(types: [
        UserType<PersonSnakeCase>(PersonSnakeCase.new),
      ]);

      var json =
          '''[{"first_name": "Henry", "last_name": "Brown"}, {"FirstName": "Ivy", "LastName": "Green"}]''';
      var result = deserialize<List<PersonSnakeCase>>(json);

      expect(result.length, equals(2));
      expect(result[0].first_name, equals('Henry'));
      expect(result[0].last_name, equals('Brown'));
      expect(result[1].first_name, equals('Ivy'));
      expect(result[1].last_name, equals('Green'));
    });
  });
}

class PersonSnakeCase {
  final String first_name;
  final String last_name;

  PersonSnakeCase({required this.first_name, required this.last_name});
}

class PersonPascalCase {
  final String FirstName;
  final String LastName;

  PersonPascalCase({required this.FirstName, required this.LastName});
}

class PersonMixed {
  final String first_name;
  final String LastName;

  PersonMixed({required this.first_name, required this.LastName});
}

class PersonWithAddress {
  final String first_name;
  final AddressSnakeCase home_address;

  PersonWithAddress({required this.first_name, required this.home_address});
}

class AddressSnakeCase {
  final String street_name;
  final String city_name;

  AddressSnakeCase({required this.street_name, required this.city_name});
}
