# MetalLens device-test APK

This directory stores APK files intended for testing MetalLens on a physical Android device.

## Current build

- File: `MetalLens-v0.1.0-build1-debug.apk`
- App version: `0.1.0+1`
- Package ID: `com.metallens.metallens`
- Build type: Debug
- Launcher icon: MetalLens camera lens and metal-surface scan reticle, with Android adaptive and iOS multi-size support
- Features: camera capture, gallery selection/rescan, real v003 metal gate, and real v003 three-condition classifier
- UX update (2026-09-09): explicit scan/rescan controls, new-photo and camera actions in results, clearer demo notices, and analysis progress.
- Model update (2026-09-15): Inclusion, Silk spot, and Scratch condition classes; condition model 004 is not bundled.
- SHA-256: `B8C6352864F6F3445749B5E94F033A88D68177A1BA68B07E0A9EE57DE717F2ED`

## Install on a phone

1. Copy the APK to the Android phone.
2. Open it with the phone's file manager.
3. If prompted, allow installation from that file-manager app.
4. Install MetalLens and grant camera permission when requested.

Alternatively, with Android platform tools and USB debugging enabled:

```powershell
adb install -r MetalLens-v0.1.0-build1-debug.apk
```

This is a development build for testing, not a signed production release.

APK binaries in this directory are intentionally excluded from Git because the
universal debug build exceeds GitHub's 100 MB per-file limit. Recreate the file
from the repository root with:

```powershell
flutter build apk --debug
Copy-Item build\app\outputs\flutter-apk\app-debug.apk test_apk\MetalLens-v0.1.0-build1-debug.apk
```
