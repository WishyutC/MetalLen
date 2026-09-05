import 'dart:math' as math;

import 'package:flutter/material.dart';

class MetalSurface extends StatelessWidget {
  const MetalSurface({this.child, this.borderRadius, super.key});

  final Widget? child;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CustomPaint(painter: _MetalPainter(), child: child),
    );
  }
}

class _MetalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF333A3E), Color(0xFF151A1D), Color(0xFF2A3034)],
          stops: [0, .48, 1],
        ).createShader(rect),
    );
    final linePaint = Paint()..strokeWidth = 1;
    for (double y = -size.width; y < size.height + size.width; y += 8) {
      final strength = .025 + .025 * (math.sin(y * .31) + 1) / 2;
      linePaint.color = Colors.white.withValues(alpha: strength);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + size.width * .14),
        linePaint,
      );
    }
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.45, -.2),
          radius: .8,
          colors: [Colors.white.withValues(alpha: .12), Colors.transparent],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
