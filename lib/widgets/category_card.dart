import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/category.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.isUnlocked,
    required this.completedLevels,
    required this.totalLevels,
    required this.l10n,
    required this.onTap,
    this.index = 0,
  });

  final GameCategory category;
  final bool isUnlocked;
  final int completedLevels;
  final int totalLevels;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final percent = totalLevels == 0
        ? 0
        : ((completedLevels / totalLevels) * 100).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 108,
        decoration: AppColors.neonCard(
          gradient: category.gradient,
          glowColor: category.color,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -16,
                top: -16,
                child: Icon(
                  category.icon,
                  size: 110,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          AppColors.neonGlow(category.color, blur: 12),
                        ],
                      ),
                      child: Icon(category.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: _buildContent(percent)),
                    Icon(
                      isUnlocked
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.lock_rounded,
                      color: Colors.white.withValues(alpha: 0.75),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 320.ms)
        .slideX(begin: 0.08, end: 0);
  }

  Widget _buildContent(int percent) {
    if (!isUnlocked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            category.name(l10n.isArabic).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, color: Colors.white70, size: 13),
                const SizedBox(width: 6),
                const Icon(Icons.key_rounded,
                    color: AppColors.accentKey, size: 13),
                Text(
                  ' × ${category.unlockCostKeys}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          category.name(l10n.isArabic).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: totalLevels == 0 ? 0 : completedLevels / totalLevels,
                  minHeight: 7,
                  backgroundColor: Colors.black.withValues(alpha: 0.35),
                  valueColor: AlwaysStoppedAnimation(
                    AppColors.neonGreen.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$percent%',
              style: const TextStyle(
                color: AppColors.neonGreen,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$completedLevels / $totalLevels',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
