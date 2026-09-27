import 'package:flutter/material.dart';
import '../models/bot_model.dart';
import '../core/repositories/bot_repository.dart';

class BotDetailScreen extends StatefulWidget {
  final BotModel bot;
  const BotDetailScreen({super.key, required this.bot});

  @override
  State<BotDetailScreen> createState() => _BotDetailScreenState();
}

class _BotDetailScreenState extends State<BotDetailScreen> {
  final BotRepository _botRepo = BotRepository();
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    if (widget.bot.id != null) {
      final logs = await _botRepo.getBotLogs(widget.bot.id!);
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } else {
      // Mock logs if bot has no id yet
      setState(() {
        _logs = [
          {'message': 'Bot initialized with capital ₹${widget.bot.initialCapital}', 'timestamp': DateTime.now().toIso8601String()},
          {'message': 'Market data connected for ${widget.bot.symbol}', 'timestamp': DateTime.now().toIso8601String()},
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bot.name, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Strategy: ${widget.bot.strategyName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Symbol: ${widget.bot.symbol}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Text('₹${widget.bot.pnl}', style: TextStyle(color: widget.bot.pnl >= 0 ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Bot Activity Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _logs.isEmpty
                      ? const Center(child: Text('No logs recorded yet.'))
                      : ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle, size: 8, color: Color(0xFF3B82F6)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(log['message'] ?? '', style: const TextStyle(fontSize: 14)),
                                  ),
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
