import 'dart:math';

import 'package:flutter/material.dart';

import '../data/store_data.dart';

/// Paints decorative scenery (stars, waves, rays, ...) over a gradient
/// so backgrounds feel like scenes rather than flat colors.
class BackgroundPatternPainter extends CustomPainter {
  BackgroundPatternPainter({required this.pattern, required this.accent});

  final BgPattern pattern;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    // Fixed seed -> stable, non-flickering decoration.
    final rng = Random(pattern.index * 7919 + 13);
    switch (pattern) {
      case BgPattern.stars:
        _stars(canvas, size, rng);
        break;
      case BgPattern.bubbles:
        _bubbles(canvas, size, rng);
        break;
      case BgPattern.waves:
        _waves(canvas, size);
        break;
      case BgPattern.rays:
        _rays(canvas, size);
        break;
      case BgPattern.aurora:
        _aurora(canvas, size);
        break;
      case BgPattern.snow:
        _snow(canvas, size, rng);
        break;
      case BgPattern.petals:
        _petals(canvas, size, rng);
        break;
      case BgPattern.none:
        break;
    }
  }

  void _stars(Canvas canvas, Size size, Random rng) {
    for (var i = 0; i < 90; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.85;
      final r = rng.nextDouble() * 1.6 + 0.4;
      final paint = Paint()
        ..color = accent.withValues(alpha: rng.nextDouble() * 0.6 + 0.15);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
    // A few glowing larger stars.
    for (var i = 0; i < 6; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.6;
      final glow = Paint()
        ..color = accent.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(x, y), 3, glow);
    }
  }

  void _bubbles(Canvas canvas, Size size, Random rng) {
    for (var i = 0; i < 26; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 26 + 6;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = accent.withValues(alpha: rng.nextDouble() * 0.18 + 0.05);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  void _waves(Canvas canvas, Size size) {
    for (var w = 0; w < 4; w++) {
      final path = Path();
      final baseY = size.height * (0.55 + w * 0.12);
      final amp = 14.0 + w * 4;
      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 8) {
        path.lineTo(x, baseY + sin((x / size.width * 4 * pi) + w) * amp);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      final paint = Paint()
        ..color = accent.withValues(alpha: 0.06 + w * 0.02);
      canvas.drawPath(path, paint);
    }
  }

  void _rays(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, -size.height * 0.1);
    for (var i = 0; i < 12; i++) {
      final angle = (pi / 11) * i;
      final paint = Paint()
        ..color = accent.withValues(alpha: i.isEven ? 0.05 : 0.025);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + cos(angle) * size.height * 1.6,
            center.dy + sin(angle) * size.height * 1.6)
        ..lineTo(center.dx + cos(angle + 0.12) * size.height * 1.6,
            center.dy + sin(angle + 0.12) * size.height * 1.6)
        ..close();
      canvas.drawPath(path, paint);
    }
    final glow = Paint()
      ..color = accent.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(center, 70, glow);
  }

  void _aurora(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final path = Path();
      final baseY = size.height * (0.2 + i * 0.16);
      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 10) {
        path.lineTo(x, baseY + sin((x / size.width * 3 * pi) + i * 1.3) * 40);
      }
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..color = accent.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
      canvas.drawPath(path, paint);
    }
  }

  void _snow(Canvas canvas, Size size, Random rng) {
    for (var i = 0; i < 70; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 2.4 + 0.6;
      final paint = Paint()
        ..color = accent.withValues(alpha: rng.nextDouble() * 0.5 + 0.2);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  void _petals(Canvas canvas, Size size, Random rng) {
    for (var i = 0; i < 36; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final s = rng.nextDouble() * 5 + 3;
      final paint = Paint()
        ..color = accent.withValues(alpha: rng.nextDouble() * 0.35 + 0.12);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rng.nextDouble() * pi);
      final rect = Rect.fromCenter(center: Offset.zero, width: s, height: s * 2);
      canvas.drawOval(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPatternPainter oldDelegate) =>
      oldDelegate.pattern != pattern || oldDelegate.accent != accent;
}
