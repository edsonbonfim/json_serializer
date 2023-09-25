# JSON Serializer

A versatile Dart package for effortless JSON serialization and deserialization without the need for
code generation or reflection.

---

## Getting Started

To get started, simply import the `json_serializer` package:

```dart
import 'package:json_serializer/json_serializer.dart';
```

### JSON Deserialization

Suppose you have the following Dart classes:

```dart
enum Gender { male, female }

class Person {
  final String name;
  final Gender gender;
  final Address address;

  Person({required this.name, required this.gender, required this.address});
}

class Address {
  final String street;
  final String city;

  Address({required this.street, required this.city});
}
```

You can deserialize JSON data into these classes as follows:

```dart
main() {
  // Define user-defined types for successful deserialization
  JsonSerializer.options = JsonSerializerOptions(types: [
    UserType<Person>(Person.new),
    UserType<Address>(Address.new),
    EnumType<Gender>(Gender.values),
  ]);

  var json =
      '{"name":"John","gender":"male","address":{"street":"123 Main St","city":"Sampletown"}}';

  var person = deserialize<Person>(json);

  print('Name: ${person.name}');
  print('Gender: ${person.gender.name}');
  print('Street: ${person.address.street}');
  print('City: ${person.address.city}');
}
```

Note that you should use `JsonSerializerOptions` to register all of your referenced classes or
enums.

### Serialization

To serialize, all your referenced classes should implement the `Serializable` interface, which
requires an implementation of `toMap`, a simple map of key and value properties.

```dart
class Person implements Serializable {
  final String name;
  final Gender gender;
  final Address address;

  Person({required this.name, required this.gender, required this.address});

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'gender': gender, 'address': address};
  }
}

class Address implements Serializable {
  final String street;
  final String city;

  Address({required this.street, required this.city});

  @override
  Map<String, dynamic> toMap() {
    return {'street': street, 'city': city};
  }
}
```

You can then easily serialize objects:

```dart
print(serialize(person));
// {"name":"John","gender":"male","address":{"street":"123 Main St","city":"Sampletown"}}
```

## License

This library is licensed under the [BSD 3-Clause License](LICENSE). Feel free to use it and
contribute to its development.

---

Made with ❤️ by Edson Bonfim