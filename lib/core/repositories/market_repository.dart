import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/stock_model.dart';

class MarketRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Stock>> getStocks() async {
    final db = await dbHelper.database;
    final result = await db.query('stocks');
    return result.map((map) => Stock.fromMap(map)).toList();
  }

  Future<Stock?> getStockBySymbol(String symbol) async {
    final db = await dbHelper.database;
    final result = await db.query('stocks', where: 'symbol = ?', whereArgs: [symbol]);
    if (result.isNotEmpty) {
      return Stock.fromMap(result.first);
    }
    return null;
  }

  Future<List<Stock>> getWatchlistStocks() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT s.* FROM stocks s
      JOIN watchlist w ON s.symbol = w.symbol
    ''');
    return result.map((map) => Stock.fromMap(map)).toList();
  }

  Future<void> addToWatchlist(String symbol) async {
    final db = await dbHelper.database;
    await db.insert('watchlist', {'symbol': symbol}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeFromWatchlist(String symbol) async {
    final db = await dbHelper.database;
    await db.delete('watchlist', where: 'symbol = ?', whereArgs: [symbol]);
  }

  Future<void> updateStockPrice(String symbol, double newPrice, double change, double changePercent) async {
    final db = await dbHelper.database;
    await db.update(
      'stocks',
      {
        'current_price': newPrice,
        'change': change,
        'change_percent': changePercent,
      },
      where: 'symbol = ?',
      whereArgs: [symbol],
    );
  }
}
