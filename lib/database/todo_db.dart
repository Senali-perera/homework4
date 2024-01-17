import 'package:sqflite/sqflite.dart';

import '../todo/todo.dart';
import 'database_service.dart';

class TodoDB {
  final tableName = 'todos';

  Future<void> createTable(Database database) async {
    await database.execute(""" CREATE TABLE IF NOT EXISTS $tableName (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "isDone" INTEGER NOT NULL,
    "imagePath" TEXT
    )""");
  }

  Future<void> insertTodo(Todo todo) async {
    final database = await DatabaseService().database;
    await database.insert(
      tableName,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> loadAllTodos() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(tableName);
    return List.generate(maps.length, (i) {
      return Todo(
        maps[i]['id'] as String,
        maps[i]['title'] as String,
        maps[i]['isDone'] == 0 ? true : false,
        maps[i]['description'] as String,
        imagePath: maps[i]['imagePath'] as String,
      );
    });
  }

  Future<void> deleteTodo(String id) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
