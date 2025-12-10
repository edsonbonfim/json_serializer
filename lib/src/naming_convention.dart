/// This file contains the implementation of various naming conventions used in JSON serialization.
/// Each convention is responsible for converting between different naming styles.

/// The base class for all naming conventions.
/// A naming convention is responsible for converting property names between different styles.
abstract class NamingConvention {
  /// Returns a unique identifier for this convention.
  String get name;

  /// Converts a property name from this convention to camelCase.
  String toCamelCase(String propertyName);

  /// Converts a property name from camelCase to this convention.
  String fromCamelCase(String propertyName);

  /// Checks if a property name matches this convention's pattern.
  bool matches(String propertyName);
}

/// CamelCase naming convention (e.g., firstName, lastName).
/// This is the default Dart convention.
class CamelCaseConvention extends NamingConvention {
  @override
  String get name => 'camelCase';

  @override
  String toCamelCase(String propertyName) => propertyName;

  @override
  String fromCamelCase(String propertyName) => propertyName;

  @override
  bool matches(String propertyName) {
    if (propertyName.isEmpty) return false;
    // Starts with lowercase and may contain uppercase letters (no underscores, hyphens, etc.)
    return RegExp(r'^[a-z][a-zA-Z0-9]*$').hasMatch(propertyName);
  }
}

/// Snake_case naming convention (e.g., first_name, last_name).
/// Common in Python, Ruby, and many REST APIs.
class SnakeCaseConvention extends NamingConvention {
  @override
  String get name => 'snake_case';

  @override
  String toCamelCase(String propertyName) {
    if (propertyName.isEmpty) return propertyName;

    final parts = propertyName.split('_');
    if (parts.length == 1) return propertyName;

    final buffer = StringBuffer(parts[0].toLowerCase());
    for (var i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        buffer.write(parts[i][0].toUpperCase());
        buffer.write(parts[i].substring(1).toLowerCase());
      }
    }
    return buffer.toString();
  }

  @override
  String fromCamelCase(String propertyName) {
    return propertyName.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  @override
  bool matches(String propertyName) {
    if (propertyName.isEmpty) return false;
    // Contains underscores and lowercase letters
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(propertyName);
  }
}

/// PascalCase naming convention (e.g., FirstName, LastName).
/// Common in C#, .NET, and some APIs.
class PascalCaseConvention extends NamingConvention {
  @override
  String get name => 'PascalCase';

  @override
  String toCamelCase(String propertyName) {
    if (propertyName.isEmpty) return propertyName;
    return propertyName[0].toLowerCase() + propertyName.substring(1);
  }

  @override
  String fromCamelCase(String propertyName) {
    if (propertyName.isEmpty) return propertyName;
    return propertyName[0].toUpperCase() + propertyName.substring(1);
  }

  @override
  bool matches(String propertyName) {
    if (propertyName.isEmpty) return false;
    // Starts with uppercase letter
    return RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(propertyName);
  }
}

/// Kebab-case naming convention (e.g., first-name, last-name).
/// Common in URLs, HTML attributes, and some APIs.
class KebabCaseConvention extends NamingConvention {
  @override
  String get name => 'kebab-case';

  @override
  String toCamelCase(String propertyName) {
    if (propertyName.isEmpty) return propertyName;

    final parts = propertyName.split('-');
    if (parts.length == 1) return propertyName;

    final buffer = StringBuffer(parts[0].toLowerCase());
    for (var i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        buffer.write(parts[i][0].toUpperCase());
        buffer.write(parts[i].substring(1).toLowerCase());
      }
    }
    return buffer.toString();
  }

  @override
  String fromCamelCase(String propertyName) {
    return propertyName.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '-${match.group(0)!.toLowerCase()}',
    );
  }

  @override
  bool matches(String propertyName) {
    if (propertyName.isEmpty) return false;
    // Contains hyphens and lowercase letters
    return RegExp(r'^[a-z][a-z0-9\-]*$').hasMatch(propertyName);
  }
}

/// UPPERCASE naming convention (e.g., FIRSTNAME, LASTNAME).
class UpperCaseConvention extends NamingConvention {
  @override
  String get name => 'UPPERCASE';

  @override
  String toCamelCase(String propertyName) {
    return propertyName.toLowerCase();
  }

  @override
  String fromCamelCase(String propertyName) {
    return propertyName.toUpperCase();
  }

  @override
  bool matches(String propertyName) {
    if (propertyName.isEmpty) return false;
    // All uppercase letters
    return RegExp(r'^[A-Z][A-Z0-9]*$').hasMatch(propertyName);
  }
}

/// lowercase naming convention (e.g., firstname, lastname).
class LowerCaseConvention extends NamingConvention {
  @override
  String get name => 'lowercase';

  @override
  String toCamelCase(String propertyName) {
    return propertyName.toLowerCase();
  }

  @override
  String fromCamelCase(String propertyName) {
    return propertyName.toLowerCase();
  }

  @override
  bool matches(String propertyName) {
    if (propertyName.isEmpty) return false;
    // All lowercase letters, no special characters
    return RegExp(r'^[a-z][a-z0-9]*$').hasMatch(propertyName);
  }
}

/// The default naming conventions used by the JSON serializer.
final defaultNamingConventions = <NamingConvention>[
  CamelCaseConvention(),
  SnakeCaseConvention(),
  PascalCaseConvention(),
  KebabCaseConvention(),
  UpperCaseConvention(),
  LowerCaseConvention(),
];
