import 'dart:convert';

import 'package:json_serializer/json_serializer.dart';
import 'package:json_serializer/src/user_type.dart';
import 'package:test/test.dart';

import 'utils.dart';

class Sample {
  final BigInt notNullable;
  final BigInt? nullable;

  Sample({
    required this.notNullable,
    this.nullable,
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
    var json = {"notNullable": 10, "nullable": 20};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, BigInt.from(10));
    expect(result.nullable, BigInt.from(20));
  });

  test('2', () {
    // Given
    var json = {"notNullable": 10, "nullable": null};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, BigInt.from(10));
    expect(result.nullable, null);
  });

  test('3', () {
    // Given
    var json = {"notNullable": null, "nullable": 20};

    // When
    act() => JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(
        act,
        throwsWithMessage(
            "type 'Null' is not a subtype of type 'BigInt' of 'notNullable'"));
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
            "type 'Null' is not a subtype of type 'BigInt' of 'notNullable'"));
  });

  test('6', () {
    // Given
    var json = {
      "notNullable": "0x1ffffffffffffffff",
      "nullable": "12345678901234567890"
    };

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, BigInt.parse("0x1ffffffffffffffff"));
    expect(result.nullable, BigInt.parse("12345678901234567890"));
  });
}
