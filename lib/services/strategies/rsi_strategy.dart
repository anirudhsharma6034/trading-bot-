class RsiStrategy {
  static double calculateRsi(List<double> prices, {int period = 14}) {
    if (prices.length < period + 1) return 50.0;

    double gainSum = 0;
    double lossSum = 0;

    for (int i = prices.length - period; i < prices.length; i++) {
      double diff = prices[i] - prices[i - 1];
      if (diff > 0) {
        gainSum += diff;
      } else {
        lossSum += diff.abs();
      }
    }

    double avgGain = gainSum / period;
    double avgLoss = lossSum / period;

    if (avgLoss == 0) return 100.0;
    double rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  static String evaluate(List<double> prices, {double oversold = 30.0, double overbought = 70.0}) {
    double rsi = calculateRsi(prices);
    if (rsi < oversold) {
      return 'BUY';
    } else if (rsi > overbought) {
      return 'SELL';
    }
    return 'HOLD';
  }
}
