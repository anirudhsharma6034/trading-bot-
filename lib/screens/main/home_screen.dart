import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/market_provider.dart';
import '../../providers/bot_provider.dart';
import '../../services/simulation_engine.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SimulationEngine.instance.startSimulation(() {
      if (mounted) {
        Provider.of<MarketProvider>(context, listen: false).loadStocks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioProv = Provider.of<PortfolioProvider>(context);
    final marketProv = Provider.of<MarketProvider>(context);
    final botProv = Provider.of<BotProvider>(context);
    final portfolio = portfolioProv.portfolio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Bot Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/market-scanner'),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => context.push('/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.science_outlined),
            onPressed: () => context.push('/backtest'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '₹${portfolio?.totalValue.toStringAsFixed(2) ?? '100,000.00'}',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem('Today P&L', '+₹${portfolio?.todayPnl.toStringAsFixed(2) ?? '0.00'}', Colors.greenAccent),
                      _buildSummaryItem('Available Cash', '₹${portfolio?.availableCash.toStringAsFixed(2) ?? '0.00'}', Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Market Overview Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Market Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.push('/strategy-builder'),
                  child: const Text('Strategy Builder'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildMarketIndexCard('NIFTY 50', '22,450.20', '+0.75%', true),
                  _buildMarketIndexCard('BANK NIFTY', '48,120.50', '+1.10%', true),
                  _buildMarketIndexCard('SENSEX', '73,890.10', '-0.20%', false),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Top Gainers
            const Text('Top Gainers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...marketProv.topGainers.map((stock) => ListTile(
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
                      Text('+${stock.changePercent}%', style: const TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            // Active Bots Summary
            const Text('Active Trading Bots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...botProv.bots.take(3).map((bot) => GestureDetector(
                  onTap: () => context.push('/bot-detail', extra: bot),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bot.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('${bot.symbol} • ${bot.strategyName}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: bot.status == 'Running' ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bot.status,
                            style: TextStyle(color: bot.status == 'Running' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMarketIndexCard(String name, String value, String change, bool isPositive) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(change, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontSize: 12)),
        ],
      ),
    );
  }
}
