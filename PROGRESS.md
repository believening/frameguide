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

## Phase 2: 机位方案可视化 + 实时确认 🔜 待开始

- [ ] 推荐方案可视化（方向示意图、站位图示）
- [ ] 方案选择交互优化（左右滑动切换）
- [ ] ML Kit 人脸检测接入实时构图确认
- [ ] 构图匹配度进度条
- [ ] 语音播报（可选）

## Phase 3: 照片分析 + 相册 🔜

- [ ] 拍照后 AI 分析
- [ ] 相册页面重构
- [ ] 照片详情页

## Phase 4: 学习页 + 技巧库 🔜

- [ ] 拍摄技巧库
- [ ] 技巧详情页
- [ ] 学习记录

## Phase 5: 打磨 + 上线 🔜

- [ ] UI/UX 统一
- [ ] 性能优化
- [ ] 错误处理
- [ ] App 图标
