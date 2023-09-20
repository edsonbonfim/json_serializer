json_serializer
===============

A Dart library for effortless JSON deserialization.

* * *

Features
--------

* Effortless JSON deserialization.
* Customizable with user-defined types.
* Robust error handling with a dedicated exception class.

Getting Started
---------------

To get started, simply import the `json_serializer` package:

```dart
import 'package:json_serializer/json_serializer.dart';
```

### JSON Deserialization

Suppose you have the following Dart classes:

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

You can deserialize JSON data into these classes as follows:

```dart
main() {
  // Define user-defined types for successful deserialization
  JsonSerializer.options = JsonSerializerOptions(userTypes: [
    UserType<Person>(Person.new),
    UserType<Address>(Address.new),
  ]);

  var json = '{"name": "John", "age": 30, "address": {"street": "123 Main St", "city": "Sampletown"}}';

  var person = deserialize<Person>(json);

  print('Name: ${person.name}');
  print('Age: ${person.age}');
  print('Street: ${person.address.street}');
  print('City: ${person.address.city}');
}
```

This example demonstrates successful JSON deserialization into nested objects.

### Exception Handling

The library provides a dedicated `JsonConversionException` for handling JSON conversion errors:

```dart
try {
  final invalidJson = '{"name": "John", "age": "thirty"}';
  final person = deserialize<Person>(invalidJson);
} catch (e) {
  if (e is JsonConversionException) {
    print('JSON conversion error: ${e.message}');
  }
}
```

Serialization (Coming Soon)
---------------------------

Serialization functionality is currently under evaluation and is planned for future implementation.

License
-------

This library is licensed under the [BSD 3-Clause License](LICENSE). Feel free to use it and
contribute to its development.

* * *

Made with ❤️ by Edson Bonfim