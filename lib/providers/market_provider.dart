import 'package:flutter/foundation.dart';
import '../models/stock_model.dart';
import '../core/repositories/market_repository.dart';

class MarketProvider extends ChangeNotifier {
  final MarketRepository _marketRepo = MarketRepository();

  List<Stock> _stocks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedSector = 'All';

  List<Stock> get stocks => _stocks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedSector => _selectedSector;

  List<Stock> get filteredStocks {
    return _stocks.where((stock) {
      final matchesSearch = stock.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          stock.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSector = _selectedSector == 'All' || stock.sector == _selectedSector;
      return matchesSearch && matchesSector;
    }).toList();
  }

  List<Stock> get topGainers {
    final sorted = List<Stock>.from(_stocks)..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    return sorted.take(5).toList();
  }

  List<Stock> get topLosers {
    final sorted = List<Stock>.from(_stocks)..sort((a, b) => a.changePercent.compareTo(b.changePercent));
    return sorted.take(5).toList();
  }

  Future<void> loadStocks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stocks = await _marketRepo.getStocks();
    } catch (e) {
      debugPrint('Error loading stocks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSector(String sector) {
    _selectedSector = sector;
    notifyListeners();
  }
}
