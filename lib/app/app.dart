import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'routes.dart';
import 'theme.dart';

class TradingBotApp extends StatelessWidget {
  const TradingBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Trading Bot',
        theme: AppTheme.darkTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
