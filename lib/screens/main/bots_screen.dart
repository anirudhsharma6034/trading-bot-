import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bot_provider.dart';
import '../../models/bot_model.dart';

class BotsScreen extends StatelessWidget {
  const BotsScreen({super.key});

  void _showCreateBotModal(BuildContext context) {
    final nameController = TextEditingController(text: 'MA Crossover Bot');
    final symbolController = TextEditingController(text: 'RELIANCE');
    final capitalController = TextEditingController(text: '25000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Trading Bot', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Bot Name', filled: true)),
            const SizedBox(height: 12),
            TextField(controller: symbolController, decoration: const InputDecoration(labelText: 'Stock Symbol', filled: true)),
            const SizedBox(height: 12),
            TextField(controller: capitalController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Initial Capital (₹)', filled: true)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                onPressed: () {
                  final bot = BotModel(
                    name: nameController.text,
                    symbol: symbolController.text,
                    strategyName: 'Moving Average',
                    initialCapital: double.parse(capitalController.text),
                    currentCapital: double.parse(capitalController.text),
                    riskLevel: 'Medium',
                    stopLoss: 1.5,
                    takeProfit: 3.0,
                    maxTradesPerDay: 5,
                    maxOpenPositions: 1,
                    positionSize: 10,
                    timeframe: '5m',
                    status: 'Paused',
                    pnl: 0.0,
                    tradesCount: 0,
                  );
                  Provider.of<BotProvider>(context, listen: false).createBot(bot);
                  Navigator.pop(context);
                },
                child: const Text('Deploy Bot', style: TextStyle(fontSize: 16, color: Colors.white)),
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
    final botProv = Provider.of<BotProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Bots', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateBotModal(context),
          ),
        ],
      ),
      body: botProv.bots.isEmpty
          ? const Center(child: Text('No active bots. Click + to create one.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: botProv.bots.length,
              itemBuilder: (context, index) {
                final bot = botProv.bots[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(bot.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: bot.status == 'Running' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(bot.status, style: TextStyle(color: bot.status == 'Running' ? Colors.green : Colors.orange)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${bot.symbol} • Strategy: ${bot.strategyName}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Capital: ₹${bot.currentCapital}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('P&L: ₹${bot.pnl}', style: TextStyle(color: bot.pnl >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => botProv.toggleBotStatus(bot.id!, bot.status),
                            icon: Icon(bot.status == 'Running' ? Icons.pause : Icons.play_arrow),
                            label: Text(bot.status == 'Running' ? 'Pause' : 'Start'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => botProv.deleteBot(bot.id!),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
