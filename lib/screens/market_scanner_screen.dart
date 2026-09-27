import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/market_provider.dart';

class MarketScannerScreen extends StatefulWidget {
  const MarketScannerScreen({super.key});

  @override
  State<MarketScannerScreen> createState() => _MarketScannerScreenState();
}

class _MarketScannerScreenState extends State<MarketScannerScreen> {
  String _selectedCondition = 'RSI < 30 (Oversold)';

  @override
  Widget build(BuildContext context) {
    final marketProv = Provider.of<MarketProvider>(context);

    // Filter stocks based on selected scan condition
    final scannedStocks = marketProv.stocks.where((stock) {
      if (_selectedCondition.contains('Oversold')) {
        return stock.changePercent < 0; // Simulated condition
      } else if (_selectedCondition.contains('Gainers')) {
        return stock.changePercent > 0.8;
      } else {
        return stock.volume > 5000000;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Market Scanner', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scan Condition', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCondition,
              dropdownColor: const Color(0xFF1E293B),
              decoration: const InputDecoration(filled: true, border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'RSI < 30 (Oversold)', child: Text('RSI < 30 (Oversold)')),
                DropdownMenuItem(value: 'Top Gainers (>0.8%)', child: Text('Top Gainers (>0.8%)')),
                DropdownMenuItem(value: 'High Volume (>5M)', child: Text('High Volume (>5M)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedCondition = val);
              },
            ),
            const SizedBox(height: 24),
            Text('Scan Results (${scannedStocks.length} matches)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: scannedStocks.length,
                itemBuilder: (context, index) {
                  final stock = scannedStocks[index];
                  return ListTile(
                    onTap: () => context.push('/stock-detail', extra: stock.symbol),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1E293B),
                      child: Text(stock.symbol.substring(0, 2), style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(stock.name, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${stock.currentPrice}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${stock.change >= 0 ? '+' : ''}${stock.changePercent}%', style: TextStyle(color: stock.change >= 0 ? Colors.green : Colors.red, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
