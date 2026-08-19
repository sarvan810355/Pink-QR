import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/qr_style_config.dart';
import '../services/premium_service.dart';
import '../theme/app_theme.dart';
import 'pink_button.dart';

/// Full QR aesthetic customizer: pattern style, pastel color palette,
/// decorative frame, and center sticker/emoji overlay.
class QrCustomizerSheet extends StatefulWidget {
  final QrStyleConfig initial;
  final ValueChanged<QrStyleConfig> onChanged;

  const QrCustomizerSheet({super.key, required this.initial, required this.onChanged});

  static Future<void> show(
    BuildContext context, {
    required QrStyleConfig initial,
    required ValueChanged<QrStyleConfig> onChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QrCustomizerSheet(initial: initial, onChanged: onChanged),
    );
  }

  @override
  State<QrCustomizerSheet> createState() => _QrCustomizerSheetState();
}

class _QrCustomizerSheetState extends State<QrCustomizerSheet> {
  late QrStyleConfig _style = widget.initial;

  // First 2 frames and first 4 stickers are free; the rest require
  // premium unlock, matching the "Remove Ads + Unlock All Stickers &
  // Frames" IAP.
  static const _freeFrameCount = 2;
  static const _freeStickerCount = 4;

  void _apply(QrStyleConfig next) {
    setState(() => _style = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPremium = context.watch<PremiumService>().isPremium;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.softPink,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Make it cute ✨', style: AppTextStyles.heading(theme.textTheme.bodyLarge!.color!)),
              const SizedBox(height: AppSpacing.lg),
              _sectionLabel('Pattern style'),
              Wrap(
                spacing: AppSpacing.sm,
                children: QrModuleStyle.values.map((m) {
                  return PinkChip(
                    label: switch (m) {
                      QrModuleStyle.square => 'Classic',
                      QrModuleStyle.rounded => 'Rounded',
                      QrModuleStyle.dots => 'Dots',
                      QrModuleStyle.hearts => '💗 Hearts',
                    },
                    selected: _style.moduleStyle == m,
                    onTap: () => _apply(_style.copyWith(moduleStyle: m)),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              _sectionLabel('Pastel palette'),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppColors.pastelPaletteChoices.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final color = AppColors.pastelPaletteChoices[i];
                    final selected = _style.foregroundColor == color;
                    return GestureDetector(
                      onTap: () => _apply(_style.copyWith(foregroundColor: color)),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? AppColors.hotPink : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _sectionLabel('Cute frame'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: QrFrameStyle.values.asMap().entries.map((entry) {
                  final locked = !isPremium && entry.key >= _freeFrameCount;
                  return _LockableChip(
                    label: QrStyleConfig.frameLabel(entry.value),
                    selected: _style.frameStyle == entry.value,
                    locked: locked,
                    onTap: () => locked
                        ? _showPremiumHint(context)
                        : _apply(_style.copyWith(frameStyle: entry.value)),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              _sectionLabel('Center sticker'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: QrSticker.values.asMap().entries.map((entry) {
                  final locked = !isPremium && entry.key >= _freeStickerCount;
                  final emoji = QrStyleConfig.stickerEmoji(entry.value);
                  return _LockableChip(
                    label: entry.value == QrSticker.none ? 'None' : emoji,
                    selected: _style.sticker == entry.value,
                    locked: locked,
                    onTap: () => locked
                        ? _showPremiumHint(context)
                        : _apply(_style.copyWith(sticker: entry.value)),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              PinkButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        );
      },
    );
  }

  void _showPremiumHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unlock all stickers & frames in Settings 💎')),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(text, style: AppTextStyles.title(AppColors.textMuted)),
      );
}

class _LockableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  const _LockableChip({
    required this.label,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(opacity: locked ? 0.5 : 1, child: PinkChip(label: label, selected: selected, onTap: onTap)),
        if (locked)
          const Positioned(
            right: 4,
            top: 4,
            child: Icon(Icons.lock_rounded, size: 14, color: AppColors.roseGold),
          ),
      ],
    );
  }
}
