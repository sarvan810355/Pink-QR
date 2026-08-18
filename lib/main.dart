import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/ads_service.dart';
import 'services/history_service.dart';
import 'services/premium_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'widgets/root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final historyService = HistoryService();
  final themeService = ThemeService();
  final premiumService = PremiumService();

  await Future.wait([
    historyService.load(),
    themeService.load(),
    premiumService.load(),
  ]);

  // Ads init is fire-and-forget so app start isn't blocked by ad SDK setup.
  AdsService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: historyService),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: premiumService),
      ],
      child: const QrBloomApp(),
    ),
  );
}

class QrBloomApp extends StatelessWidget {
  const QrBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    return MaterialApp(
      title: 'QR Bloom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.night,
      themeMode: themeService.themeMode,
      home: const RootShell(),
    );
  }
}
