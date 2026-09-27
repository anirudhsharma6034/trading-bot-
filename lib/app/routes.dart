import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/stock_detail_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/backtest_screen.dart';
import '../screens/strategy_builder_screen.dart';
import '../screens/market_scanner_screen.dart';
import '../screens/bot_detail_screen.dart';
import '../models/bot_model.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/main', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/stock-detail',
        builder: (context, state) {
          final symbol = state.extra as String? ?? 'RELIANCE';
          return StockDetailScreen(symbol: symbol);
        },
      ),
      GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
      GoRoute(path: '/backtest', builder: (context, state) => const BacktestScreen()),
      GoRoute(path: '/strategy-builder', builder: (context, state) => const StrategyBuilderScreen()),
      GoRoute(path: '/market-scanner', builder: (context, state) => const MarketScannerScreen()),
      GoRoute(
        path: '/bot-detail',
        builder: (context, state) {
          final bot = state.extra as BotModel;
          return BotDetailScreen(bot: bot);
        },
      ),
    ],
  );
}
