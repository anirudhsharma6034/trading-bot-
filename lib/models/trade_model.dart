class TradeModel {
  final int? id;
  final String symbol;
  final String side; // BUY, SELL
  final int quantity;
  final double entryPrice;
  final double exitPrice;
  final double pnl;
  final String timestamp;

  TradeModel({
    this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.entryPrice,
    required this.exitPrice,
    required this.pnl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'quantity': quantity,
      'entry_price': entryPrice,
      'exit_price': exitPrice,
      'pnl': pnl,
      'timestamp': timestamp,
    };
  }

  factory TradeModel.fromMap(Map<String, dynamic> map) {
    return TradeModel(
      id: map['id'],
      symbol: map['symbol'] ?? '',
      side: map['side'] ?? 'BUY',
      quantity: map['quantity'] ?? 0,
      entryPrice: (map['entry_price'] ?? 0.0).toDouble(),
      exitPrice: (map['exit_price'] ?? 0.0).toDouble(),
      pnl: (map['pnl'] ?? 0.0).toDouble(),
      timestamp: map['timestamp'] ?? '',
    );
  }
}
