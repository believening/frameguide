/// 拍摄技巧数据模型
class ShootingTip {
  final String id;
  final String title;
  final List<String> sceneTags;
  final String difficulty;
  final String style;
  final String positionDiagram;
  final List<String> keyPoints;
  final String? focalLength;
  final String? aperture;
  final String exampleDesc;
  final List<String> relatedTipIds;

  const ShootingTip({
    required this.id,
    required this.title,
    required this.sceneTags,
    required this.difficulty,
    required this.style,
    required this.positionDiagram,
    required this.keyPoints,
    this.focalLength,
    this.aperture,
    required this.exampleDesc,
    required this.relatedTipIds,
  });
}
