import 'dart:convert';

import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

import 'utils.dart';

class Sample {
  final DateTime notNullable;
  final DateTime? nullable;

  Sample({
    required this.notNullable,
    this.nullable,
  });
}

void main() {
  setUp(() {
    JsonSerializer.options = JsonSerializerOptions(userTypes: [UserType<Sample>(Sample.new),]);
  });

  test('1', () {
    // Given
    var now = DateTime.now();
    var tomorrow = now.add(Duration(days: 1));
    var json = {"notNullable": now, "nullable": tomorrow};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json, toEncodable: (x) => x.toString()));

    // Then
    expect(result.notNullable, now);
    expect(result.nullable, tomorrow);
  });

  test('2', () {
    // Given
    var now = DateTime.now();
    var json = {"notNullable": now, "nullable": null};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json, toEncodable: (x) => x.toString()));

    // Then
    expect(result.notNullable, now);
    expect(result.nullable, null);
  });

  test('3', () {
    // Given
    var json = {"notNullable": null, "nullable": 20};

    // When
    act() => JsonSerializer.deserialize<Sample>(jsonEncode(json, toEncodable: (x) => x.toString()));

    // Then
    expect(act, throwsWithMessage("type 'Null' is not a subtype of type 'DateTime' of 'notNullable'"));
  });

  test('4', () {
    // Given
    var json = {"notNullable": null, "nullable": null};

    // When
    act() => JsonSerializer.deserialize<Sample>(jsonEncode(json, toEncodable: (x) => x.toString()));

    // Then
    expect(act, throwsWithMessage("type 'Null' is not a subtype of type 'DateTime' of 'notNullable'"));
  });
}
