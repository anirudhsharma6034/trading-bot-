class BotModel {
  final int? id;
  final String name;
  final String symbol;
  final String strategyName;
  final double initialCapital;
  final double currentCapital;
  final String riskLevel;
  final double stopLoss;
  final double takeProfit;
  final int maxTradesPerDay;
  final int maxOpenPositions;
  final double positionSize;
  final String timeframe;
  final String status; // Running, Paused, Stopped, Completed, Error
  final double pnl;
  final int tradesCount;

  BotModel({
    this.id,
    required this.name,
    required this.symbol,
    required this.strategyName,
    required this.initialCapital,
    required this.currentCapital,
    required this.riskLevel,
    required this.stopLoss,
    required this.takeProfit,
    required this.maxTradesPerDay,
    required this.maxOpenPositions,
    required this.positionSize,
    required this.timeframe,
    required this.status,
    required this.pnl,
    required this.tradesCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'strategy_name': strategyName,
      'initial_capital': initialCapital,
      'current_capital': currentCapital,
      'risk_level': riskLevel,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'max_trades_per_day': maxTradesPerDay,
      'max_open_positions': maxOpenPositions,
      'position_size': positionSize,
      'timeframe': timeframe,
      'status': status,
      'pnl': pnl,
      'trades_count': tradesCount,
    };
  }

  factory BotModel.fromMap(Map<String, dynamic> map) {
    return BotModel(
      id: map['id'],
      name: map['name'] ?? '',
      symbol: map['symbol'] ?? '',
      strategyName: map['strategy_name'] ?? '',
      initialCapital: (map['initial_capital'] ?? 0.0).toDouble(),
      currentCapital: (map['current_capital'] ?? 0.0).toDouble(),
      riskLevel: map['risk_level'] ?? 'Medium',
      stopLoss: (map['stop_loss'] ?? 0.0).toDouble(),
      takeProfit: (map['take_profit'] ?? 0.0).toDouble(),
      maxTradesPerDay: map['max_trades_per_day'] ?? 5,
      maxOpenPositions: map['max_open_positions'] ?? 1,
      positionSize: (map['position_size'] ?? 0.0).toDouble(),
      timeframe: map['timeframe'] ?? '5m',
      status: map['status'] ?? 'Paused',
      pnl: (map['pnl'] ?? 0.0).toDouble(),
      tradesCount: map['trades_count'] ?? 0,
    );
  }
}
