import 'package:flutter/foundation.dart';
import '../models/portfolio_model.dart';
import '../core/repositories/portfolio_repository.dart';

class PortfolioProvider extends ChangeNotifier {
  final PortfolioRepository _portfolioRepo = PortfolioRepository();

  PortfolioModel? _portfolio;
  bool _isLoading = false;

  PortfolioModel? get portfolio => _portfolio;
  bool get isLoading => _isLoading;

  Future<void> loadPortfolio() async {
    _isLoading = true;
    notifyListeners();

    try {
      _portfolio = await _portfolioRepo.getPortfolio();
    } catch (e) {
      debugPrint('Error loading portfolio: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
