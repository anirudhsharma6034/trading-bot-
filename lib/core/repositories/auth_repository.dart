import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class AuthRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<bool> login(String email, String password) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
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
}
