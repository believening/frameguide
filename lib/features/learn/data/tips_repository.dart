import '../models/shooting_tip.dart';

/// 场景标签枚举
enum SceneTag {
  indoor('室内'),
  outdoor('户外'),
  portrait('人像'),
  selfie('自拍'),
  group('合影'),
  halfBody('半身照'),
  fullBody('全身照'),
  cafe('咖啡馆'),
  home('家居'),
  office('办公'),
  birthday('生日派对'),
  park('公园'),
  street('街头'),
  travel('旅行'),
  beach('海滩'),
  mountain('山景'),
  night('夜景'),
  backlight('逆光'),
  rainy('雨天'),
  food('美食'),
  flower('花卉'),
  fresh('清新自然'),
  vintage('复古胶片'),
  premium('高级感');

  final String label;
  const SceneTag(this.label);
}

/// 风格标签
enum StyleTag {
  fresh('清新自然'),
  vintage('复古胶片'),
  premium('高级感'),
  natural('自然'),
  artistic('艺术感');

  final String label;
  const StyleTag(this.label);
}

/// 难度等级
enum Difficulty {
  easy('简单'),
  medium('中等'),
  advanced('高级');

  final String label;
  const Difficulty(this.label);
}

/// 技巧库仓库
class TipsRepository {
  TipsRepository._();

  static final TipsRepository instance = TipsRepository._();

  /// 所有技巧列表
  final List<ShootingTip> _tips = const [
    // === 室内人像 ===
    ShootingTip(
      id: 'tip_001',
      title: '咖啡馆靠窗人像',
      sceneTags: ['室内', '人像', '咖啡馆'],
      difficulty: '简单',
      style: '清新自然',
      positionDiagram: '俯视: 人物坐在窗边，拍摄者在侧面45度，距离2-3米',
      keyPoints: [
        '选择靠窗位置，自然光从侧面照射',
        '让模特脸部转向光源方向',
        '使用大光圈虚化背景',
        '适当提高ISO保证快门速度',
      ],
      focalLength: '50mm',
      aperture: 'f/1.8 - f/2.8',
      exampleDesc: '阳光透过窗帘洒在模特侧脸，背景虚化的咖啡馆氛围感照片',
      relatedTipIds: ['tip_002', 'tip_005'],
    ),
    ShootingTip(
      id: 'tip_002',
      title: '家居温馨人像',
      sceneTags: ['室内', '人像', '家居'],
      difficulty: '简单',
      style: '温馨舒适',
      positionDiagram: '俯视: 人物在沙发/床边，拍摄者正前方或侧前方，距离1.5-2米',
      keyPoints: [
        '利用自然光，打开窗帘让阳光进来',
        '选择干净的背景避免杂乱',
        '让模特放松自然，表情生动',
        '可以借助抱枕、毛毯等道具',
      ],
      focalLength: '35mm',
      aperture: 'f/2.0 - f/2.8',
      exampleDesc: '阳光明媚的午后，模特靠在沙发上，表情放松愉悦的家庭照',
      relatedTipIds: ['tip_001', 'tip_003'],
    ),
    ShootingTip(
      id: 'tip_003',
      title: '办公场景职业照',
      sceneTags: ['室内', '人像', '办公'],
      difficulty: '中等',
      style: '专业简洁',
      positionDiagram: '俯视: 人物站在办公桌前，拍摄者正对面，距离2米左右',
      keyPoints: [
        '背景选择书架或简洁墙面',
        '光线均匀，避免强烈阴影',
        '模特站姿端正，肩膀打开',
        '可使用反光板补光',
      ],
      focalLength: '50mm',
      aperture: 'f/2.8',
      exampleDesc: '专业干练的职场人像，背景虚化突出人物主体',
      relatedTipIds: ['tip_002', 'tip_006'],
    ),
    ShootingTip(
      id: 'tip_004',
      title: '生日派对庆祝照',
      sceneTags: ['室内', '人像', '生日派对'],
      difficulty: '简单',
      style: '活泼欢乐',
      positionDiagram: '俯视: 人物围坐蛋糕旁，拍摄者高角度俯拍，距离2-3米',
      keyPoints: [
        '捕捉吹蜡烛或许愿的瞬间',
        '可用彩色气球/彩带做装饰',
        '暖色调灯光营造氛围',
        '连拍模式抓取自然表情',
      ],
      focalLength: '35mm',
      aperture: 'f/2.0',
      exampleDesc: '朋友围坐一圈，为寿星庆祝的温馨欢乐场面',
      relatedTipIds: ['tip_010', 'tip_011'],
    ),

    // === 户外人像 ===
    ShootingTip(
      id: 'tip_005',
      title: '公园草地人像',
      sceneTags: ['户外', '人像', '公园'],
      difficulty: '简单',
      style: '清新自然',
      positionDiagram: '俯视: 人物站在草地中央，拍摄者低角度仰拍，距离3-5米',
      keyPoints: [
        '选择清晨或傍晚柔和光线',
        '蹲下用低角度拍出天空背景',
        '让模特与背景绿色形成对比',
        '风吹过时捕捉头发飘动',
      ],
      focalLength: '85mm',
      aperture: 'f/1.8 - f/2.2',
      exampleDesc: '蓝天白云下，模特站在绿草地上，飘逸的发丝充满动感',
      relatedTipIds: ['tip_001', 'tip_006'],
    ),
    ShootingTip(
      id: 'tip_006',
      title: '街头时尚人像',
      sceneTags: ['户外', '人像', '街头'],
      difficulty: '中等',
      style: '高级感',
      positionDiagram: '俯视: 人物站在街边，拍摄者对面街道，距离5-8米',
      keyPoints: [
        '选择有特色的建筑或涂鸦墙前',
        '广角镜头增加环境感',
        '注意背景行人，耐心等待空镜',
        '可用框架构图增加层次',
      ],
      focalLength: '35mm',
      aperture: 'f/2.8',
      exampleDesc: '时尚达人站在霓虹灯下，潮流感十足的街拍照片',
      relatedTipIds: ['tip_007', 'tip_008'],
    ),
    ShootingTip(
      id: 'tip_007',
      title: '旅行打卡人像',
      sceneTags: ['户外', '人像', '旅行'],
      difficulty: '简单',
      style: '自然',
      positionDiagram: '俯视: 人物站在景点前，拍摄者正面或侧面45度，距离视景点大小',
      keyPoints: [
        '人物占画面1/3到1/2',
        '人物头顶留白适当',
        '尽量避开路人，可多拍几张',
        '广角镜头收入更多场景',
      ],
      focalLength: '24-70mm',
      aperture: 'f/8',
      exampleDesc: '在埃菲尔铁塔前留影，完美的人景结合照片',
      relatedTipIds: ['tip_006', 'tip_008'],
    ),
    ShootingTip(
      id: 'tip_008',
      title: '海滩浪漫人像',
      sceneTags: ['户外', '人像', '海滩'],
      difficulty: '中等',
      style: '浪漫',
      positionDiagram: '俯视: 人物面向大海，拍摄者侧面，距离3-4米',
      keyPoints: [
        '黄金时段拍摄，光线柔和',
        '利用海风让裙摆飘动',
        '适当过曝营造梦幻感',
        '小心海水和沙子损坏设备',
      ],
      focalLength: '85mm',
      aperture: 'f/2.0',
      exampleDesc: '夕阳下的海边，裙摆随风飘起，画面唯美浪漫',
      relatedTipIds: ['tip_005', 'tip_009'],
    ),
    ShootingTip(
      id: 'tip_009',
      title: '山景壮阔人像',
      sceneTags: ['户外', '人像', '山景'],
      difficulty: '中等',
      style: '大气',
      positionDiagram: '俯视: 人物站在山崖边，拍摄者背后低角度，距离2-3米',
      keyPoints: [
        '注意安全，选择安全观景点',
        '用山峦作为背景增加层次',
        '清晨云海或傍晚夕阳最佳',
        '广角展现大场景氛围',
      ],
      focalLength: '24mm',
      aperture: 'f/8 - f/11',
      exampleDesc: '站在山顶眺望远方，云海翻涌，气势磅礴',
      relatedTipIds: ['tip_008', 'tip_007'],
    ),

    // === 特殊场景 ===
    ShootingTip(
      id: 'tip_010',
      title: '城市夜景人像',
      sceneTags: ['户外', '夜景', '人像'],
      difficulty: '高级',
      style: '高级感',
      positionDiagram: '俯视: 人物站在霓虹灯下，拍摄者对面，距离2-3米',
      keyPoints: [
        '使用大光圈镜头保证进光量',
        '寻找色彩丰富的灯光背景',
        '适当提亮面部，避免脸黑',
        '使用补光灯或手机闪光灯',
      ],
      focalLength: '50mm',
      aperture: 'f/1.4 - f/1.8',
      exampleDesc: '霓虹灯闪烁的街头，背景虚化成彩色光斑',
      relatedTipIds: ['tip_011', 'tip_006'],
    ),
    ShootingTip(
      id: 'tip_011',
      title: '逆光温柔人像',
      sceneTags: ['户外', '逆光', '人像'],
      difficulty: '中等',
      style: '温柔',
      positionDiagram: '俯视: 太阳在模特身后，拍摄者正面面对模特，距离2-3米',
      keyPoints: [
        '用模特遮挡强光，避免直射',
        '适当补光或拉高曝光',
        '可拍出好看的轮廓光',
        '选择太阳角度低时拍摄',
      ],
      focalLength: '85mm',
      aperture: 'f/2.0 - f/2.8',
      exampleDesc: '夕阳逆光下，发丝被阳光点亮，温暖治愈的感觉',
      relatedTipIds: ['tip_008', 'tip_010'],
    ),
    ShootingTip(
      id: 'tip_012',
      title: '雨天氛围人像',
      sceneTags: ['户外', '雨天', '人像'],
      difficulty: '高级',
      style: '文艺',
      positionDiagram: '俯视: 人物撑伞站在雨中，拍摄者侧面，距离2-3米',
      keyPoints: [
        '使用雨伞作为道具',
        '可拍雨滴、积水倒影',
        '注意相机防水保护',
        '调低色温营造冷色调氛围',
      ],
      focalLength: '50mm',
      aperture: 'f/2.0',
      exampleDesc: '雨中漫步的文艺女生，积水倒影增添意境',
      relatedTipIds: ['tip_011', 'tip_013'],
    ),
    ShootingTip(
      id: 'tip_013',
      title: '美食摄影技巧',
      sceneTags: ['室内', '美食'],
      difficulty: '中等',
      style: '食欲感',
      positionDiagram: '俯视: 食物平铺桌面，拍摄者正上方，距离50-80cm',
      keyPoints: [
        '自然光是最好的光源',
        '45度角是经典视角',
        '可用喷水增加食物光泽',
        '背景简洁，突出主体',
      ],
      focalLength: '50mm',
      aperture: 'f/2.8 - f/4',
      exampleDesc: '精致的甜点从上方俯拍，色彩鲜艳令人食欲大开',
      relatedTipIds: ['tip_014', 'tip_004'],
    ),
    ShootingTip(
      id: 'tip_014',
      title: '花卉人像',
      sceneTags: ['户外', '花卉', '人像'],
      difficulty: '简单',
      style: '清新自然',
      positionDiagram: '俯视: 人物置身花丛中，拍摄者正面，距离2-3米',
      keyPoints: [
        '选择盛花期前往',
        '用花朵作为前景虚化',
        '避免花朵遮挡脸部',
        '浅色衣服与花更搭配',
      ],
      focalLength: '85mm',
      aperture: 'f/1.8 - f/2.2',
      exampleDesc: '樱花树下，模特被粉白色花瓣包围，浪漫唯美',
      relatedTipIds: ['tip_005', 'tip_001'],
    ),

    // === 人像类型 ===
    ShootingTip(
      id: 'tip_015',
      title: '完美自拍指南',
      sceneTags: ['自拍'],
      difficulty: '简单',
      style: '自然',
      positionDiagram: '俯视: 手持手机，45度俯角，距离30-50cm',
      keyPoints: [
        '寻找好光线，避免脸部落阴影',
        '45度角比正脸更显瘦',
        '自然放松的表情最上镜',
        '背景简洁或虚化',
      ],
      focalLength: '手机广角',
      aperture: 'f/2.0',
      exampleDesc: '午后窗边自拍，光线柔和，皮肤显得通透',
      relatedTipIds: ['tip_001', 'tip_016'],
    ),
    ShootingTip(
      id: 'tip_016',
      title: '多人合影技巧',
      sceneTags: ['合影'],
      difficulty: '中等',
      style: '温馨',
      positionDiagram: '俯视: 人物排成弧形，拍摄者正面，距离视人数调整',
      keyPoints: [
        '使用三脚架或找人代拍',
        '安排高矮错落有致',
        '统一表情和视线方向',
        '连拍多张选最佳',
      ],
      focalLength: '35mm',
      aperture: 'f/4 - f/5.6',
      exampleDesc: '一家人整整齐齐，在海边留下的温馨合影',
      relatedTipIds: ['tip_004', 'tip_007'],
    ),
    ShootingTip(
      id: 'tip_017',
      title: '半身照特写',
      sceneTags: ['人像', '半身照'],
      difficulty: '简单',
      style: '高级感',
      positionDiagram: '俯视: 人物腰部以上，拍摄者正面，距离1.5-2米',
      keyPoints: [
        '肩膀打开，避免正对镜头',
        '手臂与身体保持距离显瘦',
        '手部自然下垂或轻触身体',
        '眼神交流，表情生动',
      ],
      focalLength: '85mm',
      aperture: 'f/1.8 - f/2.2',
      exampleDesc: '精致妆容的特写，背景虚化，突出人物神态',
      relatedTipIds: ['tip_005', 'tip_018'],
    ),
    ShootingTip(
      id: 'tip_018',
      title: '全身照显高秘诀',
      sceneTags: ['人像', '全身照'],
      difficulty: '中等',
      style: '高级感',
      positionDiagram: '俯视: 人物全身入镜，拍摄者低角度，距离3-5米',
      keyPoints: [
        '低角度仰拍显腿长',
        '脚部贴近画面底部',
        '一条腿微微前伸',
        '穿高腰裤或裙子更佳',
      ],
      focalLength: '50mm',
      aperture: 'f/2.8',
      exampleDesc: '大长腿效果显著，人物气质优雅挺拔',
      relatedTipIds: ['tip_017', 'tip_006'],
    ),

    // === 风格专题 ===
    ShootingTip(
      id: 'tip_019',
      title: '清新自然风格',
      sceneTags: ['人像', '清新自然'],
      difficulty: '简单',
      style: '清新自然',
      positionDiagram: '俯视: 自然环境人像，拍摄者灵活选择位置',
      keyPoints: [
        '选择自然环境作为背景',
        '柔和光线，避免强烈阴影',
        '模特表情自然放松',
        '服装选择浅色系',
      ],
      focalLength: '50-85mm',
      aperture: 'f/1.8 - f/2.2',
      exampleDesc: '阳光明媚的户外，模特笑容灿烂，青春洋溢',
      relatedTipIds: ['tip_005', 'tip_014'],
    ),
    ShootingTip(
      id: 'tip_020',
      title: '复古胶片风格',
      sceneTags: ['人像', '复古胶片'],
      difficulty: '中等',
      style: '复古胶片',
      positionDiagram: '俯视: 复古城市场景，拍摄者灵活选择位置',
      keyPoints: [
        '选择有年代感的场景',
        '可降低饱和度增加复古感',
        '暖色调或低饱和度调色',
        '4:5或3:2画幅更有味道',
      ],
      focalLength: '50mm',
      aperture: 'f/2.8',
      exampleDesc: '老式公交站台，复古装扮，仿佛穿越回80年代',
      relatedTipIds: ['tip_006', 'tip_021'],
    ),
    ShootingTip(
      id: 'tip_021',
      title: '高级感大片风格',
      sceneTags: ['人像', '高级感'],
      difficulty: '高级',
      style: '高级感',
      positionDiagram: '俯视: 极简背景，拍摄者正面或侧面，距离2-3米',
      keyPoints: [
        '纯色背景或极简构图',
        '精准曝光，控制光比',
        '模特姿势大方优雅',
        '可尝试黑白或低饱和调色',
      ],
      focalLength: '85mm',
      aperture: 'f/2.0 - f/2.8',
      exampleDesc: '纯黑背景，人物眼神坚定，气场全开',
      relatedTipIds: ['tip_020', 'tip_017'],
    ),
    ShootingTip(
      id: 'tip_022',
      title: '私房写真指南',
      sceneTags: ['室内', '人像', '家居'],
      difficulty: '高级',
      style: '艺术感',
      positionDiagram: '俯视: 柔和暖光环境，拍摄者灵活选择位置',
      keyPoints: [
        '选择有氛围感的室内环境',
        '可用窗帘营造柔和光线',
        '模特姿势自然慵懒',
        '注意隐私和适度',
      ],
      focalLength: '35-50mm',
      aperture: 'f/1.8 - f/2.0',
      exampleDesc: '午后阳光透过纱帘，营造慵懒私密的氛围感',
      relatedTipIds: ['tip_002', 'tip_022'],
    ),
    ShootingTip(
      id: 'tip_023',
      title: '夜景人像进阶',
      sceneTags: ['户外', '夜景', '人像'],
      difficulty: '高级',
      style: '高级感',
      positionDiagram: '俯视: 城市灯光背景，拍摄者与模特保持3-4米',
      keyPoints: [
        '使用补光灯照亮面部',
        '慢速同步闪光技术',
        '背景灯光虚化成光斑',
        '注意人物与背景的光比平衡',
      ],
      focalLength: '50mm',
      aperture: 'f/1.4 - f/1.8',
      exampleDesc: '璀璨城市夜景下，人物清晰背景梦幻',
      relatedTipIds: ['tip_010', 'tip_011'],
    ),
  ];

  /// 获取所有技巧
  List<ShootingTip> getAllTips() => List.unmodifiable(_tips);

  /// 根据ID获取技巧
  ShootingTip? getTipById(String id) {
    try {
      return _tips.firstWhere((tip) => tip.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 根据场景标签筛选
  List<ShootingTip> getTipsBySceneTag(String tag) {
    return _tips.where((tip) => tip.sceneTags.contains(tag)).toList();
  }

  /// 根据难度筛选
  List<ShootingTip> getTipsByDifficulty(String difficulty) {
    return _tips.where((tip) => tip.difficulty == difficulty).toList();
  }

  /// 根据风格筛选
  List<ShootingTip> getTipsByStyle(String style) {
    return _tips.where((tip) => tip.style == style).toList();
  }

  /// 获取相关技巧
  List<ShootingTip> getRelatedTips(List<String> ids) {
    return ids.map((id) => getTipById(id)).whereType<ShootingTip>().toList();
  }

  /// 搜索技巧
  List<ShootingTip> searchTips(String query) {
    final q = query.toLowerCase();
    return _tips.where((tip) {
      return tip.title.toLowerCase().contains(q) ||
          tip.sceneTags.any((tag) => tag.toLowerCase().contains(q)) ||
          tip.style.toLowerCase().contains(q) ||
          tip.keyPoints.any((point) => point.toLowerCase().contains(q));
    }).toList();
  }

  /// 获取所有场景标签
  List<String> getAllSceneTags() {
    final tags = <String>{};
    for (final tip in _tips) {
      tags.addAll(tip.sceneTags);
    }
    return tags.toList()..sort();
  }

  /// 获取技巧数量
  int get tipCount => _tips.length;
}
