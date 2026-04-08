import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../models/scene_analysis.dart';

/// 机位方向示意图 - 用俯视图展示推荐站位和拍摄方向
class PositionDiagram extends StatelessWidget {
  final PositionRecommendation recommendation;

  const PositionDiagram({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _PositionDiagramPainter(recommendation),
    );
  }
}

class _PositionDiagramPainter extends CustomPainter {
  final PositionRecommendation rec;

  _PositionDiagramPainter(this.rec);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.65);

    // 背景
    final bgPaint = Paint()..color = AppColors.primary.withOpacity(0.8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 网格线
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // 人物位置（俯视图，用圆表示）
    final personPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final personFillPaint = Paint()..color = Colors.white.withOpacity(0.15);

    canvas.drawCircle(center, 18, personPaint);
    canvas.drawCircle(center, 18, personFillPaint);

    // 人物标签
    final personLabelPainter = TextPainter(
      text: const TextSpan(text: '👤', style: TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
    )..layout();
    personLabelPainter.paint(
      canvas,
      Offset(center.dx - personLabelPainter.width / 2,
          center.dy - personLabelPainter.height / 2),
    );

    // 计算拍摄者位置（基于 angle 和 position）
    final shooterInfo = _parseShooterPosition();
    final shooterOffset = Offset(
      center.dx + shooterInfo.dx * size.width * 0.35,
      center.dy + shooterInfo.dy * size.height * 0.45,
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
    final anglePaint = Paint()..color = AppColors.accent.withOpacity(0.1);
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
    final shooterPaint = Paint()..color = AppColors.accent;
    canvas.drawCircle(shooterOffset, 12, shooterPaint);

    final phonePainter = TextPainter(
      text: const TextSpan(text: '📱', style: TextStyle(fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    phonePainter.paint(
      canvas,
      Offset(shooterOffset.dx - phonePainter.width / 2,
          shooterOffset.dy - phonePainter.height / 2),
    );

    // 高度指示器（右侧）
    _drawHeightIndicator(canvas, size, rec.height);

    // 角度文字标签
    final angleLabelPainter = TextPainter(
      text: TextSpan(
        text: rec.angle,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // 标签位置在拍摄方向线中点
    final midPoint = Offset(
      (shooterOffset.dx + center.dx) / 2,
      (shooterOffset.dy + center.dy) / 2 - 14,
    );

    final labelBgPaint = Paint()..color = AppColors.primary.withOpacity(0.9);
    final labelBgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: midPoint,
        width: angleLabelPainter.width + 8,
        height: angleLabelPainter.height + 4,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(labelBgRect, labelBgPaint);
    angleLabelPainter.paint(
      canvas,
      Offset(midPoint.dx - angleLabelPainter.width / 2,
          midPoint.dy - angleLabelPainter.height / 2),
    );

    // 距离标签
    final distLabelPainter = TextPainter(
      text: TextSpan(
        text: rec.distance,
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    distLabelPainter.paint(
      canvas,
      Offset(center.dx - distLabelPainter.width / 2, center.dy + 24),
    );
  }

  ({double dx, double dy}) _parseShooterPosition() {
    final pos = rec.position;
    final angle = rec.angle;

    double dx = 0;
    double dy = -0.7;

    if (pos.contains('左前')) {
      dx = -0.5;
      dy = -0.6;
    } else if (pos.contains('右前')) {
      dx = 0.5;
      dy = -0.6;
    } else if (pos.contains('左') && !pos.contains('前方')) {
      dx = -0.7;
      dy = 0;
    } else if (pos.contains('右') && !pos.contains('前方')) {
      dx = 0.7;
      dy = 0;
    } else if (pos.contains('正前方') || pos.contains('面对')) {
      dx = 0;
      dy = -0.7;
    } else if (pos.contains('对面') || pos.contains('退到')) {
      dx = 0;
      dy = -0.8;
    }

    if (angle.contains('俯')) {
      dy += 0.05;
    } else if (angle.contains('仰')) {
      dy -= 0.05;
    }

    return (dx: dx, dy: dy);
  }

  void _drawHeightIndicator(Canvas canvas, Size size, String height) {
    final x = size.width - 30;
    const top = 20.0;
    final bottom = size.height - 20.0;
    final mid = (top + bottom) / 2;

    final linePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(Offset(x, top), Offset(x, bottom), linePaint);

    for (final y in [top, mid, bottom]) {
      canvas.drawLine(Offset(x - 4, y), Offset(x + 4, y), linePaint);
    }

    double markY;
    String label;
    if (height.contains('举高') || height.contains('过头顶')) {
      markY = top + 10;
      label = '举高';
    } else if (height.contains('蹲低') || height.contains('腰部')) {
      markY = bottom - 10;
      label = '蹲低';
    } else if (height.contains('地面')) {
      markY = bottom;
      label = '地面';
    } else {
      markY = mid;
      label = '平视';
    }

    final markPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2;
    canvas.drawLine(Offset(x - 8, markY), Offset(x + 8, markY), markPaint);
    canvas.drawCircle(Offset(x, markY), 4, markPaint);

    final heightPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: AppColors.accent, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    heightPainter.paint(canvas, Offset(x - heightPainter.width / 2, markY - 16));
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
  bool shouldRepaint(covariant _PositionDiagramPainter oldDelegate) {
    return oldDelegate.rec != rec;
  }
}
