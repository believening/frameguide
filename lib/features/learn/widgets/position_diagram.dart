import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frame_guide/core/constants/colors.dart';
import 'package:frame_guide/core/constants/dimensions.dart';

/// 机位图示组件 - 用于技巧详情页展示推荐机位
class TipPositionDiagram extends StatelessWidget {
  final String positionDescription;

  const TipPositionDiagram({
    super.key,
    required this.positionDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: _TipPositionDiagramPainter(positionDescription),
      ),
    );
  }
}

class _TipPositionDiagramPainter extends CustomPainter {
  final String description;

  _TipPositionDiagramPainter(this.description);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.65);

    // 背景网格
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // 解析位置信息
    final parsed = _parsePosition(description);

    // 人物位置（俯视图，用圆表示）
    final personPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final personFillPaint = Paint()
      ..color = Colors.white.withOpacity(0.15);
    
    canvas.drawCircle(center, 18, personPaint);
    canvas.drawCircle(center, 18, personFillPaint);
    
    // 人物标签
    final personLabelPainter = TextPainter(
      text: const TextSpan(
        text: '👤',
        style: TextStyle(fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    personLabelPainter.paint(
      canvas,
      Offset(center.dx - personLabelPainter.width / 2,
          center.dy - personLabelPainter.height / 2),
    );

    // 计算拍摄者位置
    final shooterOffset = Offset(
      center.dx + parsed.dx * size.width * 0.35,
      center.dy + parsed.dy * size.height * 0.45,
    );

    // 距离圆环
    final ringPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, size.width * 0.3, ringPaint);
    canvas.drawCircle(center, size.width * 0.2, ringPaint);

    // 拍摄方向线（虚线）
    final dashPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2;
    _drawDashedLine(canvas, shooterOffset, center, dashPaint);

    // 拍摄角度扇形
    final anglePaint = Paint()
      ..color = AppColors.accent.withOpacity(0.1);
    final angleToCenter = atan2(
      center.dy - shooterOffset.dy,
      center.dx - shooterOffset.dx,
    );
    canvas.drawArc(
      Rect.fromCircle(center: shooterOffset, radius: 40),
      angleToCenter - 0.4,
      0.8,
      true,
      anglePaint,
    );

    // 拍摄者位置（手机图标）
    final shooterPaint = Paint()
      ..color = AppColors.accent;
    canvas.drawCircle(shooterOffset, 12, shooterPaint);
    
    final phonePainter = TextPainter(
      text: const TextSpan(
        text: '📱',
        style: TextStyle(fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    phonePainter.paint(
      canvas,
      Offset(shooterOffset.dx - phonePainter.width / 2,
          shooterOffset.dy - phonePainter.height / 2),
    );

    // 位置文字标签
    final posLabelPainter = TextPainter(
      text: TextSpan(
        text: parsed.label,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    final labelPoint = Offset(
      (shooterOffset.dx + center.dx) / 2,
      (shooterOffset.dy + center.dy) / 2 - 14,
    );
    
    final labelBgPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.9);
    final labelBgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: labelPoint,
        width: posLabelPainter.width + 8,
        height: posLabelPainter.height + 4,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(labelBgRect, labelBgPaint);
    posLabelPainter.paint(
      canvas,
      Offset(labelPoint.dx - posLabelPainter.width / 2,
          labelPoint.dy - posLabelPainter.height / 2),
    );

    // 距离标签
    final distPainter = TextPainter(
      text: TextSpan(
        text: parsed.distance,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    distPainter.paint(
      canvas,
      Offset(center.dx - distPainter.width / 2,
          center.dy + 24),
    );
  }

  ({double dx, double dy, String label, String distance}) _parsePosition(String desc) {
    double dx = 0;
    double dy = -0.7;
    String label = '正面';
    String distance = '2-3米';

    final lowerDesc = desc.toLowerCase();

    // 解析位置方向
    if (lowerDesc.contains('侧面') || lowerDesc.contains('45')) {
      if (lowerDesc.contains('左')) {
        dx = -0.5;
        label = '左45°';
      } else if (lowerDesc.contains('右')) {
        dx = 0.5;
        label = '右45°';
      } else {
        dx = 0.5;
        label = '侧45°';
      }
      dy = -0.5;
    } else if (lowerDesc.contains('左前')) {
      dx = -0.5;
      dy = -0.6;
      label = '左前';
    } else if (lowerDesc.contains('右前')) {
      dx = 0.5;
      dy = -0.6;
      label = '右前';
    } else if (lowerDesc.contains('正面') || lowerDesc.contains('正对')) {
      dx = 0;
      dy = -0.7;
      label = '正面';
    } else if (lowerDesc.contains('背')) {
      dx = 0;
      dy = 0.7;
      label = '背面';
    } else if (lowerDesc.contains('侧')) {
      dx = 0.7;
      dy = 0;
      label = '侧面';
    }

    // 解析距离
    if (lowerDesc.contains('1-2米') || lowerDesc.contains('1.5')) {
      distance = '1-2米';
    } else if (lowerDesc.contains('2-3米') || lowerDesc.contains('2米')) {
      distance = '2-3米';
    } else if (lowerDesc.contains('3-5米') || lowerDesc.contains('3米')) {
      distance = '3-5米';
    } else if (lowerDesc.contains('5-8米') || lowerDesc.contains('5米')) {
      distance = '5-8米';
    }

    return (dx: dx, dy: dy, label: label, distance: distance);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 6.0;
    const gapLength = 4.0;
    final totalDistance = (end - start).distance;
    if (totalDistance == 0) return;
    
    final dx = (end.dx - start.dx) / totalDistance;
    final dy = (end.dy - start.dy) / totalDistance;

    double current = 0;
    while (current < totalDistance) {
      final segEnd = current + dashLength;
      canvas.drawLine(
        Offset(start.dx + dx * current, start.dy + dy * current),
        Offset(
          start.dx + dx * segEnd.clamp(0, totalDistance),
          start.dy + dy * segEnd.clamp(0, totalDistance),
        ),
        paint,
      );
      current = segEnd + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _TipPositionDiagramPainter oldDelegate) {
    return oldDelegate.description != description;
  }
}
