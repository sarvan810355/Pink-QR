import 'package:flutter/material.dart';
import '../../widgets/pink_text_field.dart';

class UrlTab extends StatefulWidget {
  final void Function(String data, String title) onChanged;
  const UrlTab({super.key, required this.onChanged});

  @override
  State<UrlTab> createState() => _UrlTabState();
}

class _UrlTabState extends State<UrlTab> {
  final _controller = TextEditingController();

  void _update(String v) {
    var url = v.trim();
    if (url.isNotEmpty && !url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    widget.onChanged(v.trim().isEmpty ? '' : url, url);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PinkTextField(
        label: 'Website link 🔗',
        hint: 'yourwebsite.com',
        controller: _controller,
        icon: Icons.link_rounded,
        keyboardType: TextInputType.url,
        onChanged: _update,
      ),
    );
  }
}
