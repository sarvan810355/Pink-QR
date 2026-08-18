import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/qr_history_item.dart';
import '../models/qr_style_config.dart';
import '../services/ads_service.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/pink_button.dart';
import '../widgets/qr_customizer_sheet.dart';
import '../widgets/sparkle_burst.dart';
import '../widgets/styled_qr_view.dart';
import 'detail_screen.dart';
import 'generate_tabs/contact_tab.dart';
import 'generate_tabs/event_tab.dart';
import 'generate_tabs/social_tab.dart';
import 'generate_tabs/text_tab.dart';
import 'generate_tabs/url_tab.dart';
import 'generate_tabs/wifi_tab.dart';

const _tabTypes = [
  QrItemType.url,
  QrItemType.text,
  QrItemType.wifi,
  QrItemType.contact,
  QrItemType.social,
  QrItemType.event,
];

const _tabLabels = ['URL', 'Text', 'WiFi', 'Contact', 'Social', 'Event'];

/// Generate Screen — content tabs + live customizable QR preview.
class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: _tabTypes.length, vsync: this);

  String _data = '';
  String _title = '';
  QrStyleConfig _style = const QrStyleConfig();
  bool _showSparkle = false;

  void _onDataChanged(String data, String title) {
    setState(() {
      _data = data;
      _title = title;
    });
  }

  Future<void> _save() async {
    if (_data.isEmpty) return;
    final item = QrHistoryItem(
      type: _tabTypes[_tabController.index],
      source: QrSourceKind.generated,
      rawData: _data,
      title: _title.isEmpty ? 'Untitled QR' : _title,
      style: _style,
    );
    setState(() => _showSparkle = true);
    await context.read<HistoryService>().add(item);
    AdsService.instance.registerActionAndMaybeShow();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
              child: Text('Create a QR ✨', style: AppTextStyles.heading(theme.textTheme.bodyLarge!.color!)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  onTap: (_) => setState(() {
                    _data = '';
                    _title = '';
                  }),
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    gradient: AppGradients.primaryButton,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: AppTextStyles.button(Colors.white).copyWith(fontSize: 13),
                  unselectedLabelStyle: AppTextStyles.body(AppColors.textMuted).copyWith(fontSize: 13),
                  tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    SparkleTriggerOverlay(
                      show: _showSparkle,
                      onComplete: () => setState(() => _showSparkle = false),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: StyledQrView(
                          key: ValueKey('$_data${_style.hashCode}'),
                          data: _data,
                          style: _style,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 340,
                      child: IndexedStack(
                        index: _tabController.index,
                        children: [
                          UrlTab(onChanged: _onDataChanged),
                          TextTab(onChanged: _onDataChanged),
                          WifiTab(onChanged: _onDataChanged),
                          ContactTab(onChanged: _onDataChanged),
                          SocialTab(onChanged: _onDataChanged),
                          EventTab(onChanged: _onDataChanged),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: PinkButton(
                            label: 'Customize',
                            icon: Icons.palette_outlined,
                            gradient: AppGradients.roseGoldShine,
                            onPressed: () => QrCustomizerSheet.show(
                              context,
                              initial: _style,
                              onChanged: (s) => setState(() => _style = s),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: PinkButton(
                            label: 'Save',
                            icon: Icons.check_circle_outline_rounded,
                            onPressed: _data.isEmpty
                                ? () {}
                                : () async {
                                    final navigator = Navigator.of(context);
                                    final history = context.read<HistoryService>();
                                    await _save();
                                    if (!mounted) return;
                                    navigator.push(
                                      MaterialPageRoute(builder: (_) => DetailScreen(item: history.items.first)),
                                    );
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
