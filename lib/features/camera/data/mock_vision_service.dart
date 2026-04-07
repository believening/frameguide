import 'dart:typed_data';
import 'vision_ai_service.dart';
import '../models/scene_analysis.dart';

/// Mock AI 服务 - 用于开发和测试
/// 返回真实格式的假数据，方便 UI 开发
class MockVisionService implements VisionAIService {
  @override
  String get providerName => 'Mock (开发测试)';

  int _callCount = 0;

  static const _mockScenes = <Map<String, dynamic>>[
    {
      'scene': {
        'type': '咖啡馆',
        'lighting': '自然侧光从左侧窗户照入，光线柔和',
        'background': '简约风格咖啡厅，木质桌椅，绿植点缀',
        'features': ['靠窗座位', '自然光', '木质背景', '暖色调'],
      },
      'recommendations': [
        {
          'name': '窗边侧光半身',
          'position': '站到人物左侧（靠窗一侧），面对人物',
          'angle': '平拍',
          'height': '平视，手机与人物眼睛同高',
          'distance': '1-1.5 米',
          'framing': '半身',
          'reason': '利用窗户自然侧光，让面部有明暗过渡，立体感强',
          'difficulty': '简单',
          'proTip': '让人物微微转头朝向窗户，侧光会在脸颊形成漂亮的三角光',
        },
        {
          'name': '高角度俯拍',
          'position': '站到人物正前方，靠近一些',
          'angle': '俯拍',
          'height': '手机举高过头顶 30-45°',
          'distance': '0.8-1 米',
          'framing': '特写/半身',
          'reason': '俯拍显脸小，也能把咖啡和桌面拍进画面',
          'difficulty': '简单',
          'proTip': '让人物抬头看你，下巴微收，眼睛会更有神',
        },
        {
          'name': '远景环境人像',
          'position': '退到桌子对面或更远处',
          'angle': '平拍',
          'height': '平视',
          'distance': '2-3 米',
          'framing': '环境人像',
          'reason': '把咖啡厅氛围拍进去，人物和环境的融合更有故事感',
          'difficulty': '中等',
          'proTip': '等人物自然喝咖啡或看手机时抓拍，比摆拍更生动',
        },
      ],
      'overallTip': '咖啡馆靠窗座位是拍人像的黄金位置，侧光是天然的美颜灯',
    },
    {
      'scene': {
        'type': '公园户外',
        'lighting': '户外自然光，略有云层遮挡，光线均匀',
        'background': '绿树成荫，有开阔草坪和花丛',
        'features': ['开阔空间', '自然光', '绿色背景', '花丛'],
      },
      'recommendations': [
        {
          'name': '花丛前全身',
          'position': '站在花丛对面，人物站在花丛前 1 米',
          'angle': '平拍',
          'height': '蹲低至腰部，微微仰拍',
          'distance': '2-3 米',
          'framing': '全身',
          'reason': '蹲低仰拍显腿长，花丛做前景增加层次感',
          'difficulty': '简单',
          'proTip': '让人物在花丛前自然走动，连拍比摆拍更出片',
        },
        {
          'name': '树荫下半身',
          'position': '站到树荫边缘，面对人物',
          'angle': '平拍',
          'height': '平视',
          'distance': '1-1.5 米',
          'framing': '半身',
          'reason': '树荫过滤强光形成柔光效果，树叶缝隙漏下的光斑很漂亮',
          'difficulty': '中等',
          'proTip': '找树叶缝隙漏光的位置，光斑打在脸上就是天然的聚光灯',
        },
        {
          'name': '逆光剪影',
          'position': '站到人物和太阳之间，背对太阳拍',
          'angle': '平拍',
          'height': '蹲低',
          'distance': '3-5 米',
          'framing': '全身/环境',
          'reason': '逆光拍摄，人物轮廓被金色光线勾勒，画面浪漫',
          'difficulty': '高级',
          'proTip': '太阳角度低（日出后/日落前）时效果最好，点击人物脸部测光',
        },
      ],
      'overallTip': '户外拍摄避开正午强光，上午 10 点前和下午 4 点后是黄金时间',
    },
    {
      'scene': {
        'type': '室内家居',
        'lighting': '室内灯光为主，有窗户提供部分自然光',
        'background': '家居环境，沙发书架等家具',
        'features': ['温馨环境', '混合光源', '生活气息'],
      },
      'recommendations': [
        {
          'name': '沙发半身',
          'position': '站到沙发正前方或侧前方',
          'angle': '平拍',
          'height': '蹲低与沙发面同高',
          'distance': '1-1.5 米',
          'framing': '半身',
          'reason': '坐在沙发上最自然放松，背景简洁',
          'difficulty': '简单',
          'proTip': '让人物抱个靠枕或拿本书，手里有东西姿态更自然',
        },
        {
          'name': '窗边自然光',
          'position': '让人物坐到窗户旁边',
          'angle': '侧拍',
          'height': '平视',
          'distance': '1.5-2 米',
          'framing': '半身/全身',
          'reason': '窗户自然光是最好的室内光源，柔和有方向感',
          'difficulty': '中等',
          'proTip': '纱帘可以柔化光线，没有纱帘就用白纸或白布挡一下',
        },
      ],
      'overallTip': '室内拍照尽量靠近窗户，关掉顶灯只用自然光效果更干净',
    },
  ];

  @override
  Future<SceneAnalysis> analyzeScene(Uint8List imageBytes) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    final sceneData = _mockScenes[_callCount % _mockScenes.length];
    _callCount++;

    return _parseMockScene(sceneData);
  }

  @override
  Future<PhotoAnalysis> analyzePhoto(Uint8List imageBytes) async {
    await Future.delayed(const Duration(seconds: 1));

    return const PhotoAnalysis(
      score: 78,
      summary: '构图基本到位，主体清晰，背景稍显杂乱',
      strengths: ['人物位置居中偏左，符合三分法', '光线利用不错', '表情自然'],
      improvements: ['背景可以再简洁一些', '可以尝试更低的机位显腿长'],
      nextTimeTip: '下次可以蹲低一点仰拍，会更有气势',
    );
  }

  @override
  Future<bool> healthCheck() async {
    return true;
  }

  SceneAnalysis _parseMockScene(Map<String, dynamic> data) {
    final scene = data['scene'] as Map<String, dynamic>;
    final recs = data['recommendations'] as List<dynamic>;

    return SceneAnalysis(
      scene: SceneInfo(
        type: scene['type'] as String,
        lighting: scene['lighting'] as String,
        background: scene['background'] as String,
        features: (scene['features'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
      ),
      recommendations: recs.map((r) {
        final rec = r as Map<String, dynamic>;
        return PositionRecommendation(
          name: rec['name'] as String,
          position: rec['position'] as String,
          angle: rec['angle'] as String,
          height: rec['height'] as String,
          distance: rec['distance'] as String,
          framing: rec['framing'] as String,
          reason: rec['reason'] as String,
          difficulty: rec['difficulty'] as String,
          proTip: rec['proTip'] as String,
        );
      }).toList(),
      overallTip: data['overallTip'] as String,
      analyzedAt: DateTime.now(),
    );
  }
}
