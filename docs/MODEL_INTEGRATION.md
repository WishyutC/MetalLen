# Model integration

MetalLens now uses a two-stage on-device inspection pipeline. Camera captures
and gallery images pass through exactly the same preprocessing and inference
flow.

## Pipeline

```text
Camera capture or gallery image
              |
              v
      Metal / not-metal gate
        |              |
    not metal         metal
        |              |
  stop and explain     v
               Four-class condition CNN
                         |
                         v
        Silk spot / Deburring / Factory new / Rusty old
```

The condition CNN is never run when a real material gate rejects an image.

## Expected model files

| Purpose | Asset path | Output order |
| --- | --- | --- |
| Material gate | `cnn_model/material_gate/metal_or_not.onnx` | `Not metal`, `Metal` |
| Condition classifier | `cnn_model/condition/condition_classifier.onnx` | `Silk spot`, `Deburring`, `Factory new`, `Rusty old` |

The previous `cnn_model/cnn_model_001_best.onnx` file has five incompatible
outputs. It remains in the repository as a legacy artifact but is not used or
relabelled by the new pipeline.

## Default tensor contract

Until the new exports are inspected, both models are expected to use:

| Direction | Name | Type | Shape |
| --- | --- | --- | --- |
| Input | `input` | float32 | `[1, 3, 64, 64]` |
| Output | `logits` | float32 | `[1, 2]` for the gate; `[1, 4]` for condition |

Preprocessing decodes the image, applies EXIF orientation, center-crops to a
square, resizes to 64 x 64, converts to RGB CHW order, and normalizes channels
to `[0, 1]`. Confirm all names, dimensions, class indices, and normalization
against the training/export code before treating results as valid.

## Mock behavior

The model folders currently contain instructions but no new ONNX files.

- The mock material gate assumes a valid image is metal so the rest of the UX
  can be exercised.
- The mock condition stage produces deterministic placeholder probabilities
  from simple color/edge statistics.
- Result cards and sheets display `Mock pipeline`; mock output must never be
  interpreted as a trained prediction.
- If a compatible ONNX file exists at the expected path when the app is rebuilt,
  the app attempts to load and use it automatically on the next launch.

## Result policy

- A real material-gate confidence below the configured 60% metal threshold
  stops condition analysis and reports that the image was not identified as
  metal.
- A top condition probability below 60% becomes `Review`.
- `Factory new` at or above 60% becomes `Pass`.
- `Silk spot`, `Deburring`, and `Rusty old` at or above 60% become `Defect`.

These thresholds are product defaults and require validation data before
production deployment.

## Image sources and rescanning

The result records whether bytes came from the camera or gallery. A selected
gallery image is shown as the scanner background and can be analyzed repeatedly
without reopening the picker. Camera captures can also be rerun from the result
sheet. The app does not upload image bytes; preprocessing and inference remain
on device.

## Before enabling real results

1. Copy each ONNX file to its exact path above.
2. Confirm the graph with an ONNX checker and a known validation sample.
3. Verify input/output tensor names and shapes.
4. Confirm class-index ordering from training code.
5. Confirm RGB normalization and any mean/std normalization.
6. Test metal and non-metal samples on physical Android and iOS devices.
7. Record model versions and calibration metrics in persisted inspections.
