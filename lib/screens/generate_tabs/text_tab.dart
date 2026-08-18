import 'package:flutter/material.dart';
import '../../widgets/pink_text_field.dart';

class TextTab extends StatefulWidget {
  final void Function(String data, String title) onChanged;
  const TextTab({super.key, required this.onChanged});

  @override
  State<TextTab> createState() => _TextTabState();
}

class _TextTabState extends State<TextTab> {
  final _controller = TextEditingController();

  void _update(String v) {
    final title = v.trim().isEmpty
        ? ''
        : (v.length > 30 ? '${v.substring(0, 30)}…' : v);
    widget.onChanged(v, title);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PinkTextField(
        label: 'Plain text 📝',
        hint: 'Write anything — a note, a quote, a secret…',
        controller: _controller,
        icon: Icons.notes_rounded,
        maxLines: 4,
        onChanged: _update,
      ),
    );
  }
}
