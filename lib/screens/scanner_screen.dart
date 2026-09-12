import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

import '../data/mock_data.dart';
import '../models/inference_result.dart';
import '../models/inspection.dart';
import '../services/metal_classifier.dart';
import '../services/model_config.dart';
import '../theme/app_tokens.dart';
import '../widgets/metal_surface.dart';
import '../widgets/status_badge.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({required this.onOpenSettings, super.key});

  final VoidCallback onOpenSettings;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final MetalClassifier _classifier = MetalClassifier();
  final image_picker.ImagePicker _imagePicker = image_picker.ImagePicker();
  CameraController? _camera;
  bool _flashOn = false;
  bool _capturing = false;
  bool _modelReady = false;
  String? _cameraError;
  String? _inferenceError;
  InferenceResult? _latestResult;
  Uint8List? _galleryPreview;

  void _returnToCamera() {
    if (_capturing) return;
    setState(() {
      _galleryPreview = null;
      _latestResult = null;
      _inferenceError = null;
    });
  }

  Future<void> _scanCurrentImage() async {
    final image = _galleryPreview;
    if (image != null) {
      await _analyzeImage(image, ScanImageSource.gallery);
    } else {
      await _capture();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initializeCamera());
    unawaited(_initializeModel());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final camera = _camera;
      _camera = null;
      unawaited(camera?.dispose());
    } else if (state == AppLifecycleState.resumed && _camera == null) {
      unawaited(_initializeCamera());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_camera?.dispose());
    unawaited(_classifier.dispose());
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (mounted) setState(() => _cameraError = null);
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException(
          'CameraUnavailable',
          'No camera is configured for this device.',
        );
      }
      final description = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      final previous = _camera;
      setState(() => _camera = controller);
      await previous?.dispose();
    } on CameraException catch (error) {
      if (mounted) setState(() => _cameraError = _cameraMessage(error));
    } catch (_) {
      if (mounted) {
        setState(() => _cameraError = 'Camera is unavailable on this device.');
      }
    }
  }

  Future<void> _initializeModel() async {
    try {
      await _classifier.initialize();
      if (mounted) {
        setState(() {
          _modelReady = true;
          _inferenceError = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _inferenceError = 'Inspection pipeline failed: $error');
      }
    }
  }

  Future<void> _capture() async {
    if (_capturing) return;
    var camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      await _initializeCamera();
      camera = _camera;
    }
    if (camera == null || !camera.value.isInitialized) {
      _showMessage(_cameraError ?? 'Camera is not ready yet.');
      return;
    }
    setState(() {
      _capturing = true;
      _inferenceError = null;
    });
    try {
      final picture = await camera.takePicture();
      final bytes = await picture.readAsBytes();
      if (mounted) setState(() => _galleryPreview = null);
      await _analyzeImage(
        bytes,
        ScanImageSource.camera,
        alreadyBusy: true,
      );
    } catch (error) {
      if (mounted) {
        setState(() => _inferenceError = 'Analysis failed: $error');
        _showMessage(
            'Analysis failed. Check the camera and model, then retry.');
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_capturing) return;
    setState(() {
      _capturing = true;
      _inferenceError = null;
    });
    try {
      final selected = await _imagePicker.pickImage(
        source: image_picker.ImageSource.gallery,
        requestFullMetadata: false,
      );
      if (selected == null) return;
      final bytes = await selected.readAsBytes();
      if (!mounted) return;
      setState(() {
        _galleryPreview = bytes;
        _latestResult = null;
      });
      await _analyzeImage(
        bytes,
        ScanImageSource.gallery,
        alreadyBusy: true,
      );
    } catch (error) {
      if (mounted) {
        setState(() => _inferenceError = 'Gallery import failed: $error');
        _showMessage('Could not open or analyze that image.');
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _analyzeImage(
    Uint8List bytes,
    ScanImageSource source, {
    bool alreadyBusy = false,
  }) async {
    if (!mounted || (_capturing && !alreadyBusy)) return;
    if (!_modelReady) {
      await _initializeModel();
      if (!_modelReady) {
        _showMessage(
            _inferenceError ?? 'The inspection pipeline is not ready.');
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _capturing = true;
      _inferenceError = null;
    });
    try {
      final result = await _classifier.analyze(bytes, source: source);
      if (!mounted) return;
      setState(() => _latestResult = result);
      if (!result.isMetal) {
        _showMessage('This image was not identified as metal.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _inferenceError = 'Analysis failed: $error');
        _showMessage('Analysis failed. Check the selected image and models.');
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _toggleFlash() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      _showMessage('Camera is not ready yet.');
      return;
    }
    final next = !_flashOn;
    try {
      await camera.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flashOn = next);
    } on CameraException {
      _showMessage('Flash is not available on this camera.');
    }
  }

  String _cameraMessage(CameraException error) => switch (error.code) {
        'CameraAccessDenied' =>
          'Camera permission was denied. Grant access to scan a surface.',
        'CameraAccessDeniedWithoutPrompt' =>
          'Camera permission is disabled. Enable it in device settings.',
        'CameraAccessRestricted' =>
          'Camera access is restricted on this device.',
        _ => error.description ?? 'Camera is unavailable on this device.',
      };

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String get _scanStatusText {
    if (_capturing) return 'Checking material and condition…';
    if (!_modelReady) return 'Loading inspection pipeline…';
    final result = _latestResult;
    if (result == null) {
      return _galleryPreview == null
          ? 'Position the surface, then tap Scan'
          : 'Gallery image ready to analyze';
    }
    if (!result.isMetal) return 'Not identified as metal';
    final prediction = result.prediction!;
    return '${prediction.label} · ${(prediction.probability * 100).round()}%';
  }

  Future<void> _showResult(InferenceResult result) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => _InferenceResultSheet(
          result: result,
          onRescan: () {
            Navigator.pop(context);
            unawaited(_analyzeImage(result.capturedImage, result.source));
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          // Captures require an explicit action to avoid accidental scans.
          onTap: null,
          child: MetalSurface(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _CameraBackground(
                  controller: _camera,
                  galleryImage: _galleryPreview,
                  error: _cameraError,
                  onRetry: _initializeCamera,
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: .50),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: .42),
                        ],
                        stops: const [0, .24, .66, 1],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _TopBar(
                        flashOn: _flashOn,
                        onFlash: _toggleFlash,
                        onSettings: widget.onOpenSettings,
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) => Column(
                            children: [
                              SizedBox(
                                height: constraints.maxHeight < 680 ? 12 : 42,
                              ),
                              _ScanMode(fromGallery: _galleryPreview != null),
                              if (_modelReady &&
                                  (_classifier.materialUsesMock ||
                                      _classifier.conditionUsesMock))
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Demo mode · results are simulated',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppTokens.review, fontSize: 12),
                                  ),
                                ),
                              const Spacer(),
                              _FocusGuide(
                                height: constraints.maxHeight < 680 ? 140 : 210,
                              ),
                              SizedBox(
                                height: constraints.maxHeight < 680 ? 10 : 18,
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: Text(
                                  _cameraError != null &&
                                          _galleryPreview == null
                                      ? 'Camera setup required — gallery is available'
                                      : _scanStatusText,
                                  key: ValueKey((
                                    _capturing,
                                    _cameraError,
                                    _modelReady,
                                    _latestResult?.prediction?.label,
                                  )),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _galleryPreview == null
                                    ? 'Use even lighting and avoid reflections'
                                    : 'Rescan this photo or return to the camera',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .68),
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              _CaptureControls(
                                onCapture: _scanCurrentImage,
                                onGallery: _pickFromGallery,
                                fromGallery: _galleryPreview != null,
                                busy: _capturing,
                                enabled: !_capturing &&
                                    (_galleryPreview != null ||
                                        _camera != null),
                                galleryEnabled: !_capturing,
                              ),
                              SizedBox(
                                height: constraints.maxHeight < 680 ? 156 : 224,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        DraggableScrollableSheet(
          key:
              ValueKey(_latestResult == null ? 'recent-sheet' : 'result-sheet'),
          initialChildSize: _latestResult == null ? .24 : .48,
          minChildSize: .18,
          maxChildSize: _latestResult == null ? .60 : .78,
          snap: true,
          snapSizes:
              _latestResult == null ? const [.24, .60] : const [.48, .78],
          builder: (context, controller) => ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppTokens.blur,
                sigmaY: AppTokens.blur,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(
                        alpha: AppTokens.dragSheetOpacity,
                      ),
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: .18)),
                  ),
                ),
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 118),
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .45),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_latestResult != null || _galleryPreview != null)
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: _capturing ? null : _pickFromGallery,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Choose photo'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _capturing ? null : _returnToCamera,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('New camera scan'),
                          ),
                        ],
                      ),
                    if (_capturing)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: LinearProgressIndicator(
                            semanticsLabel: 'Analyzing image'),
                      ),
                    if (_latestResult != null) ...[
                      _LatestAnalysisCard(
                        result: _latestResult!,
                        onDetails: () => _showResult(_latestResult!),
                      ),
                      const SizedBox(height: 18),
                    ],
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Example inspections',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          'Demo data',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...MockData.inspections.take(3).map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                MetalSurface(
                                  borderRadius: BorderRadius.circular(12),
                                  child: const SizedBox(width: 50, height: 50),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.partId,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${item.flaw}${item.confidence == null ? '' : ' · ${item.confidence}% confidence'}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: .67,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: item.status, compact: true),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.flashOn,
    required this.onFlash,
    required this.onSettings,
  });
  final bool flashOn;
  final VoidCallback onFlash;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppTokens.accent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.center_focus_strong_rounded,
                color: AppTokens.accentContent,
                size: 19,
              ),
            ),
            const SizedBox(width: 9),
            const Text(
              'MetalLens',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),
            const Spacer(),
            _CircleAction(
              icon: flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              label: 'Toggle flashlight',
              onTap: onFlash,
            ),
            const SizedBox(width: 8),
            _CircleAction(
              icon: Icons.tune_rounded,
              label: 'Open settings',
              onTap: onSettings,
            ),
          ],
        ),
      );
}

class _ScanMode extends StatelessWidget {
  const _ScanMode({required this.fromGallery});
  final bool fromGallery;
  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width - 32,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0x9E0A0D0F),
          borderRadius: BorderRadius.circular(999),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                fromGallery
                    ? Icons.photo_library_outlined
                    : Icons.layers_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                fromGallery ? 'Gallery rescan' : 'Surface scan',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '· ${MockData.flawClasses.length} conditions',
                style: TextStyle(color: Colors.white.withValues(alpha: .65)),
              ),
            ],
          ),
        ),
      );
}

class _FocusGuide extends StatelessWidget {
  const _FocusGuide({required this.height});

  final double height;
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Position the metal surface inside the scan guide',
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width.clamp(250, 286),
          height: height,
          child: CustomPaint(painter: _FocusPainter()),
        ),
      );
}

class _FocusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTokens.accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const length = 46.0;
    const radius = 12.0;
    final path = Path()
      ..moveTo(0, length)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(length, 0)
      ..moveTo(size.width - length, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, length)
      ..moveTo(size.width, size.height - length)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(size.width - length, size.height)
      ..moveTo(length, size.height)
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, size.height - length);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CaptureControls extends StatelessWidget {
  const _CaptureControls({
    required this.onCapture,
    required this.onGallery,
    required this.enabled,
    required this.galleryEnabled,
    required this.fromGallery,
    required this.busy,
  });
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final bool enabled;
  final bool galleryEnabled;
  final bool fromGallery;
  final bool busy;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CircleAction(
              icon: Icons.image_outlined,
              label: 'Choose an image',
              onTap: galleryEnabled ? onGallery : null,
            ),
            Semantics(
              button: true,
              label:
                  fromGallery ? 'Rescan selected photo' : 'Scan metal surface',
              child: InkWell(
                onTap: enabled ? onCapture : null,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled
                        ? AppTokens.accent
                        : AppTokens.accent.withValues(alpha: .45),
                    border: Border.all(color: Colors.white, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTokens.accent.withValues(alpha: .42),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF151A1D), width: 3),
                    ),
                    child: busy
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            fromGallery
                                ? Icons.refresh_rounded
                                : Icons.camera_alt_outlined,
                            color: AppTokens.accentContent,
                          ),
                  ),
                ),
              ),
            ),
            _CircleAction(
              icon: Icons.help_outline_rounded,
              label: 'Open inspection guide',
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Inspection guide'),
                  content: Text(
                    'Fill the guide with the metal surface and avoid glare. Tap the camera button to scan, or choose a photo from your gallery. Demo results are simulated; uncertain model results need review.',
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _CameraBackground extends StatelessWidget {
  const _CameraBackground({
    required this.controller,
    required this.galleryImage,
    required this.error,
    required this.onRetry,
  });

  final CameraController? controller;
  final Uint8List? galleryImage;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final selectedImage = galleryImage;
    if (selectedImage != null) {
      return Image.memory(
        selectedImage,
        fit: BoxFit.cover,
        semanticLabel: 'Selected gallery image',
      );
    }
    final camera = controller;
    if (camera != null && camera.value.isInitialized) {
      return ColoredBox(
        color: Colors.black,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final previewSize = camera.value.previewSize;
            if (previewSize == null) return const SizedBox.expand();
            return ClipRect(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: previewSize.height,
                    height: previewSize.width,
                    child: CameraPreview(camera),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    if (error == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: AppTokens.accent,
              size: 38,
            ),
            const SizedBox(height: 12),
            Text(
              'Starting camera…',
              style: TextStyle(color: Colors.white.withValues(alpha: .75)),
            ),
          ],
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: Colors.white,
              size: 38,
            ),
            const SizedBox(height: 10),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry camera'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InferenceResultSheet extends StatelessWidget {
  const _InferenceResultSheet({required this.result, required this.onRescan});

  final InferenceResult result;
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context) {
    final prediction = result.prediction;
    final notMetal = !result.isMetal;
    final isReview = result.status == InspectionStatus.review;
    final isPass = result.status == InspectionStatus.pass;
    final statusColor = notMetal
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : isReview
            ? AppTokens.review
            : isPass
                ? AppTokens.pass
                : AppTokens.defect;
    final statusLabel = notMetal
        ? 'Not a metal surface'
        : isReview
            ? 'Needs review'
            : isPass
                ? 'Factory-new surface'
                : 'Condition detected';
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    result.capturedImage,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    semanticLabel: 'Captured metal surface',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.usesAnyMock ? 'Demo result' : statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prediction?.label ?? 'Condition analysis skipped',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        prediction == null
                            ? result.material.usesMock
                                ? 'Material gate mock mode'
                                : '${(result.material.confidence * 100).toStringAsFixed(1)}% material confidence'
                            : '${(prediction.probability * 100).toStringAsFixed(1)}% confidence · ${result.inferenceTime.inMilliseconds} ms',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: .62),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              notMetal ? 'Condition pipeline' : 'Four-class probabilities',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (notMetal)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Condition classification was skipped because the material gate rejected the image.',
                ),
              ),
            ...result.scores.map(
              (score) => Padding(
                padding: const EdgeInsets.only(top: 11),
                child: Row(
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(score.label,
                          style: const TextStyle(fontSize: 12)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: score.probability,
                          minHeight: 8,
                          color: AppTokens.accent,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: .1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 43,
                      child: Text(
                        '${(score.probability * 100).toStringAsFixed(1)}%',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result.usesAnyMock
                    ? 'This is a simulated result for trying the app. Trained models are needed for a real inspection.'
                    : isReview
                        ? 'Confidence is below ${(ModelConfig.reviewThreshold * 100).round()}%. Keep this result for manual review.'
                        : 'This is a model prediction, not a guaranteed finding. Confirm it during inspection.',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRescan,
                icon: Icon(
                  result.source == ScanImageSource.gallery
                      ? Icons.refresh_rounded
                      : Icons.camera_alt_outlined,
                ),
                label: Text(
                  result.source == ScanImageSource.gallery
                      ? 'Analyze this gallery image again'
                      : 'Analyze this capture again',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestAnalysisCard extends StatelessWidget {
  const _LatestAnalysisCard({required this.result, required this.onDetails});

  final InferenceResult result;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final prediction = result.prediction;
    final notMetal = !result.isMetal;
    final review = result.status == InspectionStatus.review;
    final pass = result.status == InspectionStatus.pass;
    final color = notMetal
        ? Colors.blueGrey
        : review
            ? AppTokens.review
            : pass
                ? AppTokens.pass
                : AppTokens.defect;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xD9191E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: .45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                notMetal
                    ? Icons.block_rounded
                    : review
                        ? Icons.help_outline_rounded
                        : pass
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.usesAnyMock
                          ? 'Demo result'
                          : notMetal
                              ? 'Not metal'
                              : review
                                  ? 'Needs review'
                                  : pass
                                      ? 'Pass'
                                      : 'Condition detected',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      prediction?.label ?? 'Condition analysis skipped',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                prediction == null
                    ? '—'
                    : '${(prediction.probability * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${result.source == ScanImageSource.gallery ? 'Gallery' : 'Camera'} · ${result.usesAnyMock ? 'Simulated result' : 'Analyzed on device'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .62),
                    fontSize: 11,
                  ),
                ),
              ),
              TextButton(
                onPressed: onDetails,
                child: const Text('Details & rescan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => IconButton.filled(
        onPressed: onTap,
        tooltip: label,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0x900A0D0F),
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 44),
        ),
      );
}
