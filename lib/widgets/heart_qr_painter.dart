import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// Renders a QR code with heart-shaped data modules — the "hearts" pattern
/// style. Finder patterns (the three corner squares) are kept as plain
/// rounded squares since scanners rely on their exact geometry for
/// detection; only the data modules are stylized as hearts.
///
/// Uses a high error-correction level (H, ~30% redundancy) to keep codes
/// reliably scannable despite the reduced fill coverage of heart shapes.
class HeartQrView extends StatelessWidget {
  final String data;
  final Color foreground;
  final Color background;
  final double size;

  const HeartQrView({
    super.key,
    required this.data,
    required this.foreground,
    required this.background,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HeartQrPainter(
          data: data,
          foreground: foreground,
          background: background,
        ),
      ),
    );
  }
}

class _HeartQrPainter extends CustomPainter {
  final String data;
  final Color foreground;
  final Color background;

  _HeartQrPainter({
    required this.data,
    required this.foreground,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );
    final qrImage = QrImage(qrCode);
    final count = qrImage.moduleCount;
    final cell = size.width / count;
    final paint = Paint()
      ..color = foreground
      ..style = PaintingStyle.fill;

    bool inFinderZone(int r, int c) {
      final topLeft = r < 7 && c < 7;
      final topRight = r < 7 && c >= count - 7;
      final bottomLeft = r >= count - 7 && c < 7;
      return topLeft || topRight || bottomLeft;
    }

    for (var r = 0; r < count; r++) {
      for (var c = 0; c < count; c++) {
        if (!qrImage.isDark(r, c)) continue;
        final rect = Rect.fromLTWH(c * cell, r * cell, cell, cell);
        if (inFinderZone(r, c)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.2)),
            paint,
          );
        } else {
          _drawHeart(canvas, paint, rect);
        }
      }
    }
  }

  void _drawHeart(Canvas canvas, Paint paint, Rect cell) {
    final s = cell.width * 0.92;
    final dx = cell.left + (cell.width - s) / 2;
    final dy = cell.top + (cell.height - s) / 2;
    final path = Path()
      ..moveTo(dx + s * 0.5, dy + s * 0.95)
      ..cubicTo(
        dx - s * 0.4, dy + s * 0.45,
        dx + s * 0.05, dy - s * 0.12,
        dx + s * 0.5, dy + s * 0.3,
      )
      ..cubicTo(
        dx + s * 0.95, dy - s * 0.12,
        dx + s * 1.4, dy + s * 0.45,
        dx + s * 0.5, dy + s * 0.95,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartQrPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.foreground != foreground ||
        oldDelegate.background != background;
  }
}
