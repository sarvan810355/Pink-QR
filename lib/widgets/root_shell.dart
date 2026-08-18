import 'package:flutter/material.dart';
import '../screens/generate_screen.dart';
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/settings_screen.dart';
import 'floating_nav_bar.dart';

/// App shell holding the 5 primary tabs behind the floating pink nav bar.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  final Set<int> _visited = {0};

  void goTo(int index) => setState(() {
        _index = index;
        _visited.add(index);
      });

  @override
  Widget build(BuildContext context) {
    // Tabs are built lazily and kept alive once visited via IndexedStack,
    // so the Scan tab's camera and scan-line animation only start once the
    // user actually opens it — not the moment the app launches.
    final builders = <Widget Function()>[
      () => HomeScreen(onNavigate: goTo),
      () => const ScanScreen(),
      () => const GenerateScreen(),
      () => const HistoryScreen(),
      () => const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: List.generate(
          builders.length,
          (i) => _visited.contains(i) ? builders[i]() : const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: FloatingNavBar(currentIndex: _index, onTap: goTo),
    );
  }
}
