import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as image_lib;

import '../models/inference_result.dart';
import '../models/inspection.dart';
import 'model_config.dart';

class MetalClassifier {
  MetalClassifier({OnnxRuntime? runtime}) : _runtime = runtime ?? OnnxRuntime();

  final OnnxRuntime _runtime;
  OrtSession? _session;

  bool get isReady => _session != null;

  Future<void> initialize() async {
    if (_session != null) return;
    final session = await _runtime.createSessionFromAsset(
      ModelConfig.assetPath,
      options: OrtSessionOptions(intraOpNumThreads: 2, interOpNumThreads: 1),
    );
    if (!session.inputNames.contains(ModelConfig.inputName) ||
        !session.outputNames.contains(ModelConfig.outputName)) {
      await session.close();
      throw StateError(
        'Unexpected model contract. Expected input "${ModelConfig.inputName}" '
        'and output "${ModelConfig.outputName}".',
      );
    }
    _session = session;
  }

  Future<InferenceResult> analyze(Uint8List encodedImage) async {
    await initialize();
    final pixels = await compute(_preprocessImage, encodedImage);
    final input = await OrtValue.fromList(pixels, const [
      1,
      ModelConfig.channels,
      ModelConfig.inputHeight,
      ModelConfig.inputWidth,
    ]);
    final stopwatch = Stopwatch()..start();
    Map<String, OrtValue> outputs = const {};
    try {
      outputs = await _session!.run({ModelConfig.inputName: input});
      stopwatch.stop();
      final logits = (await outputs[ModelConfig.outputName]!.asFlattenedList())
          .cast<num>()
          .map((value) => value.toDouble())
          .toList(growable: false);
      if (logits.length != ModelConfig.labels.length) {
        throw StateError(
          'Expected ${ModelConfig.labels.length} class logits, got ${logits.length}.',
        );
      }
      final probabilities = _softmax(logits);
      final scores = List<ClassScore>.generate(
        ModelConfig.labels.length,
        (index) => ClassScore(
          label: ModelConfig.labels[index],
          probability: probabilities[index],
        ),
      )..sort((a, b) => b.probability.compareTo(a.probability));
      return InferenceResult(
        scores: scores,
        inferenceTime: stopwatch.elapsed,
        capturedImage: encodedImage,
        status: scores.first.probability >= ModelConfig.reviewThreshold
            ? InspectionStatus.defect
            : InspectionStatus.review,
      );
    } finally {
      await input.dispose();
      for (final output in outputs.values) {
        await output.dispose();
      }
    }
  }

  Future<void> dispose() async {
    final session = _session;
    _session = null;
    await session?.close();
  }

  static List<double> _softmax(List<double> logits) {
    final largest = logits.reduce(math.max);
    final exponentials =
        logits.map((value) => math.exp(value - largest)).toList();
    final sum = exponentials.reduce((a, b) => a + b);
    return exponentials.map((value) => value / sum).toList(growable: false);
  }
}

Float32List _preprocessImage(Uint8List bytes) {
  final decoded = image_lib.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('The captured image could not be decoded.');
  }
  final oriented = image_lib.bakeOrientation(decoded);
  final cropSize = math.min(oriented.width, oriented.height);
  final cropped = image_lib.copyCrop(
    oriented,
    x: (oriented.width - cropSize) ~/ 2,
    y: (oriented.height - cropSize) ~/ 2,
    width: cropSize,
    height: cropSize,
  );
  final resized = image_lib.copyResize(
    cropped,
    width: ModelConfig.inputWidth,
    height: ModelConfig.inputHeight,
    interpolation: image_lib.Interpolation.linear,
  );
  final result = Float32List(
    ModelConfig.channels * ModelConfig.inputWidth * ModelConfig.inputHeight,
  );
  final planeSize = ModelConfig.inputWidth * ModelConfig.inputHeight;
  for (var y = 0; y < ModelConfig.inputHeight; y++) {
    for (var x = 0; x < ModelConfig.inputWidth; x++) {
      final pixel = resized.getPixel(x, y);
      final index = y * ModelConfig.inputWidth + x;
      result[index] = pixel.r / 255.0;
      result[planeSize + index] = pixel.g / 255.0;
      result[planeSize * 2 + index] = pixel.b / 255.0;
    }
  }
  return result;
}
