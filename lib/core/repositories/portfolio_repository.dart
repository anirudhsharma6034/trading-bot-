import '../database/database_helper.dart';
import '../../models/portfolio_model.dart';

class PortfolioRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<PortfolioModel?> getPortfolio() async {
    final db = await dbHelper.database;
    final result = await db.query('portfolio');
    if (result.isNotEmpty) {
      return PortfolioModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> updatePortfolio(PortfolioModel portfolio) async {
    final db = await dbHelper.database;
    if (portfolio.id != null) {
      await db.update('portfolio', portfolio.toMap(), where: 'id = ?', whereArgs: [portfolio.id]);
    } else {
      await db.insert('portfolio', portfolio.toMap());
    }
  }
}
