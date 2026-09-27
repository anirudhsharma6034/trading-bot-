import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'providers/auth_provider.dart';
import 'providers/market_provider.dart';
import 'providers/watchlist_provider.dart';
import 'providers/portfolio_provider.dart';
import 'providers/trading_provider.dart';
import 'providers/bot_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()..loadStocks()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()..loadWatchlist()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()..loadPortfolio()),
        ChangeNotifierProvider(create: (_) => TradingProvider()..loadTradingData()),
        ChangeNotifierProvider(create: (_) => BotProvider()..loadBots()),
      ],
      child: const TradingBotApp(),
    ),
  );
}
