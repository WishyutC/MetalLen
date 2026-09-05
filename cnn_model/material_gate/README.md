# Metal material gate

Copy the future ONNX model into this directory as:

`metal_or_not.onnx`

Expected default contract:

- Input: `input`, float32 `[1, 3, 64, 64]`, RGB normalized to `[0, 1]`
- Output: `logits`, float32 `[1, 2]`
- Class order: `Not metal`, `Metal`

Until that file is present, the gate is explicitly marked as mock and assumes a
valid selected/captured image is metal. This keeps the gallery and rescan flow
testable without presenting the mock decision as a trained prediction.
