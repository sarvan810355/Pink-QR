import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/qr_style_config.dart';
import '../theme/app_theme.dart';

/// Renders a QR code with the full aesthetic customizer applied: module
/// pattern (square/rounded/dots), a cute decorative frame, and an
/// optional emoji sticker overlaid at the center.
class StyledQrView extends StatelessWidget {
  final String data;
  final QrStyleConfig style;
  final double size;
  final GlobalKey? repaintKey;

  const StyledQrView({
    super.key,
    required this.data,
    required this.style,
    this.size = 260,
    this.repaintKey,
  });

  QrEyeShape get _eyeShape => style.moduleStyle == QrModuleStyle.square
      ? QrEyeShape.square
      : QrEyeShape.circle;

  QrDataModuleShape get _dataShape =>
      style.moduleStyle == QrModuleStyle.square
          ? QrDataModuleShape.square
          : QrDataModuleShape.circle;

  @override
  Widget build(BuildContext context) {
    final content = data.isEmpty
        ? _placeholder(context)
        : Stack(
            alignment: Alignment.center,
            children: [
              QrImageView(
                data: data,
                version: QrVersions.auto,
                size: size,
                backgroundColor: style.backgroundColor,
                eyeStyle: QrEyeStyle(
                  eyeShape: _eyeShape,
                  color: style.foregroundColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: _dataShape,
                  color: style.foregroundColor,
                ),
                errorStateBuilder: (ctx, err) => _placeholder(ctx),
              ),
              if (style.sticker != QrSticker.none)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: style.backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: style.foregroundColor, width: 2),
                  ),
                  child: Text(
                    QrStyleConfig.stickerEmoji(style.sticker),
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
            ],
          );

    final framed = _FrameDecoration(frame: style.frameStyle, child: content);

    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: framed,
      ),
    );
  }

  Widget _placeholder(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text('✨', style: TextStyle(fontSize: size * 0.3)),
        ),
      );
}

class _FrameDecoration extends StatelessWidget {
  final QrFrameStyle frame;
  final Widget child;

  const _FrameDecoration({required this.frame, required this.child});

  @override
  Widget build(BuildContext context) {
    switch (frame) {
      case QrFrameStyle.none:
        return child;
      case QrFrameStyle.floral:
        return _cornerDecorated(child, '🌸');
      case QrFrameStyle.polkaDot:
        return _dottedBorder(child);
      case QrFrameStyle.heart:
        return _cornerDecorated(child, '💗');
      case QrFrameStyle.ribbon:
        return _ribbon(child);
    }
  }

  Widget _cornerDecorated(Widget child, String emoji) {
    Widget corner() => Text(emoji, style: const TextStyle(fontSize: 22));
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          Positioned(top: -4, left: -4, child: corner()),
          Positioned(top: -4, right: -4, child: corner()),
          Positioned(bottom: -4, left: -4, child: corner()),
          Positioned(bottom: -4, right: -4, child: corner()),
        ],
      ),
    );
  }

  Widget _dottedBorder(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.roseGoldLight, width: 3, style: BorderStyle.solid),
      ),
      child: child,
    );
  }

  Widget _ribbon(Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            gradient: AppGradients.roseGoldShine,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: const Text('🎀', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
