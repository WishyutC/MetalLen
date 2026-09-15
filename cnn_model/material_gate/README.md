# Metal material gate

The app uses:

`ismetal_model_003.onnx`

Verified graph contract:

- Input: `input`, float32 `[1, 3, 64, 64]`, RGB normalized to `[0, 1]`
- Output: `logits`, float32 `[1, 1]`
- Decoding: sigmoid; values at or above the configured threshold mean `Metal`

If the file is unavailable or incompatible, the gate is explicitly marked as
mock and assumes a valid selected/captured image is metal.
