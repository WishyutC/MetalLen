enum InspectionStatus { defect, pass, review }

class Inspection {
  const Inspection({
    required this.partId,
    required this.flaw,
    required this.time,
    required this.line,
    required this.confidence,
    required this.status,
    required this.group,
  });

  final String partId;
  final String flaw;
  final String time;
  final String line;
  final int? confidence;
  final InspectionStatus status;
  final String group;
}

class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.total,
    required this.defectRate,
    required this.reviewCount,
    required this.daily,
    required this.distribution,
  });

  final int total;
  final int defectRate;
  final int reviewCount;
  final List<int> daily;
  final Map<String, int> distribution;
}
