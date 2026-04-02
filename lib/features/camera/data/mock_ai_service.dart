import 'dart:math';
import 'dart:ui';

/// AI composition analysis result
class CompositionAnalysis {
  final int score;
  final String tip;
  final GuidanceDirection direction;
  final double distance;

  /// Simulated detected face bounding box (normalized 0-1)
  final Rect? faceRect;

  /// Simulated face pose
  final String? facePose;

  const CompositionAnalysis({
    required this.score,
    required this.tip,
    required this.direction,
    required this.distance,
    this.faceRect,
    this.facePose,
  });
}

enum GuidanceDirection {
  none,
  left,
  right,
  up,
  down,
  upLeft,
  upRight,
  downLeft,
  downRight
}

extension GuidanceDirectionExtension on GuidanceDirection {
  String get text {
    switch (this) {
      case GuidanceDirection.none:
        return '';
      case GuidanceDirection.left:
        return '往左移';
      case GuidanceDirection.right:
        return '往右移';
      case GuidanceDirection.up:
        return '往上移';
      case GuidanceDirection.down:
        return '往下移';
      case GuidanceDirection.upLeft:
        return '往左上移';
      case GuidanceDirection.upRight:
        return '往右上移';
      case GuidanceDirection.downLeft:
        return '往左下移';
      case GuidanceDirection.downRight:
        return '往右下移';
    }
  }

  Offset get offset {
    switch (this) {
      case GuidanceDirection.none:
        return Offset.zero;
      case GuidanceDirection.left:
        return const Offset(-50, 0);
      case GuidanceDirection.right:
        return const Offset(50, 0);
      case GuidanceDirection.up:
        return const Offset(0, -50);
      case GuidanceDirection.down:
        return const Offset(0, 50);
      case GuidanceDirection.upLeft:
        return const Offset(-40, -40);
      case GuidanceDirection.upRight:
        return const Offset(40, -40);
      case GuidanceDirection.downLeft:
        return const Offset(-40, 40);
      case GuidanceDirection.downRight:
        return const Offset(40, 40);
    }
  }
}

/// Abstract interface for AI composition analysis
abstract class AIAnalysisService {
  Future<CompositionAnalysis> analyzeImage();
  void dispose();
}

/// Mock AI analysis service with improved portrait analysis simulation
class MockAIService implements AIAnalysisService {
  static final Random _random = Random();

  // Simulated face state that drifts slowly, creating natural movement
  double _faceCenterX = 0.5;
  double _faceCenterY = 0.4;
  double _faceWidth = 0.2;
  double _faceHeight = 0.3;
  @override
  Future<CompositionAnalysis> analyzeImage() async {
    // Simulate face drifting with smooth random walk
    _faceCenterX += (_random.nextDouble() - 0.5) * 0.04;
    _faceCenterY += (_random.nextDouble() - 0.5) * 0.03;
    _faceCenterX = _faceCenterX.clamp(0.15, 0.85);
    _faceCenterY = _faceCenterY.clamp(0.15, 0.75);

    // Slight face size variation
    _faceWidth = (0.18 + _random.nextDouble() * 0.06).clamp(0.15, 0.25);
    _faceHeight = (_faceWidth * 1.3).clamp(0.2, 0.35);

    final faceRect = Rect.fromCenter(
      center: Offset(_faceCenterX, _faceCenterY),
      width: _faceWidth,
      height: _faceHeight,
    );

    // Calculate composition score based on face position
    final score = _calculateScore(faceRect);
    final direction = _calculateDirection(faceRect);
    final tip = _generateTip(score, faceRect, direction);

    return CompositionAnalysis(
      score: score,
      tip: tip,
      direction: direction,
      distance: _calculateDistance(faceRect),
      faceRect: faceRect,
      facePose: _getRandomPose(),
    );
  }

  int _calculateScore(Rect faceRect) {
    int score = 70;

    // Rule of thirds bonus: face near intersection points
    final thirdsX = [1 / 3, 2 / 3];
    final thirdsY = [1 / 3, 2 / 3];
    bool nearThirdsX = thirdsX.any((x) => (faceRect.center.dx - x).abs() < 0.1);
    bool nearThirdsY = thirdsY.any((y) => (faceRect.center.dy - y).abs() < 0.1);
    if (nearThirdsX && nearThirdsY) {
      score += 15;
    } else if (nearThirdsX || nearThirdsY) {
      score += 8;
    }

    // Center penalty (too centered is less interesting for portraits)
    final distFromCenter =
        (faceRect.center.dx - 0.5).abs() + (faceRect.center.dy - 0.45).abs();
    if (distFromCenter < 0.08) {
      score -= 5;
    }

    // Top-headroom check (face should be in upper portion with room above)
    if (faceRect.top > 0.05 && faceRect.top < 0.3) {
      score += 5;
    } else if (faceRect.top < 0.05) {
      score -= 10; // too high, cut off
    }

    // Face size check (not too small, not too large)
    if (faceRect.width > 0.15 && faceRect.width < 0.3) {
      score += 5;
    } else if (faceRect.width > 0.35) {
      score -= 10; // too close
    } else if (faceRect.width < 0.12) {
      score -= 10; // too far
    }

    // Add small random variation
    score += _random.nextInt(7) - 3;

    return score.clamp(30, 98);
  }

  GuidanceDirection _calculateDirection(Rect faceRect) {
    // Determine ideal position (rule of thirds left or right intersection)
    final targetX = faceRect.center.dx < 0.5 ? 1 / 3 : 2 / 3;
    const targetY = 1 / 3;

    final dx = targetX - faceRect.center.dx;
    final dy = targetY - faceRect.center.dy;

    // Threshold for "close enough"
    if (dx.abs() < 0.06 && dy.abs() < 0.06) {
      return GuidanceDirection.none;
    }

    const threshold = 0.03;
    bool goLeft = dx < -threshold;
    bool goRight = dx > threshold;
    bool goUp = dy < -threshold;
    bool goDown = dy > threshold;

    if (goLeft && goUp) return GuidanceDirection.upLeft;
    if (goLeft && goDown) return GuidanceDirection.downLeft;
    if (goRight && goUp) return GuidanceDirection.upRight;
    if (goRight && goDown) return GuidanceDirection.downRight;
    if (goLeft) return GuidanceDirection.left;
    if (goRight) return GuidanceDirection.right;
    if (goUp) return GuidanceDirection.up;
    if (goDown) return GuidanceDirection.down;

    return GuidanceDirection.none;
  }

  double _calculateDistance(Rect faceRect) {
    final targetX = faceRect.center.dx < 0.5 ? 1 / 3 : 2 / 3;
    const targetY = 1 / 3;
    final dx = targetX - faceRect.center.dx;
    final dy = targetY - faceRect.center.dy;
    return sqrt(dx * dx + dy * dy);
  }

  String _generateTip(int score, Rect faceRect, GuidanceDirection direction) {
    if (direction == GuidanceDirection.none) {
      return _getGoodTip();
    }

    if (score >= 80) {
      return '构图不错，可以微微调整';
    }

    if (score >= 65) {
      if (faceRect.center.dx < 0.4) {
        return '人物偏左，建议右移使人物靠近三分线';
      } else if (faceRect.center.dx > 0.6) {
        return '人物偏右，建议左移使人物靠近三分线';
      }
      if (faceRect.top < 0.1) {
        return '人物太高，留些顶部空间会更好';
      }
      return '轻微调整构图会更好';
    }

    if (faceRect.width > 0.35) {
      return '离得太近了，建议后退一些';
    }
    if (faceRect.width < 0.12) {
      return '离得太远了，建议靠近一些';
    }
    if (faceRect.top < 0.05) {
      return '人物头顶被裁切，建议下移镜头';
    }
    return '建议调整机位和角度';
  }

  String _getGoodTip() {
    const tips = [
      '构图不错，保持当前角度',
      '很好！人物位置接近三分线',
      '构图均衡，可以拍摄了',
      '人物比例和位置都不错',
    ];
    return tips[_random.nextInt(tips.length)];
  }

  String _getRandomPose() {
    const poses = ['正面', '微侧', '侧面', '仰角', '俯角'];
    return poses[_random.nextInt(poses.length)];
  }

  @override
  void dispose() {
    // No resources to clean up in mock
  }
}
