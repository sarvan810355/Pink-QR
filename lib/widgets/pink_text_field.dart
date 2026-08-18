import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Soft rounded text field matching the QR Bloom aesthetic.
class PinkTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const PinkTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.title(theme.textTheme.bodyLarge!.color!)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AppTextStyles.body(theme.textTheme.bodyMedium!.color!),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body(AppColors.textMuted),
            prefixIcon: icon != null ? Icon(icon, color: AppColors.roseGold, size: 20) : null,
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? AppColors.charcoalCard
                : AppColors.softPink.withValues(alpha: 0.18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: const BorderSide(color: AppColors.hotPink, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
