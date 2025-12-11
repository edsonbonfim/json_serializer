import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

void main() {
  group('JSON Deserialization Tests for Complex Objects', () {
    setUp(() {
      JsonSerializer.options = JsonSerializerOptions(types: [
        UserType<Person>(Person.new),
        UserType<Address>(Address.new),
        UserType<Book>(Book.new),
        UserType<Movie>(Movie.new),
        UserType<MusicAlbum>(MusicAlbum.new),
        UserType<Product>(Product.new),
        UserType<Recipe>(Recipe.new),
        UserType<Car>(Car.new),
      ]);
    });

    test('Valid JSON for Person object', () {
      var validPersonJson =
          '{"name":"Alice","age":25,"address":{"street":"456 Elm St","city":"Exampleville"}}';
      var validPerson = deserialize<Person>(validPersonJson);
      expect(validPerson.name, equals("Alice"));
      expect(validPerson.age, equals(25));
      expect(validPerson.address.street, equals("456 Elm St"));
      expect(validPerson.address.city, equals("Exampleville"));
      expect(serialize(validPerson), equals(validPersonJson));
    });

    test('Valid JSON for Address object', () {
      var validAddressJson = '{"street":"789 Oak St","city":"Sampleville"}';
      var validAddress = deserialize<Address>(validAddressJson);
      expect(validAddress.street, equals("789 Oak St"));
      expect(validAddress.city, equals("Sampleville"));
      expect(serialize(validAddress), equals(validAddressJson));
    });

    test('Invalid JSON (missing required fields) for Person', () {
      var invalidJson = '{"name":"Bob"}';
      expect(() => deserialize<Person>(invalidJson),
          throwsA(TypeMatcher<JsonSerializerException>()));
    });

    test('JSON with incorrect data types for Person', () {
      var incorrectTypeJson =
          '{"name":"Eve","age":"thirty","address":{"street":"789 Oak St","city":"Sampleville"}}';
      expect(() => deserialize<Person>(incorrectTypeJson),
          throwsA(TypeMatcher<JsonSerializerException>()));
    });

    test('Empty JSON for Person', () {
      var emptyJson = '{}';
      expect(() => deserialize<Person>(emptyJson),
          throwsA(TypeMatcher<JsonSerializerException>()));
    });

    test('Missing Person object in JSON', () {
      var missingPersonJson =
          '{"address":{"street":"123 Elm St","city":"Missingtown"}}';
      expect(() => deserialize<Person>(missingPersonJson),
          throwsA(TypeMatcher<JsonSerializerException>()));
    });

    test('Missing Address object in JSON', () {
      var missingAddressJson = '{"name":"Grace","age":35}';
      expect(() => deserialize<Person>(missingAddressJson),
          throwsA(TypeMatcher<JsonSerializerException>()));
    });

    test('Invalid JSON for both objects', () {
      var invalidJsonBoth =
          '{"name":"Dave","age":"invalid_age","address":{"street":123,"city":456}}';
      expect(() => deserialize<Person>(invalidJsonBoth),
          throwsA(TypeMatcher<JsonSerializerException>()));
    });

    test('JSON with special characters in Person name', () {
      var specialCharsJson =
          '{"name":"John@Doe","age":40,"address":{"street":"987 Maple St","city":"Specialville"}}';
      var personWithSpecialChars = deserialize<Person>(specialCharsJson);
      expect(personWithSpecialChars.name, equals("John@Doe"));
      expect(personWithSpecialChars.age, equals(40));
      expect(personWithSpecialChars.address.street, equals("987 Maple St"));
      expect(personWithSpecialChars.address.city, equals("Specialville"));
      expect(serialize(personWithSpecialChars), equals(specialCharsJson));
    });

    test('Deserialize JSON for a Book', () {
      var jsonBook =
          '''{"title":"The Great Gatsby","author":"F. Scott Fitzgerald","year":1925,"genres":["Fiction","Classics"],"reviews":{"Review1":"Excellent","Review2":"Must-read"}}''';
      var result = deserialize<Book>(jsonBook);
      expect(result.title, equals("The Great Gatsby"));
      expect(result.author, equals("F. Scott Fitzgerald"));
      expect(result.year, equals(1925));
      expect(result.genres, equals(["Fiction", "Classics"]));
      expect(result.reviews["Review1"], equals("Excellent"));
      expect(result.reviews["Review2"], equals("Must-read"));
      expect(serialize(result), equals(jsonBook));
    });

    test('Deserialize JSON for a Movie', () {
      var jsonMovie =
          '''{"title":"Inception","director":"Christopher Nolan","year":2010,"genres":["Science Fiction","Action"],"actors":{"Leonardo DiCaprio":"Dom Cobb","Ellen Page":"Ariadne"}}''';
      var result = deserialize<Movie>(jsonMovie);
      expect(result.title, equals("Inception"));
      expect(result.director, equals("Christopher Nolan"));
      expect(result.year, equals(2010));
      expect(result.genres, equals(["Science Fiction", "Action"]));
      expect(result.actors["Leonardo DiCaprio"], equals("Dom Cobb"));
      expect(result.actors["Ellen Page"], equals("Ariadne"));
      expect(serialize(result), equals(jsonMovie));
    });

    test('Deserialize JSON for a Music Album', () {
      var jsonAlbum =
          '''{"title":"Thriller","artist":"Michael Jackson","year":1982,"genres":["Pop","R&B"],"tracks":{"Wanna Be Startin' Somethin'":"Track 1","Thriller":"Track 2"}}''';
      var result = deserialize<MusicAlbum>(jsonAlbum);
      expect(result.title, equals("Thriller"));
      expect(result.artist, equals("Michael Jackson"));
      expect(result.year, equals(1982));
      expect(result.genres, equals(["Pop", "R&B"]));
      expect(result.tracks["Wanna Be Startin' Somethin'"], equals("Track 1"));
      expect(result.tracks["Thriller"], equals("Track 2"));
      expect(serialize(result), equals(jsonAlbum));
    });

    test('Deserialize JSON for a Product', () {
      var jsonProduct =
          '''{"name":"Smartphone","price":499.99,"attributes":{"Color":"Black","Screen Size":"6 inches"}}''';
      var result = deserialize<Product>(jsonProduct);
      expect(result.name, equals("Smartphone"));
      expect(result.price, equals(499.99));
      expect(result.attributes["Color"], equals("Black"));
      expect(result.attributes["Screen Size"], equals("6 inches"));
      expect(serialize(result), equals(jsonProduct));
    });

    test('Deserialize JSON for a Recipe', () {
      var jsonRecipe =
          '''{"name":"Chocolate Cake","ingredients":["Flour","Sugar","Cocoa Powder"],"instructions":{"Step1":"Mix dry ingredients","Step2":"Add wet ingredients","Step3":"Bake at 350°F"}}''';
      var result = deserialize<Recipe>(jsonRecipe);
      expect(result.name, equals("Chocolate Cake"));
      expect(result.ingredients, equals(["Flour", "Sugar", "Cocoa Powder"]));
      expect(result.instructions["Step1"], equals("Mix dry ingredients"));
      expect(result.instructions["Step2"], equals("Add wet ingredients"));
      expect(result.instructions["Step3"], equals("Bake at 350°F"));
      expect(serialize(result), equals(jsonRecipe));
    });

    test('Deserialize JSON for a Car', () {
      var jsonCar =
          '''{"brand":"Toyota","model":"Camry","features":{"Engine":"V6","Safety":"ABS","Entertainment":"Bluetooth"}}''';
      var result = deserialize<Car>(jsonCar);
      expect(result.brand, equals("Toyota"));
      expect(result.model, equals("Camry"));
      expect(result.features["Engine"], equals("V6"));
      expect(result.features["Safety"], equals("ABS"));
      expect(result.features["Entertainment"], equals("Bluetooth"));
      expect(serialize(result), equals(jsonCar));
    });
  });

  group('JSON Deserialization Tests for Primitive Types', () {
    test('Deserialize a simple string', () {
      var jsonString = '"Hello,World!"';
      var result = deserialize<String>(jsonString);
      expect(result, equals("Hello,World!"));
      expect(serialize(result), equals(jsonString));
    });

    test('Deserialize an integer', () {
      var jsonInt = '42';
      var result = deserialize<int>(jsonInt);
      expect(result, equals(42));
      expect(serialize(result), equals(jsonInt));
    });

    test('Deserialize a double', () {
      var jsonDouble = '3.14';
      var result = deserialize<double>(jsonDouble);
      expect(result, equals(3.14));
      expect(serialize(result), equals(jsonDouble));
    });

    test('Deserialize a BigInt', () {
      var jsonBigInt = '"123456789012345678901234567890"';
      var result = deserialize<BigInt>(jsonBigInt);
      expect(result, equals(BigInt.parse('123456789012345678901234567890')));
      expect(serialize(result), equals(jsonBigInt));
    });

    test('Deserialize a bool (true)', () {
      var jsonBoolTrue = 'true';
      var result = deserialize<bool>(jsonBoolTrue);
      expect(result, equals(true));
      expect(serialize(result), equals(jsonBoolTrue));
    });

    test('Deserialize a bool (false)', () {
      var jsonBoolFalse = 'false';
      var result = deserialize<bool>(jsonBoolFalse);
      expect(result, equals(false));
      expect(serialize(result), equals(jsonBoolFalse));
    });

    test('Deserialize a null value', () {
      var jsonNull = 'null';
      var result = deserialize<Object?>(jsonNull);
      expect(result, isNull);
      expect(serialize(result), equals(jsonNull));
    });

    test('Deserialize an empty list', () {
      var jsonEmptyList = '[]';
      var result = deserialize<List<Object>>(jsonEmptyList);
      expect(result, isEmpty);
      expect(serialize(result), equals(jsonEmptyList));
    });

    test('Deserialize an empty map', () {
      var jsonEmptyMap = '{}';
      var result = deserialize<Map<String, Object>>(jsonEmptyMap);
      expect(result, isEmpty);
      expect(serialize(result), equals(jsonEmptyMap));
    });

    test('Deserialize a list of maps', () {
      var jsonListOfMaps = '[{"name":"Alice"},{"name":"Bob"}]';
      var result = deserialize<List<Map<String, Object>>>(jsonListOfMaps);
      expect(result, hasLength(2));
      expect(result[0], equals({"name": "Alice"}));
      expect(result[1], equals({"name": "Bob"}));
      expect(serialize(result), equals(jsonListOfMaps));
    });

    test('Deserialize a map with a list', () {
      var jsonMapWithList = '{"numbers":[1,2,3]}';
      var result = deserialize<Map<String, List<int>>>(jsonMapWithList);
      expect(
          result,
          equals({
            "numbers": [1, 2, 3]
          }));
      expect(serialize(result), equals(jsonMapWithList));
    });

    test('Deserialize a URI', () {
      var jsonUri = '"https://www.example.com"';
      var result = deserialize<Uri>(jsonUri);
      expect(result, equals(Uri.parse("https://www.example.com")));
      expect(serialize(result), equals(jsonUri));
    });

    test('Deserialize a combination of types', () {
      var jsonCombo =
          '{"name":"John","age":30,"score":85.5,"isStudent":true,"data":null}';
      var result = deserialize<Map<String, Object?>>(jsonCombo);
      expect(
          result,
          equals({
            "name": "John",
            "age": 30,
            "score": 85.5,
            "isStudent": true,
            "data": null
          }));
      expect(serialize(result), equals(jsonCombo));
    });

    test('Deserialize a list of strings', () {
      var jsonListOfStrings = '["Apple","Banana","Cherry"]';
      var result = deserialize<List<String>>(jsonListOfStrings);
      expect(result, equals(["Apple", "Banana", "Cherry"]));
      expect(serialize(result), equals(jsonListOfStrings));
    });

    test('Deserialize a map of strings to integers', () {
      var jsonMapOfIntegers = '{"one":1,"two":2,"three":3}';
      var result = deserialize<Map<String, int>>(jsonMapOfIntegers);
      expect(result, equals({"one": 1, "two": 2, "three": 3}));
      expect(serialize(result), equals(jsonMapOfIntegers));
    });

    test('Deserialize JSON with nested lists and maps of primitives', () {
      var jsonNestedPrimitives =
          '''{"numbers":[1,2,3],"data":{"values":["A","B","C"],"info":{"code":42,"isTrue":true,"isNull":null}}}''';
      var result = deserialize<Map<String, dynamic>>(jsonNestedPrimitives);
      expect(result["numbers"], equals([1, 2, 3]));
      expect(result["data"]["values"], equals(["A", "B", "C"]));
      expect(result["data"]["info"]["code"], equals(42));
      expect(result["data"]["info"]["isTrue"], equals(true));
      expect(result["data"]["info"]["isNull"], isNull);
      expect(serialize(result), equals(jsonNestedPrimitives));
    });

    test('Deserialize JSON with boolean values', () {
      var jsonBooleans = '{"isActive":true,"isStudent":false}';
      var result = deserialize<Map<String, bool>>(jsonBooleans);
      expect(result, equals({"isActive": true, "isStudent": false}));
      expect(serialize(result), equals(jsonBooleans));
    });

    test('Deserialize JSON with URI values', () {
      var jsonURIs =
          '{"website":"https://www.example.com","api":"https://api.example.com"}';
      var result = deserialize<Map<String, Uri>>(jsonURIs);
      expect(result["website"], equals(Uri.parse("https://www.example.com")));
      expect(result["api"], equals(Uri.parse("https://api.example.com")));
      expect(serialize(result), equals(jsonURIs));
    });

    test('Deserialize JSON with null values', () {
      var jsonNulls = '{"name":null,"age":null}';
      var result = deserialize<Map<String, Object?>>(jsonNulls);
      expect(result, equals({"name": null, "age": null}));
      expect(serialize(result), equals(jsonNulls));
    });

    test('Deserialize JSON with DateTime', () {
      var jsonDateTime = '{"createdAt":"2023-09-19T15:30:00.000Z"}';
      var result = deserialize<Map<String, DateTime>>(jsonDateTime);
      expect(result["createdAt"], equals(DateTime.utc(2023, 9, 19, 15, 30, 0)));
      expect(serialize(result), equals(jsonDateTime));
    });

    test('Deserialize JSON with List of DateTimes', () {
      var jsonListofDateTimes =
          '["2023-09-19T15:30:00.000Z","2023-09-20T12:00:00.000Z"]';
      var result = deserialize<List<DateTime>>(jsonListofDateTimes);
      expect(result[0], equals(DateTime.utc(2023, 9, 19, 15, 30, 0)));
      expect(result[1], equals(DateTime.utc(2023, 9, 20, 12, 0, 0)));
      expect(serialize(result), equals(jsonListofDateTimes));
    });

    test('Deserialize JSON with Map of DateTimes', () {
      var jsonMapOfDateTimes =
          '{"startDate":"2023-09-19T15:30:00.000Z","endDate":"2023-09-20T12:00:00.000Z"}';
      var result = deserialize<Map<String, DateTime>>(jsonMapOfDateTimes);
      expect(result["startDate"], equals(DateTime.utc(2023, 9, 19, 15, 30, 0)));
      expect(result["endDate"], equals(DateTime.utc(2023, 9, 20, 12, 0, 0)));
      expect(serialize(result), equals(jsonMapOfDateTimes));
    });
  });

  group('JSON Deserialization Tests for Enum', () {
    setUp(() {
      JsonSerializer.options = JsonSerializerOptions(types: [
        UserType<User>(User.new),
        EnumType<Gender>(Gender.values),
      ]);
    });

    test('Male Gender', () {
      var json = '{"name":"John","age":30,"gender":"male"}';
      var user = deserialize<User>(json);
      expect(user.name, equals('John'));
      expect(user.age, equals(30));
      expect(user.gender, equals(Gender.male));
      expect(serialize(user), equals(json));
    });

    test('Female Gender', () {
      var json = '{"name":"Jane","age":25,"gender":"female"}';
      var user = deserialize<User>(json);
      expect(user.name, equals('Jane'));
      expect(user.age, equals(25));
      expect(user.gender, equals(Gender.female));
      expect(serialize(user), equals(json));
    });

    test('Other Gender', () {
      var json = '{"name":"Alex","age":28,"gender":"other"}';
      var user = deserialize<User>(json);
      expect(user.name, equals('Alex'));
      expect(user.age, equals(28));
      expect(user.gender, equals(Gender.other));
      expect(serialize(user), equals(json));
    });

    test('Invalid JSON', () {
      var json = '{"name":"Sam","age":22,"gender":"unknown"}';
      expect(() => deserialize<User>(json),
          throwsA(TypeMatcher<JsonSerializerException>()));
    });
  });
}

class Person implements Serializable {
  final String name;
  final int age;
  final Address address;

  Person({required this.name, required this.age, required this.address});

  @override
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "age": age,
      "address": address,
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
      "street": street,
      "city": city,
    };
  }
}

class Book implements Serializable {
  final String title;
  final String author;
  final int year;
  final List<String> genres;
  final Map<String, String> reviews;

  Book({
    required this.title,
    required this.author,
    required this.year,
    required this.genres,
    required this.reviews,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'year': year,
      'genres': genres,
      'reviews': reviews
    };
  }
}

class Movie implements Serializable {
  final String title;
  final String director;
  final int year;
  final List<String> genres;
  final Map<String, String> actors;

  Movie({
    required this.title,
    required this.director,
    required this.year,
    required this.genres,
    required this.actors,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'director': director,
      'year': year,
      'genres': genres,
      'actors': actors
    };
  }
}

class MusicAlbum implements Serializable {
  final String title;
  final String artist;
  final int year;
  final List<String> genres;
  final Map<String, String> tracks;

  MusicAlbum({
    required this.title,
    required this.artist,
    required this.year,
    required this.genres,
    required this.tracks,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'year': year,
      'genres': genres,
      'tracks': tracks
    };
  }
}

class Product implements Serializable {
  final String name;
  final double price;
  final Map<String, dynamic> attributes;

  Product({
    required this.name,
    required this.price,
    required this.attributes,
  });

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'attributes': attributes};
  }
}

class Recipe implements Serializable {
  final String name;
  final List<String> ingredients;
  final Map<String, String> instructions;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.instructions,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ingredients': ingredients,
      'instructions': instructions
    };
  }
}

class Car implements Serializable {
  final String brand;
  final String model;
  final Map<String, dynamic> features;

  Car({
    required this.brand,
    required this.model,
    required this.features,
  });

  @override
  Map<String, dynamic> toMap() {
    return {'brand': brand, 'model': model, 'features': features};
  }
}

enum Gender {
  male,
  female,
  other,
}

class User implements Serializable {
  final String name;
  final int age;
  final Gender gender;

  User({required this.name, required this.age, required this.gender});

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'age': age, 'gender': gender};
  }
}
