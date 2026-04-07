# FrameGuide v2 - 智能机位推荐相机

## 1. 重新定义问题

**用户的痛点不是"构图微调"，而是"我站在哪里拍"。**

市面上相机 App 解决的是"拍出来好不好看"（滤镜、美颜），
FrameGuide 要解决的是"怎么拍"——站在哪、什么角度、多远距离。

**核心体验：**
> 打开 App → AI 看一眼场景 → 告诉你"站到左前方 2 米，蹲低仰拍" → 你走过去 → 实时构图确认 → 拍

---

## 2. 产品分层（渐进式体验）

### Layer 1: 场景识别 + 机位推荐（核心差异化）

**用户举起手机对准场景 → AI 给出完整拍摄方案**

```
输入：相机实时画面（截帧）
输出：
  - 场景类型：室内/户外/街拍/夜景/自然风光/咖啡馆...
  - 推荐机位方案（最多 3 个）：
    {
      "name": "左侧高角度",
      "description": "站到人物左前方1.5米，手机举高俯拍45°",
      "reason": "利用窗户侧光，半身人像最显瘦",
      "difficulty": "简单",       // 简单/中等/高级
      "style": "清新自然",        // 风格标签
      "estimatedResult": "..."    // 对预期效果的描述
    }
```

**技术方案：**
- 截帧 → base64 → 调用多模态 AI API（GLM-4V / GPT-4o Vision）
- AI 以摄影师角色分析场景，给出机位建议
- 建议带有方向箭头和文字，叠加在预览画面上

### Layer 2: 实时构图确认（已有基础的增强）

**用户走到推荐位置后 → 实时判断构图是否到位**

保留现有 ML Kit 人脸检测能力，增强为：
- 检测人脸位置 + 人物占比 + 画面对称性
- 判断是否达到了推荐方案的要求
- 颜色反馈：绿色=到位 / 黄色=微调 / 红色=差距大

### Layer 3: 学习模式（长期价值）

**拍完一张好照片 → AI 分析为什么好 → 下次类似场景可以复用**

- 拍照后 AI 给出"这张照片为什么好看"的分析
- 用户可以收藏"喜欢的风格"
- 逐渐建立个人风格的偏好档案

---

## 3. 页面结构（重新设计）

```
App
├── CameraPage（主相机 - 重新设计）
│   ├── CameraPreview（摄像头预览）
│   ├── SceneAnalysisPanel（场景分析浮窗 - NEW）
│   │   ├── 场景标签（"咖啡馆 · 靠窗座位 · 自然光"）
│   │   ├── 推荐机位卡片（可滑动切换 3 个方案）
│   │   └── "分析场景" 按钮
│   ├── CompositionOverlay（构图辅助线 - 保留）
│   ├── LiveGuidanceOverlay（实时构图确认 - 增强版）
│   │   ├── 匹配度进度条（你离推荐方案还差多远）
│   │   └── 实时微调提示
│   └── ControlBar（底部控制栏 - 保留）
│
├── GalleryPage（相册 - 重新设计）
│   ├── 照片网格（带构图评分标签）
│   └── PhotoDetailPage（照片详情 + AI 分析）
│       ├── 照片预览
│       ├── "这张照片为什么好看" AI 分析
│       ├── 构图解析图（标注三分线、主体位置等）
│       └── "下次怎么拍更好" 建议
│
├── LearnPage（学习页 - NEW）
│   ├── 拍摄技巧库（场景分类）
│   │   ├── 室内人像（咖啡馆、家居、办公...）
│   │   ├── 户外人像（公园、街头、旅行...）
│   │   ├── 特殊场景（夜景、逆光、雨天...）
│   │   └── 每个场景有：推荐机位图示 + 范例照片 + 要点
│   └── 我的学习记录（拍了多少、进步曲线）
│
└── SettingsPage（设置）
    ├── AI 服务配置（API Key / 服务商选择）
    ├── 构图辅助线样式
    ├── 语音指导开关
    └── 关于
```

### 导航改为：相机 / 相册 / 学习 / 设置

底部 4 个 Tab，学习页作为新入口。

---

## 4. AI 服务架构（核心）

### 4.1 统一 AI 接口

```dart
abstract class FrameGuideAIService {
  /// 场景分析 + 机位推荐
  Future<SceneRecommendation> analyzeScene(Uint8List imageBytes);

  /// 照片分析（拍完后）
  Future<PhotoAnalysis> analyzePhoto(Uint8List imageBytes);

  /// 获取拍摄技巧
  Future<List<ShootingTip>> getShootingTips(String sceneType);
}
```

### 4.2 多后端支持

| 后端 | 用途 | 成本 |
|------|------|------|
| **GLM-4V** (智谱) | 主力 - 场景分析 + 机位推荐 | 低 |
| **GPT-4o Vision** | 备选 - 效果更好但贵 | 高 |
| **ML Kit** (本地) | 实时人脸检测 + 构图微调 | 免费 |
| **Mock** | 开发测试用 | 0 |

### 4.3 场景分析 Prompt 设计

```
你是一位专业人像摄影师。用户正在准备拍一张人像照片，请你分析当前场景并给出拍摄建议。

请以 JSON 格式回复：
{
  "scene": {
    "type": "场景类型（咖啡馆/公园/街头/室内/夜景/...）",
    "lighting": "光线条件描述",
    "background": "背景描述",
    "features": ["特征1", "特征2"]
  },
  "recommendations": [
    {
      "name": "方案名称",
      "position": "具体站位描述（如：人物左前方1.5米）",
      "angle": "拍摄角度（仰拍/平拍/俯拍/侧拍）",
      "height": "手机高度（举高/平视/蹲低/放地面）",
      "distance": "建议距离",
      "framing": "取景范围（特写/半身/全身/环境人像）",
      "reason": "为什么这么拍（一句话）",
      "difficulty": "简单/中等/高级",
      "proTip": "专业提示"
    }
  ],
  "overallTip": "关于这个场景的一句话总体建议"
}

注意：
1. 给出 2-3 个不同难度的方案
2. 考虑光线方向对人物的影响
3. 建议要具体可执行（不要说"找好角度"，要说"站到XX位置，手机举高30°"）
4. 考虑背景的利用和规避
```

---

## 5. 技术实现计划

### Phase 1: AI 服务接入 + 场景分析（2-3 天）

**目标：** 能真正识别场景并给出机位方案

- [ ] 实现 `FrameGuideAIService` 接口
- [ ] 实现 `GlmVisionService`（调用 GLM-4V API）
- [ ] 实现 `MockAIService`（开发测试用，返回真实格式）
- [ ] 相机页截帧逻辑（每 5 秒或用户点击时截帧）
- [ ] `SceneAnalysisPanel` UI 组件
- [ ] API Key 配置页面

### Phase 2: 机位方案 UI + 实时确认（2-3 天）

**目标：** 用户能看到方案，走到位后得到确认

- [ ] 机位推荐卡片 UI（方案名、方向箭头、文字说明）
- [ ] 方案选择交互（左右滑动切换）
- [ ] 增强实时构图确认（基于 ML Kit + 匹配度进度条）
- [ ] 语音播报（可选）

### Phase 3: 照片分析 + 相册（2 天）

**目标：** 拍完后有分析报告

- [ ] 照片 AI 分析（调 API 分析已拍照片）
- [ ] 相册页面重构
- [ ] 照片详情页（构图解析 + 改进建议）

### Phase 4: 学习页 + 技巧库（2 天）

**目标：** 知识沉淀，用户能学到东西

- [ ] 拍摄技巧库（预设 20+ 场景技巧）
- [ ] 技巧详情页（图示 + 文字）
- [ ] 我的学习记录

### Phase 5: 打磨 + 上线准备（2 天）

- [ ] UI/UX 统一打磨
- [ ] 性能优化（截帧频率、API 调用节流）
- [ ] 错误处理（无网络、API 限流）
- [ ] App 图标和启动页

---

## 6. 项目结构调整

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── colors.dart          # 配色
│   │   └── dimensions.dart      # 尺寸
│   ├── theme/
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   └── utils/
│       ├── image_utils.dart     # 截帧、图片压缩
│       └── permission_utils.dart
│
├── features/
│   ├── camera/
│   │   ├── data/
│   │   │   ├── ai_service.dart              # AI 服务接口
│   │   │   ├── glm_vision_service.dart      # GLM-4V 实现
│   │   │   ├── openai_vision_service.dart   # OpenAI 实现（备选）
│   │   │   ├── mock_ai_service.dart         # Mock 服务
│   │   │   └── ml_face_analyzer.dart        # ML Kit 人脸检测
│   │   ├── models/
│   │   │   ├── scene_analysis.dart          # 场景分析结果
│   │   │   ├── position_recommendation.dart # 机位推荐
│   │   │   └── composition_result.dart      # 构图分析结果
│   │   ├── providers/
│   │   │   ├── camera_provider.dart
│   │   │   ├── analysis_provider.dart       # AI 分析状态
│   │   │   └── settings_provider.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── camera_page.dart
│   │       └── widgets/
│   │           ├── scene_analysis_panel.dart    # 场景分析浮窗
│   │           ├── recommendation_card.dart     # 机位推荐卡片
│   │           ├── composition_overlay.dart     # 构图辅助线
│   │           ├── live_guidance_overlay.dart   # 实时构图确认
│   │           └── control_bar.dart
│   │
│   ├── gallery/
│   │   ├── data/
│   │   │   └── photo_storage.dart
│   │   ├── models/
│   │   │   └── photo_with_analysis.dart
│   │   ├── providers/
│   │   │   └── gallery_provider.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── gallery_page.dart
│   │       │   └── photo_detail_page.dart
│   │       └── widgets/
│   │           └── photo_analysis_card.dart
│   │
│   ├── learn/
│   │   ├── data/
│   │   │   └── tips_repository.dart
│   │   ├── models/
│   │   │   └── shooting_tip.dart
│   │   ├── providers/
│   │   │   └── learn_provider.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── learn_page.dart
│   │       │   └── tip_detail_page.dart
│   │       └── widgets/
│   │           └── tip_card.dart
│   │
│   ├── settings/
│   │   └── presentation/
│   │       └── pages/
│   │           └── settings_page.dart
│   │
│   └── shell/
│       └── presentation/
│           └── pages/
│               └── shell_page.dart
│
└── shared/
    └── widgets/
        └── common_widgets.dart
```

---

## 7. 关键设计决策

| 决策 | 选择 | 原因 |
|------|------|------|
| 主 AI 后端 | GLM-4V | 国内访问快、成本低、中文理解好 |
| 本地检测 | ML Kit 人脸检测 | 免费、实时、隐私安全 |
| 截帧频率 | 手动触发 + 自动 5 秒 | 避免 API 滥用，用户控制节奏 |
| 状态管理 | Riverpod | 已有基础，轻量好用 |
| 照片存储 | 本地 + 元数据 | MVP 阶段不需要云存储 |
| 导航 | go_router | 已有基础 |

---

## 8. MVP 优先级

**必须有的（v2.0）：**
1. ✅ 场景识别 + 机位推荐（AI 驱动）
2. ✅ 推荐方案可视化展示
3. ✅ 实时构图确认（ML Kit 增强）
4. ✅ 拍照保存

**可以延后的：**
- 学习页 → v2.1
- 照片 AI 分析报告 → v2.1
- 语音播报 → v2.2
- 个人风格偏好 → v3.0
