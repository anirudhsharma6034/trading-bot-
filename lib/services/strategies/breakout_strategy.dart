class BreakoutStrategy {
  static String evaluate(List<double> prices, {int lookback = 20}) {
    if (prices.length < lookback + 1) return 'HOLD';

    double currentPrice = prices.last;
    double highestHigh = 0;
    double lowestLow = double.infinity;

    for (int i = prices.length - lookback - 1; i < prices.length - 1; i++) {
      if (prices[i] > highestHigh) highestHigh = prices[i];
      if (prices[i] < lowestLow) lowestLow = prices[i];
    }

    if (currentPrice > highestHigh) {
      return 'BUY'; // Resistance breakout
    } else if (currentPrice < lowestLow) {
      return 'SELL'; // Support breakdown
    }
    return 'HOLD';
  }
}
