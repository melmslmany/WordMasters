import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../data/progression_data.dart';
import '../l10n/app_localizations.dart';
import '../models/daily_task.dart';
import '../providers/game_provider.dart';
import '../providers/progression_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/common_widgets.dart';

class DailyTasksTab extends StatelessWidget {
  const DailyTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.forLocale(settings.uiLanguage);
    final game = context.watch<GameProvider>();
    final progression = context.watch<ProgressionProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeonHeader(
          leading: const SizedBox(width: 48),
          title: l10n.dailyTasks,
          subtitle: l10n.dailyTasksDesc,
          badge: 'DAILY',
          trailing: CurrencyDisplay(keys: game.keys, coins: game.coins),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: DailyTasksData.tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = DailyTasksData.tasks[index];
              return _TaskCard(
                task: task,
                l10n: l10n,
                progression: progression,
                onClaim: () async {
                  final reward = await progression.claimTask(task);
                  if (reward != null) {
                    await game.addCoins(reward);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${l10n.rewardClaimed} +$reward 🪙'),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.l10n,
    required this.progression,
    required this.onClaim,
  });

  final DailyTaskDefinition task;
  final AppLocalizations l10n;
  final ProgressionProvider progression;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final progress = progression.progressFor(task);
    final complete = progression.isTaskComplete(task);
    final claimed = progression.isTaskClaimed(task.id);
    final canClaim = progression.canClaim(task);
    final ratio = task.target > 0
        ? (progress / task.target).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: complete
              ? AppColors.neonGreen.withValues(alpha: 0.5)
              : AppColors.neonBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(task.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title(l10n.isArabic),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: Colors.black26,
                    valueColor: AlwaysStoppedAnimation(
                      complete ? AppColors.neonGreen : AppColors.neonBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$progress / ${task.target}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RewardBadge(
            claimed: claimed,
            canClaim: canClaim,
            reward: task.reward,
            claimLabel: l10n.claim,
            onClaim: onClaim,
          ),
        ],
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({
    required this.claimed,
    required this.canClaim,
    required this.reward,
    required this.claimLabel,
    required this.onClaim,
  });

  final bool claimed;
  final bool canClaim;
  final int reward;
  final String claimLabel;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    if (claimed) {
      return const Icon(
        Icons.check_circle_rounded,
        color: AppColors.neonGreen,
        size: 32,
      );
    }

    if (canClaim) {
      return _CompactActionButton(
        label: claimLabel,
        color: AppColors.neonGreen,
        onTap: onClaim,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.monetization_on_rounded,
          color: AppColors.accentGold,
          size: 22,
        ),
        Text(
          '+$reward',
          style: const TextStyle(
            color: AppColors.accentGold,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
