import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/qr_history_item.dart';
import '../services/qr_content_service.dart';
import '../theme/app_theme.dart';
import 'pink_button.dart';

/// Bottom sheet shown after a successful scan — content-aware actions
/// based on smart detection (open URL, copy, call, connect WiFi, save
/// contact, add event).
class ScanResultSheet extends StatelessWidget {
  final QrHistoryItem item;

  const ScanResultSheet({super.key, required this.item});

  static Future<void> show(BuildContext context, QrHistoryItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanResultSheet(item: item),
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: item.rawData));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Copied ✨')));
    }
  }

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.tryParse(item.rawData);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _saveContact(BuildContext context) async {
    if (await FlutterContacts.requestPermission()) {
      final name = QrContentService.parseContactName(item.rawData);
      final lines = item.rawData.split('\n');
      String phone = '';
      String email = '';
      for (final l in lines) {
        if (l.startsWith('TEL')) phone = l.split(':').last.trim();
        if (l.startsWith('EMAIL')) email = l.split(':').last.trim();
      }
      final contact = Contact()
        ..name.first = name
        ..phones = phone.isNotEmpty ? [Phone(phone)] : []
        ..emails = email.isNotEmpty ? [Email(email)] : [];
      await contact.insert();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Contact saved 💌')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wifi = item.type == QrItemType.wifi
        ? QrContentService.parseWifi(item.rawData)
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
            children: [
              Text(QrHistoryItem.typeEmoji(item.type), style: const TextStyle(fontSize: 26)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Scan complete!',
                    style: AppTextStyles.heading(theme.textTheme.bodyLarge!.color!)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.softPink.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Text(
              wifi != null ? 'Wi-Fi: ${wifi['S']}' : item.rawData,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(theme.textTheme.bodyMedium!.color!),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (item.type == QrItemType.url)
                PinkButton(
                  label: 'Open link',
                  icon: Icons.open_in_new_rounded,
                  expand: false,
                  onPressed: () => _openUrl(context),
                ),
              if (item.type == QrItemType.contact)
                PinkButton(
                  label: 'Save contact',
                  icon: Icons.person_add_alt_1_rounded,
                  expand: false,
                  gradient: AppGradients.roseGoldShine,
                  onPressed: () => _saveContact(context),
                ),
              PinkButton(
                label: 'Copy',
                icon: Icons.copy_rounded,
                expand: false,
                gradient: AppGradients.roseGoldShine,
                onPressed: () => _copy(context),
              ),
              PinkButton(
                label: 'Close',
                icon: Icons.close_rounded,
                expand: false,
                gradient: const LinearGradient(
                    colors: [AppColors.lavenderMist, AppColors.roseGoldLight]),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
