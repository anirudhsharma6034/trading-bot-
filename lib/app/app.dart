import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

class TradingBotApp extends StatelessWidget {
  const TradingBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Trading Bot',
      theme: AppTheme.darkTheme,
      routerConfig: AppRoutes.router,
    );
  }
}
