import 'dart:async';
import 'dart:math';
import '../core/repositories/market_repository.dart';

class SimulationEngine {
  static final SimulationEngine instance = SimulationEngine._init();
  Timer? _timer;
  final MarketRepository _marketRepo = MarketRepository();
  bool _isRunning = false;

  SimulationEngine._init();

  bool get isRunning => _isRunning;

  void startSimulation(Function onTick) {
    if (_isRunning) return;
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final stocks = await _marketRepo.getStocks();
        final random = Random();

        for (var stock in stocks) {
          // fluctuate price by -0.5% to +0.5%
          double changePercent = (random.nextDouble() - 0.48) * 1.0;
          double newPrice = stock.currentPrice * (1 + (changePercent / 100));
          double newChange = newPrice - stock.previousClose;
          double newChangePercent = (newChange / stock.previousClose) * 100;

          await _marketRepo.updateStockPrice(stock.symbol, double.parse(newPrice.toStringAsFixed(2)), double.parse(newChange.toStringAsFixed(2)), double.parse(newChangePercent.toStringAsFixed(2)));
        }

        onTick();
      } catch (e) {
        print('Simulation tick error: $e');
      }
    });
  }

  void stopSimulation() {
    _timer?.cancel();
    _isRunning = false;
  }
}
