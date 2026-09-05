import 'dart:typed_data';

import 'inspection.dart';

class ClassScore {
  const ClassScore({required this.label, required this.probability});

  final String label;
  final double probability;
}

class InferenceResult {
  const InferenceResult({
    required this.scores,
    required this.inferenceTime,
    required this.capturedImage,
    required this.status,
  });

  final List<ClassScore> scores;
  final Duration inferenceTime;
  final Uint8List capturedImage;
  final InspectionStatus status;

  ClassScore get prediction => scores.first;
}
