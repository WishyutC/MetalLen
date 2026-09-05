# Current app status

Last reviewed: 2026-09-03

MetalLens currently provides an interactive Flutter application for Android, iOS, and web. Android camera capture and local ONNX inference are connected and verified on an emulator. Historical records, analytics, persistence, export, and backend synchronization remain mocked or incomplete.

## Working now

### Application shell

- Scanner opens as the initial destination.
- MetalLens camera-and-surface-inspection artwork is installed across Android legacy/adaptive launcher densities and all iPhone/iPad icon sizes.
- Floating Dynamic Island-style navigation switches among exactly four destinations.
- Only the active destination expands and displays its label.
- Light, dark, and device-system appearance modes are supported.
- Layouts are responsive to the required 320 px minimum width.

### Scanner

- Full-screen, center-cropped live camera preview with immersive system UI, runtime permission handling, and unavailable/restricted states.
- Cyan scanning focus guide and five-flaw status.
- Accessible capture, gallery, flashlight, settings, and help controls.
- Physical or emulator-camera image capture.
- Center-crop, orientation correction, 64 × 64 RGB resize, and NCHW tensor preprocessing.
- On-device ONNX Runtime inference with softmax decoding across all five flaw classes.
- Confidence-based Defect or Review status; low-confidence predictions are preserved.
- Persistent latest-analysis card with prediction, confidence, and inference time.
- Full result sheet with the captured thumbnail and all five class probabilities.
- Recent-inspections sheet can be dragged between compact and expanded positions.
- Sheet uses approximately 25% surface opacity with background blur, leaving the camera area visible.

### History

- Search by part ID or flaw name.
- All, Defect, Pass, and Review filters.
- Records grouped by Today and Yesterday.
- Each record displays a metal thumbnail, part ID, flaw, time, line, confidence/check state, and labeled status.
- Selecting a record opens a prepared result-detail handoff explaining the future route inputs.

### Analytics

- Seven-day and thirty-day ranges.
- Total inspections, defect rate, and review count.
- Daily inspection activity chart.
- Distribution across all five approved flaw classes.
- Prototype-data labels distinguish mock values from future backend data.

### Profile

- Inspector identity and model readiness summary.
- Expandable list of all five CNN flaw classes.
- Editable confidence threshold.
- Auto-save and scan-feedback toggles.
- Light, dark, and system appearance selection.
- English and Thai language selection UI.
- CSV and JSON export integration placeholders.
- Privacy/local-storage information and app version.

## Mocked or placeholder behavior

- `lib/data/mock_data.dart` supplies all inspection and analytics data.
- Gallery selection is an integration marker only.
- Flashlight control calls camera hardware but availability depends on the selected camera/emulator.
- Settings are held in memory and reset when the process restarts.
- Language selection changes its setting value but does not localize the interface yet.
- Export selection does not write a file.
- History detail is a prepared handoff rather than the final result-detail screen.
- Captured inference results are not persisted into History yet.
- Pass results cannot be inferred by this five-defect-class model alone.

## Model assumptions requiring confirmation

- ONNX class indices use the approved order: Rolled pit, Inclusion, Silk spot, Deburring, Waist folding.
- Camera pixels are RGB values normalized to `[0, 1]` without mean/std normalization.
- A top probability below 60% becomes Review; at or above 60% becomes Defect.

The ONNX file contains no label or preprocessing metadata, so these assumptions must be checked against the training code or validation samples before production use.

## Current validation

- `flutter analyze` passes with no issues.
- Widget tests cover all four destinations, history filtering, and navigation at 320 × 700 px.
- Android debug APK compilation succeeds with camera and ONNX Runtime dependencies.
- A physical-device test copy is stored at `test_apk/MetalLens-v0.1.0-build1-debug.apk`; installation notes and its SHA-256 checksum are in `test_apk/README.md`.
- Android 13 API 33 x86_64 emulator verification completed on 2026-09-03:
  - CameraX opened the emulator back camera.
  - Capture and ONNX inference completed end to end.
  - The observed inference call took 13 ms for the emulator frame.
  - All five probabilities appeared in the result sheet.
  - No fatal Flutter, ONNX, or image-capture errors appeared in collected logs.

The 13 ms value is one emulator observation, not a production-device performance guarantee.
