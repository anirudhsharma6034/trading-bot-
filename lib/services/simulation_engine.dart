import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../core/repositories/market_repository.dart';
import '../core/repositories/bot_repository.dart';
import '../core/repositories/trading_repository.dart';
import '../models/order_model.dart';
import '../providers/market_provider.dart';

class SimulationEngine {
  static final SimulationEngine instance = SimulationEngine._init();
  Timer? _timer;
  final MarketRepository _marketRepo = MarketRepository();
  final BotRepository _botRepo = BotRepository();
  final TradingRepository _tradingRepo = TradingRepository();
  bool _isRunning = false;
  MarketProvider? _marketProvider; // Reference to MarketProvider

  SimulationEngine._init();

  bool get isRunning => _isRunning;

  // Added parameter to pass MarketProvider for dynamic news updates
  void startSimulation(Function onTick, {MarketProvider? marketProvider}) {
    if (_isRunning) return;
    _isRunning = true;
    _marketProvider = marketProvider;

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      try {
        final stocks = await _marketRepo.getStocks();
        final random = Random();

        // Simulate Price Movement
        for (var stock in stocks) {
          // fluctuate price by -0.5% to +0.5%
          double changePercent = (random.nextDouble() - 0.48) * 1.0;
          double newPrice = stock.currentPrice * (1 + (changePercent / 100));
          double newChange = newPrice - stock.previousClose;
          double newChangePercent = (newChange / stock.previousClose) * 100;

          await _marketRepo.updateStockPrice(
            stock.symbol, 
            double.parse(newPrice.toStringAsFixed(2)), 
            double.parse(newChange.toStringAsFixed(2)), 
            double.parse(newChangePercent.toStringAsFixed(2))
          );
        }
        
        // Dynamically trigger simulated news generation
        if (_marketProvider != null) {
          _marketProvider!.generateRandomNews();
        }
        
        onTick(); // Update UI
        
        // Simulate background Bot Execution logic
        _simulateBotTrades(stocks);

      } catch (e) {
        debugPrint('Simulation tick error: $e');
      }
    });
  }

  Future<void> _simulateBotTrades(List<dynamic> stocks) async {
    final activeBots = await _botRepo.getBots();
    final runningBots = activeBots.where((b) => b.status == 'Running').toList();
    final random = Random();

    for (var bot in runningBots) {
      // 10% chance a running bot triggers a trade in every tick
      if (random.nextDouble() > 0.90) {
        String side = random.nextBool() ? 'BUY' : 'SELL';
        final stock = stocks.firstWhere((s) => s.symbol == bot.symbol, orElse: () => stocks.first);
        double currentPrice = stock.currentPrice;
        int qty = bot.positionSize.toInt();

        // Create Order
        final order = OrderModel(
          symbol: bot.symbol,
          type: 'Market',
          side: side,
          quantity: qty,
          price: currentPrice,
          status: 'Executed',
          timestamp: DateTime.now().toIso8601String(),
        );

        // Execute background trade
        await _tradingRepo.executeTrade(order, currentPrice);
        
        // Log bot activity
        await _botRepo.addBotLog(bot.id!, 'Strategy [${bot.strategyName}] triggered $side $qty @ ₹${currentPrice.toStringAsFixed(2)}');

        // Show global Top-Down Animated Toast
        toastification.show(
          title: Text('Bot Executed Trade', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          description: Text('${bot.name} ${side.toLowerCase()} $qty ${bot.symbol} @ ₹${currentPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
          type: side == 'BUY' ? ToastificationType.success : ToastificationType.warning,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 4),
          alignment: Alignment.topRight,
          direction: TextDirection.ltr,
          animationDuration: const Duration(milliseconds: 300),
          icon: Icon(side == 'BUY' ? Icons.trending_up : Icons.trending_down, color: Colors.white),
          backgroundColor: const Color(0xFF1E293B),
          showProgressBar: true,
          closeButtonShowType: CloseButtonShowType.none,
        );
      }
    }
  }

  void stopSimulation() {
    _timer?.cancel();
    _isRunning = false;
  }
}
