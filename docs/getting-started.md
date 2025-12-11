# Getting Started

This guide will help you get started with `json_serializer` in your Dart project.

## Installation

Add `json_serializer` to your `pubspec.yaml` file:

```yaml
dependencies:
  json_serializer: ^0.3.1
```

Then run:

```bash
dart pub get
```

## Import

Import the package in your Dart file:

```dart
import 'package:json_serializer/json_serializer.dart';
```

## Basic Example

### Step 1: Define Your Classes

```dart
class Person {
  final String name;
  final int age;
  final Address address;

  Person({required this.name, required this.age, required this.address});
}

class Address {
  final String street;
  final String city;

  Address({required this.street, required this.city});
}
```

### Step 2: Register Types

Before deserializing, you need to register all custom types and enums:

```dart
JsonSerializer.options = JsonSerializerOptions(
  types: [
    UserType<Person>(Person.new),
    UserType<Address>(Address.new),
  ],
);
```

### Step 3: Deserialize JSON

```dart
var json = '{"name":"John","age":30,"address":{"street":"123 Main St","city":"Sampletown"}}';
var person = deserialize<Person>(json);

print('Name: ${person.name}');
print('Age: ${person.age}');
print('Street: ${person.address.street}');
print('City: ${person.address.city}');
```

### Step 4: Serialize Objects

To serialize objects, your classes must implement the `Serializable` interface:

```dart
class Person implements Serializable {
  final String name;
  final int age;
  final Address address;

  Person({required this.name, required this.age, required this.address});

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'address': address,
    };
  }
}

class Address implements Serializable {
  final String street;
  final String city;

  Address({required this.street, required this.city});

  @override
  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
    };
  }
}
```

Then you can serialize:

```dart
var person = Person(
  name: 'John',
  age: 30,
  address: Address(street: '123 Main St', city: 'Sampletown'),
);

var jsonString = serialize(person);
print(jsonString);
// {"name":"John","age":30,"address":{"street":"123 Main St","city":"Sampletown"}}
```

## Working with Enums

Enums are supported and must be registered:

```dart
enum Gender { male, female, other }

class User {
  final String name;
  final Gender gender;

  User({required this.name, required this.gender});
}

// Register enum
JsonSerializer.options = JsonSerializerOptions(
  types: [
    UserType<User>(User.new),
    EnumType<Gender>(Gender.values),
  ],
);

// Deserialize
var json = '{"name":"John","gender":"male"}';
var user = deserialize<User>(json);
```

## Supported Types

The library supports many built-in types out of the box:

- **Primitives**: `String`, `int`, `double`, `num`, `bool`
- **Collections**: `List<T>`, `Map<String, T>`
- **Special Types**: `DateTime`, `Uri`, `BigInt`
- **Nullable Types**: All types support nullable variants (e.g., `String?`, `int?`)

## Next Steps

- Learn about [Serialization](serialization.md) in detail
- Explore [Deserialization](deserialization.md) features
- Understand [Naming Conventions](naming-conventions.md) for property name conversion
- Check out [Advanced Usage](advanced.md) for complex scenarios
