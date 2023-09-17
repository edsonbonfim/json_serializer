import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

class Foo {
  final List<Bar> bars;

  Foo({required this.bars});
}

class Bar {
  final String value;

  Bar({required this.value});
}

void main() {
  setUp(() {
    JsonSerializer.options = JsonSerializerOptions(userTypes: [
      UserType<Foo>(Foo.new),
      UserType<Bar>(Bar.new),
    ]);
  });

  test(
      'should deserialize custom type that references a list of another custom type',
      () {
    // Given
    var json = '{"bars": [{"value": "a value"}]}';

    // When
    var foo = JsonSerializer.deserialize<Foo>(json);

    // Then
    expect(foo.bars[0].value, "a value");
  });
}
