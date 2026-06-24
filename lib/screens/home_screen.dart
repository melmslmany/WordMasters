import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../data/categories_data.dart';
import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/game_mode.dart';
import '../models/game_style.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/category_card.dart';
import '../widgets/common_widgets.dart';
import '../widgets/game_dialogs.dart';
import '../providers/auth_provider.dart';
import '../providers/progression_provider.dart';
import 'daily_tasks_tab.dart';
import 'game_screen.dart';
import 'profile_tab.dart';
import 'store_tab.dart';
import 'word_guess_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final game = context.watch<GameProvider>();
    final progression = context.watch<ProgressionProvider>();
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.forLocale(settings.uiLanguage);

    game.syncLevelsPerCategory(settings.levelsPerCategory);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SizedBox.expand(
                child: _buildActiveTab(
                  l10n: l10n,
                  settings: settings,
                  game: game,
                  progression: progression,
                  auth: auth,
                ),
              ),
            ),
            GameBottomNav(
              currentIndex: _tabIndex,
              l10n: l10n,
              onTap: (i) => setState(() => _tabIndex = i),
              onPlayTap: () => setState(() => _tabIndex = 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab({
    required AppLocalizations l10n,
    required SettingsProvider settings,
    required GameProvider game,
    required ProgressionProvider progression,
    required AuthProvider auth,
  }) {
    return switch (_tabIndex) {
      0 => _CategoriesTab(
          l10n: l10n,
          settings: settings,
          game: game,
          onCategoryTap: (cat, unlocked) => _onCategoryTap(
            context,
            category: cat,
            unlocked: unlocked,
            game: game,
            l10n: l10n,
          ),
        ),
      1 => const DailyTasksTab(),
      2 => StoreTab(
          l10n: l10n,
          game: game,
          settings: settings,
          progression: progression,
          auth: auth,
        ),
      3 => ProfileTab(
          l10n: l10n,
          game: game,
          progression: progression,
          settings: settings,
        ),
      _ => const SizedBox.shrink(),
    };
  }

  void _onCategoryTap(
    BuildContext context, {
    required GameCategory category,
    required bool unlocked,
    required GameProvider game,
    required AppLocalizations l10n,
  }) {
    if (!unlocked) {
      showUnlockDialog(
        context,
        category: category,
        l10n: l10n,
        game: game,
        onUnlocked: () {},
      );
      return;
    }

    showGameModeDialog(
      context,
      category: category,
      l10n: l10n,
      game: game,
      onStartProgress: (style) {
        _launch(context, style, () => game.startGame(
              categoryId: category.id,
              mode: GameMode.progress,
            ), () => game.startWordGuess(
              categoryId: category.id,
              mode: GameMode.progress,
            ));
      },
      onStartCasual: (style) async {
        final difficulty = await showDifficultyDialog(context, l10n);
        if (difficulty == null || !context.mounted) return;
        _launch(context, style, () => game.startGame(
              categoryId: category.id,
              mode: GameMode.casual,
              difficulty: difficulty,
            ), () => game.startWordGuess(
              categoryId: category.id,
              mode: GameMode.casual,
              difficulty: difficulty,
            ));
      },
      onStartEndless: (style) {
        _launch(context, style, () => game.startGame(
              categoryId: category.id,
              mode: GameMode.endless,
            ), () => game.startWordGuess(
              categoryId: category.id,
              mode: GameMode.endless,
            ));
      },
      onContinue: game.hasSavedProgress(category.id)
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen()),
              );
            }
          : null,
    );
  }

  void _launch(
    BuildContext context,
    GameStyle style,
    VoidCallback startClassic,
    VoidCallback startWordGuess,
  ) {
    if (style == GameStyle.wordGuess) {
      startWordGuess();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WordGuessScreen()),
      );
    } else {
      startClassic();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen()),
      );
    }
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({
    required this.l10n,
    required this.settings,
    required this.game,
    required this.onCategoryTap,
  });

  final AppLocalizations l10n;
  final SettingsProvider settings;
  final GameProvider game;
  final void Function(GameCategory cat, bool unlocked) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NeonHeader(
          leading: IconButton(
            onPressed: () => showSettingsDialog(context, settings, game),
            icon: const Icon(Icons.settings_rounded, color: Colors.white70),
          ),
          title: l10n.appTitle,
          subtitle: l10n.selectCategory,
          badge: 'WORD MASTERS',
          trailing: CurrencyDisplay(keys: game.keys, coins: game.coins),
        ),
        if (game.dailyStreak > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: _StreakBanner(streak: game.dailyStreak, l10n: l10n),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: CategoriesData.all.length,
            itemBuilder: (context, index) {
              final category = CategoriesData.all[index];
              final unlocked = game.isCategoryUnlocked(category.id);
              return CategoryCard(
                category: category,
                isUnlocked: unlocked,
                completedLevels: game.getCategoryCompletedLevels(category.id),
                totalLevels: settings.levelsPerCategory,
                l10n: l10n,
                index: index,
                onTap: () => onCategoryTap(category, unlocked),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streak, required this.l10n});

  final int streak;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonOrange.withValues(alpha: 0.15),
            AppColors.neonPink.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonOrange.withValues(alpha: 0.35)),
        boxShadow: [AppColors.neonGlow(AppColors.neonOrange, blur: 12)],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(
            '${l10n.dailyStreak}: $streak',
            style: const TextStyle(
              color: AppColors.neonOrange,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shimmer(duration: 1200.ms);
  }
}
