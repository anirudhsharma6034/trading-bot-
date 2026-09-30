import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    }, marketProvider: Provider.of<MarketProvider>(context, listen: false));
  }

  void _showAddFundsDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Add Paper Funds'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (₹)', hintText: 'Enter amount to add'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Provider.of<PortfolioProvider>(context, listen: false).addFunds(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('₹${amount.toStringAsFixed(2)} added to portfolio!'), backgroundColor: Colors.green));
              }
            },
            child: const Text('Deposit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showWithdrawFundsDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Withdraw Paper Funds'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹)', hintText: 'Enter amount to withdraw'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Note: Minimum total portfolio value of ₹5,00,000 must remain in the account.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final portfolio = Provider.of<PortfolioProvider>(context, listen: false).portfolio;
                final amount = double.tryParse(amountController.text);
                
                if (amount != null && amount > 0 && portfolio != null) {
                  // Rule 1: Cannot withdraw more than available cash
                  if (amount > portfolio.availableCash) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient available cash!'), backgroundColor: Colors.red));
                    return;
                  }
                  // Rule 2: Total portfolio value must be >= 5,00,000 after withdrawal
                  if ((portfolio.totalValue - amount) < 5000000) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account balance must be at least ₹5,00,000!'), backgroundColor: Colors.red));
                    return;
                  }

                  final success = await Provider.of<PortfolioProvider>(context, listen: false).withdrawFunds(amount);
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('₹${amount.toStringAsFixed(2)} withdrawn!'), backgroundColor: Colors.green));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal failed!'), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: const Text('Withdraw', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final portfolioProv = Provider.of<PortfolioProvider>(context);
    final marketProv = Provider.of<MarketProvider>(context);
    final botProv = Provider.of<BotProvider>(context);
    
    final portfolio = portfolioProv.portfolio;
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Bot Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showAddFundsDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                children: [
                                  Icon(Icons.add, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('Deposit', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showWithdrawFundsDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                children: [
                                  Icon(Icons.remove, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('Withdraw', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    portfolio != null ? formatCurrency.format(portfolio.totalValue) : '₹0.00',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem('Today P&L', portfolio != null ? '+${formatCurrency.format(portfolio.todayPnl)}' : '₹0.00', Colors.greenAccent),
                      _buildSummaryItem('Available Cash', portfolio != null ? formatCurrency.format(portfolio.availableCash) : '₹0.00', Colors.white),
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
                children: marketProv.stocks.take(4).map((stock) => _buildDynamicMarketCard(stock.symbol, stock.currentPrice, stock.changePercent)).toList(),
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
                      Text(formatCurrency.format(stock.currentPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('+${stock.changePercent.toStringAsFixed(2)}%', style: const TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            // Active Bots Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Trading Bots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (botProv.bots.isNotEmpty)
                  Text('${botProv.bots.where((b) => b.status == 'Running').length} Running', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (botProv.bots.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No active bots. Go to Bots tab to create one.', style: TextStyle(color: Colors.grey)))),
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

  Widget _buildDynamicMarketCard(String symbol, double price, double changePercent) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isPositive = changePercent >= 0;
    
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
          Text(symbol, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(formatCurrency.format(price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text('${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%', style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontSize: 12)),
        ],
      ),
    );
  }
}
