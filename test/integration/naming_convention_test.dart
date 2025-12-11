import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

void main() {
  group('Naming Convention Tests', () {
    test('Using explicit snake_case convention', () {
      final options = JsonSerializerOptions(
        types: [UserType<Person>(Person.new)],
        jsonNamingConvention: SnakeCaseConvention(),
      );

      var json = '''{"first_name": "Alice", "last_name": "Smith"}''';
      var result = deserialize<Person>(json, options);

      expect(result.firstName, equals('Alice'));
      expect(result.lastName, equals('Smith'));
    });

    test('Using explicit PascalCase convention', () {
      final options = JsonSerializerOptions(
        types: [UserType<Person>(Person.new)],
        jsonNamingConvention: PascalCaseConvention(),
      );

      var json = '''{"FirstName": "Bob", "LastName": "Johnson"}''';
      var result = deserialize<Person>(json, options);

      expect(result.firstName, equals('Bob'));
      expect(result.lastName, equals('Johnson'));
    });

    test('Using explicit kebab-case convention', () {
      final options = JsonSerializerOptions(
        types: [UserType<Person>(Person.new)],
        jsonNamingConvention: KebabCaseConvention(),
      );

      var json = '''{"first-name": "Charlie", "last-name": "Brown"}''';
      var result = deserialize<Person>(json, options);

      expect(result.firstName, equals('Charlie'));
      expect(result.lastName, equals('Brown'));
    });

    test('Auto-detection (no explicit convention)', () {
      final options = JsonSerializerOptions(
        types: [UserType<Person>(Person.new)],
      );

      var json = '''{"first_name": "David", "last_name": "Wilson"}''';
      var result = deserialize<Person>(json, options);

      expect(result.firstName, equals('David'));
      expect(result.lastName, equals('Wilson'));
    });

    test('Custom naming convention', () {
      final customConvention = CustomPrefixConvention('x_');

      final options = JsonSerializerOptions(
        types: [UserType<Person>(Person.new)],
        namingConventions: [customConvention],
        jsonNamingConvention: customConvention,
      );

      var json = '''{"x_firstName": "Eve", "x_lastName": "Davis"}''';
      var result = deserialize<Person>(json, options);

      expect(result.firstName, equals('Eve'));
      expect(result.lastName, equals('Davis'));
    });

    test('Multiple custom conventions with priority', () {
      final conventions = [
        CustomPrefixConvention('api_'),
        SnakeCaseConvention(),
        CamelCaseConvention(),
      ];

      final options = JsonSerializerOptions(
        types: [UserType<Person>(Person.new)],
        namingConventions: conventions,
      );

      var json = '''{"api_firstName": "Frank", "api_lastName": "Miller"}''';
      var result = deserialize<Person>(json, options);

      expect(result.firstName, equals('Frank'));
      expect(result.lastName, equals('Miller'));
    });
  });
}

class Person {
  final String firstName;
  final String lastName;

  Person({required this.firstName, required this.lastName});
}

class CustomPrefixConvention extends NamingConvention {
  final String prefix;

  CustomPrefixConvention(this.prefix);

  @override
  String get name => 'custom_prefix_$prefix';

  @override
  String toCamelCase(String propertyName) {
    if (propertyName.startsWith(prefix)) {
      return propertyName.substring(prefix.length);
    }
    return propertyName;
  }

  @override
  String fromCamelCase(String propertyName) {
    return '$prefix$propertyName';
  }

  @override
  bool matches(String propertyName) {
    return propertyName.startsWith(prefix);
  }
}
