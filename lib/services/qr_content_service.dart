import '../models/qr_history_item.dart';

/// Builds spec-correct payload strings for each QR content type, and
/// performs smart content-type detection on scanned data.
class QrContentService {
  QrContentService._();

  /// WIFI:T:<type>;S:<ssid>;P:<password>;H:<hidden>;;
  static String buildWifi({
    required String ssid,
    required String password,
    String security = 'WPA',
    bool hidden = false,
  }) {
    String esc(String v) => v
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll(':', '\\:')
        .replaceAll('"', '\\"');
    final sec = security == 'None' ? 'nopass' : security;
    return 'WIFI:T:$sec;S:${esc(ssid)};P:${sec == 'nopass' ? '' : esc(password)};H:${hidden ? 'true' : 'false'};;';
  }

  /// vCard 3.0 contact card.
  static String buildContact({
    required String name,
    String phone = '',
    String email = '',
    String org = '',
    String note = '',
  }) {
    final buf = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:3.0')
      ..writeln('N:$name')
      ..writeln('FN:$name');
    if (org.isNotEmpty) buf.writeln('ORG:$org');
    if (phone.isNotEmpty) buf.writeln('TEL;TYPE=CELL:$phone');
    if (email.isNotEmpty) buf.writeln('EMAIL:$email');
    if (note.isNotEmpty) buf.writeln('NOTE:$note');
    buf.writeln('END:VCARD');
    return buf.toString();
  }

  /// Simple Instagram / social handle deep link.
  static String buildSocial({
    required String platform,
    required String handle,
  }) {
    final clean = handle.replaceAll('@', '').trim();
    switch (platform) {
      case 'Instagram':
        return 'https://instagram.com/$clean';
      case 'WhatsApp':
        return 'https://wa.me/$clean';
      case 'Snapchat':
        return 'https://snapchat.com/add/$clean';
      case 'TikTok':
        return 'https://tiktok.com/@$clean';
      default:
        return clean;
    }
  }

  /// iCalendar VEVENT for birthday / event invite cards.
  static String buildEvent({
    required String title,
    required DateTime start,
    DateTime? end,
    String location = '',
    String description = '',
  }) {
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}00';
    final e = end ?? start.add(const Duration(hours: 2));
    final buf = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('BEGIN:VEVENT')
      ..writeln('SUMMARY:$title')
      ..writeln('DTSTART:${fmt(start)}')
      ..writeln('DTEND:${fmt(e)}');
    if (location.isNotEmpty) buf.writeln('LOCATION:$location');
    if (description.isNotEmpty) buf.writeln('DESCRIPTION:$description');
    buf
      ..writeln('END:VEVENT')
      ..writeln('END:VCALENDAR');
    return buf.toString();
  }

  /// Smart classification of scanned raw payloads.
  static QrItemType detectType(String data) {
    final trimmed = data.trim();
    if (trimmed.startsWith('WIFI:')) return QrItemType.wifi;
    if (trimmed.startsWith('BEGIN:VCARD')) return QrItemType.contact;
    if (trimmed.startsWith('BEGIN:VCALENDAR')) return QrItemType.event;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return QrItemType.url;
    }
    return QrItemType.text;
  }

  /// Parses WIFI: payload into ssid/password/security map.
  static Map<String, String> parseWifi(String data) {
    final result = <String, String>{'S': '', 'P': '', 'T': 'WPA'};
    final body = data.replaceFirst('WIFI:', '');
    final parts = <String>[];
    final buf = StringBuffer();
    for (int i = 0; i < body.length; i++) {
      final c = body[i];
      if (c == '\\' && i + 1 < body.length) {
        buf.write(body[i + 1]);
        i++;
      } else if (c == ';') {
        parts.add(buf.toString());
        buf.clear();
      } else {
        buf.write(c);
      }
    }
    for (final p in parts) {
      final idx = p.indexOf(':');
      if (idx == -1) continue;
      final key = p.substring(0, idx);
      final val = p.substring(idx + 1);
      if (key == 'S' || key == 'P' || key == 'T' || key == 'H') {
        result[key] = val;
      }
    }
    return result;
  }

  /// Extracts a friendly name from vCard FN/N field.
  static String parseContactName(String data) {
    final lines = data.split('\n');
    for (final line in lines) {
      if (line.startsWith('FN:')) return line.substring(3).trim();
    }
    for (final line in lines) {
      if (line.startsWith('N:')) return line.substring(2).trim();
    }
    return 'Contact';
  }
}
