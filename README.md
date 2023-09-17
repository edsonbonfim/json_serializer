# json_serializer

Automatically convert JSON to dart objects in runtime without code generation.

## Example

```dart
import 'package:json_serializer/json_serializer.dart';

class Foo {
  final List<Bar> bars;

  Foo({required this.bars});
}

class Bar {
  final String value;

  Bar({required this.value});
}

main() {
  JsonSerializer.options = JsonSerializerOptions(userTypes: [
    UserType<Foo>(Foo.new),
    UserType<Bar>(Bar.new),
  ]);

  var json = '{"bars": [{"value": "a value"}]}';

  var foo = JsonSerializer.deserialize<Foo>(json);

  print(foo.bars[0].value); // a value
}
```