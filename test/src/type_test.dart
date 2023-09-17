import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

class Foo {
  final Bar bar;

  Foo({required this.bar});
}

class Bar {
  final Baz baz;

  Bar({required this.baz});
}

class Baz {
  final String value;
  final int count;

  Baz({required this.value, required this.count});
}

void main() {
  setUp(() {
    JsonSerializer.options = JsonSerializerOptions(userTypes: [
      UserType<Foo>(Foo.new),
      UserType<Bar>(Bar.new),
      UserType<Baz>(Baz.new),
    ]);
  });

  test('should deserialize custom type that references another custom type',
      () {
    // Given
    var json = '{"bar": {"baz": {"value": "a value", "count": 2}}}';

    // When
    var foo = JsonSerializer.deserialize<Foo>(json);

    // Then
    expect(foo.bar.baz.value, "a value");
    expect(foo.bar.baz.count, 2);
  });
}
