# MetalLens Flutter app

Camera-first mobile app for inspecting metal surfaces with on-device ONNX inference. This implementation follows the supplied MetalLens HTML handoff and design tokens.

Project documentation is maintained in [`docs/`](docs/README.md). Start with the [current app status](docs/CURRENT_STATUS.md) to see what works now and the [roadmap](docs/ROADMAP.md) for planned work.

## Run

```sh
flutter pub get
flutter run
```

## Architecture

- `lib/theme/` maps the supplied colors, radii, opacity, blur, and spacing into Flutter tokens and adaptive themes.
- `lib/widgets/` contains the reusable Dynamic Island navigation, status, inspection row, metal surface, and settings components.
- `lib/services/` contains the ONNX model contract, preprocessing, and inference service.
- `lib/data/mock_data.dart` remains the prototype history and analytics data boundary.
- `lib/screens/` contains Scanner, History, Analytics, and Profile.

## Assumptions

- Scanner is the initial destination and no separate Home screen exists.
- Camera capture and CNN inference run on device. Gallery import, export, persistent settings, history storage, and backend synchronization remain integration points.
- `Pass`, `Defect`, and `Review` are application result states—not CNN classes.
- The CNN class list remains exactly: Rolled pit, Inclusion, Silk spot, Deburring, and Waist folding.
- Theme defaults to the device setting and can be changed from Profile.

## Future integration points

- Replace history and analytics `MockData` with a persistent inspection repository.
- Connect gallery import to the same image preprocessing and ONNX inference service.
- Add result detail and manual review screens using the record handoff already exposed by History.
- Add empty/error, camera-permission, and model-unavailable states.
- Implement CSV/JSON file writing after platform storage policy is selected.

See [model integration](docs/MODEL_INTEGRATION.md) for the verified tensor contract, preprocessing assumptions, and emulator result. No accuracy guarantee is presented; uncertain predictions remain reviewable through the confidence threshold and Review state.
