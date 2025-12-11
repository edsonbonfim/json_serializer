import 'package:json_serializer/json_serializer.dart';
import 'package:test/test.dart';

void main() {
  group('https://github.com/edsonbonfim/json_serializer/issues/1', () {
    setUp(() {
      JsonSerializer.options = JsonSerializerOptions(types: [
        UserType<Node>(Node.new),
      ]);
    });

    test('https://github.com/edsonbonfim/json_serializer/issues/1', () {
      var json = '''{
"id": 1,
"parentId": null,
"name": "Root",
"children": [
{
"id": 2,
"parentId": 1,
"name": "Folder A",
"children": [
{"id": 4, "parentId": 2, "name": "File 1"},
{"id": 5, "parentId": 2, "name": "File 2"}
]
},
{
"id": 3,
"parentId": 1,
"name": "Folder B",
"children": [
{"id": 6, "parentId": 3, "name": "File 3"},
{"id": 7, "parentId": 3, "name": "File 3"}
]
}
]
}''';

      var result = deserialize<Node>(json);

      expect(result.id, equals(1));
      expect(result.parentId, isNull);
      expect(result.name, equals('Root'));
      expect(result.children, isNotNull);
      expect(result.children!.length, equals(2));

      var folderA = result.children![0];
      expect(folderA.id, equals(2));
      expect(folderA.parentId, equals(1));
      expect(folderA.name, equals('Folder A'));
      expect(folderA.children, isNotNull);
      expect(folderA.children!.length, equals(2));

      var file1 = folderA.children![0];
      expect(file1.id, equals(4));
      expect(file1.parentId, equals(2));
      expect(file1.name, equals('File 1'));
      expect(file1.children, isNull);

      var file2 = folderA.children![1];
      expect(file2.id, equals(5));
      expect(file2.parentId, equals(2));
      expect(file2.name, equals('File 2'));
      expect(file2.children, isNull);

      var folderB = result.children![1];
      expect(folderB.id, equals(3));
      expect(folderB.parentId, equals(1));
      expect(folderB.name, equals('Folder B'));
      expect(folderB.children, isNotNull);
      expect(folderB.children!.length, equals(2));

      var file3a = folderB.children![0];
      expect(file3a.id, equals(6));
      expect(file3a.parentId, equals(3));
      expect(file3a.name, equals('File 3'));
      expect(file3a.children, isNull);

      var file3b = folderB.children![1];
      expect(file3b.id, equals(7));
      expect(file3b.parentId, equals(3));
      expect(file3b.name, equals('File 3'));
      expect(file3b.children, isNull);
    });
  });
}

class Node {
  final int id;
  final int? parentId;
  final String name;
  final List<Node>? children;

  Node({
    required this.id,
    required this.parentId,
    required this.name,
    this.children,
  });
}
