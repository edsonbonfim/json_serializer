# JSON Serializer

> A versatile Dart package for effortless JSON serialization and deserialization without the need for code generation or reflection.

## Features

- 🚀 **No Code Generation**: Works without build_runner or code generation
- 🔄 **No Reflection**: Uses constructor-based deserialization
- 🎯 **Type Safe**: Full type safety with Dart's type system
- 🎨 **Flexible Naming**: Automatic conversion between naming conventions (camelCase, snake_case, PascalCase, kebab-case, etc.)
- 🔧 **Extensible**: Custom converters and naming conventions
- 📦 **Zero Dependencies**: No external dependencies required
- ⚡ **Performance**: Optimized for speed with zero-copy string operations

## Quick Start

### Installation

Add `json_serializer` to your `pubspec.yaml`:

```yaml
dependencies:
  json_serializer: ^0.3.1
```

### Basic Usage

```dart
import 'package:json_serializer/json_serializer.dart';

// Define your classes
class Person {
  final String name;
  final int age;
  
  Person({required this.name, required this.age});
}

// Register types
JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
);

// Deserialize
var json = '{"name":"John","age":30}';
var person = deserialize<Person>(json);

// Serialize (implement Serializable)
class Person implements Serializable {
  final String name;
  final int age;
  
  Person({required this.name, required this.age});
  
  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'age': age};
  }
}

var jsonString = serialize(person);
```

## Documentation

- [Getting Started](getting-started.md) - Installation and basic setup
- [Serialization](serialization.md) - Converting Dart objects to JSON
- [Deserialization](deserialization.md) - Converting JSON to Dart objects
- [Types](types.md) - Working with UserType, EnumType, and GenericType
- [Naming Conventions](naming-conventions.md) - Automatic property name conversion
- [Converters](converters.md) - Custom type converters
- [Options](options.md) - Configuration options
- [Advanced Usage](advanced.md) - Complex scenarios and best practices
- [API Reference](api-reference.md) - Complete API documentation

## License

This library is licensed under the [BSD 3-Clause License](../LICENSE).

---

Made with ❤️ by Edson Bonfim
