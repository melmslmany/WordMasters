import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/languages.dart';
import 'models/word_language.dart';
import 'widgets/common_widgets.dart';
import 'providers/ads_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/progression_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'services/cloud_sync_service.dart';
import 'services/game_service.dart';
import 'services/storage_service.dart';

class WordSearchApp extends StatelessWidget {
  const WordSearchApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isRtl = AppLanguages.isRtlCode(settings.uiLanguage);
        final bg = settings.selectedBackground;

        return MaterialApp(
          title: 'Word Masters',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(langCode: settings.uiLanguage),
          locale: Locale(settings.uiLanguage),
          supportedLocales: [
            for (final lang in AppLanguages.all) Locale(lang.code),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          builder: (context, child) {
            return Directionality(
              textDirection:
                  isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: NeonBackground(
            background: bg,
            customImagePath: settings.customBackgroundPath,
            child: const HomeScreen(),
          ),
        );
      },
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final storage = StorageService();
  await storage.init();

  final gameService = GameService();
  final gameProvider = GameProvider(storage, gameService);
  final settingsProvider = SettingsProvider(storage);
  final progressionProvider = ProgressionProvider(storage);
  final cloudSync = CloudSyncService(storage);
  final authProvider = AuthProvider(cloudSync);
  final adsProvider = AdsProvider(storage);

  await Future.wait([
    gameProvider.load(),
    settingsProvider.load(),
    progressionProvider.load(),
  ]);

  // Keep the word language unified with the UI language: a single language
  // choice drives both. If they ever diverge (e.g. older saved data), the UI
  // language wins.
  if (gameProvider.wordLanguage.code != settingsProvider.uiLanguage) {
    await gameProvider.setWordLanguage(
      WordLanguage.fromCode(settingsProvider.uiLanguage),
    );
  }

  gameProvider.bindProgression(progressionProvider);
  await progressionProvider.onDailyLogin();
  await authProvider.init();
  // Fire-and-forget: don't block first frame on ad SDK init.
  unawaited(adsProvider.init());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: gameProvider),
        ChangeNotifierProvider.value(value: progressionProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: adsProvider),
      ],
      child: const WordSearchApp(),
    ),
  );
}
