import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/user_model.dart';

class AuthRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<dynamic> login(String email, String password) async {
    final db = await dbHelper.database;
    
    final emailCheck = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (emailCheck.isEmpty) {
      return 'invalid_email';
    }

    final user = emailCheck.first;
    if (user['password'] != password) {
      return 'invalid_password';
    }

    return UserModel.fromMap(user); // Success: Return user model
  }

  Future<bool> register(String name, String email, String password) async {
    final db = await dbHelper.database;
    try {
      final existing = await db.query('users', where: 'email = ?', whereArgs: [email]);
      if (existing.isNotEmpty) return false;

      await db.insert('users', {
        'name': name,
        'email': email,
        'password': password,
        'balance': 100000.0,
        'available_cash': 75000.0,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateProfile(int userId, String newName) async {
    final db = await dbHelper.database;
    await db.update('users', {'name': newName}, where: 'id = ?', whereArgs: [userId]);
  }
}
