# Types

The `json_serializer` library uses a type system to handle serialization and deserialization. This guide covers the different types you can use.

## UserType

`UserType` is used to register custom classes (non-enum types) with the serializer.

### Basic Usage

```dart
class Person {
  final String name;
  final int age;

  Person({required this.name, required this.age});
}

// Register the type
JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
);
```

### How It Works

`UserType` takes a constructor function (typically `ClassName.new`) and uses it to create instances during deserialization. The serializer:

1. Parses the JSON into a map
2. Extracts parameter names from the constructor
3. Matches JSON keys to parameter names (with naming convention conversion)
4. Calls the constructor with the matched values

### Constructor Requirements

The constructor must use **named parameters**:

```dart
// ✅ Good: Named parameters
class Person {
  final String name;
  final int age;

  Person({required this.name, required this.age});
}

// ❌ Bad: Positional parameters won't work
class Person {
  final String name;
  final int age;

  Person(this.name, this.age); // Not supported
}
```

### Required vs Optional Parameters

```dart
class Person {
  final String name;        // Required
  final int? age;          // Optional (nullable)
  final String? email;     // Optional (nullable)

  Person({
    required this.name,     // Must be in JSON
    this.age,              // Optional in JSON
    this.email,            // Optional in JSON
  });
}
```

## EnumType

`EnumType` is used to register enum types with the serializer.

### Basic Usage

```dart
enum Gender { male, female, other }

// Register the enum
JsonSerializer.options = JsonSerializerOptions(
  types: [EnumType<Gender>(Gender.values)],
);
```

### Deserialization

Enums are deserialized from their string names:

```dart
var json = '{"gender":"male"}';
var gender = deserialize<Gender>(json); // Gender.male
```

### Serialization

Enums are serialized to their string names:

```dart
var gender = Gender.male;
var json = serialize(gender); // "male"
```

### Invalid Enum Values

If the JSON contains an invalid enum value, a `JsonSerializerException` is thrown:

```dart
var json = '{"gender":"unknown"}';
var gender = deserialize<Gender>(json); // Throws JsonSerializerException
```

## GenericType

`GenericType` is the base class for `UserType` and `EnumType`. It provides utilities for working with generic types.

### Methods

#### `createList()`

Creates an empty list of type `T`:

```dart
var userType = UserType<Person>(Person.new);
var list = userType.createList(); // List<Person>()
```

#### `createMapOfT()`

Creates an empty map with `String` keys and `T` values:

```dart
var userType = UserType<Person>(Person.new);
var map = userType.createMapOfT(); // Map<String, Person>()
```

#### `createMapOfNullableT()`

Creates an empty map with `String` keys and nullable `T` values:

```dart
var userType = UserType<Person>(Person.new);
var map = userType.createMapOfNullableT(); // Map<String, Person?>()
```

#### `createListOfMapOfT()`

Creates an empty list of maps:

```dart
var userType = UserType<Person>(Person.new);
var list = userType.createListOfMapOfT(); // List<Map<String, Person>>()
```

#### `createMapOfListOfT()`

Creates an empty map with `List<T>` values:

```dart
var userType = UserType<Person>(Person.new);
var map = userType.createMapOfListOfT(); // Map<String, List<Person>>()
```

#### `createMapOfListOfNullableT()`

Creates an empty map with nullable `List<T>` values:

```dart
var userType = UserType<Person>(Person.new);
var map = userType.createMapOfListOfNullableT(); // Map<String, List<Person>?>
```

## Type Registration

### Global Registration

Register types globally using `JsonSerializer.options`:

```dart
JsonSerializer.options = JsonSerializerOptions(
  types: [
    UserType<Person>(Person.new),
    UserType<Address>(Address.new),
    EnumType<Gender>(Gender.values),
  ],
);
```

### Per-Operation Registration

Register types for a specific operation:

```dart
var options = JsonSerializerOptions(
  types: [
    UserType<Person>(Person.new),
    EnumType<Gender>(Gender.values),
  ],
);

var person = deserialize<Person>(json, options);
```

### Merging Options

Options can be merged:

```dart
var baseOptions = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
);

var extendedOptions = JsonSerializerOptions(
  types: [UserType<Address>(Address.new)],
);

var merged = baseOptions.merge(extendedOptions);
// Contains both Person and Address types
```

## Type Information

The library uses `TypeInfo` internally to represent type information:

- **Type name**: The name of the type (e.g., "Person", "String")
- **Nullability**: Whether the type is nullable (`String?`)
- **Generics**: Generic type arguments (e.g., `List<String>`)
- **Flags**: Whether the type is a Map, List, or generic type

## Built-in Types

The following types are supported out of the box and don't need registration:

- **Primitives**: `String`, `int`, `double`, `num`, `bool`
- **Collections**: `List<T>`, `Map<String, T>`
- **Special Types**: `DateTime`, `Uri`, `BigInt`
- **Nullable Variants**: All types support nullable variants

## Type Conversion

The library automatically converts between JSON types and Dart types:

| JSON Type | Dart Type | Converter |
|-----------|-----------|-----------|
| `string` | `String` | `StringConverter` |
| `number` | `int` | `IntConverter` |
| `number` | `double` | `DoubleConverter` |
| `number` | `num` | `NumConverter` |
| `boolean` | `bool` | `BoolConverter` |
| `string` (ISO 8601) | `DateTime` | `DateTimeConverter` |
| `string` | `Uri` | `UriConverter` |
| `string` | `BigInt` | `BigIntConverter` |
| `array` | `List<T>` | `ListConverter` |
| `object` | `Map<String, T>` | `MapConverter` |

## Best Practices

1. **Register all custom types**: Always register custom classes and enums
2. **Use named parameters**: Constructors must use named parameters
3. **Mark required fields**: Use `required` keyword for required parameters
4. **Use nullable types**: Use `?` for optional fields
5. **Group related types**: Register related types together for better organization

## Common Patterns

### Registering Multiple Types

```dart
JsonSerializer.options = JsonSerializerOptions(
  types: [
    // User types
    UserType<Person>(Person.new),
    UserType<Address>(Address.new),
    UserType<Company>(Company.new),
    
    // Enums
    EnumType<Gender>(Gender.values),
    EnumType<Status>(Status.values),
  ],
);
```

### Type-Safe Deserialization

```dart
// Type-safe: Returns Person
var person = deserialize<Person>(json);

// Type-safe: Returns List<Person>
var people = deserialize<List<Person>>(json);

// Type-safe: Returns Map<String, Person>
var peopleMap = deserialize<Map<String, Person>>(json);
```

## See Also

- [Deserialization](deserialization.md) - Using types for deserialization
- [Serialization](serialization.md) - Using types for serialization
- [Converters](converters.md) - Custom type converters
- [Options](options.md) - Configuration options
