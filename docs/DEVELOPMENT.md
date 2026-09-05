# Development guide

## Requirements

- Flutter SDK compatible with Dart 3.3 or newer
- Android Studio or an Android SDK for Android builds
- Xcode on macOS for iOS builds
- Chrome or another supported browser for web development

The current camera package requires Android API 24 or newer. The ONNX plugin requires Android NDK `27.0.12077973`; this version is pinned in the Android app configuration. The iOS deployment target is 16.0.

## Install dependencies

```sh
flutter pub get
```

## Run the app

List available targets:

```sh
flutter devices
```

Run on a selected device:

```sh
flutter run -d <device-id>
```

For an Android emulator, configure a front or back virtual camera in the AVD settings. MetalLens marks camera hardware as optional so it can still install and present a recovery state when no camera is configured.

Run in Chrome:

```sh
flutter run -d chrome
```

## Verify changes

Format source files:

```sh
dart format lib test
```

Run static analysis and tests:

```sh
flutter analyze
flutter test
```

Compile the web target:

```sh
flutter build web
```

Build the Android debug APK:

```sh
flutter build apk --debug
```

## ONNX model asset

The application bundles:

```text
cnn_model/cnn_model_001_best.onnx
```

If that file is replaced, confirm its input/output contract and update `lib/services/model_config.dart`. Do not assume another model uses the same dimensions, normalization, tensor names, or class-index order. See [MODEL_INTEGRATION.md](MODEL_INTEGRATION.md).

## Definition of done

A UI change should:

- Work at 390 px and remain usable at 320 px.
- Support light and dark appearances where applicable.
- Preserve approximately 44 × 44 px touch targets.
- Provide semantic labels or tooltips for icon-only controls.
- Communicate Defect, Pass, and Review with text/icons as well as color.
- Keep bottom content clear of the navigation island.
- Add or update a widget test for behavior that can regress.
- Update the relevant document in this directory.
