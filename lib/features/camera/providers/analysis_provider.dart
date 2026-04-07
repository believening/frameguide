import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/vision_ai_service.dart';
import '../data/glm_vision_service.dart';
import '../data/mock_vision_service.dart';
import '../models/scene_analysis.dart';

// ========== AI 服务配置 ==========

/// AI 供应商选择
enum AIProvider {
  mock('mock', '开发测试 (Mock)'),
  glm('glm', '智谱 GLM-4V');

  final String id;
  final String displayName;
  const AIProvider(this.id, this.displayName);

  static AIProvider fromId(String id) {
    return AIProvider.values.firstWhere(
      (p) => p.id == id,
      orElse: () => AIProvider.mock,
    );
  }
}

/// AI 服务配置
class AIServiceConfig {
  final AIProvider provider;
  final String apiKey;
  final String baseUrl;
  final String model;

  const AIServiceConfig({
    this.provider = AIProvider.mock,
    this.apiKey = '',
    this.baseUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
    this.model = 'glm-4v-flash',
  });

  AIServiceConfig copyWith({
    AIProvider? provider,
    String? apiKey,
    String? baseUrl,
    String? model,
  }) {
    return AIServiceConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
    );
  }

  /// 创建对应的 VisionAIService 实例
  VisionAIService createService() {
    switch (provider) {
      case AIProvider.glm:
        return GlmVisionService(
          apiKey: apiKey,
          baseUrl: baseUrl,
          model: model,
        );
      case AIProvider.mock:
        return MockVisionService();
    }
  }
}

/// AI 配置 Provider（持久化到 SharedPreferences）
class AIServiceConfigNotifier extends StateNotifier<AIServiceConfig> {
  static const _keyProvider = 'ai_provider';
  static const _keyApiKey = 'ai_api_key';
  static const _keyBaseUrl = 'ai_base_url';
  static const _keyModel = 'ai_model';

  AIServiceConfigNotifier() : super(const AIServiceConfig()) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    state = AIServiceConfig(
      provider: AIProvider.fromId(prefs.getString(_keyProvider) ?? 'mock'),
      apiKey: prefs.getString(_keyApiKey) ?? '',
      baseUrl: prefs.getString(_keyBaseUrl) ?? 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
      model: prefs.getString(_keyModel) ?? 'glm-4v-flash',
    );
  }

  Future<void> updateConfig(AIServiceConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProvider, config.provider.id);
    await prefs.setString(_keyApiKey, config.apiKey);
    await prefs.setString(_keyBaseUrl, config.baseUrl);
    await prefs.setString(_keyModel, config.model);
    state = config;
  }
}

final aiConfigProvider =
    StateNotifierProvider<AIServiceConfigNotifier, AIServiceConfig>(
  (ref) => AIServiceConfigNotifier(),
);

/// 当前 AI 服务实例（根据配置动态创建）
final visionAIProvider = Provider<VisionAIService>((ref) {
  final config = ref.watch(aiConfigProvider);
  return config.createService();
});

// ========== 场景分析状态管理 ==========

/// 场景分析状态管理
class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final VisionAIService _aiService;

  AnalysisNotifier(this._aiService) : super(const AnalysisState());

  /// 分析场景（从图片字节）
  Future<void> analyzeFromImage(Uint8List imageBytes) async {
    state = state.copyWith(status: AnalysisStatus.analyzing);

    try {
      // 压缩图片以减少 API 调用体积
      final compressed = _compressImage(imageBytes);

      final analysis = await _aiService.analyzeScene(compressed);
      state = state.copyWith(
        status: AnalysisStatus.success,
        analysis: analysis,
      );
    } catch (e) {
      state = state.copyWith(
        status: AnalysisStatus.error,
        error: e.toString(),
      );
    }
  }

  /// 选择推荐方案
  void selectRecommendation(int index) {
    if (state.analysis == null) return;
    final maxIndex = state.analysis!.recommendations.length - 1;
    state = state.copyWith(
      selectedRecommendation: index.clamp(0, maxIndex),
    );
  }

  /// 切换到下一个推荐方案
  void nextRecommendation() {
    if (state.analysis == null) return;
    final maxIndex = state.analysis!.recommendations.length - 1;
    final next = state.selectedRecommendation >= maxIndex
        ? 0
        : state.selectedRecommendation + 1;
    state = state.copyWith(selectedRecommendation: next);
  }

  /// 切换到上一个推荐方案
  void prevRecommendation() {
    if (state.analysis == null) return;
    final maxIndex = state.analysis!.recommendations.length - 1;
    final prev = state.selectedRecommendation <= 0
        ? maxIndex
        : state.selectedRecommendation - 1;
    state = state.copyWith(selectedRecommendation: prev);
  }

  /// 重置状态
  void reset() {
    state = const AnalysisState();
  }

  /// 简单压缩：如果图片太大就截取部分
  Uint8List _compressImage(Uint8List bytes) {
    // 超过 2MB 就做简单截断（实际项目中应该用 flutter_image_compress）
    const maxSize = 2 * 1024 * 1024; // 2MB
    if (bytes.length > maxSize) {
      // 截取前 2MB（JPEG 即使截断也能部分识别）
      // 更好的做法是用 image 包做 resize
      return bytes.sublist(0, maxSize);
    }
    return bytes;
  }
}

final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  final aiService = ref.watch(visionAIProvider);
  return AnalysisNotifier(aiService);
});
