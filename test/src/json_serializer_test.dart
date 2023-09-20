import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

void main() {
  group('JSON Serialization Tests for Complex Objects', () {
    setUp(() {
      JsonSerializer.options = JsonSerializerOptions(userTypes: [
        UserType<Person>(Person.new),
        UserType<Address>(Address.new),
      ]);
    });

    test('Valid JSON for Person object', () {
      var validPersonJson =
          '{"name": "Alice", "age": 25, "address": {"street": "456 Elm St", "city": "Exampleville"}}';
      var validPerson = deserialize<Person>(validPersonJson);
      expect(validPerson.name, equals("Alice"));
      expect(validPerson.age, equals(25));
      expect(validPerson.address.street, equals("456 Elm St"));
      expect(validPerson.address.city, equals("Exampleville"));
    });

    test('Valid JSON for Address object', () {
      var validAddressJson = '{"street": "789 Oak St", "city": "Sampleville"}';
      var validAddress = deserialize<Address>(validAddressJson);
      expect(validAddress.street, equals("789 Oak St"));
      expect(validAddress.city, equals("Sampleville"));
    });

    test('Invalid JSON (missing required fields) for Person', () {
      var invalidJson = '{"name": "Bob"}';
      expect(() => deserialize<Person>(invalidJson),
          throwsA(TypeMatcher<JsonDeserializationException>()));
    });

    test('JSON with incorrect data types for Person', () {
      var incorrectTypeJson =
          '{"name": "Eve", "age": "thirty", "address": {"street": "789 Oak St", "city": "Sampleville"}}';
      expect(() => deserialize<Person>(incorrectTypeJson),
          throwsA(TypeMatcher<JsonDeserializationException>()));
    });

    test('Empty JSON for Person', () {
      var emptyJson = '{}';
      expect(() => deserialize<Person>(emptyJson),
          throwsA(TypeMatcher<JsonDeserializationException>()));
    });

    test('Null JSON for Person', () {
      String? nullJson;
      expect(() => deserialize<Person>(nullJson),
          throwsA(TypeMatcher<JsonDeserializationException>()));
    });

    test('Missing Person object in JSON', () {
      var missingPersonJson =
          '{"address": {"street": "123 Elm St", "city": "Missingtown"}}';
      expect(() => deserialize<Person>(missingPersonJson),
          throwsA(TypeMatcher<JsonDeserializationException>()));
    });

    test('Missing Address object in JSON', () {
      var missingAddressJson = '{"name": "Grace", "age": 35}';
      expect(() => deserialize<Person>(missingAddressJson),
          throwsA(TypeMatcher<JsonDeserializationException>()));
    });

    test('Invalid JSON for both objects', () {
      var invalidJsonBoth =
          '{"name": "Dave", "age": "invalid_age", "address": {"street": 123, "city": 456}}';
      expect(() => deserialize<Person>(invalidJsonBoth),
          throwsA(TypeMatcher<JsonDeserializationException>()));
    });

    test('JSON with special characters in Person name', () {
      var specialCharsJson =
          '{"name": "John@Doe", "age": 40, "address": {"street": "987 Maple St", "city": "Specialville"}}';
      var personWithSpecialChars = deserialize<Person>(specialCharsJson);
      expect(personWithSpecialChars.name, equals("John@Doe"));
      expect(personWithSpecialChars.age, equals(40));
      expect(personWithSpecialChars.address.street, equals("987 Maple St"));
      expect(personWithSpecialChars.address.city, equals("Specialville"));
    });
  });

  group('JSON Serialization Tests for Complex Objects (Different Concepts)',
      () {
    setUp(() {
      JsonSerializer.options = JsonSerializerOptions(userTypes: [
        UserType<Book>(Book.new),
        UserType<Movie>(Movie.new),
        UserType<MusicAlbum>(MusicAlbum.new),
      ]);
    });

    test('Deserialize JSON for a Book', () {
      var jsonBook = '''
        {
          "title": "The Great Gatsby",
          "author": "F. Scott Fitzgerald",
          "year": 1925,
          "genres": ["Fiction", "Classics"],
          "reviews": {
            "Review1": "Excellent",
            "Review2": "Must-read"
          }
        }
      ''';
      var result = deserialize<Book>(jsonBook);
      expect(result.title, equals("The Great Gatsby"));
      expect(result.author, equals("F. Scott Fitzgerald"));
      expect(result.year, equals(1925));
      expect(result.genres, equals(["Fiction", "Classics"]));
      expect(result.reviews["Review1"], equals("Excellent"));
      expect(result.reviews["Review2"], equals("Must-read"));
    });

    test('Deserialize JSON for a Movie', () {
      var jsonMovie = '''
        {
          "title": "Inception",
          "director": "Christopher Nolan",
          "year": 2010,
          "genres": ["Science Fiction", "Action"],
          "actors": {
            "Leonardo DiCaprio": "Dom Cobb",
            "Ellen Page": "Ariadne"
          }
        }
      ''';
      var result = deserialize<Movie>(jsonMovie);
      expect(result.title, equals("Inception"));
      expect(result.director, equals("Christopher Nolan"));
      expect(result.year, equals(2010));
      expect(result.genres, equals(["Science Fiction", "Action"]));
      expect(result.actors["Leonardo DiCaprio"], equals("Dom Cobb"));
      expect(result.actors["Ellen Page"], equals("Ariadne"));
    });

    test('Deserialize JSON for a Music Album', () {
      var jsonAlbum = '''
        {
          "title": "Thriller",
          "artist": "Michael Jackson",
          "year": 1982,
          "genres": ["Pop", "R&B"],
          "tracks": {
            "Wanna Be Startin' Somethin'": "Track 1",
            "Thriller": "Track 2"
          }
        }
      ''';
      var result = deserialize<MusicAlbum>(jsonAlbum);
      expect(result.title, equals("Thriller"));
      expect(result.artist, equals("Michael Jackson"));
      expect(result.year, equals(1982));
      expect(result.genres, equals(["Pop", "R&B"]));
      expect(result.tracks["Wanna Be Startin' Somethin'"], equals("Track 1"));
      expect(result.tracks["Thriller"], equals("Track 2"));
    });
  });

  group('JSON Serialization Tests for Complex Objects (More Concepts)', () {
    setUp(() {
      JsonSerializer.options = JsonSerializerOptions(userTypes: [
        UserType<Product>(Product.new),
        UserType<Recipe>(Recipe.new),
        UserType<Car>(Car.new),
      ]);
    });

    test('Deserialize JSON for a Product', () {
      var jsonProduct = '''
        {
          "name": "Smartphone",
          "price": 499.99,
          "attributes": {
            "Color": "Black",
            "Screen Size": "6 inches"
          }
        }
      ''';
      var result = deserialize<Product>(jsonProduct);
      expect(result.name, equals("Smartphone"));
      expect(result.price, equals(499.99));
      expect(result.attributes["Color"], equals("Black"));
      expect(result.attributes["Screen Size"], equals("6 inches"));
    });

    test('Deserialize JSON for a Recipe', () {
      var jsonRecipe = '''
        {
          "name": "Chocolate Cake",
          "ingredients": ["Flour", "Sugar", "Cocoa Powder"],
          "instructions": {
            "Step1": "Mix dry ingredients",
            "Step2": "Add wet ingredients",
            "Step3": "Bake at 350°F"
          }
        }
      ''';
      var result = deserialize<Recipe>(jsonRecipe);
      expect(result.name, equals("Chocolate Cake"));
      expect(result.ingredients, equals(["Flour", "Sugar", "Cocoa Powder"]));
      expect(result.instructions["Step1"], equals("Mix dry ingredients"));
      expect(result.instructions["Step2"], equals("Add wet ingredients"));
      expect(result.instructions["Step3"], equals("Bake at 350°F"));
    });

    test('Deserialize JSON for a Car', () {
      var jsonCar = '''
        {
          "brand": "Toyota",
          "model": "Camry",
          "features": {
            "Engine": "V6",
            "Safety": "ABS",
            "Entertainment": "Bluetooth"
          }
        }
      ''';
      var result = deserialize<Car>(jsonCar);
      expect(result.brand, equals("Toyota"));
      expect(result.model, equals("Camry"));
      expect(result.features["Engine"], equals("V6"));
      expect(result.features["Safety"], equals("ABS"));
      expect(result.features["Entertainment"], equals("Bluetooth"));
    });
  });

  group('JSON Serialization Tests for Primitive Types', () {
    setUp(() {
      JsonSerializer.options = JsonSerializerOptions();
    });

    test('Deserialize a simple string', () {
      var jsonString = '"Hello, World!"';
      var result = deserialize<String>(jsonString);
      expect(result, equals("Hello, World!"));
    });

    test('Deserialize an integer', () {
      var jsonInt = '42';
      var result = deserialize<int>(jsonInt);
      expect(result, equals(42));
    });

    test('Deserialize a double', () {
      var jsonDouble = '3.14';
      var result = deserialize<double>(jsonDouble);
      expect(result, equals(3.14));
    });

    test('Deserialize a BigInt', () {
      var jsonBigInt = '"123456789012345678901234567890"';
      var result = deserialize<BigInt>(jsonBigInt);
      expect(result, equals(BigInt.parse('123456789012345678901234567890')));
    });

    test('Deserialize a bool (true)', () {
      var jsonBoolTrue = 'true';
      var result = deserialize<bool>(jsonBoolTrue);
      expect(result, equals(true));
    });

    test('Deserialize a bool (false)', () {
      var jsonBoolFalse = 'false';
      var result = deserialize<bool>(jsonBoolFalse);
      expect(result, equals(false));
    });

    test('Deserialize a null value', () {
      var jsonNull = 'null';
      var result = deserialize<Object?>(jsonNull);
      expect(result, isNull);
    });

    test('Deserialize an empty list', () {
      var jsonEmptyList = '[]';
      var result = deserialize<List<Object>>(jsonEmptyList);
      expect(result, isEmpty);
    });

    test('Deserialize an empty map', () {
      var jsonEmptyMap = '{}';
      var result = deserialize<Map<String, Object>>(jsonEmptyMap);
      expect(result, isEmpty);
    });

    test('Deserialize a list of maps', () {
      var jsonListOfMaps = '[{"name": "Alice"}, {"name": "Bob"}]';
      var result = deserialize<List<Map<String, Object>>>(jsonListOfMaps);
      expect(result, hasLength(2));
      expect(result[0], equals({"name": "Alice"}));
      expect(result[1], equals({"name": "Bob"}));
    });

    test('Deserialize a map with a list', () {
      var jsonMapWithList = '{"numbers": [1, 2, 3]}';
      var result = deserialize<Map<String, List<int>>>(jsonMapWithList);
      expect(
          result,
          equals({
            "numbers": [1, 2, 3]
          }));
    });

    test('Deserialize a URI', () {
      var jsonUri = '"https://www.example.com"';
      var result = deserialize<Uri>(jsonUri);
      expect(result, equals(Uri.parse("https://www.example.com")));
    });

    test('Deserialize a combination of types', () {
      var jsonCombo =
          '{"name": "John", "age": 30, "score": 85.5, "isStudent": true, "data": null}';
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
    });

    test('Deserialize a list of strings', () {
      var jsonListOfStrings = '["Apple", "Banana", "Cherry"]';
      var result = deserialize<List<String>>(jsonListOfStrings);
      expect(result, equals(["Apple", "Banana", "Cherry"]));
    });

    test('Deserialize a map of strings to integers', () {
      var jsonMapOfIntegers = '{"one": 1, "two": 2, "three": 3}';
      var result = deserialize<Map<String, int>>(jsonMapOfIntegers);
      expect(result, equals({"one": 1, "two": 2, "three": 3}));
    });

    test('Deserialize JSON with nested lists and maps of primitives', () {
      var jsonNestedPrimitives = '''
        {
          "numbers": [1, 2, 3],
          "data": {
            "values": ["A", "B", "C"],
            "info": {
              "code": 42,
              "isTrue": true,
              "isNull": null
            }
          }
        }
      ''';
      var result = deserialize<Map<String, dynamic>>(jsonNestedPrimitives);
      expect(result["numbers"], equals([1, 2, 3]));
      expect(result["data"]["values"], equals(["A", "B", "C"]));
      expect(result["data"]["info"]["code"], equals(42));
      expect(result["data"]["info"]["isTrue"], equals(true));
      expect(result["data"]["info"]["isNull"], isNull);
    });

    test('Deserialize JSON with boolean values', () {
      var jsonBooleans = '{"isActive": true, "isStudent": false}';
      var result = deserialize<Map<String, bool>>(jsonBooleans);
      expect(result, equals({"isActive": true, "isStudent": false}));
    });

    test('Deserialize JSON with URI values', () {
      var jsonURIs =
          '{"website": "https://www.example.com", "api": "https://api.example.com"}';
      var result = deserialize<Map<String, Uri>>(jsonURIs);
      expect(result["website"], equals(Uri.parse("https://www.example.com")));
      expect(result["api"], equals(Uri.parse("https://api.example.com")));
    });

    test('Deserialize JSON with null values', () {
      var jsonNulls = '{"name": null, "age": null}';
      var result = deserialize<Map<String, Object?>>(jsonNulls);
      expect(result, equals({"name": null, "age": null}));
    });

    test('Deserialize JSON with DateTime', () {
      var jsonDateTime = '{"createdAt": "2023-09-19T15:30:00Z"}';
      var result = deserialize<Map<String, DateTime>>(jsonDateTime);
      expect(result["createdAt"], equals(DateTime.utc(2023, 9, 19, 15, 30, 0)));
    });

    test('Deserialize JSON with List of DateTimes', () {
      var jsonListofDateTimes =
          '["2023-09-19T15:30:00Z", "2023-09-20T12:00:00Z"]';
      var result = deserialize<List<DateTime>>(jsonListofDateTimes);
      expect(result[0], equals(DateTime.utc(2023, 9, 19, 15, 30, 0)));
      expect(result[1], equals(DateTime.utc(2023, 9, 20, 12, 0, 0)));
    });

    test('Deserialize JSON with Map of DateTimes', () {
      var jsonMapOfDateTimes =
          '{"startDate": "2023-09-19T15:30:00Z", "endDate": "2023-09-20T12:00:00Z"}';
      var result = deserialize<Map<String, DateTime>>(jsonMapOfDateTimes);
      expect(result["startDate"], equals(DateTime.utc(2023, 9, 19, 15, 30, 0)));
      expect(result["endDate"], equals(DateTime.utc(2023, 9, 20, 12, 0, 0)));
    });
  });
}

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

class Book {
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
}

class Movie {
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
}

class MusicAlbum {
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
}

class Product {
  final String name;
  final double price;
  final Map<String, dynamic> attributes;

  Product({
    required this.name,
    required this.price,
    required this.attributes,
  });
}

class Recipe {
  final String name;
  final List<String> ingredients;
  final Map<String, String> instructions;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.instructions,
  });
}

class Car {
  final String brand;
  final String model;
  final Map<String, dynamic> features;

  Car({
    required this.brand,
    required this.model,
    required this.features,
  });
}
