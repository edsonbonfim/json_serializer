# Advanced Usage

This guide covers advanced scenarios and best practices for using `json_serializer`.

## Complex Nested Structures

### Deep Nesting

```dart
class Company {
  final String name;
  final Address headquarters;
  final List<Department> departments;

  Company({
    required this.name,
    required this.headquarters,
    required this.departments,
  });
}

class Department {
  final String name;
  final Manager manager;
  final List<Employee> employees;

  Department({
    required this.name,
    required this.manager,
    required this.employees,
  });
}

class Manager {
  final String name;
  final Employee? assistant;

  Manager({required this.name, this.assistant});
}

class Employee {
  final String name;
  final int age;

  Employee({required this.name, required this.age});
}

// Register all types
JsonSerializer.options = JsonSerializerOptions(
  types: [
    UserType<Company>(Company.new),
    UserType<Department>(Department.new),
    UserType<Manager>(Manager.new),
    UserType<Employee>(Employee.new),
    UserType<Address>(Address.new),
  ],
);
```

### Recursive Structures

The library handles recursive structures automatically:

```dart
class TreeNode {
  final String value;
  final List<TreeNode> children;

  TreeNode({required this.value, required this.children});
}

JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<TreeNode>(TreeNode.new)],
);

var json = '{"value":"root","children":[{"value":"child1","children":[]}]}';
var tree = deserialize<TreeNode>(json);
```

## Generic Types

### Working with Generics

```dart
class Response<T> {
  final bool success;
  final T? data;
  final String? error;

  Response({
    required this.success,
    this.data,
    this.error,
  });
}

// Note: Generic types need special handling
// You may need to register specific instantiations
```

### Type Parameters

When working with generic types, register concrete instantiations:

```dart
class Box<T> {
  final T value;

  Box({required this.value});
}

// Register specific types
JsonSerializer.options = JsonSerializerOptions(
  types: [
    UserType<Box<String>>(Box<String>.new),
    UserType<Box<int>>(Box<int>.new),
  ],
);
```

## Custom Serialization Logic

### Computed Properties

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
      'fullName': '$firstName $lastName',
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': lastLogin != null && 
                  DateTime.now().difference(lastLogin!).inDays < 30,
    };
  }
}
```

### Conditional Serialization

```dart
class Product implements Serializable {
  final String name;
  final double price;
  final bool includePrice;

  Product({
    required this.name,
    required this.price,
    this.includePrice = true,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = {'name': name};
    if (includePrice) {
      map['price'] = price;
    }
    return map;
  }
}
```

## Error Handling Strategies

### Try-Catch Blocks

```dart
try {
  var person = deserialize<Person>(json);
  // Process person
} on JsonSerializerException catch (e) {
  print('Deserialization error: ${e.message}');
  // Handle error
} catch (e) {
  print('Unexpected error: $e');
  // Handle unexpected error
}
```

### Validation

```dart
class Person {
  final String name;
  final int age;

  Person({required this.name, required this.age}) {
    if (age < 0) {
      throw ArgumentError('Age cannot be negative');
    }
  }
}
```

## Performance Optimization

### Caching Options

```dart
// Create options once and reuse
final appOptions = JsonSerializerOptions(
  types: [
    UserType<Person>(Person.new),
    UserType<Address>(Address.new),
  ],
  jsonNamingConvention: SnakeCaseConvention(),
);

// Reuse for all operations
var person1 = deserialize<Person>(json1, appOptions);
var person2 = deserialize<Person>(json2, appOptions);
```

### Type Registration

Register all types upfront to avoid repeated registration:

```dart
// Do this once at app startup
JsonSerializer.options = JsonSerializerOptions(
  types: [
    // All your types
  ],
);
```

## Working with APIs

### REST API Integration

```dart
class ApiClient {
  final JsonSerializerOptions options;

  ApiClient() : options = JsonSerializerOptions(
    types: [
      UserType<User>(User.new),
      UserType<Post>(Post.new),
    ],
    jsonNamingConvention: SnakeCaseConvention(),
  );

  Future<User> getUser(String id) async {
    var response = await http.get(Uri.parse('/users/$id'));
    return deserialize<User>(response.body, options);
  }

  Future<String> createUser(User user) async {
    var json = serialize(user, options);
    var response = await http.post(
      Uri.parse('/users'),
      body: json,
      headers: {'Content-Type': 'application/json'},
    );
    return response.body;
  }
}
```

### Multiple API Support

```dart
class MultiApiClient {
  final JsonSerializerOptions api1Options;
  final JsonSerializerOptions api2Options;

  MultiApiClient()
      : api1Options = JsonSerializerOptions(
          types: [UserType<User>(User.new)],
          jsonNamingConvention: SnakeCaseConvention(),
        ),
        api2Options = JsonSerializerOptions(
          types: [UserType<User>(User.new)],
          jsonNamingConvention: PascalCaseConvention(),
        );

  Future<User> getUserFromApi1(String id) async {
    var response = await http.get(Uri.parse('https://api1.com/users/$id'));
    return deserialize<User>(response.body, api1Options);
  }

  Future<User> getUserFromApi2(String id) async {
    var response = await http.get(Uri.parse('https://api2.com/users/$id'));
    return deserialize<User>(response.body, api2Options);
  }
}
```

## Testing

### Unit Tests

```dart
void main() {
  setUp(() {
    JsonSerializer.options = JsonSerializerOptions(
      types: [
        UserType<Person>(Person.new),
        EnumType<Gender>(Gender.values),
      ],
    );
  });

  test('deserializes valid JSON', () {
    var json = '{"name":"John","age":30}';
    var person = deserialize<Person>(json);
    expect(person.name, equals('John'));
    expect(person.age, equals(30));
  });

  test('throws on invalid JSON', () {
    var json = '{"name":"John"}';
    expect(
      () => deserialize<Person>(json),
      throwsA(isA<JsonSerializerException>()),
    );
  });
}
```

### Integration Tests

```dart
void main() {
  group('API Integration', () {
    test('deserializes API response', () async {
      var options = JsonSerializerOptions(
        types: [UserType<User>(User.new)],
        jsonNamingConvention: SnakeCaseConvention(),
      );

      var apiJson = '{"first_name":"John","last_name":"Doe"}';
      var user = deserialize<User>(apiJson, options);

      expect(user.firstName, equals('John'));
      expect(user.lastName, equals('Doe'));
    });
  });
}
```

## Migration Strategies

### From Other Libraries

If migrating from `json_serializable`:

1. Remove `@JsonSerializable` annotations
2. Implement `Serializable` interface
3. Register types with `UserType`
4. Update naming conventions if needed

### Incremental Migration

You can use both libraries during migration:

```dart
// Old code
var person = Person.fromJson(jsonDecode(jsonString));

// New code
var person = deserialize<Person>(jsonString);
```

## Best Practices

1. **Register types early**: Set up types at app startup
2. **Use explicit conventions**: Specify conventions when you know them
3. **Handle errors gracefully**: Always catch `JsonSerializerException`
4. **Reuse options**: Create options once and reuse them
5. **Test edge cases**: Test with null, empty, and invalid data
6. **Document custom converters**: Document any custom converters you create
7. **Keep types simple**: Prefer simple constructors with named parameters

## Common Pitfalls

### Missing Type Registration

```dart
// ❌ Missing Address registration
JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
);

// ✅ Register all types
JsonSerializer.options = JsonSerializerOptions(
  types: [
    UserType<Person>(Person.new),
    UserType<Address>(Address.new),
  ],
);
```

### Wrong Naming Convention

```dart
// ❌ API uses snake_case but convention not set
var person = deserialize<Person>(apiJson);

// ✅ Set correct convention
var options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  jsonNamingConvention: SnakeCaseConvention(),
);
var person = deserialize<Person>(apiJson, options);
```

### Positional Parameters

```dart
// ❌ Positional parameters not supported
class Person {
  Person(this.name, this.age);
}

// ✅ Use named parameters
class Person {
  Person({required this.name, required this.age});
}
```

## See Also

- [Serialization](serialization.md) - Basic serialization
- [Deserialization](deserialization.md) - Basic deserialization
- [Types](types.md) - Type system
- [Naming Conventions](naming-conventions.md) - Naming conventions
- [Converters](converters.md) - Custom converters
- [Options](options.md) - Configuration options
