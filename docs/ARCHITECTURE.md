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

`MockData` is deliberately separated from screen widgets and continues to supply prototype history and analytics. `MetalClassifier` coordinates the metal/not-metal gate and three-class condition model, owns shared image preprocessing, ONNX sessions, sigmoid/softmax decoding, mock fallbacks, and native tensor disposal. `ScannerScreen` owns camera/gallery selection and sends both sources through the same classifier flow.

Production persistence should be added behind repository interfaces rather than adding storage or network calls directly to screen widgets.

Recommended future boundaries:

```text
UI screens
    ↓
Feature controller/state
    ↓
Inspection repository
    ├── Camera/gallery image source (implemented)
    ├── Material gate (ONNX v003; mock fallback)
    ├── Three-class condition service (ONNX v003; mock fallback)
    ├── Local inspection store
    └── Optional backend sync
```

The inference result retains its camera/gallery source, material decision, mock/real mode, three condition scores when applicable, selected prediction, timing, source bytes, and application status. A non-metal decision stops the pipeline before condition classification.

## State ownership today

- Application theme: `MetalLensApp`
- Selected destination: `MetalLensShell`
- Scanner feedback, gallery preview/rescan, and flashlight UI: `ScannerScreen`
- Camera controller and lifecycle: `ScannerScreen`
- Two-stage ONNX sessions, mock fallbacks, and preprocessing: `MetalClassifier`
- Search and status filter: `HistoryScreen`
- Analytics range: `AnalyticsScreen`
- Profile settings: `ProfileScreen`

Persistent or shared state should be introduced with the repository/controller layer when real services are connected.
