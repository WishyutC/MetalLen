import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/inspection.dart';
import '../theme/app_tokens.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _days = 7;
  AnalyticsSnapshot get data =>
      _days == 7 ? MockData.analytics7 : MockData.analytics30;

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
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTokens.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppTokens.accentContent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Inspection overview · prototype data',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _days,
                    borderRadius: BorderRadius.circular(12),
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('7 days')),
                      DropdownMenuItem(value: 30, child: Text('30 days')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _days = value);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 350;
              final cards = [
                _Metric(
                  label: 'Inspections',
                  value: '${data.total}',
                  note: _days == 7 ? '+12%' : 'Last 30 days',
                ),
                _Metric(
                  label: 'Defect rate',
                  value: '${data.defectRate}%',
                  note: '${(data.total * data.defectRate / 100).round()} found',
                  valueColor: AppTokens.defect,
                ),
                _Metric(
                  label: 'Review',
                  value: '${data.reviewCount}',
                  note: 'Needs check',
                  valueColor: AppTokens.review,
                ),
              ];
              return narrow
                  ? Column(
                      children: cards
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: e,
                            ),
                          )
                          .toList(),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cards
                          .map(
                            (e) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: e,
                              ),
                            ),
                          )
                          .toList(),
                    );
            },
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Daily inspections',
            note: '${data.total} total',
            child: SizedBox(
              width: double.infinity,
              height: 155,
              child: CustomPaint(
                key: const ValueKey('activity-chart'),
                painter: _ActivityChartPainter(
                  data.daily,
                  Theme.of(context).brightness,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Surface conditions',
            note: '${MockData.flawClasses.length} classes',
            child: Column(
              children: data.distribution.entries.map((entry) {
                final maxValue = data.distribution.values.reduce(math.max);
                return Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 92,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: entry.value / maxValue,
                            minHeight: 8,
                            backgroundColor: muted.withValues(alpha: .12),
                            color: AppTokens.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 20,
                        child: Text(
                          '${entry.value}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Prototype values only · Connect to the inspection repository when the backend is ready.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.note,
    this.valueColor,
  });
  final String label;
  final String value;
  final String note;
  final Color? valueColor;
  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: .58),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 23,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(note, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.note,
    required this.child,
  });
  final String title;
  final String note;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    note,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      );
}

class _ActivityChartPainter extends CustomPainter {
  _ActivityChartPainter(this.values, this.brightness);
  final List<int> values;
  final Brightness brightness;
  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = values.reduce(math.max).toDouble();
    final gap = values.length > 10 ? 2.0 : 8.0;
    final width = (size.width - gap * (values.length - 1)) / values.length;
    final baseline = size.height - 18;
    final labelPaint = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < values.length; i++) {
      final height = (baseline - 8) * values[i] / maxValue;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * (width + gap), baseline - height, width, height),
        const Radius.circular(5),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = AppTokens.accent.withValues(
            alpha: .45 + .5 * values[i] / maxValue,
          ),
      );
      if (values.length <= 7) {
        labelPaint.text = TextSpan(
          text: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
          style: TextStyle(
            fontSize: 10,
            color: brightness == Brightness.dark
                ? AppTokens.darkMuted
                : AppTokens.lightMuted,
          ),
        );
        labelPaint.layout();
        labelPaint.paint(
          canvas,
          Offset(
            i * (width + gap) + (width - labelPaint.width) / 2,
            baseline + 5,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.brightness != brightness;
}
