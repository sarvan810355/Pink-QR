import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/qr_history_item.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/pink_button.dart';
import '../widgets/qr_moment_card.dart';
import '../widgets/soft_card.dart';
import '../widgets/sparkle_burst.dart';
import '../widgets/styled_qr_view.dart';

/// Detail / Export Screen — full QR view with Share-as-Story export,
/// save to gallery, copy, favorite, and delete.
class DetailScreen extends StatefulWidget {
  final QrHistoryItem item;
  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final GlobalKey _momentKey = GlobalKey();
  bool _busy = false;

  Future<Uint8List?> _captureMoment() async {
    try {
      final boundary =
          _momentKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _shareAsStory() async {
    setState(() => _busy = true);
    final bytes = await _captureMoment();
    setState(() => _busy = false);
    if (bytes == null || !mounted) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/qr_bloom_moment_${widget.item.id}.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Made with QR Bloom 🌸');
  }

  Future<void> _saveToGallery() async {
    setState(() => _busy = true);
    final bytes = await _captureMoment();
    setState(() => _busy = false);
    if (bytes == null || !mounted) return;
    final result = await ImageGallerySaverPlus.saveImage(bytes, quality: 100, name: 'qr_bloom_${widget.item.id}');
    if (!mounted) return;
    final success = result is Map && (result['isSuccess'] == true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Saved to gallery 💗' : 'Could not save — check permissions')),
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.item.rawData));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard ✨')));
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        title: const Text('Delete this QR?'),
        content: const Text('This moment will be gone for good 🥺'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.heartRed)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<HistoryService>().remove(widget.item.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryService>();
    final item = history.items.where((e) => e.id == widget.item.id).firstOrNull ?? widget.item;
    final theme = Theme.of(context);

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading(theme.textTheme.bodyLarge!.color!),
                    ),
                  ),
                  HeartToggle(
                    filled: item.isFavorite,
                    onTap: () => context.read<HistoryService>().toggleFavorite(item.id),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    StyledQrView(data: item.rawData, style: item.style, size: 220),
                    const SizedBox(height: AppSpacing.lg),
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Content', style: AppTextStyles.title(AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(item.rawData, style: AppTextStyles.body(theme.textTheme.bodyMedium!.color!)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: PinkButton(
                            label: 'Share as Story',
                            icon: Icons.auto_awesome_rounded,
                            onPressed: _busy ? () {} : _shareAsStory,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: PinkButton(
                            label: 'Save',
                            icon: Icons.download_rounded,
                            gradient: AppGradients.roseGoldShine,
                            onPressed: _busy ? () {} : _saveToGallery,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: PinkButton(
                            label: 'Copy',
                            icon: Icons.copy_rounded,
                            gradient: const LinearGradient(colors: [AppColors.lavenderMist, AppColors.roseGoldLight]),
                            onPressed: _copy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.heartRed),
                      label: Text('Delete', style: AppTextStyles.body(AppColors.heartRed)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Offstage moment card used only for high-res capture.
                    Opacity(
                      opacity: 0,
                      child: IgnorePointer(
                        child: SizedBox(
                          height: 1,
                          child: OverflowBox(
                            maxHeight: 600,
                            alignment: Alignment.topCenter,
                            child: QrMomentCard(item: item, repaintKey: _momentKey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
