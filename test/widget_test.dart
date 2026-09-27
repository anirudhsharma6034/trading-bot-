import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tradingbot/app/app.dart';
import 'package:tradingbot/providers/auth_provider.dart';
import 'package:tradingbot/providers/market_provider.dart';
import 'package:tradingbot/providers/watchlist_provider.dart';
import 'package:tradingbot/providers/portfolio_provider.dart';
import 'package:tradingbot/providers/trading_provider.dart';
import 'package:tradingbot/providers/bot_provider.dart';

void main() {
  testWidgets('TradingBotApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => MarketProvider()),
          ChangeNotifierProvider(create: (_) => WatchlistProvider()),
          ChangeNotifierProvider(create: (_) => PortfolioProvider()),
          ChangeNotifierProvider(create: (_) => TradingProvider()),
          ChangeNotifierProvider(create: (_) => BotProvider()),
        ],
        child: const TradingBotApp(),
      ),
    );

    // Verify that the splash screen shows 'Trading Bot'
    expect(find.text('Trading Bot'), findsOneWidget);

    // Advance time to allow the splash screen timer to complete and navigate
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
