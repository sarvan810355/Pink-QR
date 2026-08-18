import 'package:flutter/material.dart';
import '../../services/qr_content_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pink_button.dart';
import '../../widgets/pink_text_field.dart';

class WifiTab extends StatefulWidget {
  final void Function(String data, String title) onChanged;
  const WifiTab({super.key, required this.onChanged});

  @override
  State<WifiTab> createState() => _WifiTabState();
}

class _WifiTabState extends State<WifiTab> {
  final _ssid = TextEditingController();
  final _password = TextEditingController();
  String _security = 'WPA';
  bool _hidden = false;

  void _update() {
    if (_ssid.text.trim().isEmpty) {
      widget.onChanged('', '');
      return;
    }
    final data = QrContentService.buildWifi(
      ssid: _ssid.text.trim(),
      password: _password.text,
      security: _security,
      hidden: _hidden,
    );
    widget.onChanged(data, 'Wi-Fi: ${_ssid.text.trim()}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PinkTextField(
            label: 'Network name (SSID) 📶',
            hint: 'Study Group WiFi',
            controller: _ssid,
            icon: Icons.wifi_rounded,
            onChanged: (_) => _update(),
          ),
          if (_security != 'None')
            PinkTextField(
              label: 'Password',
              hint: '••••••••',
              controller: _password,
              icon: Icons.lock_outline_rounded,
              onChanged: (_) => _update(),
            ),
          Text('Security', style: AppTextStyles.title(Theme.of(context).textTheme.bodyLarge!.color!)),
          const SizedBox(height: 6),
          Wrap(
            spacing: AppSpacing.sm,
            children: ['WPA', 'WEP', 'None'].map((s) {
              return PinkChip(
                label: s,
                selected: _security == s,
                onTap: () => setState(() {
                  _security = s;
                  _update();
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile.adaptive(
            value: _hidden,
            onChanged: (v) => setState(() {
              _hidden = v;
              _update();
            }),
            activeThumbColor: AppColors.hotPink,
            contentPadding: EdgeInsets.zero,
            title: Text('Hidden network', style: AppTextStyles.body(AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}
