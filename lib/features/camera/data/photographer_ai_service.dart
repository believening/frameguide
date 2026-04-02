import 'dart:math';

/// 摄影师视角的构图分析结果
class CompositionAnalysis {
  final int score;
  final String tip;
  final List<Guidance> guidances;
  final String photographerNote;

  const CompositionAnalysis({
    required this.score,
    required this.tip,
    required this.guidances,
    required this.photographerNote,
  });
}

/// 单条指导
class Guidance {
  final GuidanceType type;
  final String direction;
  final String instruction;
  final double priority;

  const Guidance({
    required this.type,
    required this.direction,
    required this.instruction,
    required this.priority,
  });
}

enum GuidanceType {
  moveHorizontal,  // 水平移动
  moveVertical,     // 垂直移动（前后）
  adjustHeight,     // 调整高度（蹲下/站起）
  adjustAngle,      // 调整拍摄角度
  zoom,             // 焦距调整
  recompose,        // 重新构图
}

extension GuidanceTypeExtension on GuidanceType {
  String get text {
    switch (this) {
      case GuidanceType.moveHorizontal:
        return '水平移动';
      case GuidanceType.moveVertical:
        return '前后移动';
      case GuidanceType.adjustHeight:
        return '调整高度';
      case GuidanceType.adjustAngle:
        return '调整角度';
      case GuidanceType.zoom:
        return '焦距';
      case GuidanceType.recompose:
        return '重新构图';
    }
  }
}

/// 专业摄影师 Mock AI 服务
class ProfessionalPhotographerAI {
  static final Random _random = Random();

  /// 摄影师指导语料库
  static const _photographerTips = [
    "试试低角度仰拍，可以让人物显得更有气场",
    "稍微后退一点，背景太紧会让画面显得压抑",
    "让人物往左移一点，右侧留白会更舒服",
    "尝试俯拍角度，45度往往是最保险的人像视角",
    "站高一点，俯拍可以显脸小",
    "试试侧光或逆光，光线会让照片更有层次",
    "靠近一点，主体更突出，背景自然虚化",
    "让人物转动身体30度，比正面照更显瘦",
    "尝试三分法，把眼睛放在三分线交点",
    "背景太杂乱，试试拉近或换个角度",
    "试试把手机放低一些，低角度显腿长",
    "让人物微微抬头，下巴会更尖",
    "注意光斑，避免阳光直射镜头产生眩光",
    "试试黄金螺旋构图，视觉焦点更吸引人",
    "靠近窗户用自然光，比闪光灯更柔和",
  ];

  /// 专业术语解释
  static const _techniqueNotes = {
    '三分法': '将画面横竖各分三等份，主体放在交叉点上',
    '黄金比例': '1:1.618的比例分割，螺旋构图引导视线',
    '俯拍': '相机从上往下拍，显得人更小巧',
    '仰拍': '相机从下往上拍，显得人更高大有气场',
    '45度角': '斜侧光角度，最立体的人像光线',
    '三分线交点': '四条线交叉的四个点，是画面的视觉焦点',
  };

  /// 位置建议
  static const _positionAdjustments = [
    '往左移动半步',
    '往右移动半步',
    '稍微往前一点',
    '往后一步试试',
    '站高一点',
    '稍微蹲下',
    '向左转一点身体',
    '向右转30度',
    '头部稍微歪一下',
    '抬眼看镜头',
  ];

  /// 分析画面并给出专业摄影师建议
  static CompositionAnalysis analyze() {
    final directions = [
      GuidanceDirection.left,
      GuidanceDirection.right,
      GuidanceDirection.up,
      GuidanceDirection.down,
      GuidanceDirection.upLeft,
      GuidanceDirection.upRight,
      GuidanceDirection.downLeft,
      GuidanceDirection.downRight,
    ];

    // 随机选择主要移动方向
    final primaryDirection = directions[_random.nextInt(directions.length)];
    final secondaryDirection = directions[_random.nextInt(directions.length)];

    // 生成综合评分（60-90分，模拟真实场景）
    final baseScore = 55 + _random.nextInt(30);
    final score = baseScore.clamp(0, 100);

    // 根据评分生成不同级别的建议
    List<Guidance> guidances = [];
    String overallTip;
    String photographerNote;

    if (score >= 85) {
      overallTip = '构图很棒！保持这个位置';
      photographerNote = _getExcellentNote();
      guidances = [
        Guidance(
          type: GuidanceType.recompose,
          direction: '',
          instruction: '保持当前机位，稍微微调',
          priority: 0.9,
        ),
      ];
    } else if (score >= 70) {
      overallTip = '基本到位，再调整一下会更好';
      photographerNote = _getGoodNote();
      guidances = [
        Guidance(
          type: _random.nextBool()
              ? GuidanceType.moveHorizontal
              : GuidanceType.moveVertical,
          direction: primaryDirection.text,
          instruction: _getAdjustmentInstruction(primaryDirection),
          priority: 0.8,
        ),
        Guidance(
          type: GuidanceType.adjustHeight,
          direction: secondaryDirection.text,
          instruction: _getHeightAdvice(),
          priority: 0.6,
        ),
      ];
    } else {
      overallTip = '需要调整机位以获得最佳构图';
      photographerNote = _getNeedsWorkNote();
      guidances = [
        Guidance(
          type: GuidanceType.moveHorizontal,
          direction: primaryDirection.text,
          instruction: _getAdjustmentInstruction(primaryDirection),
          priority: 0.9,
        ),
        Guidance(
          type: GuidanceType.moveVertical,
          direction: secondaryDirection.text,
          instruction: secondaryDirection == GuidanceDirection.up
              ? '稍微后退一点'
              : '往前走一步',
          priority: 0.8,
        ),
        Guidance(
          type: GuidanceType.adjustHeight,
          direction: '',
          instruction: _getHeightAdvice(),
          priority: 0.7,
        ),
        Guidance(
          type: GuidanceType.adjustAngle,
          direction: '',
          instruction: _getAngleAdvice(),
          priority: 0.5,
        ),
      ];
    }

    return CompositionAnalysis(
      score: score,
      tip: overallTip,
      guidances: guidances,
      photographerNote: photographerNote,
    );
  }

  static String _getAdjustmentInstruction(GuidanceDirection direction) {
    switch (direction) {
      case GuidanceDirection.left:
        return '往左移动一步，让主体偏左';
      case GuidanceDirection.right:
        return '往右移动一步，让主体偏右';
      case GuidanceDirection.up:
        return '往前走半步';
      case GuidanceDirection.down:
        return '往后退一步';
      case GuidanceDirection.upLeft:
        return '往前半步并向左转';
      case GuidanceDirection.upRight:
        return '往前半步并向右转';
      case GuidanceDirection.downLeft:
        return '往后退半步并向左调整';
      case GuidanceDirection.downRight:
        return '往后退半步并向右调整';
      case GuidanceDirection.none:
        return '保持不动';
    }
  }

  static String _getHeightAdvice() {
    final advices = [
      '试试站高一点，俯拍更显瘦',
      '稍微蹲下一点，仰拍更有气场',
      '保持眼睛在同一高度',
      '试试把手机举高一点',
    ];
    return advices[_random.nextInt(advices.length)];
  }

  static String _getAngleAdvice() {
    final advices = [
      '试试45度侧脸，光影更立体',
      '让人物稍微低一下头',
      '尝试微微仰头',
      '侧身30度比正面更显瘦',
      '让人物转动身体找到最佳角度',
    ];
    return advices[_random.nextInt(advices.length)];
  }

  static String _getExcellentNote() {
    final notes = [
      '完美！这个光线和角度非常出色',
      '构图很专业，保持这个感觉',
      '背景虚化到位，主体突出',
      '眼神光很漂亮，抓住了最佳瞬间',
    ];
    return notes[_random.nextInt(notes.length)];
  }

  static String _getGoodNote() {
    final notes = [
      '整体不错，注意一下光线的方向',
      '基本构图到位，可以尝试更多角度',
      '背景选择很好',
      '试试让人物放松表情',
    ];
    return notes[_random.nextInt(notes.length)];
  }

  static String _getNeedsWorkNote() {
    final notes = [
      '尝试换个角度，背景有点杂',
      '光线太硬了，找个有遮挡的地方',
      '机位太高或太低都会影响脸型',
      '试试让人物远离背景，虚化效果更好',
    ];
    return notes[_random.nextInt(notes.length)];
  }

  /// 获取随机摄影师技巧提示
  static String getRandomTip() {
    return _photographerTips[_random.nextInt(_photographerTips.length)];
  }

  /// 获取术语解释
  static String? getTechniqueNote(String term) {
    return _techniqueNotes[term];
  }
}

enum GuidanceDirection { none, left, right, up, down, upLeft, upRight, downLeft, downRight }

extension GuidanceDirectionExtension on GuidanceDirection {
  String get text {
    switch (this) {
      case GuidanceDirection.none:
        return '';
      case GuidanceDirection.left:
        return '往左';
      case GuidanceDirection.right:
        return '往右';
      case GuidanceDirection.up:
        return '往前';
      case GuidanceDirection.down:
        return '往后';
      case GuidanceDirection.upLeft:
        return '往左前';
      case GuidanceDirection.upRight:
        return '往右前';
      case GuidanceDirection.downLeft:
        return '往左后';
      case GuidanceDirection.downRight:
        return '往右后';
    }
  }

  String get moveText {
    switch (this) {
      case GuidanceDirection.none:
        return '保持不动';
      case GuidanceDirection.left:
        return '向左移动';
      case GuidanceDirection.right:
        return '向右移动';
      case GuidanceDirection.up:
        return '向前移动';
      case GuidanceDirection.down:
        return '向后移动';
      case GuidanceDirection.upLeft:
        return '向左前方移动';
      case GuidanceDirection.upRight:
        return '向右前方移动';
      case GuidanceDirection.downLeft:
        return '向左后方移动';
      case GuidanceDirection.downRight:
        return '向右后方移动';
    }
  }
}
