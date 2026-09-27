class MovingAverageStrategy {
  static String evaluate(List<double> prices, {int shortPeriod = 9, int longPeriod = 21}) {
    if (prices.length < longPeriod) return 'HOLD';

    double shortSum = 0;
    for (int i = prices.length - shortPeriod; i < prices.length; i++) {
      shortSum += prices[i];
    }
    double shortMA = shortSum / shortPeriod;

    double longSum = 0;
    for (int i = prices.length - longPeriod; i < prices.length; i++) {
      longSum += prices[i];
    }
    double longMA = longSum / longPeriod;

    if (shortMA > longMA) {
      return 'BUY';
    } else if (shortMA < longMA) {
      return 'SELL';
    }
    return 'HOLD';
  }
}
