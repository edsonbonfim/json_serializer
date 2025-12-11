import 'package:json_serializer/src/naming/convention.dart';
import 'package:test/test.dart';

void main() {
  group('CamelCaseConvention', () {
    final convention = CamelCaseConvention();

    test('name returns camelCase', () {
      expect(convention.name, equals('camelCase'));
    });

    test('toCamelCase returns same value', () {
      expect(convention.toCamelCase('firstName'), equals('firstName'));
    });

    test('fromCamelCase returns same value', () {
      expect(convention.fromCamelCase('firstName'), equals('firstName'));
    });

    test('matches returns true for camelCase', () {
      expect(convention.matches('firstName'), isTrue);
      expect(convention.matches('myVariable'), isTrue);
    });

    test('matches returns false for non-camelCase', () {
      expect(convention.matches('first_name'), isFalse);
      expect(convention.matches('FirstName'), isFalse);
    });
  });

  group('SnakeCaseConvention', () {
    final convention = SnakeCaseConvention();

    test('name returns snake_case', () {
      expect(convention.name, equals('snake_case'));
    });

    test('toCamelCase converts snake_case to camelCase', () {
      expect(convention.toCamelCase('first_name'), equals('firstName'));
      expect(convention.toCamelCase('my_variable_name'), equals('myVariableName'));
    });

    test('fromCamelCase converts camelCase to snake_case', () {
      expect(convention.fromCamelCase('firstName'), equals('first_name'));
      expect(convention.fromCamelCase('myVariableName'), equals('my_variable_name'));
    });

    test('matches returns true for snake_case', () {
      expect(convention.matches('first_name'), isTrue);
      expect(convention.matches('my_variable'), isTrue);
    });

    test('matches returns false for non-snake_case', () {
      expect(convention.matches('firstName'), isFalse);
      expect(convention.matches('FirstName'), isFalse);
    });

    test('handles empty string', () {
      expect(convention.toCamelCase(''), equals(''));
      expect(convention.fromCamelCase(''), equals(''));
    });
  });

  group('PascalCaseConvention', () {
    final convention = PascalCaseConvention();

    test('name returns PascalCase', () {
      expect(convention.name, equals('PascalCase'));
    });

    test('toCamelCase converts PascalCase to camelCase', () {
      expect(convention.toCamelCase('FirstName'), equals('firstName'));
      expect(convention.toCamelCase('MyVariable'), equals('myVariable'));
    });

    test('fromCamelCase converts camelCase to PascalCase', () {
      expect(convention.fromCamelCase('firstName'), equals('FirstName'));
      expect(convention.fromCamelCase('myVariable'), equals('MyVariable'));
    });

    test('matches returns true for PascalCase', () {
      expect(convention.matches('FirstName'), isTrue);
      expect(convention.matches('MyVariable'), isTrue);
    });

    test('matches returns false for non-PascalCase', () {
      expect(convention.matches('firstName'), isFalse);
      expect(convention.matches('first_name'), isFalse);
    });
  });

  group('KebabCaseConvention', () {
    final convention = KebabCaseConvention();

    test('name returns kebab-case', () {
      expect(convention.name, equals('kebab-case'));
    });

    test('toCamelCase converts kebab-case to camelCase', () {
      expect(convention.toCamelCase('first-name'), equals('firstName'));
      expect(convention.toCamelCase('my-variable-name'), equals('myVariableName'));
    });

    test('fromCamelCase converts camelCase to kebab-case', () {
      expect(convention.fromCamelCase('firstName'), equals('first-name'));
      expect(convention.fromCamelCase('myVariableName'), equals('my-variable-name'));
    });

    test('matches returns true for kebab-case', () {
      expect(convention.matches('first-name'), isTrue);
      expect(convention.matches('my-variable'), isTrue);
    });

    test('matches returns false for non-kebab-case', () {
      expect(convention.matches('firstName'), isFalse);
      expect(convention.matches('first_name'), isFalse);
    });
  });

  group('Edge cases', () {
    final snake = SnakeCaseConvention();
    final pascal = PascalCaseConvention();
    final kebab = KebabCaseConvention();

    test('handles single word', () {
      expect(snake.toCamelCase('name'), equals('name'));
      expect(pascal.toCamelCase('Name'), equals('name'));
      expect(kebab.toCamelCase('name'), equals('name'));
    });

    test('handles multiple consecutive separators', () {
      expect(snake.toCamelCase('first__name'), equals('firstName'));
      expect(kebab.toCamelCase('first--name'), equals('firstName'));
    });

    test('handles numbers', () {
      expect(snake.toCamelCase('item_1'), equals('item1'));
      expect(pascal.toCamelCase('Item1'), equals('item1'));
    });

    test('handles empty parts', () {
      expect(snake.toCamelCase('_name'), equals('Name')); // First part empty, second capitalized
      expect(snake.toCamelCase('name_'), equals('name')); // Last part empty, ignored
    });
  });
}
