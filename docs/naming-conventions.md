# Naming Conventions

The `json_serializer` library supports automatic conversion between different naming conventions. This allows you to work with JSON that uses different naming styles (snake_case, PascalCase, etc.) while keeping your Dart code in camelCase.

## Built-in Conventions

The library provides several built-in naming conventions:

### CamelCase

Default Dart convention (e.g., `firstName`, `lastName`):

```dart
var convention = CamelCaseConvention();
var json = '{"firstName":"John","lastName":"Doe"}';
```

### SnakeCase

Common in Python and REST APIs (e.g., `first_name`, `last_name`):

```dart
var convention = SnakeCaseConvention();
var json = '{"first_name":"John","last_name":"Doe"}';
```

### PascalCase

Common in C# and .NET (e.g., `FirstName`, `LastName`):

```dart
var convention = PascalCaseConvention();
var json = '{"FirstName":"John","LastName":"Doe"}';
```

### KebabCase

Common in URLs and HTML (e.g., `first-name`, `last-name`):

```dart
var convention = KebabCaseConvention();
var json = '{"first-name":"John","last-name":"Doe"}';
```

### UPPERCASE

All uppercase (e.g., `FIRSTNAME`, `LASTNAME`):

```dart
var convention = UpperCaseConvention();
var json = '{"FIRSTNAME":"John","LASTNAME":"Doe"}';
```

### lowercase

All lowercase (e.g., `firstname`, `lastname`):

```dart
var convention = LowerCaseConvention();
var json = '{"firstname":"John","lastname":"Doe"}';
```

## Auto-Detection

The library can automatically detect the naming convention used in JSON:

```dart
class Person {
  final String firstName;
  final String lastName;

  Person({required this.firstName, required this.lastName});
}

JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  // No explicit convention - will auto-detect
);

// Works with snake_case
var json1 = '{"first_name":"John","last_name":"Doe"}';
var person1 = deserialize<Person>(json1);

// Works with PascalCase
var json2 = '{"FirstName":"John","LastName":"Doe"}';
var person2 = deserialize<Person>(json2);

// Works with kebab-case
var json3 = '{"first-name":"John","last-name":"Doe"}';
var person3 = deserialize<Person>(json3);
```

## Explicit Convention

You can specify the JSON naming convention explicitly:

```dart
var options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  jsonNamingConvention: SnakeCaseConvention(),
);

var json = '{"first_name":"John","last_name":"Doe"}';
var person = deserialize<Person>(json, options);
```

## Custom Conventions

You can create custom naming conventions by extending `NamingConvention`:

```dart
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

// Use custom convention
var options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  namingConventions: [CustomPrefixConvention('api_')],
  jsonNamingConvention: CustomPrefixConvention('api_'),
);

var json = '{"api_firstName":"John","api_lastName":"Doe"}';
var person = deserialize<Person>(json, options);
```

## How It Works

### Deserialization (JSON → Dart)

1. The library receives JSON with property names in any convention
2. It tries to match JSON keys to Dart parameter names:
   - First, exact match (e.g., `firstName` → `firstName`)
   - Then, using the configured `jsonNamingConvention`
   - Finally, trying all available `namingConventions`
3. When a match is found, the value is extracted and converted

### Serialization (Dart → JSON)

1. Dart properties are in camelCase (by convention)
2. The library converts them using `jsonNamingConvention` or defaults to camelCase
3. The converted names are used as JSON keys

## Configuration

### Setting Default Conventions

```dart
var options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  namingConventions: [
    SnakeCaseConvention(),
    PascalCaseConvention(),
    KebabCaseConvention(),
  ],
);
```

### Setting JSON Convention

```dart
var options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  jsonNamingConvention: SnakeCaseConvention(),
);
```

## Examples

### Working with REST APIs

Many REST APIs use snake_case:

```dart
class User {
  final String firstName;
  final String lastName;
  final String emailAddress;

  User({
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
  });
}

var options = JsonSerializerOptions(
  types: [UserType<User>(User.new)],
  jsonNamingConvention: SnakeCaseConvention(),
);

// API returns snake_case
var apiJson = '{"first_name":"John","last_name":"Doe","email_address":"john@example.com"}';
var user = deserialize<User>(apiJson, options);

// Serialize back to snake_case
var json = serialize(user, options);
// {"first_name":"John","last_name":"Doe","email_address":"john@example.com"}
```

### Working with .NET APIs

.NET APIs often use PascalCase:

```dart
var options = JsonSerializerOptions(
  types: [UserType<User>(User.new)],
  jsonNamingConvention: PascalCaseConvention(),
);

var apiJson = '{"FirstName":"John","LastName":"Doe"}';
var user = deserialize<User>(apiJson, options);
```

### Mixed Conventions

You can support multiple conventions:

```dart
var options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  namingConventions: [
    SnakeCaseConvention(),
    PascalCaseConvention(),
    KebabCaseConvention(),
  ],
);

// All of these work:
var json1 = '{"first_name":"John"}';      // snake_case
var json2 = '{"FirstName":"John"}';        // PascalCase
var json3 = '{"first-name":"John"}';      // kebab-case
```

## Best Practices

1. **Use auto-detection when possible**: Let the library detect the convention automatically
2. **Specify convention for APIs**: If you know the API's convention, specify it explicitly
3. **Create custom conventions**: For APIs with unique naming patterns, create custom conventions
4. **Keep Dart code in camelCase**: Follow Dart conventions in your code, let the library handle conversion

## Implementation Details

### Matching Algorithm

The library uses a scoring system to detect conventions:

1. For each property name in the JSON, it checks all available conventions
2. Each convention that matches gets a score
3. The convention with the highest score is used

### Conversion Methods

Each convention implements:

- `toCamelCase(String)`: Converts from convention to camelCase
- `fromCamelCase(String)`: Converts from camelCase to convention
- `matches(String)`: Checks if a property name matches the convention pattern

## See Also

- [Deserialization](deserialization.md) - Using naming conventions in deserialization
- [Serialization](serialization.md) - Using naming conventions in serialization
- [Options](options.md) - Configuration options
