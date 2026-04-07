# FrameGuide v2 开发进度

## Phase 1: AI 服务接入 + 场景分析 ✅ 已完成

**提交:** `0a42530` | **CI:** ✅ 通过 | **日期:** 2026-04-07

### 完成内容

| 文件 | 说明 |
|------|------|
| `SPEC-v2.md` | v2 项目规划文档 |
| `data/vision_ai_service.dart` | AI 视觉服务抽象接口 |
| `data/glm_vision_service.dart` | GLM-4V 实现（含场景分析 + 照片分析） |
| `data/mock_vision_service.dart` | Mock 服务（3套场景：咖啡馆/公园/室内） |
| `models/scene_analysis.dart` | 数据模型（SceneAnalysis, PositionRecommendation 等） |
| `providers/analysis_provider.dart` | 分析状态管理 + AI 配置持久化 |
| `presentation/widgets/scene_analysis_panel.dart` | 场景分析 UI（信息条 + 推荐方案卡片） |
| `presentation/widgets/live_guidance_overlay.dart` | 实时构图确认框架 |
| `presentation/pages/camera_page.dart` | 重构相机页面（集成"分析场景"按钮） |
| `settings/presentation/pages/settings_page.dart` | 设置页重构（AI 供应商配置） |

### 架构设计

```
用户点"分析场景" → 截帧 → base64 → VisionAIService
                                         ↓
                              GlmVisionService (GLM-4V)
                              MockVisionService (测试)
                              ... (可扩展)
                                         ↓
                              SceneAnalysis → UI 展示推荐方案
```

- 供应商无关设计，开发者配置 API Key 即可切换
- 当前默认 Mock 模式，配置 GLM API Key 后切到真实 AI

---

## Phase 2: 机位方案可视化 + 实时确认 ✅ 已完成

**提交:** `afa0737` | **CI:** ✅ 通过 | **日期:** 2026-04-07

### 完成内容

| 文件 | 说明 |
|------|------|
| `widgets/position_diagram.dart` | 俯视方向示意图（自定义 Canvas 绘制） |
| `widgets/live_guidance_overlay.dart` | 实时构图匹配指示器（进度条 + 状态标签） |
| `widgets/scene_analysis_panel.dart` | 集成方向示意图到推荐卡片 |

### 方向示意图功能
- 俯视图展示人物位置（👤）和拍摄者位置（📱）
- 虚线连接拍摄方向
- 扇形表示拍摄角度范围
- 右侧高度指示器（举高/平视/蹲低/地面）
- 自动解析推荐方案的站位和角度

### 实时构图确认
- ML Kit 人脸检测（移动端）+ Mock 模式（Web/开发）
- 颜色编码：绿色 ≥ 80% | 黄色 ≥ 60% | 红色 < 60%
- 进度条 + 百分比 + 状态文字
- 微调提示（箭头 + 文字）

---

## Phase 3: 照片分析 + 相册 🔜 待开始

- [ ] 拍照后 AI 分析（调用 VisionAIService.analyzePhoto）
- [ ] 相册页面重构（照片网格 + 构图评分标签）
- [ ] 照片详情页（AI 分析报告 + 构图解析图）

## Phase 4: 学习页 + 技巧库 🔜

- [ ] 拍摄技巧库（预设 20+ 场景技巧）
- [ ] 技巧详情页（图示 + 文字）
- [ ] 我的学习记录

## Phase 5: 打磨 + 上线 🔜

- [ ] UI/UX 统一打磨
- [ ] 性能优化（截帧频率、API 调用节流）
- [ ] 错误处理（无网络、API 限流）
- [ ] App 图标和启动页
