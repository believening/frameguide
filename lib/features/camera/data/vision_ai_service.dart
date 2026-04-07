import 'dart:typed_data';
import '../models/scene_analysis.dart';

/// AI 视觉服务抽象接口
/// 所有 AI 供应商实现此接口，上层代码不依赖具体供应商
abstract class VisionAIService {
  /// 供应商名称（用于日志和调试）
  String get providerName;

  /// 分析场景，返回机位推荐
  Future<SceneAnalysis> analyzeScene(Uint8List imageBytes);

  /// 分析已拍照片，返回评分和改进建议
  Future<PhotoAnalysis> analyzePhoto(Uint8List imageBytes);

  /// 健康检查（验证 API Key 是否有效）
  Future<bool> healthCheck();
}
