import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/qr_history_item.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/soft_card.dart';
import '../widgets/sparkle_burst.dart';
import 'detail_screen.dart';

/// History Screen — searchable, swipe-to-delete card list with favorites.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryService>();
    final theme = Theme.of(context);

    var items = history.search(_query);
    if (_favoritesOnly) items = items.where((e) => e.isFavorite).toList();

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('History 🗂️', style: AppTextStyles.heading(theme.textTheme.bodyLarge!.color!)),
                  GestureDetector(
                    onTap: () => setState(() => _favoritesOnly = !_favoritesOnly),
                    child: Icon(
                      _favoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: AppColors.heartRed,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: AppTextStyles.body(theme.textTheme.bodyMedium!.color!),
                decoration: InputDecoration(
                  hintText: 'Search your moments…',
                  hintStyle: AppTextStyles.body(AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.roseGold),
                  filled: true,
                  fillColor: theme.cardTheme.color,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? _EmptyHistory(hasQuery: _query.isNotEmpty || _favoritesOnly)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 100),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: AppColors.heartRed.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                          ),
                          onDismissed: (_) => context.read<HistoryService>().remove(item.id),
                          child: _HistoryCard(item: item),
                        ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.03, end: 0);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final QrHistoryItem item;
  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryButton,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(QrHistoryItem.typeEmoji(item.type), style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title(theme.textTheme.bodyLarge!.color!)),
                const SizedBox(height: 2),
                Text(
                  '${item.source == QrSourceKind.scanned ? "Scanned" : "Created"} · ${_formatDate(item.createdAt)}',
                  style: AppTextStyles.caption(AppColors.textMuted),
                ),
              ],
            ),
          ),
          HeartToggle(
            filled: item.isFavorite,
            onTap: () => context.read<HistoryService>().toggleFavorite(item.id),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    }
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _EmptyHistory extends StatelessWidget {
  final bool hasQuery;
  const _EmptyHistory({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hasQuery ? '🔍' : '🎀', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasQuery ? 'Nothing here yet' : 'Your history is empty',
              style: AppTextStyles.title(AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              hasQuery ? 'Try a different search' : 'Scan or create a QR to get started',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
