import 'package:flutter/material.dart';
import '../../services/qr_content_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pink_button.dart';
import '../../widgets/pink_text_field.dart';

/// Event invite / birthday QR builder.
class EventTab extends StatefulWidget {
  final void Function(String data, String title) onChanged;
  const EventTab({super.key, required this.onChanged});

  @override
  State<EventTab> createState() => _EventTabState();
}

class _EventTabState extends State<EventTab> {
  final _title = TextEditingController();
  final _location = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);

  void _update() {
    if (_title.text.trim().isEmpty) {
      widget.onChanged('', '');
      return;
    }
    final start = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final data = QrContentService.buildEvent(
      title: _title.text.trim(),
      start: start,
      location: _location.text.trim(),
    );
    widget.onChanged(data, _title.text.trim());
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _update();
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() {
        _time = picked;
        _update();
      });
    }
  }

  void _applyBirthdayPreset() {
    _title.text = 'Birthday Party 🎂';
    _location.text = 'My place';
    setState(() => _update());
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = '${_date.day}/${_date.month}/${_date.year}';
    final timeLabel = _time.format(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: PinkChip(label: '🎂 Use birthday preset', selected: false, onTap: _applyBirthdayPreset),
          ),
          const SizedBox(height: AppSpacing.md),
          PinkTextField(
            label: 'Event title 🎉',
            hint: 'Study Group Meetup',
            controller: _title,
            icon: Icons.celebration_outlined,
            onChanged: (_) => _update(),
          ),
          PinkTextField(
            label: 'Location (optional)',
            hint: 'Coffee Shop, Main St',
            controller: _location,
            icon: Icons.place_outlined,
            onChanged: (_) => _update(),
          ),
          Row(
            children: [
              Expanded(
                child: _PickerField(label: 'Date', value: dateLabel, icon: Icons.calendar_today_rounded, onTap: _pickDate),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _PickerField(label: 'Time', value: timeLabel, icon: Icons.access_time_rounded, onTap: _pickTime),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({required this.label, required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.title(theme.textTheme.bodyLarge!.color!)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? AppColors.charcoalCard
                  : AppColors.softPink.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.roseGold, size: 18),
                const SizedBox(width: 8),
                Text(value, style: AppTextStyles.body(theme.textTheme.bodyMedium!.color!)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
