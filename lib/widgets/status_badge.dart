import 'package:flutter/material.dart';

import '../models/inspection.dart';
import '../theme/app_tokens.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, this.compact = false, super.key});

  final InspectionStatus status;
  final bool compact;

  Color get color => switch (status) {
        InspectionStatus.defect => AppTokens.defect,
        InspectionStatus.pass => AppTokens.pass,
        InspectionStatus.review => AppTokens.review,
      };

  String get label => switch (status) {
        InspectionStatus.defect => 'Defect',
        InspectionStatus.pass => 'Pass',
        InspectionStatus.review => 'Review',
      };

  IconData get icon => switch (status) {
        InspectionStatus.defect => Icons.error_outline_rounded,
        InspectionStatus.pass => Icons.check_circle_outline_rounded,
        InspectionStatus.review => Icons.help_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 13 : 15, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
