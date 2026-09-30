import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:toastification/toastification.dart';
import '../providers/market_provider.dart';
import '../providers/trading_provider.dart';
import '../models/order_model.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;
  const StockDetailScreen({super.key, required this.symbol});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  List<Candle> _candles = [];

  @override
  void initState() {
    super.initState();
    _generateMockCandles();
  }

  void _generateMockCandles() {
    final random = Random();
    List<Candle> candles = [];
    double currentPrice = 1500.0; 

    DateTime date = DateTime.now().subtract(const Duration(days: 60));

    for (int i = 0; i < 60; i++) {
      double change = (random.nextDouble() - 0.5) * 50;
      double open = currentPrice;
      double close = open + change;
      double high = max(open, close) + random.nextDouble() * 20;
      double low = min(open, close) - random.nextDouble() * 20;
      double volume = random.nextDouble() * 1000000;

      candles.add(Candle(
        date: date,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));

      currentPrice = close;
      date = date.add(const Duration(days: 1));
    }
    
    setState(() {
      _candles = candles.reversed.toList();
    });
  }

  void _showOrderBottomSheet(BuildContext context, String side, double currentPrice) {
    HapticFeedback.heavyImpact(); 
    final qtyController = TextEditingController(text: '10');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This allows the bottom sheet to resize properly
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Dynamically shift up above keyboard
        ),
        child: SingleChildScrollView( // Added scroll view inside bottom sheet to prevent overflow
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$side Order - ${widget.symbol}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: side == 'BUY' ? Colors.green : Colors.red)),
                const SizedBox(height: 16),
                Text('Current Price: ₹$currentPrice', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), // Allows numbers and at most one decimal dot
                  ],
                  decoration: const InputDecoration(labelText: 'Quantity', filled: true),
                ),
                const SizedBox(height: 24),
            SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: side == 'BUY' ? Colors.green : Colors.red),
                    onPressed: () {
                      final qtyText = qtyController.text.trim();
                      if (qtyText.isEmpty || double.tryParse(qtyText) == null || double.parse(qtyText) <= 0) {
                        // Show error toast if quantity is invalid
                        toastification.show(
                          context: context,
                          title: const Text('Invalid Quantity', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          description: const Text('Please enter a valid quantity greater than 0', style: TextStyle(color: Colors.white70)),
                          type: ToastificationType.error,
                          style: ToastificationStyle.flat,
                          autoCloseDuration: const Duration(seconds: 3),
                          alignment: Alignment.topCenter,
                          backgroundColor: Colors.red.shade800,
                          icon: const Icon(Icons.error_outline, color: Colors.white),
                          showProgressBar: false,
                        );
                        return; // Stop execution
                      }

                      HapticFeedback.mediumImpact(); 
                      final order = OrderModel(
                        symbol: widget.symbol,
                        type: 'Market',
                        side: side,
                        quantity: double.tryParse(qtyText)?.toInt() ?? 0, // safely parse to Int
                        price: currentPrice,
                        status: 'Executed',
                        timestamp: DateTime.now().toIso8601String(),
                      );
                      Provider.of<TradingProvider>(context, listen: false).placeOrder(order, currentPrice);
                      Navigator.pop(context);
                      
                      // Premium Top-Down Animated Toast Notification
                      toastification.show(
                        context: context,
                        title: Text('Trade Executed', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        description: Text('${side == 'BUY' ? 'Bought' : 'Sold'} $qtyText ${widget.symbol} @ ₹$currentPrice', style: const TextStyle(color: Colors.white70)),
                        type: side == 'BUY' ? ToastificationType.success : ToastificationType.error,
                        style: ToastificationStyle.flat,
                        autoCloseDuration: const Duration(seconds: 3),
                        alignment: Alignment.topCenter,
                        direction: TextDirection.ltr,
                        animationDuration: const Duration(milliseconds: 300),
                        icon: Icon(side == 'BUY' ? Icons.check_circle : Icons.offline_bolt, color: Colors.white),
                        backgroundColor: const Color(0xFF1E293B),
                        showProgressBar: true,
                        closeButtonShowType: CloseButtonShowType.none,
                      );
                    },
                    child: Text('Confirm $side', style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketProv = Provider.of<MarketProvider>(context);
    final stock = marketProv.stocks.firstWhere((s) => s.symbol == widget.symbol, orElse: () => marketProv.stocks.first);

    return Scaffold(
      appBar: AppBar(
        title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                ],
              ),
            ),
            
            // Interactive Candlestick Chart
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: const Color(0xFF0F172A),
                child: Candlesticks(
                  candles: _candles,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat('Open', '₹${stock.open}'),
                      _buildStat('High', '₹${stock.high}'),
                      _buildStat('Low', '₹${stock.low}'),
                      _buildStat('Volume', '${stock.volume}'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Market Depth (Simulated Order Book)
                  const Text('Market Depth', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Bids (Buy)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            const Divider(),
                            _buildDepthRow((stock.currentPrice - 0.5).toStringAsFixed(2), '1,200', Colors.green),
                            _buildDepthRow((stock.currentPrice - 1.2).toStringAsFixed(2), '850', Colors.green),
                            _buildDepthRow((stock.currentPrice - 2.0).toStringAsFixed(2), '3,400', Colors.green),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Asks (Sell)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            const Divider(),
                            _buildDepthRow((stock.currentPrice + 0.4).toStringAsFixed(2), '900', Colors.red),
                            _buildDepthRow((stock.currentPrice + 1.5).toStringAsFixed(2), '2,100', Colors.red),
                            _buildDepthRow((stock.currentPrice + 2.5).toStringAsFixed(2), '1,500', Colors.red),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

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

  Widget _buildDepthRow(String price, String qty, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(qty, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(price, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
