import 'package:camera/camera.dart';
import 'photographer_ai_service.dart';

/// Stub ML 分析器
class MLCompositionAnalyzer {
  MLCompositionAnalyzer();

  Future<CompositionAnalysis> analyzeFrame(CameraImage image, int rotation) async {
    return ProfessionalPhotographerAI.analyze();
  }

  void dispose() {}
}
