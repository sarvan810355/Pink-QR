import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/feedback_service.dart';

/// Primary CTA button with a soft-pink gradient and a playful bounce
/// on tap. Used for "Scan", "Generate", and other big actions.
class PinkButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final double height;
  final bool expand;

  const PinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.height = 56,
    this.expand = true,
  });

  @override
  State<PinkButton> createState() => _PinkButtonState();
}

class _PinkButtonState extends State<PinkButton> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.94);
  void _onTapUp(_) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final button = AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        height: widget.height,
        width: widget.expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: widget.gradient ?? AppGradients.primaryButton,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: AppShadows.button,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: Colors.white, size: 22),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(
                widget.label,
                style: AppTextStyles.button(Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        FeedbackService.instance.tap();
        widget.onPressed();
      },
      child: button,
    );
  }
}

/// Small pill-shaped chip button, e.g. for color/style selectors.
class PinkChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const PinkChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.primaryButton : null,
          color: selected ? null : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.softPink.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(selected ? Colors.white : theme.textTheme.bodyMedium!.color!),
        ),
      ),
    ).animate(target: selected ? 1 : 0).scaleXY(begin: 1, end: 1.04, duration: 150.ms);
  }
}
