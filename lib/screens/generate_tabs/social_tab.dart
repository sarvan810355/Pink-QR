import 'package:flutter/material.dart';
import '../../services/qr_content_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pink_button.dart';
import '../../widgets/pink_text_field.dart';

const _platforms = ['Instagram', 'WhatsApp', 'Snapchat', 'TikTok'];
const _platformEmoji = {
  'Instagram': '📸',
  'WhatsApp': '💬',
  'Snapchat': '👻',
  'TikTok': '🎵',
};

/// Instagram handle / WhatsApp contact style "QR Card" builder.
class SocialTab extends StatefulWidget {
  final void Function(String data, String title) onChanged;
  const SocialTab({super.key, required this.onChanged});

  @override
  State<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends State<SocialTab> {
  String _platform = 'Instagram';
  final _handle = TextEditingController();

  void _update() {
    if (_handle.text.trim().isEmpty) {
      widget.onChanged('', '');
      return;
    }
    final data = QrContentService.buildSocial(platform: _platform, handle: _handle.text);
    widget.onChanged(data, '$_platform @${_handle.text.replaceAll('@', '')}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose platform 💌', style: AppTextStyles.title(Theme.of(context).textTheme.bodyLarge!.color!)),
          const SizedBox(height: 8),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _platforms.map((p) {
              return PinkChip(
                label: '${_platformEmoji[p]} $p',
                selected: _platform == p,
                onTap: () => setState(() {
                  _platform = p;
                  _update();
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          PinkTextField(
            label: _platform == 'WhatsApp' ? 'Phone number' : 'Handle / username',
            hint: _platform == 'WhatsApp' ? '15551234567' : 'yourusername',
            controller: _handle,
            icon: Icons.alternate_email_rounded,
            onChanged: (_) => _update(),
          ),
        ],
      ),
    );
  }
}
