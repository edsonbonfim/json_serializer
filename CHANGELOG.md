# Changelog

All release notes for the `json_serializer` library will be documented on this page.

## [0.3.0] - 2025-12-10

### Added

- **Naming Conventions API**: Extensible system for conversion between different naming conventions (camelCase, snake_case, PascalCase, kebab-case, UPPERCASE, lowercase).
- Auto-detection of naming conventions in JSON objects.
- Built-in naming conventions: `CamelCaseConvention`, `SnakeCaseConvention`, `PascalCaseConvention`, `KebabCaseConvention`, `UpperCaseConvention`, `LowerCaseConvention`.
- Abstract class `NamingConvention` for creating custom conventions.
- Support for Dart properties in different naming conventions (not just camelCase).
- Bidirectional conversion: JSON in any case ↔ Dart properties in any case.
- `namingConventions` and `jsonNamingConvention` properties in `JsonSerializerOptions`.
- Intelligent property name normalization algorithm.

### Fixed

- Issue #1: Support for tree-structured data with recursive nested objects.
- Issue #2: Automatic conversion between different naming conventions (snake_case, PascalCase, etc.).
- Parameter matching now works when Dart properties use different naming conventions than JSON.

### Changed

- `JsonSerializerOptions` now accepts a list of naming conventions.
- `GenericTypeConverter` updated to use the naming conventions system.
- Property lookup algorithm improved with exact match first, then convention-based fallback.

## [0.2.0] - 2023-09-19

### Added

- JSON serialization functionality.

## [0.1.0] - 2023-09-19

### Added

- JSON deserialization functionality.
- Support for deserialization of nested objects.
- Ability to customize deserialization with user-defined types.
- `JsonConversionException` exception for handling JSON conversion errors.
