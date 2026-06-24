import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../l10n/languages.dart';
import '../models/category.dart';
import '../models/difficulty.dart';
import '../models/game_style.dart';
import '../models/levels_option.dart';
import '../models/word_language.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import 'common_widgets.dart';

Future<void> showSettingsDialog(
  BuildContext context,
  SettingsProvider settings,
  GameProvider game,
) {
  final l10n = AppLocalizations.forLocale(settings.uiLanguage);

  return showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        return _GameDialog(
          title: l10n.settings,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.55,
            ),
            child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToggleRow(
                icon: Icons.music_note_rounded,
                label: l10n.music,
                value: settings.musicEnabled,
                onChanged: (v) async {
                  await settings.setMusic(v);
                  setState(() {});
                },
              ),
              _ToggleRow(
                icon: Icons.volume_up_rounded,
                label: l10n.sounds,
                value: settings.soundsEnabled,
                onChanged: (v) async {
                  await settings.setSounds(v);
                  setState(() {});
                },
              ),
              const Divider(color: Colors.white24, height: 24),
              _LanguageSelector(
                label: l10n.language,
                value: settings.uiLanguage,
                onChanged: (v) async {
                  await settings.setUiLanguage(v);
                  await game.setWordLanguage(WordLanguage.fromCode(v));
                  setState(() {});
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 12),
              _LevelsPerCategorySelector(
                label: l10n.levelsPerCategory,
                value: settings.levelsPerCategory,
                onChanged: (v) async {
                  await settings.setLevelsPerCategory(v);
                  game.syncLevelsPerCategory(v);
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              GameButton(
                label: l10n.dataPrivacy,
                onTap: () {},
                color: AppColors.accent,
                outlined: true,
              ),
              const SizedBox(height: 8),
              GameButton(
                label: l10n.privacyPolicy,
                onTap: () {},
                color: AppColors.primary,
                outlined: true,
              ),
            ],
            ),
            ),
          ),
          onClose: () => Navigator.pop(ctx),
          l10n: l10n,
        );
      },
    ),
  );
}

Future<void> showGameModeDialog(
  BuildContext context, {
  required GameCategory category,
  required AppLocalizations l10n,
  required GameProvider game,
  required ValueChanged<GameStyle> onStartProgress,
  required ValueChanged<GameStyle> onStartCasual,
  required ValueChanged<GameStyle> onStartEndless,
  required VoidCallback? onContinue,
}) {
  return showDialog(
    context: context,
    builder: (ctx) {
      var selectedStyle = game.gameStyle;
      return StatefulBuilder(
        builder: (ctx, setState) => _GameDialog(
          title: category.name(l10n.isArabic).toUpperCase(),
          icon: category.icon,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.62,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StyleSelector(
                    l10n: l10n,
                    value: selectedStyle,
                    onChanged: (s) async {
                      await game.setGameStyle(s);
                      setState(() => selectedStyle = s);
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.pickGameMode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _ModeColumn(
                    title: l10n.casual,
                    icon: Icons.coffee_rounded,
                    description: l10n.casualDesc,
                    accent: AppColors.neonBlue,
                    buttons: [
                      GameButton(
                        label: l10n.play,
                        onTap: () {
                          Navigator.pop(ctx);
                          onStartCasual(selectedStyle);
                        },
                        color: AppColors.neonGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _ModeColumn(
                    title: l10n.progress,
                    icon: Icons.emoji_events_rounded,
                    description: l10n.progressDesc,
                    accent: AppColors.neonOrange,
                    buttons: [
                      GameButton(
                        label: l10n.playNext,
                        onTap: () {
                          Navigator.pop(ctx);
                          onStartProgress(selectedStyle);
                        },
                        color: AppColors.neonGreen,
                      ),
                      if (onContinue != null) ...[
                        const SizedBox(height: 8),
                        GameButton(
                          label: l10n.continueGame,
                          onTap: () {
                            Navigator.pop(ctx);
                            onContinue();
                          },
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  _ModeColumn(
                    title: l10n.endless,
                    icon: Icons.all_inclusive_rounded,
                    description: l10n.endlessDesc,
                    accent: AppColors.neonPink,
                    buttons: [
                      GameButton(
                        label: l10n.play,
                        onTap: () {
                          Navigator.pop(ctx);
                          onStartEndless(selectedStyle);
                        },
                        color: AppColors.neonPurple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          onClose: () => Navigator.pop(ctx),
          l10n: l10n,
        ),
      );
    },
  );
}

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({
    required this.l10n,
    required this.value,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final GameStyle value;
  final ValueChanged<GameStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.style_rounded,
                color: AppColors.neonCyan, size: 18),
            const SizedBox(width: 6),
            Text(l10n.gameStyle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StyleCard(
                icon: Icons.grid_4x4_rounded,
                title: l10n.classic,
                desc: l10n.classicDesc,
                selected: value == GameStyle.classic,
                accent: AppColors.neonBlue,
                onTap: () => onChanged(GameStyle.classic),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StyleCard(
                icon: Icons.hexagon_outlined,
                title: l10n.wordGuess,
                desc: l10n.wordGuessDesc,
                selected: value == GameStyle.wordGuess,
                accent: AppColors.neonPink,
                onTap: () => onChanged(GameStyle.wordGuess),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StyleCard extends StatelessWidget {
  const _StyleCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String desc;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? accent : Colors.white24,
            width: selected ? 2 : 1,
          ),
          boxShadow:
              selected ? [AppColors.neonGlow(accent, blur: 12)] : null,
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? accent : Colors.white60, size: 26),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Difficulty?> showDifficultyDialog(
  BuildContext context,
  AppLocalizations l10n,
) {
  return showDialog<Difficulty>(
    context: context,
    builder: (ctx) => _GameDialog(
      title: l10n.selectDifficulty,
      child: Column(
        children: Difficulty.values.map((d) {
          final label = switch (d) {
            Difficulty.easy => l10n.easy,
            Difficulty.medium => l10n.medium,
            Difficulty.hard => l10n.hard,
          };
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GameButton(
              label: '$label (${d.gridSize}×${d.gridSize})',
              onTap: () => Navigator.pop(ctx, d),
              color: AppColors.accent,
            ),
          );
        }).toList(),
      ),
      onClose: () => Navigator.pop(ctx),
      l10n: l10n,
    ),
  );
}

Future<void> showUnlockDialog(
  BuildContext context, {
  required GameCategory category,
  required AppLocalizations l10n,
  required GameProvider game,
  required VoidCallback onUnlocked,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => _GameDialog(
      title: category.name(l10n.isArabic).toUpperCase(),
      icon: category.icon,
      child: Column(
        children: [
          Text(
            '${l10n.unlockFor} ${category.unlockCostKeys} 🔑',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '(${category.unlockCostCoins} 🪙)',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          GameButton(
            label: l10n.unlock,
            onTap: () async {
              await game.unlockCategory(category.id);
              if (ctx.mounted) Navigator.pop(ctx);
              onUnlocked();
            },
            color: AppColors.accent,
          ),
        ],
      ),
      onClose: () => Navigator.pop(ctx),
      l10n: l10n,
    ),
  );
}

Future<void> showCompleteDialog(
  BuildContext context, {
  required AppLocalizations l10n,
  required int reward,
  required bool isProgressMode,
  required VoidCallback onNext,
  required VoidCallback onCategories,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _GameDialog(
      title: l10n.completed,
      child: Column(
        children: [
          if (reward > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: AppColors.accentGold, size: 40),
                const SizedBox(width: 8),
                Text(
                  '× $reward',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          if (reward > 0) const SizedBox(height: 24),
          GameButton(
            label: isProgressMode ? l10n.nextLevel : l10n.playNext,
            onTap: () {
              Navigator.pop(ctx);
              onNext();
            },
          ),
          const SizedBox(height: 8),
          GameButton(
            label: l10n.categories,
            onTap: () {
              Navigator.pop(ctx);
              onCategories();
            },
            color: const Color(0xFF555577),
          ),
        ],
      ),
      onClose: () {
        Navigator.pop(ctx);
        onCategories();
      },
      l10n: l10n,
    ),
  );
}

class _GameDialog extends StatelessWidget {
  const _GameDialog({
    required this.title,
    required this.child,
    required this.onClose,
    required this.l10n,
    this.icon,
  });

  final String title;
  final Widget child;
  final VoidCallback onClose;
  final AppLocalizations l10n;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.surfaceLight,
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.35)),
          boxShadow: [
            AppColors.neonGlow(AppColors.neonPurple, blur: 28),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
            child,
            const SizedBox(height: 8),
            TextButton(
              onPressed: onClose,
              child: Text(l10n.close,
                  style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.language_rounded,
                color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppLanguages.all.map((lang) {
            return _LangChip(
              label: '${lang.flag} ${lang.nativeName}',
              selected: value == lang.code,
              onTap: () => onChanged(lang.code),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.white12,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.accent : Colors.white24,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ModeColumn extends StatelessWidget {
  const _ModeColumn({
    required this.title,
    required this.description,
    required this.buttons,
    this.icon,
    this.accent = AppColors.neonBlue,
  });

  final String title;
  final String description;
  final List<Widget> buttons;
  final IconData? icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: accent, size: 18),
                const SizedBox(width: 6),
              ],
              Text(title,
                  style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 6),
          Text(description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 12),
          ...buttons,
        ],
      ),
    );
  }
}

class _LevelsPerCategorySelector extends StatelessWidget {
  const _LevelsPerCategorySelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.layers_rounded,
                color: AppColors.neonCyan, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: LevelsOption.options.map((count) {
            final selected = value == count;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(count),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.neonCyan.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.neonCyan
                          : Colors.white24,
                    ),
                  ),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? AppColors.neonCyan : Colors.white60,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
