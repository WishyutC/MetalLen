import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as image_lib;

import '../models/inference_result.dart';
import '../models/inspection.dart';
import 'model_config.dart';

/// Coordinates the binary material gate and three-class condition classifier.
///
/// Missing ONNX assets intentionally fall back to visible mock behavior so the
/// capture/gallery flow remains testable while models are being trained.
class MetalClassifier {
  MetalClassifier({OnnxRuntime? runtime}) : _runtime = runtime ?? OnnxRuntime();

  final OnnxRuntime _runtime;
  OrtSession? _materialSession;
  OrtSession? _conditionSession;
  bool _initialized = false;

  bool get isReady => _initialized;
  bool get materialUsesMock => _materialSession == null;
  bool get conditionUsesMock => _conditionSession == null;

  Future<void> initialize() async {
    if (_initialized) return;
    _materialSession = await _tryCreateSession(ModelConfig.materialAssetPath);
    _conditionSession = await _tryCreateSession(ModelConfig.conditionAssetPath);
    _initialized = true;
  }

  Future<OrtSession?> _tryCreateSession(String assetPath) async {
    try {
      final session = await _runtime.createSessionFromAsset(
        assetPath,
        options: OrtSessionOptions(intraOpNumThreads: 2, interOpNumThreads: 1),
      );
      if (!session.inputNames.contains(ModelConfig.inputName) ||
          !session.outputNames.contains(ModelConfig.outputName)) {
        await session.close();
        return null;
      }
      return session;
    } catch (_) {
      return null;
    }
  }

  Future<InferenceResult> analyze(
    Uint8List encodedImage, {
    required ScanImageSource source,
  }) async {
    await initialize();
    final pixels = await compute(_preprocessImage, encodedImage);
    final input = await OrtValue.fromList(pixels, const [
      1,
      ModelConfig.channels,
      ModelConfig.inputHeight,
      ModelConfig.inputWidth,
    ]);
    final totalStopwatch = Stopwatch()..start();
    try {
      final material = await _classifyMaterial(input);
      if (!material.isMetal) {
        totalStopwatch.stop();
        return InferenceResult(
          scores: const [],
          inferenceTime: totalStopwatch.elapsed,
          capturedImage: encodedImage,
          status: InspectionStatus.review,
          source: source,
          material: material,
          conditionUsesMock: false,
        );
      }

      final scores = await _classifyCondition(input, pixels);
      totalStopwatch.stop();
      final prediction = scores.first;
      final status = prediction.probability < ModelConfig.reviewThreshold
          ? InspectionStatus.review
          : InspectionStatus.defect;
      return InferenceResult(
        scores: scores,
        inferenceTime: totalStopwatch.elapsed,
        capturedImage: encodedImage,
        status: status,
        source: source,
        material: material,
        conditionUsesMock: conditionUsesMock,
      );
    } finally {
      await input.dispose();
    }
  }

  Future<MaterialDecision> _classifyMaterial(OrtValue input) async {
    final session = _materialSession;
    if (session == null) {
      return const MaterialDecision(
        isMetal: true,
        confidence: 0,
        inferenceTime: Duration.zero,
        usesMock: true,
      );
    }
    final stopwatch = Stopwatch()..start();
    final logits = await _run(session, input);
    stopwatch.stop();
    if (logits.length != 1) {
      throw StateError(
        'Expected one material logit, '
        'got ${logits.length}.',
      );
    }
    final metalProbability = sigmoid(logits.single);
    return MaterialDecision(
      isMetal: metalProbability >= ModelConfig.materialThreshold,
      confidence: metalProbability >= ModelConfig.materialThreshold
          ? metalProbability
          : 1 - metalProbability,
      inferenceTime: stopwatch.elapsed,
      usesMock: false,
    );
  }

  Future<List<ClassScore>> _classifyCondition(
    OrtValue input,
    Float32List pixels,
  ) async {
    final session = _conditionSession;
    final logits = session == null
        ? _mockConditionLogits(pixels)
        : await _run(session, input);
    if (logits.length != ModelConfig.conditionLabels.length) {
      throw StateError(
        'Expected ${ModelConfig.conditionLabels.length} condition logits, '
        'got ${logits.length}.',
      );
    }
    final probabilities = _softmax(logits);
    return List<ClassScore>.generate(
      ModelConfig.conditionLabels.length,
      (index) => ClassScore(
        label: ModelConfig.conditionLabels[index],
        probability: probabilities[index],
      ),
    )..sort((a, b) => b.probability.compareTo(a.probability));
  }

  Future<List<double>> _run(OrtSession session, OrtValue input) async {
    Map<String, OrtValue> outputs = const {};
    try {
      outputs = await session.run({ModelConfig.inputName: input});
      return (await outputs[ModelConfig.outputName]!.asFlattenedList())
          .cast<num>()
          .map((value) => value.toDouble())
          .toList(growable: false);
    } finally {
      for (final output in outputs.values) {
        await output.dispose();
      }
    }
  }

  Future<void> dispose() async {
    final material = _materialSession;
    final condition = _conditionSession;
    _materialSession = null;
    _conditionSession = null;
    _initialized = false;
    await material?.close();
    await condition?.close();
  }

  static List<double> _softmax(List<double> logits) {
    final largest = logits.reduce(math.max);
    final exponentials =
        logits.map((value) => math.exp(value - largest)).toList();
    final sum = exponentials.reduce((a, b) => a + b);
    return exponentials.map((value) => value / sum).toList(growable: false);
  }

  @visibleForTesting
  static double sigmoid(double logit) {
    if (logit >= 0) return 1 / (1 + math.exp(-logit));
    final exponential = math.exp(logit);
    return exponential / (1 + exponential);
  }
}

List<double> _mockConditionLogits(Float32List pixels) {
  final planeSize = ModelConfig.inputWidth * ModelConfig.inputHeight;
  var meanR = 0.0;
  var meanG = 0.0;
  var meanB = 0.0;
  var edge = 0.0;
  for (var index = 0; index < planeSize; index++) {
    meanR += pixels[index];
    meanG += pixels[planeSize + index];
    meanB += pixels[planeSize * 2 + index];
    if (index % ModelConfig.inputWidth != 0) {
      edge += (pixels[index] - pixels[index - 1]).abs();
    }
  }
  meanR /= planeSize;
  meanG /= planeSize;
  meanB /= planeSize;
  edge /= planeSize;
  final channelSpread = math.max(meanR, math.max(meanG, meanB)) -
      math.min(meanR, math.min(meanG, meanB));
  final brightness = (meanR + meanG + meanB) / 3;

  return [
    1.0 + (1 - brightness) * 2 + channelSpread,
    1.1 + channelSpread * 3,
    1.0 + edge * 10,
  ];
}

Float32List _preprocessImage(Uint8List bytes) {
  final decoded = image_lib.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('The selected image could not be decoded.');
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
