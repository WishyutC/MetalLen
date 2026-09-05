import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/analytics_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/scanner_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/dynamic_island_nav.dart';

class MetalLensApp extends StatefulWidget {
  const MetalLensApp({super.key});

  @override
  State<MetalLensApp> createState() => _MetalLensAppState();
}

class _MetalLensAppState extends State<MetalLensApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetalLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: MetalLensShell(
        themeMode: _themeMode,
        onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

class MetalLensShell extends StatefulWidget {
  const MetalLensShell({
    required this.themeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<MetalLensShell> createState() => _MetalLensShellState();
}

class _MetalLensShellState extends State<MetalLensShell> {
  int _index = 0;

  void _selectDestination(int index) {
    setState(() => _index = index);
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        index == 0 ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      ScannerScreen(onOpenSettings: () => _selectDestination(3)),
      const HistoryScreen(),
      const AnalyticsScreen(),
      ProfileScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Center(
          heightFactor: 1,
          child: DynamicIslandNav(
            selectedIndex: _index,
            onDestinationSelected: _selectDestination,
          ),
        ),
      ),
    );
  }
}
