# ONNX model integration

Last verified: 2026-09-03

## Bundled model

```text
cnn_model/cnn_model_001_best.onnx
```

- File size: 1,427,467 bytes
- SHA-256: `13205ff4d08be93668512157db8b33e9a73d665afd675aee6c2eb8a64de7ebab`
- Producer: PyTorch 2.11.0
- ONNX IR version: 8
- ONNX opset: 17

The model passed ONNX validation and a CPU zero-input inference during inspection.

## Verified tensor contract

| Direction | Name | Type | Shape | Meaning |
| --- | --- | --- | --- | --- |
| Input | `input` | float32 | `[batch, 3, 64, 64]` | NCHW image tensor |
| Output | `logits` | float32 | `[batch, 5]` | Raw class logits |

The graph uses standard Conv, ReLU, MaxPool, AveragePool, Flatten, and Gemm operators.

## Current preprocessing

1. Decode the captured JPEG.
2. Apply encoded orientation.
3. Center-crop the image to a square.
4. Resize to 64 × 64 with linear interpolation.
5. Read RGB channels.
6. Convert each channel from 0–255 to float `[0, 1]`.
7. Store values in NCHW order as `[1, 3, 64, 64]`.

Preprocessing runs in a Flutter isolate. ONNX Runtime executes the model asynchronously, and native input/output tensors are disposed after every run. The session is reused until the scanner is disposed.

## Current output decoding

The raw five logits are converted to probabilities with numerically stable softmax. The configured class order is:

1. Rolled pit
2. Inclusion
3. Silk spot
4. Deburring
5. Waist folding

The model file does not contain class-label metadata. This ordering must be confirmed against training code.

If the highest probability is below 60%, the application marks the result Review. Otherwise it displays Defect predicted. The app does not derive Pass from this model because all five outputs are defect types.

## Runtime verification

An end-to-end test was completed on an Android 13 API 33 x86_64 emulator:

- CameraX opened the configured virtual back camera.
- The camera preview was verified center-cropped and full-screen without aspect-ratio letterboxing.
- MetalLens captured the emulator virtual-scene frame.
- The image was decoded, resized, and passed to the bundled ONNX model.
- The result card and full five-class probability sheet were displayed.
- One observed inference call completed in 13 ms.
- Collected logs contained no fatal Flutter, ONNX Runtime, or ImageCapture exception.

The virtual-scene prediction is not an accuracy test, and emulator latency is not representative of all physical phones.

## Production checks still required

- Confirm RGB versus BGR.
- Confirm `[0, 1]` scaling versus mean/std normalization.
- Confirm class-index order.
- Validate predictions against labeled images from the training/validation pipeline.
- Benchmark representative low-, mid-, and high-tier physical phones.
- Define how a defect-free surface is recognized without adding a sixth CNN class.
- Record model version and preprocessing version with every persisted inspection.
