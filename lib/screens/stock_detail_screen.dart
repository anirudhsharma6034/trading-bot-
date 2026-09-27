import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/market_provider.dart';
import '../providers/trading_provider.dart';
import '../models/order_model.dart';

class StockDetailScreen extends StatelessWidget {
  final String symbol;
  const StockDetailScreen({super.key, required this.symbol});

  void _showOrderBottomSheet(BuildContext context, String side, double currentPrice) {
    final qtyController = TextEditingController(text: '10');

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$side Order - $symbol', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: side == 'BUY' ? Colors.green : Colors.red)),
            const SizedBox(height: 16),
            Text('Current Price: ₹$currentPrice', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity', filled: true),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: side == 'BUY' ? Colors.green : Colors.red),
                onPressed: () {
                  final order = OrderModel(
                    symbol: symbol,
                    type: 'Market',
                    side: side,
                    quantity: int.parse(qtyController.text),
                    price: currentPrice,
                    status: 'Executed',
                    timestamp: DateTime.now().toIso8601String(),
                  );
                  Provider.of<TradingProvider>(context, listen: false).placeOrder(order, currentPrice);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$side order executed successfully!')));
                },
                child: Text('Confirm $side', style: const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketProv = Provider.of<MarketProvider>(context);
    final stock = marketProv.stocks.firstWhere((s) => s.symbol == symbol, orElse: () => marketProv.stocks.first);

    return Scaffold(
      appBar: AppBar(
        title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stock.name, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('₹${stock.currentPrice}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Text('${stock.change >= 0 ? '+' : ''}${stock.changePercent}%', style: TextStyle(color: stock.change >= 0 ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            // Candlestick / Line Chart Placeholder using fl_chart
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 100),
                        FlSpot(1, 105),
                        FlSpot(2, 102),
                        FlSpot(3, 110),
                        FlSpot(4, 108),
                        FlSpot(5, 115),
                      ],
                      isCurved: true,
                      color: const Color(0xFF3B82F6),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Open', '₹${stock.open}'),
                _buildStat('High', '₹${stock.high}'),
                _buildStat('Low', '₹${stock.low}'),
                _buildStat('Volume', '${stock.volume}'),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () => _showOrderBottomSheet(context, 'BUY', stock.currentPrice),
                    child: const Text('BUY', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () => _showOrderBottomSheet(context, 'SELL', stock.currentPrice),
                    child: const Text('SELL', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
