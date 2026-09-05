# Architecture

## Source layout

```text
lib/
├── app/       Application shell and primary navigation state
├── data/      Mock repository and future data-source boundary
├── models/    Inspection and analytics domain models
├── screens/   Scanner, History, Analytics, and Profile
├── services/  ONNX tensor contract, preprocessing, and inference lifecycle
├── theme/     Design tokens and adaptive Flutter themes
└── widgets/   Reusable navigation, status, list, surface, and setting UI
```

## Application flow

`main.dart` starts `MetalLensApp`, which owns the appearance mode. `MetalLensShell` owns the selected primary destination and preserves screen state with an `IndexedStack`. The floating navigation island is rendered once by the shell so its behavior remains consistent across all screens.

## Design system

`AppTokens` maps the approved handoff values into shared Flutter constants, including the cyan accent, status colors, spacing, radii, blur, and drag-sheet opacity. `AppTheme` derives adaptive light and dark Material themes without replacing the industrial MetalLens appearance with generic component styling.

## Data boundary

`MockData` is deliberately separated from screen widgets and continues to supply prototype history and analytics. `MetalClassifier` owns ONNX session creation, image preprocessing, inference, softmax decoding, and native tensor disposal. `ScannerScreen` owns the camera lifecycle and calls the classifier after capture.

Production persistence should be added behind repository interfaces rather than adding storage or network calls directly to screen widgets.

Recommended future boundaries:

```text
UI screens
    ↓
Feature controller/state
    ↓
Inspection repository
    ├── Camera/image source (implemented for capture)
    ├── CNN inference service (implemented with ONNX Runtime)
    ├── Local inspection store
    └── Optional backend sync
```

The inference result should retain all five class scores, selected prediction, model version, threshold, timestamp, source image reference, and review state. Application logic may derive Pass, Defect, or Review without changing the model's five-class output.

## State ownership today

- Application theme: `MetalLensApp`
- Selected destination: `MetalLensShell`
- Scanner feedback and flashlight UI: `ScannerScreen`
- Camera controller and lifecycle: `ScannerScreen`
- ONNX session and preprocessing: `MetalClassifier`
- Search and status filter: `HistoryScreen`
- Analytics range: `AnalyticsScreen`
- Profile settings: `ProfileScreen`

Persistent or shared state should be introduced with the repository/controller layer when real services are connected.
