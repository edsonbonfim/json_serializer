# Serialization

Serialization is the process of converting Dart objects into JSON strings. This guide covers how to serialize objects using `json_serializer`.

## Basic Serialization

To serialize an object, it must implement the `Serializable` interface:

```dart
abstract class Serializable {
  Map<String, dynamic> toMap();
}
```

### Simple Example

```dart
class Person implements Serializable {
  final String name;
  final int age;

  Person({required this.name, required this.age});

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
    };
  }
}

var person = Person(name: 'John', age: 30);
var json = serialize(person);
// {"name":"John","age":30}
```

## Serializing Nested Objects

When your object contains other objects, include them in the `toMap()` method:

```dart
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

class Person implements Serializable {
  final String name;
  final Address address;

  Person({required this.name, required this.address});

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address, // Serializable objects are automatically serialized
    };
  }
}
```

## Serializing Collections

### Lists

```dart
class Book implements Serializable {
  final String title;
  final List<String> genres;

  Book({required this.title, required this.genres});

  @override
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'genres': genres, // Lists are automatically serialized
    };
  }
}
```

### Maps

```dart
class Product implements Serializable {
  final String name;
  final Map<String, dynamic> attributes;

  Product({required this.name, required this.attributes});

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'attributes': attributes, // Maps are automatically serialized
    };
  }
}
```

## Serializing Enums

Enums are automatically serialized to their string names:

```dart
enum Status { active, inactive, pending }

class User implements Serializable {
  final String name;
  final Status status;

  User({required this.name, required this.status});

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status, // Serialized as "active", "inactive", or "pending"
    };
  }
}
```

## Serializing Special Types

### DateTime

`DateTime` objects are automatically serialized to ISO 8601 format:

```dart
class Event implements Serializable {
  final String name;
  final DateTime createdAt;

  Event({required this.name, required this.createdAt});

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': createdAt, // Serialized as ISO 8601 string
    };
  }
}
```

### Uri

`Uri` objects are automatically serialized to their string representation:

```dart
class Website implements Serializable {
  final String name;
  final Uri url;

  Website({required this.name, required this.url});

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url, // Serialized as string
    };
  }
}
```

### BigInt

`BigInt` objects are automatically serialized to strings:

```dart
class Transaction implements Serializable {
  final String id;
  final BigInt amount;

  Transaction({required this.id, required this.amount});

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount, // Serialized as string
    };
  }
}
```

## Nullable Types

Nullable types are handled automatically:

```dart
class Person implements Serializable {
  final String name;
  final int? age; // Nullable

  Person({required this.name, this.age});

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age, // null values are included in JSON
    };
  }
}
```

## Using Options

You can provide custom options for serialization:

```dart
var options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  jsonNamingConvention: SnakeCaseConvention(),
);

var json = serialize(person, options);
```

## Best Practices

1. **Always implement `Serializable`**: This ensures your objects can be serialized
2. **Include all properties**: Make sure `toMap()` includes all properties you want in the JSON
3. **Handle nested objects**: Include nested `Serializable` objects directly in the map
4. **Use consistent naming**: Consider using naming conventions for consistent JSON output

## Common Patterns

### Serializing with Custom Logic

```dart
class User implements Serializable {
  final String firstName;
  final String lastName;
  final DateTime? lastLogin;

  User({
    required this.firstName,
    required this.lastName,
    this.lastLogin,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'fullName': '$firstName $lastName', // Computed property
      'lastLogin': lastLogin?.toIso8601String(), // Custom formatting
    };
  }
}
```

### Conditional Serialization

```dart
class Product implements Serializable {
  final String name;
  final double? price;
  final bool includePrice;

  Product({
    required this.name,
    this.price,
    this.includePrice = true,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = {'name': name};
    if (includePrice && price != null) {
      map['price'] = price;
    }
    return map;
  }
}
```

## See Also

- [Deserialization](deserialization.md) - Converting JSON to Dart objects
- [Naming Conventions](naming-conventions.md) - Property name conversion
- [Options](options.md) - Configuration options
