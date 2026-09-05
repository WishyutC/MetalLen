# MetalLens documentation

This directory is the source of truth for MetalLens project documentation. Keep documentation here updated whenever behavior, architecture, setup, or planned work changes.

## Documentation index

- [Current app status](CURRENT_STATUS.md) — features working in the current build, mocked behavior, and known limitations.
- [Development guide](DEVELOPMENT.md) — prerequisites, commands, tests, and supported platforms.
- [Architecture](ARCHITECTURE.md) — source layout, UI structure, state ownership, and integration boundaries.
- [Model integration](MODEL_INTEGRATION.md) — ONNX contract, preprocessing, result decoding, assumptions, and runtime verification.
- [Roadmap](ROADMAP.md) — upcoming product and engineering work in recommended order.

## Product rules

- Scanner is the home destination. Do not add a separate Home tab.
- Primary navigation contains exactly Scanner, History, Analytics, and Profile.
- The condition CNN classes must remain exactly:
  1. Silk spot
  2. Deburring
  3. Factory new
  4. Rusty old
- A separate two-class CNN must gate `Not metal` versus `Metal` before the condition CNN runs.
- Pass, Defect, and Review are application-level result states, not CNN classes.
- Never present model predictions as guaranteed or 100% accurate.
- Uncertain results must remain available for manual review.
