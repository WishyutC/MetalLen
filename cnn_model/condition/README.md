# Three-class condition model

The app uses:

`cnn_model_003.onnx`

Verified graph contract:

- Input: `input`, float32 `[1, 3, 64, 64]`, RGB normalized to `[0, 1]`
- Output: `logits`, float32 `[1, 3]`
- Class order supplied for the app: `Inclusion`, `Silk spot`, `Scratch`

`cnn_model_004.onnx` is retained for comparison but is not bundled or loaded.
If model 003 is unavailable or incompatible, MetalLens uses a clearly labeled
deterministic mock condition result.
