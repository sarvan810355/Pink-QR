import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only "premium unlocked" flag for the "Remove Ads + Unlock All
/// Stickers & Frames" one-time purchase. No real payment integration is
/// wired up — flipping this flag is where an IAP plugin (e.g. in_app_purchase)
/// would hook in once store products are configured.
class PremiumService extends ChangeNotifier {
  static const _key = 'qr_bloom_is_premium';

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> unlockPremium() async {
    _isPremium = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  Future<void> restore() async => load();
}
