# Model integration

MetalLens uses a two-stage on-device ONNX pipeline. Camera captures and gallery
images pass through the same preprocessing and inference flow.

## Pipeline

```text
Camera capture or gallery image
              |
              v
      Metal / not-metal gate v003
        |              |
    not metal         metal
        |              |
  stop and explain     v
               Condition CNN v003
                         |
                         v
              Inclusion / Silk spot / Scratch
```

The condition CNN is never run when the material gate rejects an image.

## Active model files

| Purpose | Asset path | Output decoding |
| --- | --- | --- |
| Material gate | `cnn_model/material_gate/ismetal_model_003.onnx` | One logit passed through sigmoid: `Not metal` / `Metal` |
| Condition classifier | `cnn_model/condition/cnn_model_003.onnx` | Three logits passed through softmax: `Inclusion`, `Silk spot`, `Scratch` |

`cnn_model/condition/cnn_model_004.onnx` is retained in the source tree for
comparison, but the Flutter asset manifest does not bundle or load it.

## Verified graph contract

The supplied ONNX graphs were inspected on 2026-09-15:

| Model | Direction | Name | Type | Shape |
| --- | --- | --- | --- | --- |
| Material v003 | Input | `input` | float32 | `[batch_size, 3, 64, 64]` |
| Material v003 | Output | `logits` | float32 | `[batch_size, 1]` |
| Condition v003 | Input | `input` | float32 | `[batch_size, 3, 64, 64]` |
| Condition v003 | Output | `logits` | float32 | `[batch_size, 3]` |

Preprocessing decodes the image, applies EXIF orientation, center-crops to a
square, resizes to 64 × 64, converts to RGB CHW order, and normalizes channels
to `[0, 1]`. Tensor names and shapes are graph-verified. RGB normalization and
the class-index order are product/training assumptions and must still be
checked against the training code or known validation samples.

## Fallback behavior

- If the material model cannot load, a clearly marked mock gate assumes a valid
  image is metal so the rest of the workflow stays testable.
- If the condition model cannot load, deterministic placeholder probabilities
  are generated for the same three UI classes.
- Result cards and sheets say `Demo result` whenever a fallback contributes to
  the result; mock output must not be interpreted as trained inference.

## Result policy

- Material probability is `sigmoid(logit)`. At 60% or higher the image proceeds
  as metal; otherwise condition inference is skipped and the app reports
  `Not metal`.
- Condition probabilities are `softmax(logits)`.
- A top condition probability below 60% becomes `Review`.
- Inclusion, Silk spot, or Scratch at or above 60% becomes `Defect`.
- `Pass` remains an application/history state. It is not an output class of the
  current three-condition CNN.

These thresholds require calibration against representative validation data
before production use.

## Image sources and rescanning

The result records whether bytes came from the camera or gallery. A selected
gallery image is shown as the scanner background and can be analyzed repeatedly
without reopening the picker. Camera captures can also be rerun from the result
sheet. Image bytes remain on device.

## Validation checklist

1. Confirm the class-index order against the condition training code.
2. Confirm the material target convention (`1 = Metal`) against training code.
3. Confirm `[0, 1]` RGB normalization and whether mean/std normalization is used.
4. Run known validation samples and compare mobile output with Python output.
5. Test metal and non-metal samples on physical Android and iOS devices.
6. Calibrate both thresholds and record model versions with saved inspections.
