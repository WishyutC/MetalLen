# Four-class condition model

Copy the new ONNX model into this directory as:

`condition_classifier.onnx`

Expected default contract:

- Input: `input`, float32 `[1, 3, 64, 64]`, RGB normalized to `[0, 1]`
- Output: `logits`, float32 `[1, 4]`
- Class order: `Silk spot`, `Deburring`, `Factory new`, `Rusty old`

Until that file is present, MetalLens uses a clearly labeled deterministic mock
condition result. The old five-class model is not relabeled or used.
