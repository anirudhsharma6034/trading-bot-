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

  Future<void> addFunds(double amount) async {
    await _portfolioRepo.addFunds(amount);
    await loadPortfolio();
  }

  Future<bool> withdrawFunds(double amount) async {
    final success = await _portfolioRepo.withdrawFunds(amount);
    if (success) {
      await loadPortfolio();
    }
    return success;
  }
}
