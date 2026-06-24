import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/categories_data.dart';
import '../l10n/app_localizations.dart';
import '../models/game_mode.dart';
import '../providers/ads_provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/common_widgets.dart';
import '../widgets/game_dialogs.dart';

class WordGuessScreen extends StatefulWidget {
  const WordGuessScreen({super.key});

  @override
  State<WordGuessScreen> createState() => _WordGuessScreenState();
}

class _WordGuessScreenState extends State<WordGuessScreen> {
  late ConfettiController _confettiController;
  bool _showingComplete = false;

  /// Indices (into the letter pool) currently tapped to form a word.
  List<int> _selection = [];

  /// Display order of pool tiles (lets us shuffle without touching state).
  List<int>? _order;
  String? _orderKey;

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

  void _ensureOrder(int count, String key) {
    if (_order == null || _order!.length != count || _orderKey != key) {
      _order = List<int>.generate(count, (i) => i);
      _orderKey = key;
      _selection = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final game = context.watch<GameProvider>();
    final l10n = AppLocalizations.forLocale(settings.uiLanguage);
    final guess = game.activeWordGuess;

    if (guess == null) {
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

    final category = CategoriesData.byId(guess.categoryId);
    final fontFamily = AppTheme.gridFontFamily(game.wordLanguage);
    _ensureOrder(guess.letters.length,
        '${guess.categoryId}-${guess.level}-${guess.targets.join()}');

    if (guess.isComplete && !_showingComplete) {
      _showingComplete = true;
      final isProgress = guess.isProgressMode;
      final isEndless = guess.isEndlessMode;
      final categoryId = guess.categoryId;
      final difficulty = guess.difficulty;
      final endlessStage = guess.endlessStage;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        HapticFeedback.heavyImpact();
        _confettiController.play();
        final reward = await game.completeWordGuess();
        if (!mounted) return;
        final ads = context.read<AdsProvider>();
        await showCompleteDialog(
          context,
          l10n: l10n,
          reward: reward,
          isProgressMode: isProgress,
          onNext: () {
            ads.onLevelCompletedMaybeShowInterstitial();
            game.startWordGuess(
              categoryId: categoryId,
              mode: isEndless
                  ? GameMode.endless
                  : isProgress
                      ? GameMode.progress
                      : GameMode.casual,
              difficulty: difficulty,
              endlessStage: isEndless ? endlessStage + 1 : null,
            );
            setState(() {
              _showingComplete = false;
              _selection = [];
              _order = null;
            });
          },
          onCategories: () => Navigator.pop(context),
        );
      });
    }

    final levelLabel = guess.isEndlessMode
        ? '${l10n.endlessStageLabel} ${guess.endlessStage}'
        : '${l10n.level} ${guess.level}';

    final currentWord =
        _selection.map((i) => guess.letters[i]).join();

    return Scaffold(
      body: Stack(
        children: [
          NeonBackground(
            background: settings.selectedBackground,
            customImagePath: settings.customBackgroundPath,
            child: Column(
              children: [
                NeonHeader(
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white70, size: 22),
                  ),
                  title: category?.name(l10n.isArabic).toUpperCase() ?? '',
                  subtitle: levelLabel,
                  badge: l10n.wordGuess.toUpperCase(),
                  trailing:
                      CurrencyDisplay(keys: game.keys, coins: game.coins),
                ),
                const SizedBox(height: 8),
                Text(
                  '${guess.solvedCount} ${l10n.of} ${guess.targets.length}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                // Answer rows (one per target word).
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      children: [
                        for (var t = 0; t < guess.targets.length; t++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AnswerRow(
                              word: guess.targets[t],
                              solved: guess.isSolved(t),
                              fontFamily: fontFamily,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Current selection preview.
                SizedBox(
                  height: 44,
                  child: Center(
                    child: currentWord.isEmpty
                        ? Text(
                            l10n.findWords,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          )
                        : Text(
                            currentWord,
                            style: TextStyle(
                              fontFamily: fontFamily,
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              shadows: const [
                                Shadow(
                                    color: AppColors.neonCyan, blurRadius: 14),
                              ],
                            ),
                          ),
                  ),
                ),
                // Letter pool (hex tiles).
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final i in _order!)
                        _HexTile(
                          letter: guess.letters[i],
                          fontFamily: fontFamily,
                          used: guess.isUsed(i),
                          selected: _selection.contains(i),
                          onTap: () => _onTileTap(game, guess, i),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _ControlsBar(
                  l10n: l10n,
                  onUndo: _selection.isEmpty
                      ? null
                      : () => setState(() => _selection.removeLast()),
                  onReset: _selection.isEmpty
                      ? null
                      : () => setState(() => _selection = []),
                  onShuffle: () {
                    HapticFeedback.selectionClick();
                    setState(() => _order!.shuffle());
                  },
                  onHint: () async {
                    final ok = await game.useWordGuessHint();
                    if (!ok && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.notEnoughCoins)),
                      );
                    } else if (ok) {
                      HapticFeedback.mediumImpact();
                      setState(() => _selection = []);
                    }
                  },
                  hintCost: GameProvider.highlightWordCost,
                ),
                const SizedBox(height: 6),
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
        ],
      ),
    );
  }

  void _onTileTap(GameProvider game, guess, int index) {
    if (guess.isUsed(index) || _selection.contains(index)) return;
    HapticFeedback.selectionClick();
    final next = [..._selection, index];
    final word = next.map((i) => guess.letters[i] as String).join();

    int? matchTarget;
    for (var t = 0; t < guess.targets.length; t++) {
      if (!guess.isSolved(t) && guess.targets[t] == word) {
        matchTarget = t;
        break;
      }
    }

    if (matchTarget != null) {
      game.solveWordGuessTarget(matchTarget, next);
      _confettiController.play();
      HapticFeedback.mediumImpact();
      setState(() => _selection = []);
    } else {
      setState(() => _selection = next);
    }
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.word,
    required this.solved,
    this.fontFamily,
  });

  final String word;
  final bool solved;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    final letters = word.split('');
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        for (final ch in letters)
          Container(
            width: 34,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: solved
                  ? LinearGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.85),
                        AppColors.accent.withValues(alpha: 0.5),
                      ],
                    )
                  : null,
              color: solved ? null : Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: solved
                    ? AppColors.accent
                    : Colors.white.withValues(alpha: 0.18),
              ),
              boxShadow: solved
                  ? [AppColors.neonGlow(AppColors.accent, blur: 8)]
                  : null,
            ),
            child: Text(
              solved ? ch : '',
              style: TextStyle(
                fontFamily: fontFamily,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
      ],
    );
  }
}

class _HexTile extends StatelessWidget {
  const _HexTile({
    required this.letter,
    required this.used,
    required this.selected,
    required this.onTap,
    this.fontFamily,
  });

  final String letter;
  final bool used;
  final bool selected;
  final VoidCallback onTap;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    const size = 62.0;
    final accent = selected ? AppColors.accentGold : AppColors.neonBlue;

    return GestureDetector(
      onTap: used ? null : onTap,
      child: Opacity(
        opacity: used ? 0.2 : 1,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _HexPainter(
              fill: selected ? AppColors.accentGold : AppColors.neonBlue,
              dim: selected,
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontFamily: fontFamily,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  shadows: [Shadow(color: accent, blurRadius: 8)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  _HexPainter({required this.fill, required this.dim});

  final Color fill;
  final bool dim;

  Path _hexPath(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()
      ..moveTo(w * 0.25, 0)
      ..lineTo(w * 0.75, 0)
      ..lineTo(w, h * 0.5)
      ..lineTo(w * 0.75, h)
      ..lineTo(w * 0.25, h)
      ..lineTo(0, h * 0.5)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _hexPath(size);

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          fill.withValues(alpha: dim ? 0.5 : 0.9),
          fill.withValues(alpha: dim ? 0.25 : 0.55),
        ],
      ).createShader(Offset.zero & size);

    final glowPaint = Paint()
      ..color = fill.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, bgPaint);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = fill.withValues(alpha: 0.9);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _HexPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.dim != dim;
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.l10n,
    required this.onUndo,
    required this.onReset,
    required this.onShuffle,
    required this.onHint,
    required this.hintCost,
  });

  final AppLocalizations l10n;
  final VoidCallback? onUndo;
  final VoidCallback? onReset;
  final VoidCallback onShuffle;
  final VoidCallback onHint;
  final int hintCost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CtrlButton(
            icon: Icons.undo_rounded,
            label: l10n.undo,
            color: AppColors.neonOrange,
            onTap: onUndo,
          ),
          _CtrlButton(
            icon: Icons.refresh_rounded,
            label: l10n.reset,
            color: AppColors.neonPink,
            onTap: onReset,
          ),
          _CtrlButton(
            icon: Icons.shuffle_rounded,
            label: l10n.shuffle,
            color: AppColors.neonCyan,
            onTap: onShuffle,
          ),
          _CtrlButton(
            icon: Icons.lightbulb_rounded,
            label: l10n.hintWord,
            color: AppColors.neonGreen,
            onTap: onHint,
            badge: hintCost,
          ),
        ],
      ),
    );
  }
}

class _CtrlButton extends StatelessWidget {
  const _CtrlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface.withValues(alpha: 0.85),
                border: Border.all(color: color.withValues(alpha: 0.6)),
                boxShadow: enabled
                    ? [AppColors.neonGlow(color, blur: 10)]
                    : null,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (badge != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on_rounded,
                      color: AppColors.accentGold, size: 11),
                  const SizedBox(width: 2),
                  Text(
                    '$badge',
                    style: const TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
