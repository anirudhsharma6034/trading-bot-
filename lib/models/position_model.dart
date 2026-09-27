class PositionModel {
  final int? id;
  final String symbol;
  final int quantity;
  final double averagePrice;
  final double currentPrice;
  final double pnl;
  final double pnlPercent;

  PositionModel({
    this.id,
    required this.symbol,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.pnl,
    required this.pnlPercent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'quantity': quantity,
      'average_price': averagePrice,
      'current_price': currentPrice,
      'pnl': pnl,
      'pnl_percent': pnlPercent,
    };
  }

  factory PositionModel.fromMap(Map<String, dynamic> map) {
    return PositionModel(
      id: map['id'],
      symbol: map['symbol'] ?? '',
      quantity: map['quantity'] ?? 0,
      averagePrice: (map['average_price'] ?? 0.0).toDouble(),
      currentPrice: (map['current_price'] ?? 0.0).toDouble(),
      pnl: (map['pnl'] ?? 0.0).toDouble(),
      pnlPercent: (map['pnl_percent'] ?? 0.0).toDouble(),
    );
  }
}
