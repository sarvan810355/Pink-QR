import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../models/qr_history_item.dart';
import '../services/ads_service.dart';
import '../services/history_service.dart';
import '../services/premium_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/pink_button.dart';
import '../widgets/soft_card.dart';
import 'detail_screen.dart';

/// Home / Dashboard — mood greeting, quick actions, recent history, stats.
class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    final premium = context.read<PremiumService>();
    if (!premium.isPremium) {
      AdsService.instance.setAdsRemoved(false);
      _bannerAd = AdsService.instance.createBannerAd(onLoaded: () {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  String _greeting(int hour) {
    if (hour < 5) return 'Sweet dreams, cutie 🌙';
    if (hour < 12) return 'Good morning, cutie! ✨';
    if (hour < 17) return 'Hi gorgeous! ☀️';
    if (hour < 20) return 'Good evening, lovely 🌸';
    return 'Cozy night, bestie 💫';
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryService>();
    final premium = context.watch<PremiumService>();
    final hour = DateTime.now().hour;
    final recent = history.items.take(4).toList();

    return GradientBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
                child: _GreetingHeader(text: _greeting(hour), hour: hour),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: PinkButton(
                          label: 'Scan',
                          icon: Icons.qr_code_scanner_rounded,
                          onPressed: () => widget.onNavigate(1),
                          height: 88,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: PinkButton(
                          label: 'Generate',
                          icon: Icons.auto_awesome_rounded,
                          gradient: AppGradients.roseGoldShine,
                          onPressed: () => widget.onNavigate(2),
                          height: 88,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
                  const SizedBox(height: AppSpacing.lg),
                  _StatsRow(history: history)
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 300.ms),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent moments 🩷', style: AppTextStyles.heading(
                          Theme.of(context).textTheme.bodyLarge!.color!)),
                      TextButton(
                        onPressed: () => widget.onNavigate(3),
                        child: Text('See all',
                            style: AppTextStyles.body(AppColors.roseGold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (recent.isEmpty)
                    const _EmptyRecent()
                  else
                    ...recent.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _RecentTile(item: item),
                        )),
                  if (!premium.isPremium && _bannerAd != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  ],
                  const SizedBox(height: 90),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String text;
  final int hour;
  const _GreetingHeader({required this.text, required this.hour});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.greetingForHour(hour),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: AppTextStyles.greeting(AppColors.textDark)),
          const SizedBox(height: 4),
          Text('Welcome back to QR Bloom',
              style: AppTextStyles.body(AppColors.textDark.withValues(alpha: 0.75))),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.05, end: 0);
  }
}

class _StatsRow extends StatelessWidget {
  final HistoryService history;
  const _StatsRow({required this.history});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          _StatItem(label: 'Total', value: '${history.totalCount}', emoji: '📦'),
          _divider(),
          _StatItem(label: 'Scanned', value: '${history.scanCount}', emoji: '📷'),
          _divider(),
          _StatItem(label: 'Created', value: '${history.generatedCount}', emoji: '✨'),
          _divider(),
          _StatItem(label: 'Faves', value: '${history.favorites.length}', emoji: '💗'),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 34, color: AppColors.softPink.withValues(alpha: 0.4));
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  const _StatItem({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.title(Theme.of(context).textTheme.bodyLarge!.color!)),
          Text(label, style: AppTextStyles.caption(AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final QrHistoryItem item;
  const _RecentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.softPink.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(QrHistoryItem.typeEmoji(item.type), style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title(Theme.of(context).textTheme.bodyLarge!.color!)),
                Text(item.source == QrSourceKind.scanned ? 'Scanned' : 'Generated',
                    style: AppTextStyles.caption(AppColors.textMuted)),
              ],
            ),
          ),
          if (item.isFavorite)
            const Icon(Icons.favorite_rounded, color: AppColors.heartRed, size: 18),
        ],
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Text('🎀', style: TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.sm),
          Text('No moments yet', style: AppTextStyles.title(AppColors.textMuted)),
          const SizedBox(height: 4),
          Text('Scan or create your first QR to see it here',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(AppColors.textMuted)),
        ],
      ),
    );
  }
}
