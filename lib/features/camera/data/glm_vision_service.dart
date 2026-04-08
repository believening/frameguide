import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'vision_ai_service.dart';
import '../models/scene_analysis.dart';

/// GLM-4V (智谱) 视觉 AI 服务实现
class GlmVisionService implements VisionAIService {
  final String apiKey;
  final String baseUrl;
  final String model;

  GlmVisionService({
    required this.apiKey,
    this.baseUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
    this.model = 'glm-4v-flash',
  });

  @override
  String get providerName => 'GLM-4V ($model)';

  static const String _sceneAnalysisPrompt = '''你是一位专业人像摄影师。用户正在准备拍一张人像照片，请你分析当前画面中的场景并给出拍摄机位建议。

请严格以 JSON 格式回复（不要包含 markdown 代码块标记）：
{
  "scene": {
    "type": "场景类型（如：咖啡馆、公园、街头、室内、夜景、海边等）",
    "lighting": "光线条件描述（如：自然侧光、顶灯照明、逆光等）",
    "background": "背景描述（简洁描述主要元素）",
    "features": ["场景特征1", "场景特征2"]
  },
  "recommendations": [
    {
      "name": "方案名称（简洁，如：窗边侧光半身）",
      "position": "具体站位（如：人物左前方1.5米）",
      "angle": "拍摄角度（仰拍/平拍/俯拍/侧拍）",
      "height": "手机高度（举高过头顶/平视/蹲低至腰部/放地面）",
      "distance": "建议距离（如：1-1.5米）",
      "framing": "取景范围（特写/半身/全身/环境人像）",
      "reason": "为什么这么拍（一句话，面向普通用户）",
      "difficulty": "简单",
      "proTip": "一个专业小技巧"
    }
  ],
  "overallTip": "关于这个场景的一句话总体建议"
}

要求：
1. 给出 2-3 个不同难度的方案（从简单到高级）
2. 建议要非常具体可执行（不要说"找好角度"，要说"站到XX位置，手机举高30°"）
3. 考虑光线方向对人物的影响
4. 考虑背景的利用和规避
5. 如果画面中没有人，也给出准备拍摄的建议
6. difficulty 只能是：简单、中等、高级''';

  static const String _photoAnalysisPrompt = '''你是一位专业摄影师，请分析这张照片的拍摄质量，特别是构图方面。

请严格以 JSON 格式回复（不要包含 markdown 代码块标记）：
{
  "score": 75,
  "summary": "一句话总结这张照片",
  "strengths": ["优点1", "优点2"],
  "improvements": ["改进建议1", "改进建议2"],
  "nextTimeTip": "下次拍摄的建议"
}

要求：
1. score 范围 0-100
2. 优点 1-3 条
3. 改进建议 1-3 条，要具体可操作
4. nextTimeTip 是给普通用户的实用建议''';

  @override
  Future<SceneAnalysis> analyzeScene(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    final mimeType = _inferMimeType(imageBytes);

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                },
              },
              {
                'type': 'text',
                'text': _sceneAnalysisPrompt,
              },
            ],
          },
        ],
        'temperature': 0.7,
        'max_tokens': 2048,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
        'GLM API error: ${response.statusCode} - ${response.body}',
      );
    }

    final json = jsonDecode(response.body);
    final content = json['choices'][0]['message']['content'] as String;
    return _parseSceneAnalysis(content);
  }

  @override
  Future<PhotoAnalysis> analyzePhoto(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    final mimeType = _inferMimeType(imageBytes);

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                },
              },
              {
                'type': 'text',
                'text': _photoAnalysisPrompt,
              },
            ],
          },
        ],
        'temperature': 0.7,
        'max_tokens': 1024,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
        'GLM API error: ${response.statusCode} - ${response.body}',
      );
    }

    final json = jsonDecode(response.body);
    final content = json['choices'][0]['message']['content'] as String;
    return _parsePhotoAnalysis(content);
  }

  @override
  Future<bool> healthCheck() async {
    try {
      // 发一个简单请求验证 API Key
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': '你好'},
          ],
          'max_tokens': 10,
        }),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 解析场景分析 JSON
  SceneAnalysis _parseSceneAnalysis(String content) {
    // 尝试提取 JSON（可能被 markdown 代码块包裹）
    final jsonStr = _extractJson(content);
    final data = jsonDecode(jsonStr);

    final sceneData = data['scene'] as Map<String, dynamic>;
    final recsData = data['recommendations'] as List<dynamic>;

    return SceneAnalysis(
      scene: SceneInfo(
        type: sceneData['type'] as String? ?? '未知',
        lighting: sceneData['lighting'] as String? ?? '',
        background: sceneData['background'] as String? ?? '',
        features: (sceneData['features'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      ),
      recommendations: recsData.map((r) {
        final rec = r as Map<String, dynamic>;
        return PositionRecommendation(
          name: rec['name'] as String? ?? '方案',
          position: rec['position'] as String? ?? '',
          angle: rec['angle'] as String? ?? '',
          height: rec['height'] as String? ?? '',
          distance: rec['distance'] as String? ?? '',
          framing: rec['framing'] as String? ?? '',
          reason: rec['reason'] as String? ?? '',
          difficulty: rec['difficulty'] as String? ?? '中等',
          proTip: rec['proTip'] as String? ?? '',
        );
      }).toList(),
      overallTip: data['overallTip'] as String? ?? '',
      analyzedAt: DateTime.now(),
    );
  }

  /// 解析照片分析 JSON
  PhotoAnalysis _parsePhotoAnalysis(String content) {
    final jsonStr = _extractJson(content);
    final data = jsonDecode(jsonStr);

    return PhotoAnalysis(
      score: (data['score'] as num?)?.toInt() ?? 50,
      summary: data['summary'] as String? ?? '',
      strengths: (data['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      improvements: (data['improvements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      nextTimeTip: data['nextTimeTip'] as String? ?? '',
    );
  }

  /// 从可能的 markdown 代码块中提取 JSON
  String _extractJson(String content) {
    // 去掉 ```json ... ``` 包裹
    final regex = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final match = regex.firstMatch(content);
    if (match != null) {
      return match.group(1)!.trim();
    }
    // 尝试直接找 { }
    final start = content.indexOf('{');
    final end = content.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return content.substring(start, end + 1);
    }
    return content.trim();
  }

  /// 根据 magic bytes 推断 MIME 类型
  String _inferMimeType(Uint8List bytes) {
    if (bytes.length < 4) return 'image/jpeg';
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return 'image/png';
    }
    // WebP: 52 49 46 46
    if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) {
      return 'image/webp';
    }
    // Default JPEG
    return 'image/jpeg';
  }
}
