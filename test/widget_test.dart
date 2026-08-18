import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qr_bloom/main.dart';
import 'package:qr_bloom/services/history_service.dart';
import 'package:qr_bloom/services/premium_service.dart';
import 'package:qr_bloom/services/theme_service.dart';

void main() {
  testWidgets('QR Bloom launches to the Home tab', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final historyService = HistoryService();
    final themeService = ThemeService();
    final premiumService = PremiumService();
    await Future.wait([
      historyService.load(),
      themeService.load(),
      premiumService.load(),
    ]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: historyService),
          ChangeNotifierProvider.value(value: themeService),
          ChangeNotifierProvider.value(value: premiumService),
        ],
        child: const QrBloomApp(),
      ),
    );
    // Flush the one-shot entrance animations (flutter_animate schedules
    // their initial delay via Future.delayed) before asserting.
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Scan'), findsWidgets);
    expect(find.text('Generate'), findsWidgets);
  });
}
