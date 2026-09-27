import '../database/database_helper.dart';
import '../../models/bot_model.dart';

class BotRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<BotModel>> getBots() async {
    final db = await dbHelper.database;
    final result = await db.query('bots', orderBy: 'id DESC');
    return result.map((map) => BotModel.fromMap(map)).toList();
  }

  Future<int> insertBot(BotModel bot) async {
    final db = await dbHelper.database;
    return await db.insert('bots', bot.toMap());
  }

  Future<void> updateBotStatus(int id, String status) async {
    final db = await dbHelper.database;
    await db.update('bots', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteBot(int id) async {
    final db = await dbHelper.database;
    await db.delete('bots', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getBotLogs(int botId) async {
    final db = await dbHelper.database;
    return await db.query('bot_logs', where: 'bot_id = ?', whereArgs: [botId], orderBy: 'id DESC');
  }

  Future<void> addBotLog(int botId, String message) async {
    final db = await dbHelper.database;
    await db.insert('bot_logs', {
      'bot_id': botId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
