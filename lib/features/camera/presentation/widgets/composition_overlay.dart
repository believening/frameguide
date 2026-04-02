import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Composition overlay widget that draws grid lines
class CompositionOverlay extends StatelessWidget {
  final GridStyle style;

  const CompositionOverlay({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CompositionPainter(style),
      size: Size.infinite,
    );
  }
}

class _CompositionPainter extends CustomPainter {
  final GridStyle style;

  _CompositionPainter(this.style);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridLine
      ..strokeWidth = AppDimensions.gridLineWidth
      ..style = PaintingStyle.stroke;

    switch (style) {
      case GridStyle.ruleOfThirds:
        _drawRuleOfThirds(canvas, size, paint);
        break;
      case GridStyle.goldenRatio:
        _drawGoldenRatio(canvas, size, paint);
        break;
      case GridStyle.diagonal:
        _drawDiagonal(canvas, size, paint);
        break;
      case GridStyle.centerPoint:
        _drawCenterPoint(canvas, size, paint);
        break;
    }
  }

  void _drawRuleOfThirds(Canvas canvas, Size size, Paint paint) {
    // Vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );
    // Horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );
  }

  void _drawGoldenRatio(Canvas canvas, Size size, Paint paint) {
    const phi = 1.618033988749895;
    final w = size.width;
    final h = size.height;

    // Draw golden ratio grid lines
    canvas.drawLine(
      Offset(w / phi, 0),
      Offset(w / phi, h),
      paint,
    );
    canvas.drawLine(
      Offset(w - w / phi, 0),
      Offset(w - w / phi, h),
      paint,
    );
    canvas.drawLine(
      Offset(0, h / phi),
      Offset(w, h / phi),
      paint,
    );
    canvas.drawLine(
      Offset(0, h - h / phi),
      Offset(w, h - h / phi),
      paint,
    );

    // Draw golden spiral
    final path = Path();
    path.moveTo(w, h);
    for (int i = 0; i < 4; i++) {
      final rect = Rect.fromLTWH(
        i.isEven ? 0 : w - w / pow(phi, i + 1),
        i.isEven ? h - h / pow(phi, i + 1) : 0,
        w / pow(phi, i + 1),
        h / pow(phi, i + 1),
      );
      path.arcTo(rect, i * pi / 2, -pi / 2, false);
    }
    canvas.drawPath(path, paint..strokeWidth = 1.5);
  }

  void _drawDiagonal(Canvas canvas, Size size, Paint paint) {
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  void _drawCenterPoint(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    const crossSize = 30.0;
    
    canvas.drawLine(
      Offset(center.dx - crossSize, center.dy),
      Offset(center.dx + crossSize, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - crossSize),
      Offset(center.dx, center.dy + crossSize),
      paint,
    );
    
    canvas.drawCircle(center, 8, paint);
  }

  @override
  bool shouldRepaint(covariant _CompositionPainter oldDelegate) {
    return oldDelegate.style != style;
  }
}
