import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Playful sparkle/heart burst overlay shown on successful scan or
/// QR creation. Purely decorative, self-dismissing.
class SparkleBurst extends StatelessWidget {
  final int particleCount;
  final VoidCallback? onComplete;

  const SparkleBurst({super.key, this.particleCount = 14, this.onComplete});

  static const _emojis = ['✨', '💗', '⭐', '🩷'];

  @override
  Widget build(BuildContext context) {
    final random = Random();
    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          children: List.generate(particleCount, (i) {
            final angle = random.nextDouble() * 2 * pi;
            final distance = 80.0 + random.nextDouble() * 160;
            final dx = cos(angle) * distance;
            final dy = sin(angle) * distance;
            final emoji = _emojis[random.nextInt(_emojis.length)];
            final delay = Duration(milliseconds: random.nextInt(150));

            return Align(
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 22))
                  .animate(
                    onComplete: i == particleCount - 1
                        ? (_) => onComplete?.call()
                        : null,
                  )
                  .fadeIn(delay: delay, duration: 150.ms)
                  .move(
                    begin: Offset.zero,
                    end: Offset(dx, dy),
                    delay: delay,
                    duration: 700.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeOut(delay: delay + 400.ms, duration: 350.ms)
                  .scaleXY(begin: 0.6, end: 1.2, delay: delay, duration: 700.ms),
            );
          }),
        ),
      ),
    );
  }
}

/// Wraps a child and shows a [SparkleBurst] centered over it when [trigger] flips true.
class SparkleTriggerOverlay extends StatelessWidget {
  final Widget child;
  final bool show;
  final VoidCallback? onComplete;

  const SparkleTriggerOverlay({
    super.key,
    required this.child,
    required this.show,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (show) SparkleBurst(onComplete: onComplete),
      ],
    );
  }
}

/// Small heart-shaped icon toggle used across the app for favorites.
class HeartToggle extends StatelessWidget {
  final bool filled;
  final VoidCallback onTap;
  final double size;

  const HeartToggle({
    super.key,
    required this.filled,
    required this.onTap,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: filled ? AppColors.heartRed : AppColors.textMuted,
        size: size,
      )
          .animate(target: filled ? 1 : 0)
          .scaleXY(begin: 1, end: 1.3, duration: 150.ms, curve: Curves.easeOut)
          .then()
          .scaleXY(begin: 1.3, end: 1.0, duration: 120.ms),
    );
  }
}
