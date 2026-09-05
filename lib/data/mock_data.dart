import '../models/inspection.dart';

/// Prototype-only data. Replace this repository at the backend/CNN boundary.
abstract final class MockData {
  static const flawClasses = <String>[
    'Silk spot',
    'Deburring',
    'Factory new',
    'Rusty old',
  ];

  static const inspections = <Inspection>[
    Inspection(
      partId: 'Sheet A-1042',
      flaw: 'Rusty old',
      time: '14:32',
      line: 'Line 2',
      confidence: 87,
      status: InspectionStatus.defect,
      group: 'Today',
    ),
    Inspection(
      partId: 'Sheet A-1041',
      flaw: 'Factory new',
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
      flaw: 'Deburring',
      time: '17:42',
      line: 'Line 1',
      confidence: 92,
      status: InspectionStatus.defect,
      group: 'Yesterday',
    ),
    Inspection(
      partId: 'Coil B-881',
      flaw: 'Factory new',
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
      'Silk spot': 4,
      'Deburring': 3,
      'Factory new': 9,
      'Rusty old': 7,
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
      'Silk spot': 19,
      'Deburring': 17,
      'Factory new': 41,
      'Rusty old': 26,
    },
  );
}
