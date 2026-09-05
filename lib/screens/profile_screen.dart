import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_tokens.dart';
import '../widgets/setting_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.themeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _threshold = .60;
  bool _autoSave = true;
  bool _scanFeedback = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: .58);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: () => _showInfo(
                  'Inspector profile',
                  'Profile editing will be connected to operator authentication.',
                ),
                tooltip: 'Edit profile',
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 29,
                    backgroundColor: AppTokens.accent,
                    foregroundColor: AppTokens.accentContent,
                    child: Text(
                      'W',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Wishayut',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Inspector profile',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppTokens.pass,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Text(
                              'Two-stage CNN · 4 conditions · Mock-ready',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text(
              'CNN model information',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            subtitle: const Text(
              'Material gate, then condition classification',
              style: TextStyle(fontSize: 11),
            ),
            children: MockData.flawClasses
                .map(
                  (name) => ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.adjust_rounded,
                      size: 16,
                      color: AppTokens.accent,
                    ),
                    title: Text(name, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
          ),
          const _SectionTitle('Inspection settings'),
          SettingRow(
            icon: Icons.speed_rounded,
            label: 'Confidence threshold',
            note: 'Flag uncertain results',
            trailing: Text(
              '${(_threshold * 100).round()}% ›',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onTap: _editThreshold,
          ),
          SettingRow(
            icon: Icons.save_outlined,
            label: 'Auto-save results',
            note: 'Add scans to history',
            trailing: Switch(
              value: _autoSave,
              onChanged: (value) => setState(() => _autoSave = value),
            ),
          ),
          SettingRow(
            icon: Icons.vibration_rounded,
            label: 'Scan feedback',
            note: 'Vibrate after detection',
            trailing: Switch(
              value: _scanFeedback,
              onChanged: (value) => setState(() => _scanFeedback = value),
            ),
          ),
          const _SectionTitle('App & data'),
          SettingRow(
            icon: Icons.brightness_6_outlined,
            label: 'Appearance',
            note: 'Light, dark, or system',
            trailing: Text(
              _themeLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            onTap: _chooseTheme,
          ),
          SettingRow(
            icon: Icons.language_rounded,
            label: 'Language',
            note: 'Interface language',
            trailing: Text(
              '$_language ›',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            onTap: _chooseLanguage,
          ),
          SettingRow(
            icon: Icons.file_download_outlined,
            label: 'Export inspections',
            note: 'CSV or JSON',
            onTap: _chooseExport,
          ),
          SettingRow(
            icon: Icons.shield_outlined,
            label: 'Privacy & storage',
            note: 'Images stay on device',
            onTap: () => _showInfo(
              'Privacy & storage',
              'Prototype data is local and mocked. Production storage controls and retention policy will be connected here.',
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'MetalLens prototype · v0.1',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String get _themeLabel => switch (widget.themeMode) {
        ThemeMode.system => 'System ›',
        ThemeMode.light => 'Light ›',
        ThemeMode.dark => 'Dark ›',
      };

  Future<void> _editThreshold() async {
    var draft = _threshold;
    final result = await showDialog<double>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Confidence threshold'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(draft * 100).round()}%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Slider(
                value: draft,
                min: .30,
                max: .95,
                divisions: 13,
                label: '${(draft * 100).round()}%',
                onChanged: (value) => update(() => draft = value),
              ),
              const Text(
                'Predictions below this threshold are preserved and marked for manual review.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, draft),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result != null) setState(() => _threshold = result);
  }

  Future<void> _chooseTheme() async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values
              .map(
                (mode) => RadioListTile<ThemeMode>(
                  value: mode,
                  groupValue: widget.themeMode,
                  onChanged: (value) => Navigator.pop(context, value),
                  title: Text(switch (mode) {
                    ThemeMode.system => 'Use device setting',
                    ThemeMode.light => 'Light',
                    ThemeMode.dark => 'Dark',
                  }),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null) widget.onThemeModeChanged(selected);
  }

  Future<void> _chooseLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'ไทย']
              .map(
                (language) => RadioListTile<String>(
                  value: language,
                  groupValue: _language,
                  onChanged: (value) => Navigator.pop(context, value),
                  title: Text(language),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null) setState(() => _language = selected);
  }

  Future<void> _chooseExport() async {
    final format = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Export prototype records',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                'File writing connects here after storage permissions are selected.',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text('CSV'),
              onTap: () => Navigator.pop(context, 'CSV'),
            ),
            ListTile(
              leading: const Icon(Icons.data_object_rounded),
              title: const Text('JSON'),
              onTap: () => Navigator.pop(context, 'JSON'),
            ),
          ],
        ),
      ),
    );
    if (format != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$format export integration point ready')),
      );
    }
  }

  void _showInfo(String title, String message) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 22, 4, 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      );
}
