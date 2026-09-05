import '../models/inspection.dart';

/// Prototype-only data. Replace this repository at the backend/CNN boundary.
abstract final class MockData {
  static const flawClasses = <String>[
    'Rolled pit',
    'Inclusion',
    'Silk spot',
    'Deburring',
    'Waist folding',
  ];

  static const inspections = <Inspection>[
    Inspection(
      partId: 'Sheet A-1042',
      flaw: 'Rolled pit',
      time: '14:32',
      line: 'Line 2',
      confidence: 87,
      status: InspectionStatus.defect,
      group: 'Today',
    ),
    Inspection(
      partId: 'Sheet A-1041',
      flaw: 'No actionable flaw',
      time: '14:26',
      line: 'Line 2',
      confidence: null,
      status: InspectionStatus.pass,
      group: 'Today',
    ),
    Inspection(
      partId: 'Sheet A-1040',
      flaw: 'Silk spot',
      time: '14:18',
      line: 'Line 2',
      confidence: 54,
      status: InspectionStatus.review,
      group: 'Today',
    ),
    Inspection(
      partId: 'Coil B-882',
      flaw: 'Inclusion',
      time: '17:42',
      line: 'Line 1',
      confidence: 92,
      status: InspectionStatus.defect,
      group: 'Yesterday',
    ),
    Inspection(
      partId: 'Coil B-881',
      flaw: 'Waist folding',
      time: '17:31',
      line: 'Line 1',
      confidence: null,
      status: InspectionStatus.pass,
      group: 'Yesterday',
    ),
  ];

  static const analytics7 = AnalyticsSnapshot(
    total: 124,
    defectRate: 18,
    reviewCount: 7,
    daily: [12, 19, 14, 23, 18, 21, 17],
    distribution: {
      'Rolled pit': 8,
      'Inclusion': 6,
      'Silk spot': 4,
      'Deburring': 3,
      'Waist folding': 2,
    },
  );

  static const analytics30 = AnalyticsSnapshot(
    total: 516,
    defectRate: 21,
    reviewCount: 29,
    daily: [
      12,
      17,
      15,
      22,
      18,
      26,
      20,
      16,
      13,
      19,
      24,
      18,
      21,
      17,
      14,
      23,
      25,
      19,
      16,
      20,
      18,
      27,
      23,
      17,
      21,
      24,
      20,
      26,
      19,
      22,
    ],
    distribution: {
      'Rolled pit': 32,
      'Inclusion': 27,
      'Silk spot': 19,
      'Deburring': 17,
      'Waist folding': 13,
    },
  );
}
