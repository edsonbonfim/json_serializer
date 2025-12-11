# API Reference

Complete API reference for `json_serializer`.

## Top-Level Functions

### `serialize(Object?, [JsonSerializerOptions?])`

Serializes a Dart object to a JSON string.

**Parameters:**
- `object`: The object to serialize
- `options`: Optional serializer options

**Returns:** `String` - JSON string representation

**Example:**
```dart
var person = Person(name: 'John', age: 30);
var json = serialize(person);
```

### `deserialize<T>(String, [JsonSerializerOptions?])`

Deserializes a JSON string to a Dart object of type `T`.

**Parameters:**
- `json`: The JSON string to deserialize
- `options`: Optional serializer options

**Returns:** `T` - Deserialized object

**Throws:** `JsonSerializerException` if deserialization fails

**Example:**
```dart
var json = '{"name":"John","age":30}';
var person = deserialize<Person>(json);
```

## Classes

### `JsonSerializer`

Main serializer class with static methods.

#### Static Properties

##### `options`

Default serializer options used when no options are provided.

**Type:** `JsonSerializerOptions`

**Example:**
```dart
JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
);
```

#### Static Methods

##### `serialize(Object?, [JsonSerializerOptions?])`

Serializes an object to JSON string.

##### `deserialize<T>(String, [JsonSerializerOptions?])`

Deserializes JSON string to object.

### `JsonSerializerOptions`

Configuration options for the serializer.

#### Constructor

```dart
JsonSerializerOptions({
  List<GenericType> types = const [],
  List<JsonConverter> converters = const [],
  List<NamingConvention>? namingConventions,
  NamingConvention? jsonNamingConvention,
})
```

#### Properties

- `types`: List of registered types
- `converters`: List of custom converters
- `namingConventions`: List of naming conventions
- `jsonNamingConvention`: Explicit JSON naming convention

#### Methods

##### `merge(JsonSerializerOptions?)`

Merges options with provided options.

##### `getConverter(TypeInfo)`

Gets converter for a type.

##### `getGenericType(TypeInfo)`

Gets generic type for a type.

##### `detectNamingConvention(Map)`

Detects naming convention from JSON.

##### `convertFromJson(String, Map)`

Converts JSON property name to camelCase.

##### `convertToJson(String)`

Converts camelCase property name to JSON convention.

### `Serializable`

Interface for serializable objects.

#### Methods

##### `toMap()`

Converts object to map representation.

**Returns:** `Map<String, dynamic>`

### `UserType<T>`

Represents a user-defined type.

#### Constructor

```dart
UserType(Function function)
```

**Parameters:**
- `function`: Constructor function (e.g., `Person.new`)

#### Example

```dart
UserType<Person>(Person.new)
```

### `EnumType<T>`

Represents an enum type.

#### Constructor

```dart
EnumType(List<T> values)
```

**Parameters:**
- `values`: List of enum values (e.g., `Gender.values`)

#### Methods

##### `parse(String)`

Parses string to enum value.

**Returns:** `T`

**Throws:** `ArgumentError` if value doesn't match

### `GenericType<T>`

Base class for user-defined and enum types.

#### Properties

- `name`: Type name

#### Methods

##### `createList()`

Creates empty list of type `T`.

**Returns:** `List<T>`

##### `createMapOfT()`

Creates empty map with `String` keys and `T` values.

**Returns:** `Map<String, T>`

##### `createMapOfNullableT()`

Creates empty map with nullable `T` values.

**Returns:** `Map<String, T?>`

##### `createListOfMapOfT()`

Creates empty list of maps.

**Returns:** `List<Map<String, T>>`

##### `createMapOfListOfT()`

Creates empty map with `List<T>` values.

**Returns:** `Map<String, List<T>>`

##### `createMapOfListOfNullableT()`

Creates empty map with nullable `List<T>` values.

**Returns:** `Map<String, List<T>?>`

### `JsonConverter<T>`

Base class for custom converters.

#### Methods

##### `canConvert(TypeInfo)`

Checks if converter can handle type.

**Returns:** `bool`

##### `write(T, TypeInfo, JsonSerializerOptions)`

Converts value to JSON.

**Returns:** `Object?`

##### `read(dynamic, TypeInfo, JsonSerializerOptions)`

Converts JSON to value.

**Returns:** `T`

##### `readNull(dynamic, TypeInfo, JsonSerializerOptions)`

Handles null values.

**Returns:** `T?`

### `NamingConvention`

Base class for naming conventions.

#### Properties

- `name`: Convention name

#### Methods

##### `toCamelCase(String)`

Converts property name to camelCase.

**Returns:** `String`

##### `fromCamelCase(String)`

Converts camelCase to convention format.

**Returns:** `String`

##### `matches(String)`

Checks if property name matches convention.

**Returns:** `bool`

### Built-in Naming Conventions

#### `CamelCaseConvention`

CamelCase naming (e.g., `firstName`).

#### `SnakeCaseConvention`

Snake_case naming (e.g., `first_name`).

#### `PascalCaseConvention`

PascalCase naming (e.g., `FirstName`).

#### `KebabCaseConvention`

Kebab-case naming (e.g., `first-name`).

#### `UpperCaseConvention`

UPPERCASE naming (e.g., `FIRSTNAME`).

#### `LowerCaseConvention`

lowercase naming (e.g., `firstname`).

## Exceptions

### `JsonSerializerException`

Exception thrown during serialization/deserialization.

#### Constructor

```dart
JsonSerializerException(String message)
```

#### Properties

- `message`: Error message

#### Example

```dart
try {
  var person = deserialize<Person>(json);
} on JsonSerializerException catch (e) {
  print(e.message);
}
```

### `DartParserException`

Exception thrown during type parsing.

#### Constructor

```dart
DartParserException(String message)
```

## Built-in Converters

### `StringConverter`

Converts `String` values.

### `IntConverter`

Converts `int` values.

### `DoubleConverter`

Converts `double` values.

### `NumConverter`

Converts `num` values.

### `BoolConverter`

Converts `bool` values.

### `DateTimeConverter`

Converts `DateTime` to/from ISO 8601 strings.

### `UriConverter`

Converts `Uri` to/from strings.

### `BigIntConverter`

Converts `BigInt` to/from strings.

### `ListConverter`

Converts `List<T>` values.

### `MapConverter`

Converts `Map<String, T>` values.

### `ObjectConverter`

Converts `Object` values.

### `DynamicConverter`

Converts `dynamic` values.

### `GenericTypeConverter`

Converts user-defined types and enums.

## Type Information

### `TypeInfo`

Represents type information.

#### Properties

- `name`: Type name
- `isNullable`: Whether type is nullable
- `isMap`: Whether type is a Map
- `isList`: Whether type is a List
- `isGeneric`: Whether type is generic
- `generics`: List of generic type arguments

### `FunctionInfo`

Represents function signature information.

#### Properties

- `type`: Return type
- `positional`: List of positional parameters
- `optional`: List of optional parameters
- `named`: List of named parameters

### `PropertyInfo`

Represents property information.

#### Properties

- `type`: Property type
- `name`: Property name
- `isRequired`: Whether property is required

## Internal Utilities

### `DartParser`

Parses Dart type and function signatures.

#### Static Methods

##### `parseType(String)`

Parses type string to `TypeInfo`.

##### `parseFunction(Function)`

Parses function to `FunctionInfo`.

### `DartLexer`

Tokenizes Dart-like type strings.

### `JsonParser`

Parses JSON strings.

### `JsonWriter`

Writes JSON strings.

## See Also

- [Getting Started](getting-started.md) - Quick start guide
- [Serialization](serialization.md) - Serialization guide
- [Deserialization](deserialization.md) - Deserialization guide
- [Types](types.md) - Type system guide
- [Naming Conventions](naming-conventions.md) - Naming conventions guide
- [Converters](converters.md) - Converters guide
- [Options](options.md) - Options guide
- [Advanced Usage](advanced.md) - Advanced scenarios
