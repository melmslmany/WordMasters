import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Centralized AdMob unit ids.
///
/// Currently uses Google's official TEST ids so no real fill happens during
/// development. Replace the production ids (and the App ID in
/// AndroidManifest.xml / Info.plist) before release.
abstract final class AdIds {
  /// Toggle to false and fill the production ids when going live.
  static const useTestAds = true;

  static bool get supported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  // ---- Test ids (Google official) ----
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';
  static const _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';
  static const _testAppOpenAndroid =
      'ca-app-pub-3940256099942544/9257395921';
  static const _testAppOpenIos = 'ca-app-pub-3940256099942544/5575463023';

  // ---- Production ids (fill before release) ----
  static const _prodBannerAndroid = '';
  static const _prodBannerIos = '';
  static const _prodInterstitialAndroid = '';
  static const _prodInterstitialIos = '';
  static const _prodRewardedAndroid = '';
  static const _prodRewardedIos = '';
  static const _prodAppOpenAndroid = '';
  static const _prodAppOpenIos = '';

  static String _pick(String testA, String testI, String prodA, String prodI) {
    if (useTestAds) return _isAndroid ? testA : testI;
    return _isAndroid ? prodA : prodI;
  }

  static String get banner => _pick(
        _testBannerAndroid,
        _testBannerIos,
        _prodBannerAndroid,
        _prodBannerIos,
      );

  static String get interstitial => _pick(
        _testInterstitialAndroid,
        _testInterstitialIos,
        _prodInterstitialAndroid,
        _prodInterstitialIos,
      );

  static String get rewarded => _pick(
        _testRewardedAndroid,
        _testRewardedIos,
        _prodRewardedAndroid,
        _prodRewardedIos,
      );

  static String get appOpen => _pick(
        _testAppOpenAndroid,
        _testAppOpenIos,
        _prodAppOpenAndroid,
        _prodAppOpenIos,
      );
}
