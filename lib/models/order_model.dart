class OrderModel {
  final int? id;
  final String symbol;
  final String type; // Market, Limit, Stop Loss
  final String side; // BUY, SELL
  final int quantity;
  final double price;
  final double? stopPrice;
  final String status; // Pending, Executed, Cancelled, Rejected
  final String timestamp;

  OrderModel({
    this.id,
    required this.symbol,
    required this.type,
    required this.side,
    required this.quantity,
    required this.price,
    this.stopPrice,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'type': type,
      'side': side,
      'quantity': quantity,
      'price': price,
      'stop_price': stopPrice,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      symbol: map['symbol'] ?? '',
      type: map['type'] ?? 'Market',
      side: map['side'] ?? 'BUY',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      stopPrice: map['stop_price'] != null ? (map['stop_price']).toDouble() : null,
      status: map['status'] ?? 'Pending',
      timestamp: map['timestamp'] ?? '',
    );
  }
}
