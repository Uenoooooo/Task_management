import '../database_helper.dart';
import '../../models/user_model.dart';

class AuthRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> register(UserModel user) async {
    final db = await dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> login(String email, String password) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }
}
