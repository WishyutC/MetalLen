import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class DynamicIslandNav extends StatelessWidget {
  const DynamicIslandNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _destinations = <({String label, IconData icon})>[
    (label: 'Scanner', icon: Icons.center_focus_strong_rounded),
    (label: 'History', icon: Icons.history_rounded),
    (label: 'Analytics', icon: Icons.bar_chart_rounded),
    (label: 'Profile', icon: Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 340;
    return Semantics(
      label: 'Primary navigation',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 370),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTokens.island,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: .1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_destinations.length, (index) {
            final item = _destinations[index];
            final active = index == selectedIndex;
            return Semantics(
              selected: active,
              button: true,
              label: item.label,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                decoration: BoxDecoration(
                  color: active ? AppTokens.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: InkWell(
                  key: ValueKey('nav-${item.label.toLowerCase()}'),
                  onTap: () => onDestinationSelected(index),
                  customBorder: const StadiumBorder(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          active ? (compact ? 4 : 13) : (compact ? 4 : 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: active
                              ? AppTokens.accentContent
                              : const Color(0xFF9DA8AE),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          child: active
                              ? Padding(
                                  padding:
                                      EdgeInsets.only(left: compact ? 4 : 7),
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      color: AppTokens.accentContent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: compact ? 11 : 13,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
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
