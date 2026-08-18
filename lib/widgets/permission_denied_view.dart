import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import 'pink_button.dart';
import 'soft_card.dart';

/// Friendly, pink-themed replacement for the scary native "permission
/// denied" dialog — shown when camera access is blocked.
class PermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetry;
  final String title;
  final String message;

  const PermissionDeniedView({
    super.key,
    required this.onRetry,
    this.title = 'We need your camera, cutie 🌸',
    this.message =
        'QR Bloom uses the camera only to scan codes — nothing is ever stored or sent anywhere. '
        'Pop over to Settings to turn it on!',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SoftCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppSpacing.md),
              Text(title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading(
                      Theme.of(context).textTheme.bodyLarge!.color!)),
              const SizedBox(height: AppSpacing.sm),
              Text(message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(AppColors.textMuted)),
              const SizedBox(height: AppSpacing.lg),
              const PinkButton(
                label: 'Open Settings',
                icon: Icons.settings_rounded,
                onPressed: openAppSettings,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: onRetry,
                child: Text('Try again', style: AppTextStyles.body(AppColors.roseGold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
