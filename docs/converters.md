# Converters

Converters are responsible for converting values between JSON and Dart types. The library provides built-in converters for common types, and you can create custom converters for special cases.

## Built-in Converters

The library includes converters for all common Dart types:

### Primitive Types

- **StringConverter**: Converts `String` values
- **IntConverter**: Converts `int` values
- **DoubleConverter**: Converts `double` values
- **NumConverter**: Converts `num` values
- **BoolConverter**: Converts `bool` values

### Special Types

- **DateTimeConverter**: Converts `DateTime` to/from ISO 8601 strings
- **UriConverter**: Converts `Uri` to/from strings
- **BigIntConverter**: Converts `BigInt` to/from strings

### Collection Types

- **ListConverter**: Converts `List<T>` values
- **MapConverter**: Converts `Map<String, T>` values

### Generic Types

- **GenericTypeConverter**: Handles user-defined types and enums
- **ObjectConverter**: Handles `Object` type
- **DynamicConverter**: Handles `dynamic` type

## Custom Converters

You can create custom converters by extending `JsonConverter<T>`:

```dart
class CustomTypeConverter extends JsonConverter<CustomType> {
  @override
  bool canConvert(TypeInfo type) {
    return type.name == 'CustomType';
  }

  @override
  Object? write(CustomType value, TypeInfo type, JsonSerializerOptions options) {
    // Convert CustomType to JSON-compatible value
    return value.toJsonString();
  }

  @override
  CustomType read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    // Convert JSON value to CustomType
    return CustomType.fromJsonString(value.toString());
  }
}
```

### Example: Custom Date Format

```dart
class CustomDateConverter extends JsonConverter<DateTime> {
  final String format;

  CustomDateConverter(this.format);

  @override
  bool canConvert(TypeInfo type) {
    return type.name == 'DateTime';
  }

  @override
  Object? write(DateTime value, TypeInfo type, JsonSerializerOptions options) {
    // Custom serialization format
    return value.toIso8601String();
  }

  @override
  DateTime read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    // Custom deserialization format
    return DateTime.parse(value.toString());
  }
}
```

### Example: Custom String Converter

```dart
class TrimmedStringConverter extends JsonConverter<String> {
  @override
  bool canConvert(TypeInfo type) {
    return type.name == 'String';
  }

  @override
  Object? write(String value, TypeInfo type, JsonSerializerOptions options) {
    return value;
  }

  @override
  String read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value.toString().trim();
  }
}
```

## Registering Converters

### Global Registration

```dart
JsonSerializer.options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  converters: [
    CustomDateConverter('yyyy-MM-dd'),
    TrimmedStringConverter(),
  ],
);
```

### Per-Operation Registration

```dart
var options = JsonSerializerOptions(
  types: [UserType<Person>(Person.new)],
  converters: [CustomDateConverter('yyyy-MM-dd')],
);

var person = deserialize<Person>(json, options);
```

## Converter Selection

The library selects converters in this order:

1. **Custom converters**: Checks custom converters first
2. **Default converters**: Falls back to built-in converters

The first converter where `canConvert()` returns `true` is used.

## Converter Methods

### `canConvert(TypeInfo)`

Determines if the converter can handle a specific type:

```dart
@override
bool canConvert(TypeInfo type) {
  return type.name == 'MyType';
}
```

### `write(T, TypeInfo, JsonSerializerOptions)`

Converts a Dart value to a JSON-compatible value:

```dart
@override
Object? write(MyType value, TypeInfo type, JsonSerializerOptions options) {
  return value.toJson();
}
```

### `read(dynamic, TypeInfo, JsonSerializerOptions)`

Converts a JSON value to a Dart value:

```dart
@override
MyType read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
  return MyType.fromJson(value);
}
```

### `readNull(dynamic, TypeInfo, JsonSerializerOptions)`

Handles null values (optional override):

```dart
@override
MyType? readNull(dynamic value, TypeInfo type, JsonSerializerOptions options) {
  if (value == null) {
    return null;
  }
  return read(value, type, options);
}
```

## Advanced Examples

### Converter for Custom Number Format

```dart
class PercentageConverter extends JsonConverter<double> {
  @override
  bool canConvert(TypeInfo type) {
    return type.name == 'double' && type.name.contains('Percentage');
  }

  @override
  Object? write(double value, TypeInfo type, JsonSerializerOptions options) {
    return value * 100; // Store as percentage (0.85 -> 85)
  }

  @override
  double read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return (value as num) / 100; // Convert from percentage (85 -> 0.85)
  }
}
```

### Converter with Options

```dart
class ConfigurableConverter extends JsonConverter<String> {
  final bool uppercase;

  ConfigurableConverter({this.uppercase = false});

  @override
  bool canConvert(TypeInfo type) {
    return type.name == 'String';
  }

  @override
  Object? write(String value, TypeInfo type, JsonSerializerOptions options) {
    return uppercase ? value.toUpperCase() : value;
  }

  @override
  String read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    var str = value.toString();
    return uppercase ? str.toUpperCase() : str;
  }
}
```

## Best Practices

1. **Check type name**: Use `type.name` to identify types in `canConvert()`
2. **Handle nullability**: Consider nullable types in your converter
3. **Error handling**: Throw `JsonSerializerException` for conversion errors
4. **Type safety**: Use generic type parameter `T` for type safety
5. **Performance**: Keep converters lightweight for better performance

## Common Patterns

### Overriding Built-in Converters

You can override built-in converters by registering custom ones first:

```dart
var options = JsonSerializerOptions(
  converters: [
    CustomDateConverter('yyyy-MM-dd'), // Overrides DateTimeConverter
  ],
);
```

### Conditional Conversion

```dart
class ConditionalConverter extends JsonConverter<String> {
  @override
  bool canConvert(TypeInfo type) {
    // Only convert specific types
    return type.name == 'String' && type.isNullable;
  }

  @override
  Object? write(String value, TypeInfo type, JsonSerializerOptions options) {
    return value.isEmpty ? null : value;
  }

  @override
  String read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
    return value?.toString() ?? '';
  }
}
```

## Error Handling

Converters should throw `JsonSerializerException` for conversion errors:

```dart
@override
DateTime read(dynamic value, TypeInfo type, JsonSerializerOptions options) {
  try {
    return DateTime.parse(value.toString());
  } on FormatException catch (e) {
    throw JsonSerializerException(
      'Error converting to DateTime.\n'
      'Received value: "$value"\n'
      'Details: ${e.message}',
    );
  }
}
```

## See Also

- [Types](types.md) - Understanding type system
- [Options](options.md) - Configuration options
- [Advanced Usage](advanced.md) - Complex scenarios
