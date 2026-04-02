# FrameGuide - 智能机位推荐相机

## 1. 项目概述

**项目名称：** FrameGuide  
**项目类型：** Flutter 跨平台相机应用 (iOS + Android)  
**核心功能：** 实时取景时 AI 分析拍摄场景，智能推荐机位和角度，帮助用户获得最佳人像构图。

**目标用户：** 摄影初学者、自拍爱好者、社交媒体内容创作者

**技术路线：** Flutter + 云端 AI API（隐私优先可降级本地）

---

## 2. UI/UX 规格

### 2.1 页面结构

```
App
├── SplashScreen (启动页)
├── MainCameraPage (主相机页面)
│   ├── CameraPreview (摄像头预览 + 构图叠加层)
│   ├── CompositionOverlay (构图辅助线层)
│   ├── GuidanceOverlay (AI 指导层：箭头、文字)
│   └── ControlBar (底部控制栏)
├── GalleryPage (照片GalleryPage)
│   └── PhotoDetailPage (照片详情 + AI 分析报告)
└── SettingsPage (设置)
    ├── GridStyleSelector (构图线样式选择)
    ├── VoiceGuidanceToggle (语音指导开关)
    └── APIKeySettings (AI API 配置)
```

### 2.2 导航结构

- **底部 Tab 导航：** 相机 / 相册 / 设置
- 使用 `go_router` 管理路由

### 2.3 视觉规格

**配色方案：**
- 主色：`#1A1A2E` (深蓝黑)
- 强调色：`#FFD700` (金色 - 用于指导箭头、高亮)
- 辅助色：`#16213E` (深蓝)
- 文字色：`#FFFFFF` (白色)
- 半透明层：`rgba(0,0,0,0.5)`

**字体：**
- 主字体：系统默认
- 标题：16sp bold
- 指导文字：14sp medium
- 辅助信息：12sp regular

**间距系统：**
- 基础单位：8px
- 组件内边距：16px
- 组件间距：12px

### 2.4 构图辅助线样式

| 样式 | 描述 |
|------|------|
| 三分法 | 2等分横线 + 2等分竖线 |
| 黄金比例 | 螺旋辅助线 |
| 对角线 | 两条对角参考线 |
| 中心点 | 十字中心 + 圆形标记 |

### 2.5 AI 指导交互

**视觉反馈：**
- 半透明箭头指向调整方向
- 距离目标位置的百分比显示
- 颜色编码：绿色=good, 黄色=adjusting, 红色=far

**语音反馈：**
- "往左移" / "往上一点" / "俯角更好"
- 开关可控制

---

## 3. 功能规格

### 3.1 核心功能 (MVP)

#### F1: 实时相机预览
- 全屏摄像头预览
- 支持前后摄像头切换
- 横竖屏自适应

#### F2: 构图辅助线叠加
- 多种构图线样式可选
- 实时叠加在预览画面上
- 不影响实际拍照

#### F3: AI 场景分析 (云端)
- 拍摄前实时分析画面
- 检测人像位置、姿态、比例
- 计算当前构图评分

#### F4: 机位/角度指导
- 基于分析结果，UI 叠加方向箭头
- 文字提示具体调整建议
- 可选语音播报

#### F5: 拍照保存
- 快门按钮拍照
- 保存原图到本地 Gallery
- 同时保存 AI 分析元数据

#### F6: 照片 AI 分析报告
- 查看历史照片的 AI 分析
- 显示拍摄时的构图评分
- 提供改进建议

### 3.2 AI API 设计

**接口：** 云端 REST API（可配置 endpoint）

**请求：**
```json
{
  "image_base64": "...",
  "scene_type": "portrait",
  "analysis_type": "composition"
}
```

**响应：**
```json
{
  "score": 72,
  "detections": [
    {
      "type": "person",
      "bbox": {"x": 0.4, "y": 0.3, "w": 0.2, "h": 0.5},
      "pose": "standing"
    }
  ],
  "guidance": {
    "direction": "left",
    "distance": 0.15,
    "angle": "down"
  },
  "tips": ["人物偏右，建议向左移动"]
}
```

**本地 Mock 模式：**
- 无网络时使用本地模拟响应
- 演示用

### 3.3 状态管理

使用 **Riverpod** 进行状态管理：

```
providers/
├── camera_provider.dart (摄像头状态)
├── composition_provider.dart (构图设置)
├── ai_analysis_provider.dart (AI 分析结果)
├── guidance_provider.dart (当前指导状态)
└── settings_provider.dart (用户设置)
```

### 3.4 权限

- 相机权限 (camera)
- 相册/存储权限 (photos)
- 麦克风权限 (microphone) - 仅语音反馈时

---

## 4. 技术架构

### 4.1 项目结构

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   └── dimensions.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── permission_utils.dart
├── features/
│   ├── camera/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── main_camera_page.dart
│   │   │   └── widgets/
│   │   │       ├── camera_preview.dart
│   │   │       ├── composition_overlay.dart
│   │   │       ├── guidance_overlay.dart
│   │   │       └── control_bar.dart
│   │   ├── providers/
│   │   │   └── camera_provider.dart
│   │   └── data/
│   │       └── camera_repository.dart
│   ├── gallery/
│   │   ├── presentation/
│   │   └── providers/
│   ├── analysis/
│   │   ├── data/
│   │   │   └── ai_api_client.dart
│   │   └── providers/
│   │       └── ai_analysis_provider.dart
│   └── settings/
│       ├── presentation/
│       └── providers/
│           └── settings_provider.dart
└── shared/
    └── widgets/
        └── common_button.dart
```

### 4.2 依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  # 相机
  camera: ^0.11.0
  # 状态管理
  flutter_riverpod: ^2.4.9
  # 导航
  go_router: ^13.0.0
  # 本地存储
  shared_preferences: ^2.2.2
  # 图片相关
  image_picker: ^1.0.7
  path_provider: ^2.1.2
  # UI
  google_fonts: ^6.1.0
  flutter_animate: ^4.3.0
  # 网络
  http: ^1.2.0
```

### 4.3 AI API 预留

当前版本使用本地 Mock，未来可接入：
- OpenAI Vision API
- 阿里云视觉智能
- 腾讯云 AI 视觉
- 自建模型服务

---

## 5. MVP 里程碑

### M1: 基础相机功能
- 相机预览 ✅
- 构图辅助线叠加 ✅
- 拍照保存

### M2: AI 指导 (Mock)
- 本地 Mock AI 响应
- 方向箭头 UI
- 指导文字显示

### M3: AI 云端集成
- API 客户端实现
- 真实 AI 服务对接
- 语音反馈

### M4: Gallery & 设置
- 照片浏览
- AI 分析报告
- 设置页面

---

## 6. 设计决策记录

| 日期 | 决策 | 原因 |
|------|------|------|
| 2026-04-02 | Flutter 跨平台 | 用户要求双平台 |
| 2026-04-02 | Riverpod 状态管理 | Flutter 官方推荐，简洁 |
| 2026-04-02 | 云端 AI + 本地 Mock | 初期快速验证，云端效果更强 |
| 2026-04-02 | 人像场景优先 | 用户明确需求 |
