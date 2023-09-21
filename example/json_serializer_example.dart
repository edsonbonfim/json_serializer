import 'package:json_serializer/json_serializer.dart';

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

main() {
  // Define user-defined types for successful deserialization
  JsonSerializer.options = JsonSerializerOptions(userTypes: [
    UserType<Person>(Person.new),
    UserType<Address>(Address.new),
  ]);

  var json =
      '{"name": "John", "age": 30, "address": {"street": "123 Main St", "city": "Sampletown"}}';

  var person = deserialize<Person>(json);

  print('Name: ${person.name}');
  print('Age: ${person.age}');
  print('Street: ${person.address.street}');
  print('City: ${person.address.city}');
}
