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
- Camera capture and gallery selection share an on-device two-stage inspection pipeline. Export, persistent settings, history storage, and backend synchronization remain integration points.
- `Pass`, `Defect`, and `Review` are application result states—not CNN classes.
- The condition CNN class list is exactly: Silk spot, Deburring, Factory new, and Rusty old.
- A separate material CNN gates metal versus non-metal images before condition classification.
- Theme defaults to the device setting and can be changed from Profile.

## Future integration points

- Replace history and analytics `MockData` with a persistent inspection repository.
- Replace the clearly labeled material-gate and four-condition mocks with validated ONNX exports.
- Add result detail and manual review screens using the record handoff already exposed by History.
- Add empty/error, camera-permission, and model-unavailable states.
- Implement CSV/JSON file writing after platform storage policy is selected.

See [model integration](docs/MODEL_INTEGRATION.md) for the verified tensor contract, preprocessing assumptions, and emulator result. No accuracy guarantee is presented; uncertain predictions remain reviewable through the confidence threshold and Review state.
