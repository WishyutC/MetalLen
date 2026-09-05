import '../data/mock_data.dart';

/// Tensor and label contract for cnn_model_001_best.onnx.
///
/// The tensor dimensions were verified from the ONNX graph. The model contains
/// no preprocessing or label metadata, so RGB [0, 1] normalization and label
/// order remain explicit assumptions until confirmed against training code.
abstract final class ModelConfig {
  static const assetPath = 'cnn_model/cnn_model_001_best.onnx';
  static const inputName = 'input';
  static const outputName = 'logits';
  static const inputWidth = 64;
  static const inputHeight = 64;
  static const channels = 3;
  static const reviewThreshold = .60;
  static const labels = MockData.flawClasses;
}
