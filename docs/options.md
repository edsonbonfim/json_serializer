# Options

`JsonSerializerOptions` provides configuration for the JSON serializer. This guide covers all available options and how to use them.

## Basic Configuration

```dart
var options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  converters: [],
  namingConventions: [],
  jsonNamingConvention: null,
);
```

## Properties

### `types`

List of registered types (UserType and EnumType):

```dart
var options = JsonSerializerOptions(
  types: [
    UserType<Person>(Person.new),
    UserType<Address>(Address.new),
    EnumType<Gender>(Gender.values),
  ],
);
```

### `converters`

List of custom converters:

```dart
var options = JsonSerializerOptions(
  converters: [
    CustomDateConverter(),
    TrimmedStringConverter(),
  ],
);
```

### `namingConventions`

List of naming conventions for auto-detection:

```dart
var options = JsonSerializerOptions(
  namingConventions: [
    SnakeCaseConvention(),
    PascalCaseConvention(),
    KebabCaseConvention(),
  ],
);
```

Defaults to all built-in conventions if not specified.

### `jsonNamingConvention`

Explicit naming convention for JSON property names:

```dart
var options = JsonSerializerOptions(
  jsonNamingConvention: SnakeCaseConvention(),
);
```

If `null`, the convention is auto-detected from the JSON structure.

## Global Options

Set global options that apply to all operations:

```dart
JsonSerializer.options = JsonSerializerOptions(
  types: [
    UserType<Person>(Person.new),
    EnumType<Gender>(Gender.values),
  ],
  jsonNamingConvention: SnakeCaseConvention(),
);

// All operations use these options
var person = deserialize<Person>(json);
var jsonString = serialize(person);
```

## Per-Operation Options

Provide options for specific operations:

```dart
var options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  jsonNamingConvention: PascalCaseConvention(),
);

var person = deserialize<Person>(json, options);
var jsonString = serialize(person, options);
```

## Merging Options

Options can be merged, with the provided options taking precedence:

```dart
var baseOptions = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  jsonNamingConvention: SnakeCaseConvention(),
);

var extendedOptions = JsonSerializerOptions(
  types: [UserType<Address>(Address.new)],
  jsonNamingConvention: PascalCaseConvention(),
);

var merged = baseOptions.merge(extendedOptions);
// Contains: Person, Address types
// Uses: PascalCaseConvention (from extendedOptions)
```

## Methods

### `merge(JsonSerializerOptions?)`

Merges the current options with provided options:

```dart
var merged = baseOptions.merge(extendedOptions);
```

### `getConverter(TypeInfo)`

Retrieves the appropriate converter for a type:

```dart
var type = DartParser.parseType('String');
var converter = options.getConverter(type);
```

### `getGenericType(TypeInfo)`

Retrieves the appropriate generic type for a type:

```dart
var type = DartParser.parseType('Person');
var genericType = options.getGenericType(type);
```

### `detectNamingConvention(Map)`

Detects the naming convention used in a JSON object:

```dart
var json = {'first_name': 'John', 'last_name': 'Doe'};
var convention = options.detectNamingConvention(json);
// Returns SnakeCaseConvention
```

### `convertFromJson(String, Map)`

Converts a JSON property name to camelCase:

```dart
var json = {'first_name': 'John'};
var camelCase = options.convertFromJson('first_name', json);
// Returns 'firstName'
```

### `convertToJson(String)`

Converts a camelCase property name to the JSON naming convention:

```dart
var jsonName = options.convertToJson('firstName');
// Returns 'first_name' if jsonNamingConvention is SnakeCaseConvention
```

## Common Patterns

### Setting Up for an API

```dart
// Configure for a REST API that uses snake_case
var apiOptions = JsonSerializerOptions(
  types: [
    UserType<User>(User.new),
    UserType<Post>(Post.new),
    EnumType<Status>(Status.values),
  ],
  jsonNamingConvention: SnakeCaseConvention(),
);

// Use for all API operations
var user = deserialize<User>(apiJson, apiOptions);
var responseJson = serialize(user, apiOptions);
```

### Multiple API Support

```dart
// Base options
var baseOptions = JsonSerializerOptions(
  types: [
    UserType<User>(User.new),
    EnumType<Status>(Status.values),
  ],
);

// API 1: snake_case
var api1Options = baseOptions.merge(JsonSerializerOptions(
  jsonNamingConvention: SnakeCaseConvention(),
));

// API 2: PascalCase
var api2Options = baseOptions.merge(JsonSerializerOptions(
  jsonNamingConvention: PascalCaseConvention(),
));
```

### Development vs Production

```dart
// Development: Auto-detect conventions
var devOptions = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
);

// Production: Explicit convention
var prodOptions = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  jsonNamingConvention: SnakeCaseConvention(),
);
```

## Best Practices

1. **Set global options**: Use `JsonSerializer.options` for app-wide configuration
2. **Use per-operation options**: Override options for specific operations when needed
3. **Merge options**: Use `merge()` to extend base configurations
4. **Explicit conventions**: Specify `jsonNamingConvention` when you know the API's convention
5. **Group related types**: Register related types together for better organization

## Default Values

If not specified, options use these defaults:

- **types**: Empty list `[]`
- **converters**: Empty list `[]` (uses built-in converters)
- **namingConventions**: All built-in conventions
- **jsonNamingConvention**: `null` (auto-detected)

## See Also

- [Types](types.md) - Type registration
- [Naming Conventions](naming-conventions.md) - Naming convention configuration
- [Converters](converters.md) - Custom converter configuration
- [Advanced Usage](advanced.md) - Complex configuration scenarios
