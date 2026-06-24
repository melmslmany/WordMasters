import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_ids.dart';
import '../services/storage_service.dart';

/// Central manager for all AdMob formats.
///
/// Web-safe: when ads are not supported (web/desktop) every method is a no-op
/// so the rest of the app behaves normally.
class AdsProvider extends ChangeNotifier with WidgetsBindingObserver {
  AdsProvider(this._storage);

  final StorageService _storage;

  bool _initialized = false;
  bool removeAds = false;

  // Interstitial cadence: show after every N completed levels.
  static const _interstitialEveryLevels = 3;
  int _levelsSinceInterstitial = 0;

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  AppOpenAd? _appOpenAd;
  DateTime? _appOpenLoadedAt;
  bool _showingAppOpen = false;
  bool _resumedOnce = false;

  bool get enabled => AdIds.supported && !removeAds;

  Future<void> init() async {
    removeAds = _storage.removeAds;
    if (!AdIds.supported) {
      _initialized = true;
      notifyListeners();
      return;
    }

    await MobileAds.instance.initialize();
    WidgetsBinding.instance.addObserver(this);
    _initialized = true;

    if (!removeAds) {
      _loadInterstitial();
      _loadAppOpen();
      // Show the app-open ad shortly after launch.
      Future.delayed(const Duration(milliseconds: 800), showAppOpenIfReady);
    }
    _loadRewarded(); // rewarded stays available even with removeAds.
    notifyListeners();
  }

  Future<void> setRemoveAds(bool value) async {
    removeAds = value;
    await _storage.setRemoveAds(value);
    if (value) {
      _interstitial?.dispose();
      _interstitial = null;
      _appOpenAd?.dispose();
      _appOpenAd = null;
    } else if (AdIds.supported) {
      _loadInterstitial();
      _loadAppOpen();
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // App Open
  // ---------------------------------------------------------------------------
  void _loadAppOpen() {
    if (!enabled) return;
    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (_) => _appOpenAd = null,
      ),
    );
  }

  bool get _appOpenValid {
    if (_appOpenAd == null || _appOpenLoadedAt == null) return false;
    // App open ads expire after 4 hours.
    return DateTime.now().difference(_appOpenLoadedAt!).inHours < 4;
  }

  void showAppOpenIfReady() {
    if (!enabled || _showingAppOpen || !_appOpenValid) {
      if (enabled && !_appOpenValid) _loadAppOpen();
      return;
    }
    final ad = _appOpenAd!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _showingAppOpen = true,
      onAdDismissedFullScreenContent: (ad) {
        _showingAppOpen = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        _showingAppOpen = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpen();
      },
    );
    ad.show();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Skip the very first resume right after launch (avoids double show).
      if (!_resumedOnce) {
        _resumedOnce = true;
        return;
      }
      showAppOpenIfReady();
    }
  }

  // ---------------------------------------------------------------------------
  // Interstitial
  // ---------------------------------------------------------------------------
  void _loadInterstitial() {
    if (!enabled) return;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Call after a level is completed. Shows an interstitial every N levels.
  void onLevelCompletedMaybeShowInterstitial() {
    if (!enabled) return;
    _levelsSinceInterstitial++;
    if (_levelsSinceInterstitial < _interstitialEveryLevels) return;
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    _levelsSinceInterstitial = 0;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
    );
    ad.show();
  }

  // ---------------------------------------------------------------------------
  // Rewarded
  // ---------------------------------------------------------------------------
  void _loadRewarded() {
    if (!AdIds.supported) return;
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (_) => _rewarded = null,
      ),
    );
  }

  bool get rewardedReady => _rewarded != null;

  /// Shows a rewarded ad. Returns true if the user earned the reward.
  Future<bool> showRewarded() async {
    if (!AdIds.supported) return false;
    final ad = _rewarded;
    if (ad == null) {
      _loadRewarded();
      return false;
    }

    var earned = false;
    final completer = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
        if (!completer.isCompleted) completer.complete();
      },
    );
    ad.show(onUserEarnedReward: (_, __) => earned = true);
    await completer.future;
    return earned;
  }

  /// Creates a fresh banner ad for the gameplay screen. Caller disposes it.
  BannerAd? createBanner(BannerAdListener listener) {
    if (!enabled) return null;
    return BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener,
    )..load();
  }

  @override
  void dispose() {
    if (AdIds.supported) WidgetsBinding.instance.removeObserver(this);
    _interstitial?.dispose();
    _rewarded?.dispose();
    _appOpenAd?.dispose();
    super.dispose();
  }
}
