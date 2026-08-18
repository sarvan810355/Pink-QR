import 'package:flutter/material.dart';
import '../../services/qr_content_service.dart';
import '../../widgets/pink_text_field.dart';

class ContactTab extends StatefulWidget {
  final void Function(String data, String title) onChanged;
  const ContactTab({super.key, required this.onChanged});

  @override
  State<ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<ContactTab> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _org = TextEditingController();

  void _update() {
    if (_name.text.trim().isEmpty) {
      widget.onChanged('', '');
      return;
    }
    final data = QrContentService.buildContact(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      org: _org.text.trim(),
    );
    widget.onChanged(data, _name.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PinkTextField(
            label: 'Full name 📇',
            hint: 'Jane Doe',
            controller: _name,
            icon: Icons.person_outline_rounded,
            onChanged: (_) => _update(),
          ),
          PinkTextField(
            label: 'Phone',
            hint: '+1 555 123 4567',
            controller: _phone,
            icon: Icons.call_outlined,
            keyboardType: TextInputType.phone,
            onChanged: (_) => _update(),
          ),
          PinkTextField(
            label: 'Email',
            hint: 'jane@email.com',
            controller: _email,
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _update(),
          ),
          PinkTextField(
            label: 'Organization (optional)',
            hint: 'QR Bloom Inc.',
            controller: _org,
            icon: Icons.business_outlined,
            onChanged: (_) => _update(),
          ),
        ],
      ),
    );
  }
}
