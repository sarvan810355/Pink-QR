import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/ads_service.dart';
import '../services/history_service.dart';
import '../services/premium_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/pink_button.dart';
import '../widgets/soft_card.dart';

/// Settings Screen — theme toggle, history management, premium unlock,
/// and the usual about/rate/privacy links.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearHistory(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        title: const Text('Clear all history?'),
        content: const Text('All your scanned & created QR moments will be removed. This can\'t be undone 🥺'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: AppColors.heartRed)),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    await context.read<HistoryService>().clearAll();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _unlockPremium(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        title: const Text('Unlock QR Bloom Premium 💎'),
        content: const Text(
          'Remove all ads and unlock every sticker & frame — one-time purchase.\n\n'
          '(Demo build: this flips a local flag; wire up in_app_purchase with your '
          'store product ID for a real purchase flow.)',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unlock', style: TextStyle(color: AppColors.roseGold)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<PremiumService>().unlockPremium();
      AdsService.instance.setAdsRemoved(true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium unlocked — enjoy, gorgeous! 💗')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final premium = context.watch<PremiumService>();
    final theme = Theme.of(context);

    return GradientBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 100),
          children: [
            Text('Settings 🩷', style: AppTextStyles.heading(theme.textTheme.bodyLarge!.color!)),
            const SizedBox(height: AppSpacing.lg),
            if (!premium.isPremium)
              SoftCard(
                gradient: const LinearGradient(
                  colors: [AppColors.lavenderMist, AppColors.softPink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text('Go Premium', style: AppTextStyles.title(AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(
                      'Remove ads + unlock all stickers & frames',
                      style: AppTextStyles.body(AppColors.textDark.withValues(alpha: 0.75)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PinkButton(
                      label: 'Unlock for \$2.99',
                      onPressed: () => _unlockPremium(context),
                    ),
                  ],
                ),
              )
            else
              SoftCard(
                child: Row(
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text('Premium unlocked — thank you!', style: AppTextStyles.title(AppColors.roseGold)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            const _SectionLabel('Appearance'),
            SoftCard(
              child: Row(
                children: [
                  Text(themeService.isNight ? '🌙' : '☀️', style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      themeService.isNight ? 'Night Pink' : 'Day Pink',
                      style: AppTextStyles.title(theme.textTheme.bodyLarge!.color!),
                    ),
                  ),
                  Switch.adaptive(
                    value: themeService.isNight,
                    activeThumbColor: AppColors.dustyRose,
                    onChanged: (v) => themeService.toggle(v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _SectionLabel('Data'),
            SoftCard(
              onTap: () => _clearHistory(context),
              child: Row(
                children: [
                  const Icon(Icons.delete_sweep_outlined, color: AppColors.heartRed),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Clear history', style: AppTextStyles.title(AppColors.heartRed)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _SectionLabel('About'),
            SoftCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.star_border_rounded,
                    label: 'Rate QR Bloom',
                    onTap: () => _openUrl('https://play.google.com/store/apps/details?id=com.qrbloom.app'),
                  ),
                  const Divider(height: 20, color: AppColors.softPink),
                  _SettingsRow(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () => _openUrl('https://qrbloom.app/privacy'),
                  ),
                  const Divider(height: 20, color: AppColors.softPink),
                  _SettingsRow(
                    icon: Icons.info_outline_rounded,
                    label: 'About QR Bloom',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'QR Bloom',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Text('🌸', style: TextStyle(fontSize: 32)),
                      children: const [
                        Text('A soft-pink QR generator & scanner, made with love. 🩷'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
      child: Text(text, style: AppTextStyles.caption(AppColors.textMuted)),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: AppColors.roseGold),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label, style: AppTextStyles.title(theme.textTheme.bodyLarge!.color!))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
