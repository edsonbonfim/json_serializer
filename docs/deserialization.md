# Deserialization

Deserialization is the process of converting JSON strings into Dart objects. This guide covers how to deserialize JSON using `json_serializer`.

## Basic Deserialization

To deserialize JSON, you need to:

1. Register your types with `JsonSerializerOptions`
2. Use the `deserialize<T>()` function

### Simple Example

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

// Deserialize
var json = '{"name":"John","age":30}';
var person = deserialize<Person>(json);

print(person.name); // John
print(person.age);  // 30
```

## Deserializing Nested Objects

For nested objects, register all types:

```dart
class Address {
  final String street;
  final String city;

  Address({required this.street, required this.city});
}

class Person {
  final String name;
  final Address address;

  Person({required this.name, required this.address});
}

// Register all types
JsonSerializer.options = JsonSerializerOptions(
  types: [
    UserType<Person>(Person.new),
    UserType<Address>(Address.new),
  ],
);

// Deserialize
var json = '{"name":"John","address":{"street":"123 Main St","city":"Sampletown"}}';
var person = deserialize<Person>(json);
```

## Deserializing Collections

### Lists

```dart
class Book {
  final String title;
  final List<String> genres;

  Book({required this.title, required this.genres});
}

JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Book>(Book.new)],
);

var json = '{"title":"The Great Gatsby","genres":["Fiction","Classics"]}';
var book = deserialize<Book>(json);
```

### Maps

```dart
class Product {
  final String name;
  final Map<String, String> attributes;

  Product({required this.name, required this.attributes});
}

JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Product>(Product.new)],
);

var json = '{"name":"Smartphone","attributes":{"Color":"Black","Size":"6 inches"}}';
var product = deserialize<Product>(json);
```

### Complex Collections

```dart
class User {
  final String name;
  final List<Map<String, String>> preferences;

  User({required this.name, required this.preferences});
}

JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<User>(User.new)],
);

var json = '{"name":"John","preferences":[{"key":"theme","value":"dark"}]}';
var user = deserialize<User>(json);
```

## Deserializing Enums

Enums must be registered using `EnumType`:

```dart
enum Gender { male, female, other }

class User {
  final String name;
  final Gender gender;

  User({required this.name, required this.gender});
}

// Register both the class and enum
JsonSerializer.options = JsonSerializerOptions(
  types: [
    UserType<User>(User.new),
    EnumType<Gender>(Gender.values),
  ],
);

var json = '{"name":"John","gender":"male"}';
var user = deserialize<User>(json);
```

## Deserializing Special Types

### DateTime

`DateTime` values are automatically parsed from ISO 8601 strings:

```dart
class Event {
  final String name;
  final DateTime createdAt;

  Event({required this.name, required this.createdAt});
}

JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Event>(Event.new)],
);

var json = '{"name":"Meeting","createdAt":"2023-09-19T15:30:00.000Z"}';
var event = deserialize<Event>(json);
```

### Uri

`Uri` values are automatically parsed from strings:

```dart
class Website {
  final String name;
  final Uri url;

  Website({required this.name, required this.url});
}

JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Website>(Website.new)],
);

var json = '{"name":"Example","url":"https://www.example.com"}';
var website = deserialize<Website>(json);
```

### BigInt

`BigInt` values are automatically parsed from strings:

```dart
class Transaction {
  final String id;
  final BigInt amount;

  Transaction({required this.id, required this.amount});
}

JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Transaction>(Transaction.new)],
);

var json = '{"id":"123","amount":"12345678901234567890"}';
var transaction = deserialize<Transaction>(json);
```

## Nullable Types

Nullable types handle `null` values automatically:

```dart
class Person {
  final String name;
  final int? age; // Nullable

  Person({required this.name, this.age});
}

JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
);

// With age
var json1 = '{"name":"John","age":30}';
var person1 = deserialize<Person>(json1);

// Without age (null)
var json2 = '{"name":"John"}';
var person2 = deserialize<Person>(json2);
```

## Required vs Optional Parameters

The serializer respects Dart's `required` keyword:

```dart
class Person {
  final String name;        // Required
  final int? age;          // Optional (nullable)
  final String? email;     // Optional (nullable)

  Person({
    required this.name,
    this.age,
    this.email,
  });
}

// Valid: name is provided
var json1 = '{"name":"John"}';
var person1 = deserialize<Person>(json1); // OK

// Invalid: name is missing
var json2 = '{"age":30}';
var person2 = deserialize<Person>(json2); // Throws JsonSerializerException
```

## Using Options

You can provide custom options for deserialization:

```dart
var options = JsonSerializerOptions(
  types: [
    UserType<Person>(Person.new),
    EnumType<Gender>(Gender.values),
  ],
  jsonNamingConvention: SnakeCaseConvention(),
);

var json = '{"first_name":"John","age":30}';
var person = deserialize<Person>(json, options);
```

## Error Handling

The deserializer throws `JsonSerializerException` when:

- Required parameters are missing
- Type conversion fails
- Enum values don't match
- Invalid JSON structure

```dart
try {
  var person = deserialize<Person>(json);
} on JsonSerializerException catch (e) {
  print('Deserialization error: ${e.message}');
}
```

## Naming Convention Support

The library automatically handles different naming conventions:

```dart
class Person {
  final String firstName;
  final String lastName;

  Person({required this.firstName, required this.lastName});
}

// Works with snake_case JSON
var json1 = '{"first_name":"John","last_name":"Doe"}';
var person1 = deserialize<Person>(json1);

// Works with PascalCase JSON
var json2 = '{"FirstName":"John","LastName":"Doe"}';
var person2 = deserialize<Person>(json2);

// Works with kebab-case JSON
var json3 = '{"first-name":"John","last-name":"Doe"}';
var person3 = deserialize<Person>(json3);
```

See [Naming Conventions](naming-conventions.md) for more details.

## Best Practices

1. **Register all types**: Make sure all custom types and enums are registered
2. **Use required parameters**: Mark required fields with `required` keyword
3. **Handle nullable types**: Use nullable types (`?`) for optional fields
4. **Error handling**: Always handle `JsonSerializerException` in production code
5. **Type safety**: Use generic type parameter `deserialize<T>()` for type safety

## Common Patterns

### Deserializing Lists of Objects

```dart
class Person {
  final String name;
  final int age;

  Person({required this.name, required this.age});
}

JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
);

var json = '[{"name":"John","age":30},{"name":"Jane","age":25}]';
var people = deserialize<List<Person>>(json);
```

### Deserializing Maps with Object Values

```dart
class User {
  final String name;
  final int age;

  User({required this.name, required this.age});
}

JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<User>(User.new)],
);

var json = '{"user1":{"name":"John","age":30},"user2":{"name":"Jane","age":25}}';
var users = deserialize<Map<String, User>>(json);
```

## See Also

- [Serialization](serialization.md) - Converting Dart objects to JSON
- [Types](types.md) - Understanding UserType, EnumType, and GenericType
- [Naming Conventions](naming-conventions.md) - Property name conversion
- [Options](options.md) - Configuration options
