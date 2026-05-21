import '../database_helper.dart';
import '../../models/task_model.dart';

class TaskRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertTask(TaskModel task) async {
    final db = await dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<TaskModel>> getTasksByUser(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return result.map((json) => TaskModel.fromMap(json)).toList();
  }

  Future<int> updateTaskStatus(int taskId, String status) async {
    final db = await dbHelper.database;
    return await db.update(
      'tasks',
      {'status': status},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<int> deleteTask(int taskId) async {
    final db = await dbHelper.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
