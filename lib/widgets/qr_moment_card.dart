import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/qr_history_item.dart';
import '../theme/app_theme.dart';
import 'styled_qr_view.dart';

/// The pretty "QR Card" used for Instagram Story-style sharing — a
/// pastel branded card with the QR, a cute title, and a themed
/// gradient/emoji chosen from the content type.
class QrMomentCard extends StatelessWidget {
  final QrHistoryItem item;
  final GlobalKey repaintKey;

  const QrMomentCard({super.key, required this.item, required this.repaintKey});

  Gradient get _gradient {
    switch (item.type) {
      case QrItemType.wifi:
        return const LinearGradient(
          colors: [AppColors.skyBlush, AppColors.softPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case QrItemType.contact:
        return const LinearGradient(
          colors: [AppColors.lavenderMist, AppColors.roseGoldLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case QrItemType.social:
        return const LinearGradient(
          colors: [Color(0xFFFFD6E8), Color(0xFFFFB6C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case QrItemType.event:
        return const LinearGradient(
          colors: [AppColors.butterYellow, AppColors.softPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppGradients.dayBackground;
    }
  }

  String get _kicker {
    switch (item.type) {
      case QrItemType.wifi:
        return 'CONNECT TO WIFI';
      case QrItemType.contact:
        return 'SAVE MY CONTACT';
      case QrItemType.social:
        return 'FOLLOW ME';
      case QrItemType.event:
        return "YOU'RE INVITED";
      case QrItemType.url:
        return 'VISIT MY LINK';
      default:
        return 'QR BLOOM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: _gradient,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _kicker,
              style: GoogleFonts.comfortaa(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark.withValues(alpha: 0.6),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              padding: const EdgeInsets.all(12),
              child: StyledQrView(data: item.rawData, style: item.style, size: 190),
            ),
            const SizedBox(height: 20),
            Text('made with QR Bloom 🌸', style: AppTextStyles.caption(AppColors.textDark.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}
