/// Contracts for the two-stage inspection pipeline.
///
/// Both deployed models accept a 64 x 64 RGB NCHW float tensor normalized to
/// [0, 1]. The material gate emits one binary logit; the condition model emits
/// three logits in the approved class order below.
abstract final class ModelConfig {
  static const conditionAssetPath = 'cnn_model/condition/cnn_model_003.onnx';
  static const materialAssetPath =
      'cnn_model/material_gate/ismetal_model_003.onnx';
  static const conditionModelVersion = '003';
  static const materialModelVersion = '003';
  static const inputName = 'input';
  static const outputName = 'logits';
  static const inputWidth = 64;
  static const inputHeight = 64;
  static const channels = 3;
  static const reviewThreshold = .60;
  static const materialThreshold = .60;
  static const conditionLabels = <String>[
    'Inclusion',
    'Silk spot',
    'Scratch',
  ];
  static const materialLabels = <String>['Not metal', 'Metal'];

  // Kept as an alias for callers that display the condition classes.
  static const labels = conditionLabels;
}
