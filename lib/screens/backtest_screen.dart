import 'package:flutter/material.dart';

class BacktestScreen extends StatefulWidget {
  const BacktestScreen({super.key});

  @override
  State<BacktestScreen> createState() => _BacktestScreenState();
}

class _BacktestScreenState extends State<BacktestScreen> {
  bool _isBacktesting = false;
  bool _hasResults = false;

  void _runBacktest() {
    setState(() => _isBacktesting = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isBacktesting = false;
          _hasResults = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Strategy Backtesting', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Strategy & Parameters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: 'Moving Average Crossover',
              dropdownColor: const Color(0xFF1E293B),
              decoration: const InputDecoration(filled: true, border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Moving Average Crossover', child: Text('Moving Average Crossover')),
                DropdownMenuItem(value: 'RSI Oversold/Overbought', child: Text('RSI Oversold/Overbought')),
                DropdownMenuItem(value: 'MACD Histogram', child: Text('MACD Histogram')),
              ],
              onChanged: (val) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                onPressed: _isBacktesting ? null : _runBacktest,
                child: _isBacktesting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Run Backtest', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 32),
            if (_hasResults) ...[
              const Text('Backtest Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Net Profit', style: TextStyle(color: Colors.grey)),
                        Text('+₹12,450.00', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Win Rate', style: TextStyle(color: Colors.grey)),
                        Text('72.4%', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Trades', style: TextStyle(color: Colors.grey)),
                        Text('45', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Max Drawdown', style: TextStyle(color: Colors.grey)),
                        Text('-4.2%', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
