import 'package:camera/camera.dart';
import 'photographer_ai_service.dart';

/// Web 平台的 ML 分析器（使用 Mock AI）
class MLCompositionAnalyzer {
  MLCompositionAnalyzer();

  Future<CompositionAnalysis> analyzeFrame(CameraImage image, int rotation) async {
    // Web 上使用 Mock AI
    return ProfessionalPhotographerAI.analyze();
  }

  void dispose() {}
}
