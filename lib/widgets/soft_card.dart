import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Rounded, softly-shadowed card — the base surface for the whole app.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.radius = AppRadii.lg,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? theme.cardTheme.color) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: theme.brightness == Brightness.light ? AppShadows.soft : null,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
