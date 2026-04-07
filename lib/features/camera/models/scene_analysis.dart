import 'dart:typed_data';
import 'package:flutter/material.dart';

/// 场景分析结果
class SceneAnalysis {
  final SceneInfo scene;
  final List<PositionRecommendation> recommendations;
  final String overallTip;
  final DateTime analyzedAt;

  const SceneAnalysis({
    required this.scene,
    required this.recommendations,
    required this.overallTip,
    required this.analyzedAt,
  });

  factory SceneAnalysis.empty() => SceneAnalysis(
        scene: const SceneInfo(
          type: '未知',
          lighting: '',
          background: '',
          features: [],
        ),
        recommendations: [],
        overallTip: '',
        analyzedAt: DateTime.now(),
      );

  bool get isEmpty => recommendations.isEmpty;
}

/// 场景信息
class SceneInfo {
  final String type;       // 咖啡馆/公园/街头/室内/夜景/...
  final String lighting;   // 光线条件
  final String background; // 背景描述
  final List<String> features; // 场景特征

  const SceneInfo({
    required this.type,
    required this.lighting,
    required this.background,
    required this.features,
  });
}

/// 机位推荐方案
class PositionRecommendation {
  final String name;          // 方案名称
  final String position;      // 具体站位描述
  final String angle;         // 拍摄角度（仰拍/平拍/俯拍/侧拍）
  final String height;        // 手机高度（举高/平视/蹲低/放地面）
  final String distance;      // 建议距离
  final String framing;       // 取景范围（特写/半身/全身/环境人像）
  final String reason;        // 为什么这么拍
  final String difficulty;    // 简单/中等/高级
  final String proTip;        // 专业提示
  final IconData? icon;       // 图标（本地映射）

  const PositionRecommendation({
    required this.name,
    required this.position,
    required this.angle,
    required this.height,
    required this.distance,
    required this.framing,
    required this.reason,
    required this.difficulty,
    required this.proTip,
    this.icon,
  });

  /// 难度颜色
  Color get difficultyColor {
    switch (difficulty) {
      case '简单':
        return const Color(0xFF4CAF50);
      case '中等':
        return const Color(0xFFFFC107);
      case '高级':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// 难度图标
  IconData get difficultyIcon {
    switch (difficulty) {
      case '简单':
        return Icons.sentiment_satisfied;
      case '中等':
        return Icons.sentiment_neutral;
      case '高级':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }
}

/// AI 分析状态
enum AnalysisStatus {
  idle,        // 空闲
  capturing,   // 截帧中
  analyzing,   // AI 分析中
  success,     // 分析成功
  error,       // 分析失败
}

/// 分析状态数据
class AnalysisState {
  final AnalysisStatus status;
  final SceneAnalysis? analysis;
  final int selectedRecommendation; // 当前选中的推荐方案索引
  final String? error;

  const AnalysisState({
    this.status = AnalysisStatus.idle,
    this.analysis,
    this.selectedRecommendation = 0,
    this.error,
  });

  AnalysisState copyWith({
    AnalysisStatus? status,
    SceneAnalysis? analysis,
    int? selectedRecommendation,
    String? error,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      analysis: analysis ?? this.analysis,
      selectedRecommendation:
          selectedRecommendation ?? this.selectedRecommendation,
      error: error,
    );
  }

  /// 当前选中的推荐方案
  PositionRecommendation? get currentRecommendation {
    if (analysis == null || analysis!.recommendations.isEmpty) return null;
    final index = selectedRecommendation.clamp(
      0,
      analysis!.recommendations.length - 1,
    );
    return analysis!.recommendations[index];
  }
}

/// 照片分析结果
class PhotoAnalysis {
  final int score;
  final String summary;          // 一句话总结
  final List<String> strengths;  // 优点
  final List<String> improvements; // 改进建议
  final String nextTimeTip;      // 下次怎么拍更好

  const PhotoAnalysis({
    required this.score,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.nextTimeTip,
  });
}
