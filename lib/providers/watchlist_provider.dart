import 'package:flutter/foundation.dart';
import '../models/stock_model.dart';
import '../core/repositories/market_repository.dart';

class WatchlistProvider extends ChangeNotifier {
  final MarketRepository _marketRepo = MarketRepository();

  List<Stock> _watchlist = [];
  bool _isLoading = false;

  List<Stock> get watchlist => _watchlist;
  bool get isLoading => _isLoading;

  Future<void> loadWatchlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      _watchlist = await _marketRepo.getWatchlistStocks();
    } catch (e) {
      debugPrint('Error loading watchlist: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToWatchlist(String symbol) async {
    await _marketRepo.addToWatchlist(symbol);
    await loadWatchlist();
  }

  Future<void> removeFromWatchlist(String symbol) async {
    await _marketRepo.removeFromWatchlist(symbol);
    await loadWatchlist();
  }

  bool isInWatchlist(String symbol) {
    return _watchlist.any((s) => s.symbol == symbol);
  }
}
