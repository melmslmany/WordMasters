import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/constants/app_colors.dart';
import '../data/store_data.dart';
import 'background_painter.dart';

class CurrencyDisplay extends StatelessWidget {
  const CurrencyDisplay({
    super.key,
    required this.keys,
    required this.coins,
  });

  final int keys;
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Badge(icon: Icons.key_rounded, value: keys, color: AppColors.accentKey),
        const SizedBox(width: 8),
        _Badge(
          icon: Icons.monetization_on_rounded,
          value: coins,
          color: AppColors.accentGold,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [AppColors.neonGlow(color, blur: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            '× $value',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class NeonHeader extends StatelessWidget {
  const NeonHeader({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.badge,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 18,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.95),
            AppColors.backgroundLight.withValues(alpha: 0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.neonPurple.withValues(alpha: 0.25)),
        ),
        boxShadow: [
          AppColors.neonGlow(AppColors.neonPurple, blur: 24),
        ],
      ),
      child: Row(
        children: [
          leading,
          Expanded(
            child: Column(
              children: [
                if (badge != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.neonPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.neonPurple.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: AppColors.neonPurple,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: AppColors.neonBlue, blurRadius: 12),
                    ],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.15, end: 0);
  }
}

@Deprecated('Use NeonHeader')
typedef GradientHeader = NeonHeader;

class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.neonGreen,
    this.icon,
    this.trailing,
    this.enabled = true,
    this.outlined = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final IconData? icon;
  final Widget? trailing;
  final bool enabled;
  final bool outlined;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: outlined || !enabled
                ? null
                : LinearGradient(
                    colors: [color, color.withValues(alpha: 0.65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: outlined
                ? Colors.transparent
                : (!enabled ? Colors.grey.withValues(alpha: 0.2) : null),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: outlined
                  ? Colors.white.withValues(alpha: 0.35)
                  : color.withValues(alpha: 0.5),
            ),
            boxShadow: enabled && !outlined
                ? [AppColors.neonGlow(color, blur: 14)]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 16,
              vertical: compact ? 10 : 14,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: compact ? 16 : 20),
                  const SizedBox(width: 6),
                ],
                if (compact)
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: enabled
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.6,
                    ),
                  )
                else
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: enabled
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                if (trailing != null) ...[
                  const SizedBox(width: 6),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NeonBackground extends StatelessWidget {
  const NeonBackground({
    super.key,
    required this.child,
    this.background,
    this.customImagePath,
  });

  final Widget child;
  final StoreBackground? background;
  final String? customImagePath;

  bool get _useCustomImage =>
      background?.isCustom == true &&
      customImagePath != null &&
      customImagePath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_useCustomImage) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _CustomImageLayer(path: customImagePath!),
          // Dark overlay keeps the grid and text readable over any photo.
          Container(color: Colors.black.withValues(alpha: 0.45)),
          child,
        ],
      );
    }

    final bg = background;
    final gradientColors = bg?.colors ??
        const [Color(0xFF1B1040), AppColors.background];

    return Container(
      decoration: BoxDecoration(
        gradient: gradientColors.length > 2
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              )
            : RadialGradient(
                center: const Alignment(0, -0.4),
                radius: 1.4,
                colors: gradientColors,
              ),
      ),
      child: (bg != null && bg.pattern != BgPattern.none)
          ? CustomPaint(
              painter: BackgroundPatternPainter(
                pattern: bg.pattern,
                accent: bg.accent,
              ),
              child: child,
            )
          : child,
    );
  }
}

class _CustomImageLayer extends StatelessWidget {
  const _CustomImageLayer({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final ImageProvider provider = kIsWeb
        ? NetworkImage(path)
        : FileImage(File(path)) as ImageProvider;
    return Image(
      image: provider,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B1040), AppColors.background],
          ),
        ),
      ),
    );
  }
}
