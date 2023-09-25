import 'package:json_serializer/json_serializer.dart';

enum Gender { male, female }

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

  print(serialize(person));
}
