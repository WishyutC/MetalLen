/// Contracts for the two-stage inspection pipeline.
///
/// Both future models are expected to accept a 64 x 64 RGB NCHW float tensor
/// normalized to [0, 1]. Update these values if the exported models differ.
abstract final class ModelConfig {
  static const conditionAssetPath =
      'cnn_model/condition/condition_classifier.onnx';
  static const materialAssetPath = 'cnn_model/material_gate/metal_or_not.onnx';
  static const inputName = 'input';
  static const outputName = 'logits';
  static const inputWidth = 64;
  static const inputHeight = 64;
  static const channels = 3;
  static const reviewThreshold = .60;
  static const materialThreshold = .60;
  static const conditionLabels = <String>[
    'Silk spot',
    'Deburring',
    'Factory new',
    'Rusty old',
  ];
  static const materialLabels = <String>['Not metal', 'Metal'];

  // Kept as an alias for callers that display the condition classes.
  static const labels = conditionLabels;
}
