import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps google_mobile_ads: a persistent Home banner + an interstitial
/// shown every 3rd "action" (scan complete / QR generated / export).
///
/// Uses Google's public test ad unit IDs — swap these for real AdMob
/// unit IDs before release (see SETUP.md).
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static String get bannerAdUnitId => defaultTargetPlatform == TargetPlatform.iOS
      ? 'ca-app-pub-3940256099942544/2934735716'
      : 'ca-app-pub-3940256099942544/6300978111';

  static String get interstitialAdUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712';

  InterstitialAd? _interstitialAd;
  int _actionCount = 0;
  bool _adsRemoved = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  void setAdsRemoved(bool removed) => _adsRemoved = removed;

  BannerAd createBannerAd({required VoidCallback onLoaded}) {
    final banner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    banner.load();
    return banner;
  }

  void _loadInterstitial() {
    if (_adsRemoved) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// Call after a meaningful user action. Shows an interstitial every 3rd call.
  void registerActionAndMaybeShow() {
    if (_adsRemoved) return;
    _actionCount++;
    if (_actionCount % 3 == 0 && _interstitialAd != null) {
      final ad = _interstitialAd!;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (a) {
          a.dispose();
          _interstitialAd = null;
          _loadInterstitial();
        },
        onAdFailedToShowFullScreenContent: (a, _) {
          a.dispose();
          _interstitialAd = null;
          _loadInterstitial();
        },
      );
      ad.show();
    }
  }
}
