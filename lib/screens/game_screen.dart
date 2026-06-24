import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/categories_data.dart';
import '../l10n/app_localizations.dart';
import '../models/game_mode.dart';
import '../models/word_language.dart';
import '../providers/ads_provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/common_widgets.dart';
import '../widgets/game_dialogs.dart';
import '../widgets/word_grid.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ConfettiController _confettiController;
  bool _showingComplete = false;
  bool _endlessBanner = false;
  int _lastEndlessStage = 0;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final game = context.watch<GameProvider>();
    final l10n = AppLocalizations.forLocale(settings.uiLanguage);
    final activeGame = game.activeGame;

    if (activeGame == null) {
      if (!_showingComplete) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SizedBox.shrink(),
      );
    }

    final category = CategoriesData.byId(activeGame.categoryId);
    final isArabicWords = game.wordLanguage == WordLanguage.arabic;
    final isEndless = activeGame.isEndlessMode;

    if (activeGame.isComplete && !_showingComplete) {
      _showingComplete = true;
      final isProgress = activeGame.isProgressMode;
      final categoryId = activeGame.categoryId;
      final endlessStage = activeGame.endlessStage;
      final nextDifficulty = activeGame.difficulty;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        HapticFeedback.heavyImpact();
        _confettiController.play();

        if (isEndless) {
          await game.advanceEndlessStage();
          if (!mounted) return;
          setState(() {
            _showingComplete = false;
            _endlessBanner = true;
            _lastEndlessStage = endlessStage;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _endlessBanner = false);
          });
          return;
        }

        final reward = await game.completeLevel();
        if (!mounted) return;
        final ads = context.read<AdsProvider>();
        await showCompleteDialog(
          context,
          l10n: l10n,
          reward: reward,
          isProgressMode: isProgress,
          onNext: () {
            // Distribute interstitials: every few levels at a natural break.
            ads.onLevelCompletedMaybeShowInterstitial();
            game.startGame(
              categoryId: categoryId,
              mode: isProgress ? GameMode.progress : GameMode.casual,
              difficulty: nextDifficulty,
            );
            setState(() => _showingComplete = false);
          },
          onCategories: () {
            Navigator.pop(context);
          },
        );
      });
    }

    final levelLabel = isEndless
        ? '${l10n.endlessStageLabel} ${activeGame.endlessStage}'
        : '${l10n.level} ${activeGame.level}';

    return Scaffold(
      body: Stack(
        children: [
          NeonBackground(
            background: settings.selectedBackground,
            customImagePath: settings.customBackgroundPath,
            child: Column(
              children: [
                NeonHeader(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            showSettingsDialog(context, settings, game),
                        icon: const Icon(Icons.settings_rounded,
                            color: Colors.white70, size: 22),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (isEndless) await game.clearActiveGame();
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white70, size: 22),
                      ),
                    ],
                  ),
                  title: category?.name(l10n.isArabic).toUpperCase() ?? '',
                  subtitle: levelLabel,
                  badge: isEndless ? l10n.endless.toUpperCase() : null,
                  trailing:
                      CurrencyDisplay(keys: game.keys, coins: game.coins),
                ),
                if (isEndless)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(
                      l10n.endlessDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.neonPink.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    l10n.findWords,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: WordGrid(
                    grid: activeGame.grid,
                    placements: activeGame.placements,
                    foundPlacementIndices: activeGame.foundPlacementIndices,
                    highlightedPlacementIndex:
                        activeGame.highlightedPlacementIndex,
                    highlightedLetters: activeGame.highlightedLetters,
                    isArabic: isArabicWords,
                    fontFamily: AppTheme.gridFontFamily(game.wordLanguage),
                    onPlacementFound: (index, cells) async {
                      HapticFeedback.lightImpact();
                      await game.markPlacementFound(index);
                    },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${activeGame.foundCount} ${l10n.of} ${activeGame.placements.length} ${l10n.wordsFound}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: activeGame.placements.asMap().entries.map((e) {
                        final index = e.key;
                        final word = e.value.word;
                        final found = activeGame.isPlacementFound(index);
                        final color = AppColors.highlightColors[
                            e.value.colorIndex % AppColors.highlightColors.length];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: found
                                ? null
                                : LinearGradient(
                                    colors: [
                                      color.withValues(alpha: 0.85),
                                      color.withValues(alpha: 0.55),
                                    ],
                                  ),
                            color: found
                                ? AppColors.surface.withValues(alpha: 0.5)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: found
                                  ? Colors.white24
                                  : color.withValues(alpha: 0.6),
                            ),
                            boxShadow: found
                                ? null
                                : [AppColors.neonGlow(color, blur: 10)],
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              color: found
                                  ? AppColors.textSecondary
                                  : Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: isArabicWords ? 14 : 13,
                              decoration: found
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.accentGold,
                              decorationThickness: 2,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GameButton(
                          label: l10n.hintWord,
                          icon: Icons.highlight_rounded,
                          compact: true,
                          onTap: () async {
                            final ok = await game.useHighlightWordHint();
                            if (!ok && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.notEnoughCoins)),
                              );
                            }
                          },
                          color: AppColors.neonGreen,
                          trailing:
                              _CostBadge(GameProvider.highlightWordCost),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GameButton(
                          label: l10n.hintLetter,
                          icon: Icons.text_fields_rounded,
                          compact: true,
                          onTap: () async {
                            final ok = await game.useHighlightLetterHint();
                            if (!ok && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.notEnoughCoins)),
                              );
                            }
                          },
                          color: AppColors.neonCyan,
                          trailing:
                              _CostBadge(GameProvider.highlightLetterCost),
                        ),
                      ),
                    ],
                  ),
                ),
                const Center(child: BannerAdWidget()),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: AppColors.wordFoundColors,
              numberOfParticles: 30,
            ),
          ),
          if (_endlessBanner)
            Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonPurple.withValues(alpha: 0.9),
                      AppColors.neonPink.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [AppColors.neonGlow(AppColors.neonPink, blur: 24)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.completed,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.endlessStageLabel} $_lastEndlessStage ✓',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.keepPlaying,
                      style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CostBadge extends StatelessWidget {
  const _CostBadge(this.cost);

  final int cost;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.monetization_on_rounded,
            color: AppColors.accentGold, size: 14),
        Text(
          '×$cost',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
