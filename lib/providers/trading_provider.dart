import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/position_model.dart';
import '../models/trade_model.dart';
import '../core/repositories/trading_repository.dart';

class TradingProvider extends ChangeNotifier {
  final TradingRepository _tradingRepo = TradingRepository();

  List<OrderModel> _orders = [];
  List<PositionModel> _positions = [];
  List<TradeModel> _trades = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  List<PositionModel> get positions => _positions;
  List<TradeModel> get trades => _trades;
  bool get isLoading => _isLoading;

  Future<void> loadTradingData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _tradingRepo.getOrders();
      _positions = await _tradingRepo.getPositions();
      _trades = await _tradingRepo.getTrades();
    } catch (e) {
      debugPrint('Error loading trading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> placeOrder(OrderModel order, double currentPrice) async {
    try {
      await _tradingRepo.executeTrade(order, currentPrice);
      await loadTradingData();
    } catch (e) {
      debugPrint('Error placing order: $e');
    }
  }
}
