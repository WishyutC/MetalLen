import 'dart:typed_data';

import 'inspection.dart';

class ClassScore {
  const ClassScore({required this.label, required this.probability});

  final String label;
  final double probability;
}

enum ScanImageSource { camera, gallery }

class MaterialDecision {
  const MaterialDecision({
    required this.isMetal,
    required this.confidence,
    required this.inferenceTime,
    required this.usesMock,
  });

  final bool isMetal;
  final double confidence;
  final Duration inferenceTime;
  final bool usesMock;
}

class InferenceResult {
  const InferenceResult({
    required this.scores,
    required this.inferenceTime,
    required this.capturedImage,
    required this.status,
    required this.source,
    required this.material,
    required this.conditionUsesMock,
  });

  final List<ClassScore> scores;
  final Duration inferenceTime;
  final Uint8List capturedImage;
  final InspectionStatus status;
  final ScanImageSource source;
  final MaterialDecision material;
  final bool conditionUsesMock;

  ClassScore? get prediction => scores.isEmpty ? null : scores.first;
  bool get isMetal => material.isMetal;
  bool get usesAnyMock => material.usesMock || conditionUsesMock;
}
