# Current app status

Last reviewed: 2026-09-15

MetalLens currently provides an interactive Flutter application for Android, iOS, and web. Camera capture and gallery selection share a two-stage material/condition pipeline using the supplied ONNX v003 models. Historical records, analytics, persistence, export, and backend synchronization remain mocked or incomplete.

## Working now

### Application shell

- Scanner opens as the initial destination.
- MetalLens camera-and-surface-inspection artwork is installed across Android legacy/adaptive launcher densities and all iPhone/iPad icon sizes.
- Floating Dynamic Island-style navigation switches among exactly four destinations.
- Only the active destination expands and displays its label.
- Light, dark, and device-system appearance modes are supported.
- Layouts are responsive to the required 320 px minimum width.

### Scanner

- Explicit scan button prevents accidental background-tap captures; in gallery mode it rescans the selected photo.
- Results include accessible Choose photo and New camera scan actions, plus visible analysis progress.
- Demo mode is announced before scanning, and simulated outputs are titled Demo result.
- Full-screen, center-cropped live camera preview with immersive system UI, runtime permission handling, and unavailable/restricted states.
- Cyan scanning focus guide and three-condition status.
- Accessible capture, gallery, flashlight, settings, and help controls.
- Physical or emulator-camera image capture plus system gallery selection.
- Selected gallery image preview and one-tap reanalysis without reopening the picker.
- Center-crop, orientation correction, 64 × 64 RGB resize, and NCHW tensor preprocessing.
- Two-stage flow: single-logit metal/not-metal gate followed by three-class condition analysis only for metal images.
- Active ONNX assets are `ismetal_model_003.onnx` and `cnn_model_003.onnx`; condition model 004 is stored but not loaded or bundled.
- Stable sigmoid decoding for the binary gate and softmax decoding for the three condition logits.
- Explicit mock fallbacks remain available if either active model cannot load.
- Confidence-based Defect or Review status; low-confidence predictions are preserved.
- Persistent latest-analysis card with prediction, confidence, and inference time.
- Full result sheet with source thumbnail, material decision, mock/real status, three condition probabilities, and rescan action.
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
- Daily inspection activity chart fills the card width with evenly spaced bars and readable weekday labels.
- Distribution across all three approved condition classes.
- Prototype-data labels distinguish mock values from future backend data.

### Profile

- Inspector identity and model readiness summary.
- Expandable list of all three CNN condition classes and active model version.
- Editable confidence threshold.
- Auto-save and scan-feedback toggles.
- Light, dark, and system appearance selection.
- English and Thai language selection UI.
- CSV and JSON export integration placeholders.
- Privacy/local-storage information and app version.

## Mocked or placeholder behavior

- `lib/data/mock_data.dart` supplies all inspection and analytics data.
- Flashlight control calls camera hardware but availability depends on the selected camera/emulator.
- Settings are held in memory and reset when the process restarts.
- Language selection changes its setting value but does not localize the interface yet.
- Export selection does not write a file.
- History detail is a prepared handoff rather than the final result-detail screen.
- Captured inference results are not persisted into History yet.
- Real-model accuracy is not yet validated against known samples on a physical device.

## Model contracts requiring confirmation

- Material output is one logit, decoded with sigmoid under the assumption `1 = Metal`.
- Condition output order is `Inclusion`, `Silk spot`, `Scratch`.
- Both models use 64 x 64 RGB pixels normalized to `[0, 1]` without mean/std normalization.
- A top condition probability below 60% becomes Review; any of the three conditions above threshold becomes Defect. Pass is not a current CNN class.

These assumptions must be checked against both models' training code and validation samples before production use.

## Current validation

- `flutter analyze` passes with no issues.
- Widget tests cover all four destinations, history filtering, and navigation at 320 × 700 px.
- Android debug APK compilation succeeds with camera, gallery picker, ONNX Runtime, and both selected v003 models.
- APK inspection confirms that condition v003 and material v003 are bundled and condition v004 is excluded.
- A physical-device test copy is stored at `test_apk/MetalLens-v0.1.0-build1-debug.apk`; installation notes and its SHA-256 checksum are in `test_apk/README.md`.
- Android 10 API 29 x86 emulator verification completed on 2026-09-15:
  - Both v003 ONNX sessions loaded; no mock-mode notice was shown.
  - A camera frame completed the material gate and condition classifier end to end.
  - The real result displayed `Scratch` with three-condition UI and `Analyzed on device`.
  - The synthetic emulator-frame prediction is a runtime check, not an accuracy measurement.
- Android emulator verification completed on 2026-09-05 for the new workflow:
  - Camera capture completed through the two-stage mock pipeline.
  - The Android gallery picker opened and returned a selected image to MetalLens.
  - The selected image appeared as the scanner preview and produced four condition scores.
  - The result displayed `Gallery · Mock pipeline` rather than presenting placeholder output as real inference.
  - `Analyze this gallery image again` completed without reopening the picker.
- Android 13 API 33 x86_64 emulator verification completed on 2026-09-03:
  - CameraX opened the emulator back camera.
  - The previous five-class capture and ONNX inference completed end to end before the model contract changed.
  - The observed inference call took 13 ms for the emulator frame.
  - All five legacy probabilities appeared in the result sheet.
  - No fatal Flutter, ONNX, or image-capture errors appeared in collected logs.

The 13 ms value is one emulator observation, not a production-device performance guarantee.
