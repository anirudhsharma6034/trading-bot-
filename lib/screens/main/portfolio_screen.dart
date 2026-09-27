import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/trading_provider.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioProv = Provider.of<PortfolioProvider>(context);
    final tradingProv = Provider.of<TradingProvider>(context);
    final portfolio = portfolioProv.portfolio;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Portfolio & Positions', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Open Positions'),
              Tab(text: 'Trade History'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Invested Amount', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('₹${portfolio?.investedAmount.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoCol('Available Cash', '₹${portfolio?.availableCash.toStringAsFixed(2) ?? '0.00'}'),
                      _buildInfoCol('Overall P&L', '₹${portfolio?.overallPnl.toStringAsFixed(2) ?? '0.00'}'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Open Positions Tab
                  tradingProv.positions.isEmpty
                      ? const Center(child: Text('No open positions'))
                      : ListView.builder(
                          itemCount: tradingProv.positions.length,
                          itemBuilder: (context, index) {
                            final pos = tradingProv.positions[index];
                            return ListTile(
                              title: Text(pos.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Qty: ${pos.quantity} • Avg: ₹${pos.averagePrice}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${pos.pnl.toStringAsFixed(2)}', style: TextStyle(color: pos.pnl >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                  Text('${pos.pnlPercent.toStringAsFixed(2)}%', style: TextStyle(color: pos.pnlPercent >= 0 ? Colors.green : Colors.red, fontSize: 12)),
                                ],
                              ),
                            );
                          },
                        ),
                  // Trade History Tab
                  tradingProv.trades.isEmpty
                      ? const Center(child: Text('No trade history'))
                      : ListView.builder(
                          itemCount: tradingProv.trades.length,
                          itemBuilder: (context, index) {
                            final trade = tradingProv.trades[index];
                            return ListTile(
                              title: Text('${trade.side} ${trade.symbol}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Qty: ${trade.quantity} @ ₹${trade.entryPrice}'),
                              trailing: Text('₹${trade.pnl}', style: TextStyle(color: trade.pnl >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCol(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
