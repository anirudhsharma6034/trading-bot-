class Stock {
  final String symbol;
  final String name;
  final double currentPrice;
  final double previousClose;
  final double open;
  final double high;
  final double low;
  final int volume;
  final double change;
  final double changePercent;
  final String sector;

  Stock({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.previousClose,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
    required this.change,
    required this.changePercent,
    required this.sector,
  });

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'current_price': currentPrice,
      'previous_close': previousClose,
      'open': open,
      'high': high,
      'low': low,
      'volume': volume,
      'change': change,
      'change_percent': changePercent,
      'sector': sector,
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      currentPrice: (map['current_price'] ?? 0.0).toDouble(),
      previousClose: (map['previous_close'] ?? 0.0).toDouble(),
      open: (map['open'] ?? 0.0).toDouble(),
      high: (map['high'] ?? 0.0).toDouble(),
      low: (map['low'] ?? 0.0).toDouble(),
      volume: map['volume'] ?? 0,
      change: (map['change'] ?? 0.0).toDouble(),
      changePercent: (map['change_percent'] ?? 0.0).toDouble(),
      sector: map['sector'] ?? '',
    );
  }

  Stock copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? previousClose,
    double? open,
    double? high,
    double? low,
    int? volume,
    double? change,
    double? changePercent,
    String? sector,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      previousClose: previousClose ?? this.previousClose,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      volume: volume ?? this.volume,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      sector: sector ?? this.sector,
    );
  }
}
