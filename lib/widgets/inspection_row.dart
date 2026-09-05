import 'package:flutter/material.dart';

import '../models/inspection.dart';
import 'metal_surface.dart';
import 'status_badge.dart';

class InspectionRow extends StatelessWidget {
  const InspectionRow({
    required this.inspection,
    required this.onTap,
    super.key,
  });

  final Inspection inspection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: .58);
    return Semantics(
      button: true,
      label:
          '${inspection.partId}, ${inspection.flaw}, ${inspection.status.name}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              MetalSurface(
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(width: 54, height: 54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspection.partId,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inspection.flaw,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                    Text(
                      '${inspection.time} · ${inspection.line}',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(status: inspection.status, compact: true),
                  const SizedBox(height: 5),
                  Text(
                    inspection.confidence == null
                        ? 'Checked'
                        : '${inspection.confidence}%',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
