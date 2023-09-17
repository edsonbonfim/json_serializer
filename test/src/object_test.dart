import 'dart:convert';

import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

import 'utils.dart';

class Sample {
  final Object notNullable;
  final Object notNullableWithDefault;
  final Object? nullable;
  final Object? nullableWithDefault;

  Sample({
    required this.notNullable,
    this.notNullableWithDefault = 'default',
    this.nullable,
    this.nullableWithDefault = 'default',
  });
}

void main() {
  setUp(() {
    JsonSerializer.options = JsonSerializerOptions(userTypes: [UserType<Sample>(Sample.new),]);
  });

  test('1', () {
    // Given
    var json = {"notNullable": "notNullable", "nullable": 10};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, "notNullable");
    expect(result.notNullableWithDefault, "default");
    expect(result.nullable, 10);
    expect(result.nullableWithDefault, "default");
  });

  test('2', () {
    // Given
    var json = {"notNullable": 20.0, "nullable": null};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, 20.0);
    expect(result.notNullableWithDefault, "default");
    expect(result.nullable, null);
    expect(result.nullableWithDefault, "default");
  });

  test('3', () {
    // Given
    var json = {"notNullable": null, "nullable": "nullable"};

    // When
    act() => JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(act, throwsWithMessage("type 'Null' is not a subtype of type 'Object' of 'notNullable'"));
  });

  test('4', () {
    // Given
    var json = {"notNullable": null, "nullable": null};

    // When
    act() => JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(act, throwsWithMessage("type 'Null' is not a subtype of type 'Object' of 'notNullable'"));
  });

  test('5', () {
    // Given
    final now = DateTime.now();
    final json = {"notNullable": "notNullable", "notNullableWithDefault": now };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json, toEncodable: (x) => x.toString()));

    // Then
    expect(result.notNullable, "notNullable");
    expect(result.notNullableWithDefault, now.toString());
    expect(result.nullable, null);
    expect(result.nullableWithDefault, "default");
  });

  test('6', () {
    // Given
    final json = {"notNullable": "notNullable", "nullableWithDefault": "nullableWithDefault" };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, "notNullable");
    expect(result.notNullableWithDefault, "default");
    expect(result.nullable, null);
    expect(result.nullableWithDefault, "nullableWithDefault");
  });

  test('7', () {
    // Given
    final json = {"notNullable": "notNullable", "notNullableWithDefault": "notNullableWithDefault", "nullableWithDefault": "nullableWithDefault" };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, "notNullable");
    expect(result.notNullableWithDefault, "notNullableWithDefault");
    expect(result.nullable, null);
    expect(result.nullableWithDefault, "nullableWithDefault");
  });

  test('8', () {
    // Given
    final json = {"notNullable": "notNullable", "nullable": "nullable", "notNullableWithDefault": "notNullableWithDefault", "nullableWithDefault": "nullableWithDefault" };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, "notNullable");
    expect(result.notNullableWithDefault, "notNullableWithDefault");
    expect(result.nullable, "nullable");
    expect(result.nullableWithDefault, "nullableWithDefault");
  });
}
