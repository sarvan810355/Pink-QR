import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Soft pastel gradient backdrop used behind every screen.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  const GradientBackground({super.key, required this.child, this.gradient});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            (isDark ? AppGradients.nightBackground : AppGradients.dayBackground),
      ),
      child: child,
    );
  }
}
