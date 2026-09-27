import 'package:flutter/foundation.dart';
import '../models/bot_model.dart';
import '../core/repositories/bot_repository.dart';

class BotProvider extends ChangeNotifier {
  final BotRepository _botRepo = BotRepository();

  List<BotModel> _bots = [];
  bool _isLoading = false;

  List<BotModel> get bots => _bots;
  bool get isLoading => _isLoading;

  Future<void> loadBots() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bots = await _botRepo.getBots();
    } catch (e) {
      debugPrint('Error loading bots: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBot(BotModel bot) async {
    await _botRepo.insertBot(bot);
    await loadBots();
  }

  Future<void> toggleBotStatus(int id, String currentStatus) async {
    final newStatus = currentStatus == 'Running' ? 'Paused' : 'Running';
    await _botRepo.updateBotStatus(id, newStatus);
    await loadBots();
  }

  Future<void> deleteBot(int id) async {
    await _botRepo.deleteBot(id);
    await loadBots();
  }
}
