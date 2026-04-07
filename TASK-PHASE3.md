# Phase 3 Task: 照片分析 + 相册

## 项目位置
`/home/believening/.openclaw/workspace-codes/frameguide`

## 背景
这是一个 Flutter 相机应用（FrameGuide），已经完成了 Phase 1（AI 场景分析）和 Phase 2（机位方向示意图 + 实时确认）。

现在需要实现 Phase 3：用户拍照后，AI 分析照片质量，并在相册中展示。

## 已有的基础设施

### AI 服务（已实现）
- `lib/features/camera/data/vision_ai_service.dart` - 抽象接口，有 `analyzePhoto(Uint8List)` 方法
- `lib/features/camera/data/glm_vision_service.dart` - GLM-4V 实现
- `lib/features/camera/data/mock_vision_service.dart` - Mock 实现
- `lib/features/camera/models/scene_analysis.dart` - 包含 `PhotoAnalysis` 模型：
  ```dart
  class PhotoAnalysis {
    final int score;           // 0-100
    final String summary;      // 一句话总结
    final List<String> strengths;   // 优点
    final List<String> improvements; // 改进建议
    final String nextTimeTip;  // 下次怎么拍更好
  }
  ```
- `lib/features/camera/providers/analysis_provider.dart` - 有 `visionAIProvider` 和 `aiConfigProvider`

### 已有但需重构的文件
- `lib/features/gallery/presentation/pages/gallery_page.dart` - 当前是空的/占位的
- `lib/features/gallery/providers/gallery_provider.dart` - 当前是空的/占位的

### 项目技术栈
- Flutter 3.27.0, Dart 3.2+
- flutter_riverpod 状态管理
- go_router 路由
- path_provider 本地路径
- shared_preferences 本地存储

## 需要实现的功能

### 1. 照片存储层
**文件:** `lib/features/gallery/data/photo_storage.dart`

- 保存照片文件到应用文档目录
- 保存/读取照片的分析元数据（JSON 文件，与照片同名 `.json` 后缀）
- 获取所有照片列表（按时间倒序）
- 删除照片及其元数据

数据模型：
```dart
class SavedPhoto {
  final String id;           // 时间戳
  final String filePath;     // 照片文件路径
  final DateTime takenAt;    // 拍摄时间
  final PhotoAnalysis? analysis; // AI 分析结果（可能还没分析）
  final String? sceneType;   // 场景类型（来自场景分析）
}
```

### 2. Gallery Provider
**文件:** `lib/features/gallery/providers/gallery_provider.dart`

- 加载照片列表
- 触发单张照片 AI 分析（调用 `visionAIProvider.analyzePhoto`）
- 保存分析结果
- 删除照片

### 3. 相册页面重构
**文件:** `lib/features/gallery/presentation/pages/gallery_page.dart`

- 照片网格（2列或3列，自适应）
- 每张照片右上角显示构图评分标签（颜色编码：绿/黄/红）
- 未分析的照片显示"待分析"标记
- 点击进入照片详情页
- 空状态提示（"还没有照片，去拍一张吧"）
- 下拉刷新

### 4. 照片详情页
**文件:** `lib/features/gallery/presentation/pages/photo_detail_page.dart`

- 照片全屏预览
- AI 分析报告卡片：
  - 评分（大数字 + 颜色）
  - 一句话总结
  - 优点列表（绿色图标）
  - 改进建议列表（橙色图标）
  - 下次拍摄建议
- "分析" 按钮（如果照片还没分析过）
- "重新分析" 按钮
- "删除" 按钮
- 返回按钮

### 5. 拍照后自动分析
**修改文件:** `lib/features/camera/presentation/pages/camera_page.dart`（在 `_takePicture()` 方法中）

- 拍照后保存照片到本地
- 自动触发 AI 分析
- 保存分析元数据
- 显示分析结果 Toast

## 设计规范

### 配色
- 主色：`#1A1A2E` (AppColors.primary)
- 强调色：`#FFD700` (AppColors.accent)
- 辅助色：`#16213E` (AppColors.secondary)
- 好：`#4CAF50` (AppColors.guidanceGood)
- 中：`#FFC107` (AppColors.guidanceAdjusting)
- 差：`#FF5252` (AppColors.guidanceFar)

### 间距
- 基础单位 8px，使用 AppDimensions 常量

### 风格
- 深色主题
- 简洁卡片式设计
- 与现有 camera_page 和 settings_page 保持一致

## 注意事项

1. **不要修改** `pubspec.yaml` 添加新依赖，除非真的需要
2. 导入路径使用相对路径
3. 所有 Widget 使用 `const` 构造函数
4. 遵循已有代码的组织方式（features/ 下按功能分目录）
5. 完成后运行 `flutter analyze` 确保无 error
6. AI 服务通过 `ref.read(visionAIProvider)` 获取，不要自己创建实例
