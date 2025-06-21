import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: _ScannerOverlayShape(
          borderColor: Colors.white,
          borderWidth: 3.0,
          overlayColor: Colors.black.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  const _ScannerOverlayShape({
    required this.borderColor,
    required this.borderWidth,
    required this.overlayColor,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path scanArea = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: rect.width * 0.8,
            height: rect.height * 0.3,
          ),
          const Radius.circular(12),
        ),
      );
    return Path.combine(PathOperation.difference, path, scanArea);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(getOuterPath(rect), paint);

    // Draw corner brackets
    final scanRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * 0.8,
      height: rect.height * 0.3,
    );

    final bracketPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final bracketLength = 30.0;

    // Draw all four corner brackets
    _drawCornerBrackets(canvas, scanRect, bracketPaint, bracketLength);
  }

  void _drawCornerBrackets(Canvas canvas, Rect scanRect, Paint bracketPaint, double bracketLength) {
    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.top + bracketLength)
        ..lineTo(scanRect.left, scanRect.top)
        ..lineTo(scanRect.left + bracketLength, scanRect.top),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - bracketLength, scanRect.top)
        ..lineTo(scanRect.right, scanRect.top)
        ..lineTo(scanRect.right, scanRect.top + bracketLength),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.bottom - bracketLength)
        ..lineTo(scanRect.left, scanRect.bottom)
        ..lineTo(scanRect.left + bracketLength, scanRect.bottom),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - bracketLength, scanRect.bottom)
        ..lineTo(scanRect.right, scanRect.bottom)
        ..lineTo(scanRect.right, scanRect.bottom - bracketLength),
      bracketPaint,
    );
  }

  @override
  ShapeBorder scale(double t) => _ScannerOverlayShape(
        borderColor: borderColor,
        borderWidth: borderWidth,
        overlayColor: overlayColor,
      );
}
