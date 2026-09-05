# Roadmap

This roadmap separates features currently running from future implementation. Current behavior is documented in [CURRENT_STATUS.md](CURRENT_STATUS.md).

## Completed: camera and local model foundation

- Camera permission states and recovery guidance.
- Live camera preview, image capture, and flashlight control.
- ONNX model asset loading and on-device five-class inference.
- Image preprocessing and probability/result presentation.
- Android emulator end-to-end verification.

## Next: complete the inspection workflow

- Confirm label-index order and image normalization against model training code.
- Connect gallery import to the existing inference service.
- Add analysis cancellation and timeout handling.
- Build Scan result detail with image, predicted flaw, confidence, class scores, model version, and metadata.
- Build Manual review so uncertain predictions can be accepted, corrected among the five classes, or rejected.

## Then: persistence and operational states

- Add a local inspection repository and persist profile preferences.
- Implement empty, loading, error, offline, and model-unavailable states.
- Add insufficient-image-quality guidance.
- Implement real CSV and JSON export with platform-safe storage/share behavior.
- Add record deletion and retention controls with confirmation and recovery where practical.

## Backend and model integration

- Connect production inspection storage behind the repository boundary.
- Record model version and inference timing with each inspection.
- Replace analytics mock values with computed repository data.
- Add optional authenticated backend synchronization if required by deployment.
- Define privacy, retention, encryption, and device-loss requirements before storing production images.

## Quality and release readiness

- Add unit tests for status/threshold decision logic.
- Add widget tests for settings, analytics ranges, search, empty states, and review behavior.
- Add integration tests for camera-to-result and export flows.
- Test accessibility with large text, screen readers, and reduced motion.
- Validate supported Android and iOS versions on physical devices.
- Replace default launcher/launch assets with approved MetalLens branding.
- Establish build flavors, signing, versioning, crash reporting, and release automation.

## Useful later screens

- Scan result detail
- Manual review
- Camera permission
- Empty and error states
- Model unavailable/update state
- Export history
- Storage management

No onboarding, social features, subscriptions, advertising, or unrelated destinations are planned.
