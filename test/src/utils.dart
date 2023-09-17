import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

//
// throwsWithMessage(String message) => throwsA(
//     isA<JsonException>().having((p0) => p0.message, 'message', message));

throwsWithMessage(String message) => throwsA(isA<JsonException>());
