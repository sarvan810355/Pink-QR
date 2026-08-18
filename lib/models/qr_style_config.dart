import 'package:flutter/material.dart';

enum QrModuleStyle { square, rounded, dots }

enum QrFrameStyle { none, floral, polkaDot, heart, ribbon }

enum QrSticker { none, heart, star, birthday, love, study, party, sparkle }

/// Everything needed to render a customized, on-brand QR code.
class QrStyleConfig {
  final QrModuleStyle moduleStyle;
  final QrFrameStyle frameStyle;
  final QrSticker sticker;
  final Color foregroundColor;
  final Color backgroundColor;

  const QrStyleConfig({
    this.moduleStyle = QrModuleStyle.rounded,
    this.frameStyle = QrFrameStyle.none,
    this.sticker = QrSticker.none,
    this.foregroundColor = const Color(0xFFFF6B81),
    this.backgroundColor = const Color(0xFFFFFBFD),
  });

  QrStyleConfig copyWith({
    QrModuleStyle? moduleStyle,
    QrFrameStyle? frameStyle,
    QrSticker? sticker,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    return QrStyleConfig(
      moduleStyle: moduleStyle ?? this.moduleStyle,
      frameStyle: frameStyle ?? this.frameStyle,
      sticker: sticker ?? this.sticker,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'moduleStyle': moduleStyle.index,
        'frameStyle': frameStyle.index,
        'sticker': sticker.index,
        'foregroundColor': foregroundColor.toARGB32(),
        'backgroundColor': backgroundColor.toARGB32(),
      };

  factory QrStyleConfig.fromJson(Map<String, dynamic> json) => QrStyleConfig(
        moduleStyle: QrModuleStyle.values[json['moduleStyle'] ?? 1],
        frameStyle: QrFrameStyle.values[json['frameStyle'] ?? 0],
        sticker: QrSticker.values[json['sticker'] ?? 0],
        foregroundColor: Color(json['foregroundColor'] ?? 0xFFFF6B81),
        backgroundColor: Color(json['backgroundColor'] ?? 0xFFFFFBFD),
      );

  static String stickerEmoji(QrSticker s) {
    switch (s) {
      case QrSticker.none:
        return '';
      case QrSticker.heart:
        return '💗';
      case QrSticker.star:
        return '⭐';
      case QrSticker.birthday:
        return '🎂';
      case QrSticker.love:
        return '💌';
      case QrSticker.study:
        return '📚';
      case QrSticker.party:
        return '🎉';
      case QrSticker.sparkle:
        return '✨';
    }
  }

  static String frameLabel(QrFrameStyle f) {
    switch (f) {
      case QrFrameStyle.none:
        return 'No frame';
      case QrFrameStyle.floral:
        return 'Floral';
      case QrFrameStyle.polkaDot:
        return 'Polka Dot';
      case QrFrameStyle.heart:
        return 'Heart';
      case QrFrameStyle.ribbon:
        return 'Ribbon';
    }
  }
}
