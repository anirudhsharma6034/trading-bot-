import 'dart:math';
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

  // Initial Seeded News
  List<Map<String, dynamic>> _newsList = [
    {
      'title': 'RBI holds interest rates steady at 6.5%',
      'source': 'Financial Times',
      'sentiment': 'Neutral',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      'title': 'Tech stocks rally as IT sector shows strong Q3 earnings',
      'source': 'Market Watch',
      'sentiment': 'Bullish',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 32)),
    },
    {
      'title': 'Global supply chain issues hit Auto sector stocks',
      'source': 'Bloomberg',
      'sentiment': 'Bearish',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'title': 'Reliance Industries announces mega green energy project',
      'source': 'Reuters',
      'sentiment': 'Bullish',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
  ];

  // Pool of random headlines to simulate incoming news
  final List<Map<String, dynamic>> _newsPool = [
    {'title': 'Crude oil prices drop unexpectedly', 'source': 'Reuters', 'sentiment': 'Bullish'},
    {'title': 'FIIs pump ₹5,000 Cr into Indian equities', 'source': 'Mint', 'sentiment': 'Bullish'},
    {'title': 'Inflation data raises concerns for FMCG sector', 'source': 'CNBC TV18', 'sentiment': 'Bearish'},
    {'title': 'Banking stocks slip on profit booking', 'source': 'Bloomberg', 'sentiment': 'Bearish'},
    {'title': 'Government announces new export subsidies', 'source': 'Financial Times', 'sentiment': 'Bullish'},
    {'title': 'Rupee hits record low against US Dollar', 'source': 'Market Watch', 'sentiment': 'Bearish'},
    {'title': 'Top IT firm wins \\\$1 Billion contract', 'source': 'Mint', 'sentiment': 'Bullish'}, // Escaped $ sign
    {'title': 'Regulatory body issues new guidelines for brokers', 'source': 'Reuters', 'sentiment': 'Neutral'},
  ];

  List<Map<String, dynamic>> get newsList => _newsList;

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

  // Method to simulate adding a new random news headline
  void generateRandomNews() {
    final random = Random();
    // 30% chance to generate news in a given tick
    if (random.nextDouble() > 0.70) {
      final newNews = Map<String, dynamic>.from(_newsPool[random.nextInt(_newsPool.length)]);
      newNews['timestamp'] = DateTime.now();
      
      _newsList.insert(0, newNews); // Add to top
      
      if (_newsList.length > 20) {
        _newsList.removeLast(); // Keep list size manageable
      }
      notifyListeners();
    }
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
