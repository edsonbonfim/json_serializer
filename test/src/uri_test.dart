import 'dart:convert';

import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

import 'utils.dart';

class Sample {
  final Uri notNullable;
  final Uri? nullable;

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
    var json = {"notNullable": "https://dart.dev/guides/libraries/library-tour#utility-classes", "nullable": "https://dart.dev"};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, Uri.parse("https://dart.dev/guides/libraries/library-tour#utility-classes"));
    expect(result.nullable, Uri.parse("https://dart.dev"));
  });

  test('2', () {
    // Given
    var json = {"notNullable": "https://dart.dev", "nullable": null};

    // When
    var result = JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(result.notNullable, Uri.parse("https://dart.dev"));
    expect(result.nullable, null);
  });

  test('3', () {
    // Given
    var json = {"notNullable": null, "nullable": "https://dart.dev"};

    // When
    act() => JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(act, throwsWithMessage("type 'Null' is not a subtype of type 'Uri' of 'notNullable'"));
  });

  test('4', () {
    // Given
    var json = {"notNullable": null, "nullable": null};

    // When
    act() => JsonSerializer.deserialize<Sample>(jsonEncode(json));

    // Then
    expect(act, throwsWithMessage("type 'Null' is not a subtype of type 'Uri' of 'notNullable'"));
  });
}
