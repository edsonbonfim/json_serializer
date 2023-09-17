import 'dart:convert';

import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

import 'utils.dart';

class Sample {
  final bool notNullable;
  final bool notNullableWithDefault;
  final bool? nullable;
  final bool? nullableWithDefault;

  Sample({
    required this.notNullable,
    this.notNullableWithDefault = true,
    this.nullable,
    this.nullableWithDefault = true,
  });
}

void main() {
  setUp(() {
    JsonSerializer.options = JsonSerializerOptions(userTypes: [
      UserType<Sample>(Sample.new),
    ]);
  });

  test('1', () {
    // Given
    var json = {"notNullable": true, "nullable": true};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, true);
    expect(result.notNullableWithDefault, true);
    expect(result.nullable, true);
    expect(result.nullableWithDefault, true);
  });

  test('2', () {
    // Given
    var json = {"notNullable": true, "nullable": null};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, true);
    expect(result.notNullableWithDefault, true);
    expect(result.nullable, null);
    expect(result.nullableWithDefault, true);
  });

  test('3', () {
    // Given
    var json = {"notNullable": null, "nullable": true};

    // When
    act() => JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(
        act,
        throwsWithMessage(
            "type 'Null' is not a subtype of type 'bool' of 'notNullable'"));
  });

  test('4', () {
    // Given
    var json = {"notNullable": null, "nullable": null};

    // When
    act() => JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(
        act,
        throwsWithMessage(
            "type 'Null' is not a subtype of type 'bool' of 'notNullable'"));
  });

  test('5', () {
    // Given
    final json = {"notNullable": true, "notNullableWithDefault": false};

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, true);
    expect(result.notNullableWithDefault, false);
    expect(result.nullable, null);
    expect(result.nullableWithDefault, true);
  });

  test('6', () {
    // Given
    final json = {"notNullable": false, "nullableWithDefault": false};

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, false);
    expect(result.notNullableWithDefault, true);
    expect(result.nullable, null);
    expect(result.nullableWithDefault, false);
  });

  test('7', () {
    // Given
    final json = {
      "notNullable": true,
      "notNullableWithDefault": false,
      "nullableWithDefault": false
    };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, true);
    expect(result.notNullableWithDefault, false);
    expect(result.nullable, null);
    expect(result.nullableWithDefault, false);
  });

  test('8', () {
    // Given
    final json = {
      "notNullable": true,
      "nullable": true,
      "notNullableWithDefault": false,
      "nullableWithDefault": false
    };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, true);
    expect(result.notNullableWithDefault, false);
    expect(result.nullable, true);
    expect(result.nullableWithDefault, false);
  });

  test('9', () {
    // Given
    final json = {
      "notNullable": "true",
      "nullable": "true",
      "notNullableWithDefault": "false",
      "nullableWithDefault": "false"
    };

    // When
    final result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, true);
    expect(result.notNullableWithDefault, false);
    expect(result.nullable, true);
    expect(result.nullableWithDefault, false);
  });
}
