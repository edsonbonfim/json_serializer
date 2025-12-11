/// This file contains the implementation of various naming conventions used in JSON serialization.
/// Each convention is responsible for converting between different naming styles.

/// The base class for all naming conventions.
///
/// A naming convention is responsible for converting property names between different styles,
/// such as camelCase, snake_case, PascalCase, etc.
abstract class NamingConvention {
  /// Returns a unique identifier for this convention.
  ///
  /// @returns The name of the convention (e.g., 'camelCase', 'snake_case').
  String get name;

  /// Converts a property name from this convention to camelCase.
  ///
  /// @param [propertyName] The property name in this convention's format.
  /// @returns The property name converted to camelCase.
  String toCamelCase(String propertyName);

  /// Converts a property name from camelCase to this convention.
  ///
  /// @param [propertyName] The property name in camelCase format.
  /// @returns The property name converted to this convention's format.
  String fromCamelCase(String propertyName);

  /// Checks if a property name matches this convention's pattern.
  ///
  /// @param [propertyName] The property name to check.
  /// @returns True if the property name matches this convention's pattern, false otherwise.
  bool matches(String propertyName);
}

/// CamelCase naming convention (e.g., firstName, lastName).
///
/// This is the default Dart convention where the first letter is lowercase
/// and subsequent words start with uppercase.
class CamelCaseConvention extends NamingConvention {
  static const String _conventionName = 'camelCase';
  static final RegExp _camelCasePattern = RegExp(r'^[a-z][a-zA-Z0-9]*$');

  @override
  String get name => _conventionName;

  @override
  String toCamelCase(String propertyName) => propertyName;

  @override
  String fromCamelCase(String propertyName) => propertyName;

  @override
  bool matches(String propertyName) {
    if (propertyName.isEmpty) return false;
    return _camelCasePattern.hasMatch(propertyName);
  }
}

/// Snake_case naming convention (e.g., first_name, last_name).
///
/// Common in Python, Ruby, and many REST APIs. Words are separated by underscores
/// and typically written in lowercase.
class SnakeCaseConvention extends NamingConvention {
  static const String _conventionName = 'snake_case';
  static const String _separator = '_';
  static const int _minimumParts = 1;
  static final RegExp _snakeCasePattern = RegExp(r'^[a-z][a-z0-9_]*$');

  @override
  String get name => _conventionName;

  @override
  String toCamelCase(String propertyName) {
    if (propertyName.isEmpty) return propertyName;

    final parts = propertyName.split(_separator);
    if (parts.length == _minimumParts) return propertyName;

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
    if (propertyName.isEmpty) return propertyName;
    
    final codeUnits = propertyName.codeUnits;
    final buffer = StringBuffer();
    final separatorCode = _separator.codeUnitAt(0);
    
    for (var i = 0; i < codeUnits.length; i++) {
      final codeUnit = codeUnits[i];
      // Check if uppercase (A-Z: 65-90)
      if (codeUnit >= 65 && codeUnit <= 90) {
        if (i > 0) {
          buffer.writeCharCode(separatorCode);
        }
        // Convert to lowercase
        buffer.writeCharCode(codeUnit + 32);
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    
    return buffer.toString();
  }

  @override
  bool matches(String propertyName) {
    if (propertyName.isEmpty) return false;
    return _snakeCasePattern.hasMatch(propertyName);
  }
}

/// PascalCase naming convention (e.g., FirstName, LastName).
///
/// Common in C#, .NET, and some APIs. Similar to camelCase but starts with an uppercase letter.
class PascalCaseConvention extends NamingConvention {
  static const String _conventionName = 'PascalCase';
  static const int _firstCharacterIndex = 0;
  static final RegExp _pascalCasePattern = RegExp(r'^[A-Z][a-zA-Z0-9]*$');

  @override
  String get name => _conventionName;

  @override
  String toCamelCase(String propertyName) {
    if (propertyName.isEmpty) return propertyName;
    return propertyName[_firstCharacterIndex].toLowerCase() +
        propertyName.substring(1);
  }

  @override
  String fromCamelCase(String propertyName) {
    if (propertyName.isEmpty) return propertyName;
    return propertyName[_firstCharacterIndex].toUpperCase() +
        propertyName.substring(1);
  }

  @override
  bool matches(String propertyName) {
    if (propertyName.isEmpty) return false;
    return _pascalCasePattern.hasMatch(propertyName);
  }
}

/// Kebab-case naming convention (e.g., first-name, last-name).
///
/// Common in URLs, HTML attributes, and some APIs. Words are separated by hyphens
/// and typically written in lowercase.
class KebabCaseConvention extends NamingConvention {
  static const String _conventionName = 'kebab-case';
  static const String _separator = '-';
  static const int _minimumParts = 1;
  static final RegExp _kebabCasePattern = RegExp(r'^[a-z][a-z0-9\-]*$');

  @override
  String get name => _conventionName;

  @override
  String toCamelCase(String propertyName) {
    if (propertyName.isEmpty) return propertyName;

    final parts = propertyName.split(_separator);
    if (parts.length == _minimumParts) return propertyName;

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
    if (propertyName.isEmpty) return propertyName;
    
    final codeUnits = propertyName.codeUnits;
    final buffer = StringBuffer();
    final separatorCode = _separator.codeUnitAt(0);
    
    for (var i = 0; i < codeUnits.length; i++) {
      final codeUnit = codeUnits[i];
      // Check if uppercase (A-Z: 65-90)
      if (codeUnit >= 65 && codeUnit <= 90) {
        if (i > 0) {
          buffer.writeCharCode(separatorCode);
        }
        // Convert to lowercase
        buffer.writeCharCode(codeUnit + 32);
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    
    return buffer.toString();
  }

  @override
  bool matches(String propertyName) {
    if (propertyName.isEmpty) return false;
    return _kebabCasePattern.hasMatch(propertyName);
  }
}

/// UPPERCASE naming convention (e.g., FIRSTNAME, LASTNAME).
///
/// All characters are uppercase letters and numbers.
class UpperCaseConvention extends NamingConvention {
  static const String _conventionName = 'UPPERCASE';
  static final RegExp _uppercasePattern = RegExp(r'^[A-Z][A-Z0-9]*$');

  @override
  String get name => _conventionName;

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
    return _uppercasePattern.hasMatch(propertyName);
  }
}

/// lowercase naming convention (e.g., firstname, lastname).
///
/// All characters are lowercase letters and numbers, with no separators.
class LowerCaseConvention extends NamingConvention {
  static const String _conventionName = 'lowercase';
  static final RegExp _lowercasePattern = RegExp(r'^[a-z][a-z0-9]*$');

  @override
  String get name => _conventionName;

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
    return _lowercasePattern.hasMatch(propertyName);
  }
}

/// The default naming conventions used by the JSON serializer.
///
/// These conventions are tried in order when auto-detecting the naming convention
/// from a JSON object.
final defaultNamingConventions = <NamingConvention>[
  CamelCaseConvention(),
  SnakeCaseConvention(),
  PascalCaseConvention(),
  KebabCaseConvention(),
  UpperCaseConvention(),
  LowerCaseConvention(),
];
