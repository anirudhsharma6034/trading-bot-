import '../database/database_helper.dart';
import '../../models/order_model.dart';
import '../../models/position_model.dart';
import '../../models/trade_model.dart';

class TradingRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<OrderModel>> getOrders() async {
    final db = await dbHelper.database;
    final result = await db.query('orders', orderBy: 'id DESC');
    return result.map((map) => OrderModel.fromMap(map)).toList();
  }

  Future<int> insertOrder(OrderModel order) async {
    final db = await dbHelper.database;
    return await db.insert('orders', order.toMap());
  }

  Future<List<PositionModel>> getPositions() async {
    final db = await dbHelper.database;
    final result = await db.query('positions');
    return result.map((map) => PositionModel.fromMap(map)).toList();
  }

  Future<List<TradeModel>> getTrades() async {
    final db = await dbHelper.database;
    final result = await db.query('trades', orderBy: 'id DESC');
    return result.map((map) => TradeModel.fromMap(map)).toList();
  }

  Future<void> executeTrade(OrderModel order, double executionPrice) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      // 1. Insert order as Executed
      await txn.insert('orders', {
        'symbol': order.symbol,
        'type': order.type,
        'side': order.side,
        'quantity': order.quantity,
        'price': executionPrice,
        'stop_price': order.stopPrice,
        'status': 'Executed',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // 2. Add to trades table
      await txn.insert('trades', {
        'symbol': order.symbol,
        'side': order.side,
        'quantity': order.quantity,
        'entry_price': executionPrice,
        'exit_price': executionPrice,
        'pnl': 0.0,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // 3. Update positions / portfolio cash
      final existingPosition = await txn.query('positions', where: 'symbol = ?', whereArgs: [order.symbol]);
      if (existingPosition.isNotEmpty) {
        final pos = PositionModel.fromMap(existingPosition.first);
        if (order.side == 'BUY') {
          final newQty = pos.quantity + order.quantity;
          final newAvgPrice = ((pos.quantity * pos.averagePrice) + (order.quantity * executionPrice)) / newQty;
          await txn.update('positions', {
            'quantity': newQty,
            'average_price': newAvgPrice,
            'current_price': executionPrice,
            'pnl': (executionPrice - newAvgPrice) * newQty,
            'pnl_percent': ((executionPrice - newAvgPrice) / newAvgPrice) * 100,
          }, where: 'symbol = ?', whereArgs: [order.symbol]);
        } else {
          // Sell
          final newQty = pos.quantity - order.quantity;
          if (newQty <= 0) {
            await txn.delete('positions', where: 'symbol = ?', whereArgs: [order.symbol]);
          } else {
            await txn.update('positions', {
              'quantity': newQty,
              'current_price': executionPrice,
              'pnl': (executionPrice - pos.averagePrice) * newQty,
              'pnl_percent': ((executionPrice - pos.averagePrice) / pos.averagePrice) * 100,
            }, where: 'symbol = ?', whereArgs: [order.symbol]);
          }
        }
      } else if (order.side == 'BUY') {
        await txn.insert('positions', {
          'symbol': order.symbol,
          'quantity': order.quantity,
          'average_price': executionPrice,
          'current_price': executionPrice,
          'pnl': 0.0,
          'pnl_percent': 0.0,
        });
      }

      // Update portfolio cash & invested amount
      final portfolioResult = await txn.query('portfolio');
      if (portfolioResult.isNotEmpty) {
        final p = portfolioResult.first;
        double cash = (p['available_cash'] as double);
        double invested = (p['invested_amount'] as double);
        double totalVal = (p['total_value'] as double);
        double cost = order.quantity * executionPrice;

        if (order.side == 'BUY') {
          cash -= cost;
          invested += cost;
        } else {
          cash += cost;
          invested -= cost;
        }
        totalVal = cash + invested;

        await txn.update('portfolio', {
          'available_cash': cash,
          'invested_amount': invested,
          'total_value': totalVal,
        }, where: 'id = ?', whereArgs: [p['id']]);
      }
    });
  }
}
