# FrameGuide 全面 Code Review 报告

**日期**: 2026-04-07
**审查工具**: Claude Code (via ACP)
**项目**: AI 驱动的人像摄影指导 Flutter 应用

---

## 一、项目概览

FrameGuide 是一个 AI 驱动的人像摄影指导 Flutter 应用，使用 Riverpod 状态管理 + go_router 路由 + ML Kit 本地分析 + GLM-4V 云端 AI。功能模块：相机、相册、学习、设置。

---

## 二、项目结构与架构

### 优点
- **Feature-first 架构清晰**：每个功能模块有 data / models / providers / presentation 分层
- **AI 服务抽象合理**：`VisionAIService` 接口 + 多实现（GLM / Mock），方便扩展
- **平台条件导入**：ML Kit 使用 stub/mobile/web 三套实现，处理得当
- **设计系统统一**：`AppColors` + `AppDimensions` + `AppTheme` 集中管理

### 问题

**1. 存在两个同名 `MainCameraPage` 类（严重）**

| 文件 | 说明 |
|------|------|
| `presentation/pages/main_camera_page.dart` | v2 重构版，277行，使用 SceneAnalysis 模型 |
| `presentation/pages/camera_page.dart` | 旧版，410行，使用 CompositionAnalysis 模型 |

两个文件都定义了 `class MainCameraPage`，**会导致编译冲突或导出歧义**。`camera_page.dart` 还通过 `export` 导出了 `photographer_ai_service.dart` 和 `ml_composition_analyzer.dart`，进一步加剧混乱。

**2. 重复的模型定义（严重）**

`GuidanceDirection` 枚举和 `GuidanceDirectionExtension` 在三个地方各自定义了一遍：
- `mock_ai_service.dart:27-85`
- `photographer_ai_service.dart:290-338`

而且两个扩展的 `.text` 返回值**不一致**（如 `left` 在一个里返回 `'往左移'`，另一个返回 `'往左'`）。

`CompositionAnalysis` 类也定义了两个**不同结构**的版本：
- `mock_ai_service.dart` — 含 `direction`, `distance`, `faceRect`, `facePose`
- `photographer_ai_service.dart` — 含 `guidances: List<Guidance>`, `photographerNote`

---

## 三、严重 Bug

### Bug 1：图片"压缩"实际会损坏图片
**文件**：`analysis_provider.dart:177-186`

```dart
Uint8List _compressImage(Uint8List bytes) {
  const maxSize = 2 * 1024 * 1024;
  if (bytes.length > maxSize) {
    return bytes.sublist(0, maxSize); // 截断 JPEG 字节 → 产生损坏的图片
  }
  return bytes;
}
```

`bytes.sublist(0, maxSize)` 只是粗暴截断字节数组，会产生**损坏的 JPEG**。注释说"JPEG 即使截断也能部分识别"，但传给 AI API 很可能导致解析失败。应使用 `flutter_image_compress` 或 `image` 包做真正的 resize/压缩。

### Bug 2：Camera Controller 生命周期泄漏
**文件**：`main_camera_page.dart:49-53`

```dart
if (state == AppLifecycleState.inactive) {
  cameraState.controller?.dispose();  // dispose 了 controller
} else if (state == AppLifecycleState.resumed) {
  _initCamera();  // 重新初始化
}
```

问题：dispose 后 provider 仍然持有已销毁的 controller 引用。`_initCamera` 会创建新 controller，但在新 controller 初始化完成之前，UI 可能尝试使用旧的已销毁 controller，导致 `CameraException`。

### Bug 3：`camera_page.dart` 中拍照后未恢复 imageStream
**文件**：`camera_page.dart:162`

```dart
await cameraState.controller!.stopImageStream(); // 拍照前停止
// ...拍照...
Future.delayed(const Duration(milliseconds: 500), () {
  _startImageAnalysis(); // 500ms 后恢复
});
```

`Future.delayed` 回调不检查 `mounted`，且如果用户快速连续操作，可能产生多个并行 imageStream。

### Bug 4：静默用假数据掩盖错误
**文件**：`main_camera_page.dart:74-79`

```dart
} catch (e) {
  debugPrint('截帧失败，使用 Mock: $e');
  final mockBytes = Uint8List(100);
  ref.read(analysisProvider.notifier).analyzeFromImage(mockBytes);
}
```

截帧失败时发送 100 字节的假数据给 AI 服务。用户看到的是基于假数据的结果，却以为是真的分析。应该给用户明确的错误提示。

### Bug 5：Camera 分辨率设置无效
**文件**：`camera_provider.dart:72-74`

```dart
final controller = CameraController(
  camera,
  ResolutionPreset.high,  // 硬编码为 high
  enableAudio: false,
);
```

虽然有 `cameraResolutionProvider` 和 `CameraResolution` 枚举，但初始化时完全没用到，始终使用 `ResolutionPreset.high`（720p）。

---

## 四、代码质量问题

### 1. 硬编码中文字符串，无国际化支持
全项目散布硬编码中文：`'分析场景'`、`'照片已保存'`、`'相机初始化失败'` 等。应使用 `flutter_localizations` + ARB 文件。

### 2. 大量 `!` 强制解包
```dart
cameraState.controller!.takePicture()  // 多处使用
json['choices'][0]['message']['content'] as String  // GLM 服务中
```
应使用 null 安全模式或提前校验。

### 3. GLM 服务无请求超时
`glm_vision_service.dart` 中的 `http.post` 没有设置 timeout，网络差时可能永远挂起。应加 `timeout` 参数。

### 4. API Key 明文存储
API Key 存在 `SharedPreferences` 中，无加密。应使用 `flutter_secure_storage`。

### 5. 魔法数字
```dart
final int _analysisFrameSkip = 15;        // 为什么是15？
Timer.periodic(const Duration(seconds: 2)); // 为什么是2秒？
await Future.delayed(const Duration(milliseconds: 500)); // 为什么500ms？
```

### 6. 测试覆盖为零
`test/` 目录下只有默认的 widget_test 桩文件，核心业务逻辑（AI 解析、相机管理、照片存储）完全没有测试。

---

## 五、改进建议（按优先级）

### P0 - 必须修复

| # | 问题 | 建议 |
|---|------|------|
| 1 | 两个同名 `MainCameraPage` 类 | 删除旧版 `camera_page.dart`，只保留重构版 |
| 2 | 重复的 `GuidanceDirection` / `CompositionAnalysis` | 抽取到 `core/models/` 或 `features/camera/models/` 作为共享定义 |
| 3 | 图片截断"压缩" | 引入 `flutter_image_compress` 做真正的压缩 |
| 4 | Camera Controller 生命周期 | dispose 后立即将 provider state 重置为 `isInitialized: false` |
| 5 | 假数据掩盖错误 | 改为显示用户友好的错误提示，不要静默发送假数据 |

### P1 - 应该修复

| # | 问题 | 建议 |
|---|------|------|
| 6 | 分辨率设置无效 | 将 `CameraResolution` 映射到 `ResolutionPreset`，并在 `_setupCamera` 中使用 |
| 7 | GLM 请求无超时 | 添加 `.timeout(const Duration(seconds: 30))` |
| 8 | API Key 明文存储 | 改用 `flutter_secure_storage` |
| 9 | 学习进度不持久化 | 将 `LearningState` 存入 `SharedPreferences` 或 SQLite |
| 10 | 缺少单元测试 | 优先为 AI JSON 解析、评分算法、存储逻辑添加测试 |

### P2 - 建议改进

| # | 问题 | 建议 |
|---|------|------|
| 11 | 无国际化 | 引入 `flutter_localizations` + ARB |
| 12 | PositionDiagram 重复实现 | 合并 camera/ 和 learn/ 下的 `position_diagram.dart` |
| 13 | `ref.listen` 监听整个 gallery | 使用 `select` 只监听特定 photo 的变化 |
| 14 | 无障碍支持 | 为自定义 Widget 添加 `Semantics` 标签 |
| 15 | 错误处理不一致 | 统一错误处理策略，考虑引入 `AsyncValue` 模式 |

---

## 六、总结

FrameGuide 的**架构设计思路良好**（feature-first、AI 服务抽象、条件导入），但在**工程落地质量**上存在明显不足：

- **编译级问题**：同名类 + 重复模型定义会影响构建
- **运行时 Bug**：图片损坏、controller 泄漏、假数据掩盖错误是实际功能缺陷
- **质量基础设施缺失**：零测试、无超时、明文存 key

建议先集中解决 P0 的 5 个问题，再补齐测试覆盖。
