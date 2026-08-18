import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/feedback_service.dart';

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItemData(this.icon, this.activeIcon, this.label);
}

/// Custom floating rounded bottom navigation bar — replaces the default
/// Material BottomNavigationBar with a cute pill-shaped pink dock.
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    NavItemData(Icons.home_outlined, Icons.home_rounded, 'Home'),
    NavItemData(Icons.qr_code_scanner_outlined, Icons.qr_code_scanner_rounded, 'Scan'),
    NavItemData(Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'Create'),
    NavItemData(Icons.history_rounded, Icons.history_rounded, 'History'),
    NavItemData(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalCard : AppColors.blushWhite,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.primaryPink)
                  .withValues(alpha: isDark ? 0.4 : 0.22),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_items.length, (i) {
            final selected = i == currentIndex;
            final item = _items[i];
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FeedbackService.instance.tap();
                  onTap(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: selected ? AppGradients.primaryButton : null,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? item.activeIcon : item.icon,
                        color: selected
                            ? Colors.white
                            : (isDark ? AppColors.nightTextMuted : AppColors.textMuted),
                        size: 22,
                      ).animate(target: selected ? 1 : 0).scaleXY(
                            begin: 1,
                            end: 1.15,
                            duration: 180.ms,
                            curve: Curves.easeOut,
                          ),
                      if (selected)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.label,
                            style: AppTextStyles.caption(Colors.white).copyWith(fontSize: 10),
                          ),
                        ).animate().fadeIn(duration: 180.ms),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
