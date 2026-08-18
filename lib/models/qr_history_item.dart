import 'package:uuid/uuid.dart';
import 'qr_style_config.dart';

enum QrItemType { url, text, wifi, contact, social, event, scanned }

enum QrSourceKind { generated, scanned }

class QrHistoryItem {
  final String id;
  final QrItemType type;
  final QrSourceKind source;
  final String rawData;
  final String title;
  final DateTime createdAt;
  final bool isFavorite;
  final QrStyleConfig style;

  QrHistoryItem({
    String? id,
    required this.type,
    required this.source,
    required this.rawData,
    required this.title,
    DateTime? createdAt,
    this.isFavorite = false,
    QrStyleConfig? style,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        style = style ?? const QrStyleConfig();

  QrHistoryItem copyWith({
    bool? isFavorite,
    String? title,
    QrStyleConfig? style,
  }) {
    return QrHistoryItem(
      id: id,
      type: type,
      source: source,
      rawData: rawData,
      title: title ?? this.title,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      style: style ?? this.style,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'source': source.index,
        'rawData': rawData,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'isFavorite': isFavorite,
        'style': style.toJson(),
      };

  factory QrHistoryItem.fromJson(Map<String, dynamic> json) => QrHistoryItem(
        id: json['id'],
        type: QrItemType.values[json['type'] ?? 0],
        source: QrSourceKind.values[json['source'] ?? 0],
        rawData: json['rawData'] ?? '',
        title: json['title'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        isFavorite: json['isFavorite'] ?? false,
        style: json['style'] != null
            ? QrStyleConfig.fromJson(Map<String, dynamic>.from(json['style']))
            : const QrStyleConfig(),
      );

  static String typeEmoji(QrItemType t) {
    switch (t) {
      case QrItemType.url:
        return '🔗';
      case QrItemType.text:
        return '📝';
      case QrItemType.wifi:
        return '📶';
      case QrItemType.contact:
        return '📇';
      case QrItemType.social:
        return '💌';
      case QrItemType.event:
        return '🎉';
      case QrItemType.scanned:
        return '📷';
    }
  }
}
