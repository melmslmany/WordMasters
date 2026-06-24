import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../data/progression_data.dart';
import '../l10n/app_localizations.dart';
import '../models/player_rank.dart';
import '../models/player_stats.dart';
import '../providers/game_provider.dart';
import '../providers/progression_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/game_dialogs.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.l10n,
    required this.game,
    required this.progression,
    required this.settings,
  });

  final AppLocalizations l10n;
  final GameProvider game;
  final ProgressionProvider progression;
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final rank = progression.currentRank;
    final next = progression.nextRank;
    final stats = progression.stats;

    return Column(
      children: [
        NeonHeader(
          leading: IconButton(
            onPressed: () => showSettingsDialog(context, settings, game),
            icon: const Icon(Icons.settings_rounded, color: Colors.white70),
          ),
          title: l10n.profile,
          subtitle: l10n.ranks,
          trailing: CurrencyDisplay(keys: game.keys, coins: game.coins),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CurrentRankCard(
                rank: rank,
                next: next,
                totalWords: stats.totalWordsFound,
                progress: progression.rankProgress,
                l10n: l10n,
              ).animate().fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 16),
              _StatsRow(stats: stats, l10n: l10n),
              const SizedBox(height: 20),
              Text(
                l10n.allRanks,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ...RanksData.ranks.asMap().entries.map((e) {
                final r = e.value;
                final unlocked = stats.totalWordsFound >= r.requiredWords;
                final isCurrent = r.id == rank.id;
                return _RankTile(
                  rank: r,
                  unlocked: unlocked,
                  isCurrent: isCurrent,
                  totalWords: stats.totalWordsFound,
                  l10n: l10n,
                ).animate(delay: (e.key * 40).ms).fadeIn();
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrentRankCard extends StatelessWidget {
  const _CurrentRankCard({
    required this.rank,
    required this.next,
    required this.totalWords,
    required this.progress,
    required this.l10n,
  });

  final PlayerRank rank;
  final PlayerRank? next;
  final int totalWords;
  final double progress;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rank.color.withValues(alpha: 0.25),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rank.color.withValues(alpha: 0.5)),
        boxShadow: [AppColors.neonGlow(rank.color, blur: 16)],
      ),
      child: Column(
        children: [
          Icon(rank.icon, color: rank.color, size: 48),
          const SizedBox(height: 8),
          Text(
            rank.name(l10n.isArabic),
            style: TextStyle(
              color: rank.color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalWords ${l10n.wordsFoundTotal}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (next != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.black26,
                valueColor: AlwaysStoppedAnimation(rank.color),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${l10n.nextRank}: ${next!.name(l10n.isArabic)} (${next!.requiredWords} ${l10n.wordsFoundTotal})',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.l10n});

  final PlayerStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(label: l10n.levels, value: '${stats.totalLevelsCompleted}'),
        const SizedBox(width: 8),
        _StatChip(label: l10n.wordsFound, value: '${stats.totalWordsFound}'),
        const SizedBox(width: 8),
        _StatChip(label: l10n.dailyStreak, value: '${context.watch<GameProvider>().dailyStreak}'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({
    required this.rank,
    required this.unlocked,
    required this.isCurrent,
    required this.totalWords,
    required this.l10n,
  });

  final PlayerRank rank;
  final bool unlocked;
  final bool isCurrent;
  final int totalWords;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent
            ? rank.color.withValues(alpha: 0.15)
            : AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked
              ? rank.color.withValues(alpha: isCurrent ? 0.6 : 0.3)
              : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            unlocked ? rank.icon : Icons.lock_outline,
            color: unlocked ? rank.color : Colors.white38,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rank.name(l10n.isArabic),
              style: TextStyle(
                color: unlocked ? Colors.white : Colors.white54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (unlocked && isCurrent)
            Icon(Icons.star_rounded, color: rank.color, size: 20)
          else if (unlocked)
            const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 20)
          else
            Text(
              '${rank.requiredWords} ${l10n.wordsFoundTotal}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
        ],
      ),
    );
  }
}
