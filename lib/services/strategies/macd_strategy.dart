class MacdStrategy {
  static String evaluate(List<double> prices, {int fastPeriod = 12, int slowPeriod = 26, int signalPeriod = 9}) {
    if (prices.length < slowPeriod + signalPeriod) return 'HOLD';

    // Simple MACD simulation calculation
    double fastEMA = _calculateEMA(prices, fastPeriod);
    double slowEMA = _calculateEMA(prices, slowPeriod);
    double macdLine = fastEMA - slowEMA;

    if (macdLine > 0) {
      return 'BUY';
    } else if (macdLine < 0) {
      return 'SELL';
    }
    return 'HOLD';
  }

  static double _calculateEMA(List<double> prices, int period) {
    if (prices.isEmpty) return 0;
    double sum = 0;
    int count = prices.length >= period ? period : prices.length;
    for (int i = prices.length - count; i < prices.length; i++) {
      sum += prices[i];
    }
    return sum / count;
  }
}
