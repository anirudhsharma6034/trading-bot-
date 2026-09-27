class PortfolioModel {
  final int? id;
  final double totalValue;
  final double availableCash;
  final double investedAmount;
  final double todayPnl;
  final double overallPnl;

  PortfolioModel({
    this.id,
    required this.totalValue,
    required this.availableCash,
    required this.investedAmount,
    required this.todayPnl,
    required this.overallPnl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_value': totalValue,
      'available_cash': availableCash,
      'invested_amount': investedAmount,
      'today_pnl': todayPnl,
      'overall_pnl': overallPnl,
    };
  }

  factory PortfolioModel.fromMap(Map<String, dynamic> map) {
    return PortfolioModel(
      id: map['id'],
      totalValue: (map['total_value'] ?? 0.0).toDouble(),
      availableCash: (map['available_cash'] ?? 0.0).toDouble(),
      investedAmount: (map['invested_amount'] ?? 0.0).toDouble(),
      todayPnl: (map['today_pnl'] ?? 0.0).toDouble(),
      overallPnl: (map['overall_pnl'] ?? 0.0).toDouble(),
    );
  }
}
