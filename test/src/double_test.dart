import 'dart:convert';

import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

import 'utils.dart';

class Sample {
  final double notNullable;
  final double notNullableWithDefault;
  final double? nullable;
  final double? nullableWithDefault;

  Sample({
    required this.notNullable,
    this.notNullableWithDefault = 0.0,
    this.nullable,
    this.nullableWithDefault = 0.0,
  });
}

void main() {
  setUp(() {
    JsonSerializer.options = JsonSerializerOptions(userTypes: [UserType<Sample>(Sample.new),]);
  });

  test('1', () {
    // Given
    var json = {"notNullable": 10.0, "nullable": 20.0};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, 10.0);
    expect(result.notNullableWithDefault, 0.0);
    expect(result.nullable, 20.0);
    expect(result.nullableWithDefault, 0.0);
  });

  test('2', () {
    // Given
    var json = {"notNullable": 10.0, "nullable": null};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, 10.0);
    expect(result.notNullableWithDefault, 0.0);
    expect(result.nullable, null);
    expect(result.nullableWithDefault, 0.0);
  });

  test('3', () {
    // Given
    var json = {"notNullable": null, "nullable": 20.0};

    // When
    act() => JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(act, throwsWithMessage("type 'Null' is not a subtype of type 'double' of 'notNullable'"));
  });

  test('4', () {
    // Given
    var json = {"notNullable": null, "nullable": null};

    // When
    act() => JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(act, throwsWithMessage("type 'Null' is not a subtype of type 'double' of 'notNullable'"));
  });

  test('5', () {
    // Given
    final json = {"notNullable": 10.0, "notNullableWithDefault": 20.0 };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, 10.0);
    expect(result.notNullableWithDefault, 20.0);
    expect(result.nullable, null);
    expect(result.nullableWithDefault, 0.0);
  });

  test('6', () {
    // Given
    final json = {"notNullable": 10.0, "nullableWithDefault": 20.0 };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, 10.0);
    expect(result.notNullableWithDefault, 0.0);
    expect(result.nullable, null);
    expect(result.nullableWithDefault, 20.0);
  });

  test('7', () {
    // Given
    final json = {"notNullable": 10.0, "notNullableWithDefault": 20.0, "nullableWithDefault": 30.0 };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, 10.0);
    expect(result.notNullableWithDefault, 20.0);
    expect(result.nullable, null);
    expect(result.nullableWithDefault, 30.0);
  });

  test('8', () {
    // Given
    final json = {"notNullable": 10.0, "nullable": 20.0, "notNullableWithDefault": 30.0, "nullableWithDefault": 40.0 };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, 10.0);
    expect(result.notNullableWithDefault, 30.0);
    expect(result.nullable, 20.0);
    expect(result.nullableWithDefault, 40.0);
  });

  test('9', () {
    // Given
    final json = {"notNullable": "10.0", "nullable": "20.0", "notNullableWithDefault": "30.0", "nullableWithDefault": "40.0" };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, 10.0);
    expect(result.notNullableWithDefault, 30.0);
    expect(result.nullable, 20.0);
    expect(result.nullableWithDefault, 40.0);
  });
}
