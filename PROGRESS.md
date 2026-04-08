# FrameGuide v2 开发进度

## Phase 1: AI 服务接入 + 场景分析 ✅ 已完成

**提交:** `0a42530` | **CI:** ✅ 通过 | **日期:** 2026-04-07

### 完成内容

| 文件 | 说明 |
|------|------|
| `data/vision_ai_service.dart` | AI 视觉服务抽象接口 |
| `data/glm_vision_service.dart` | GLM-4V 实现 |
| `data/mock_vision_service.dart` | Mock 服务（3套场景） |
| `models/scene_analysis.dart` | 数据模型 |
| `providers/analysis_provider.dart` | 分析状态管理 + AI 配置 |
| `presentation/widgets/scene_analysis_panel.dart` | 场景分析 UI |
| `presentation/widgets/live_guidance_overlay.dart` | 实时构图确认 |
| `presentation/pages/camera_page.dart` | 相机页面 |
| `settings/presentation/pages/settings_page.dart` | 设置页 |

---

## Phase 2: 机位方案可视化 + 实时确认 ✅ 已完成

**提交:** `afa0737` | **CI:** ✅ 通过 | **日期:** 2026-04-07

### 完成内容

| 文件 | 说明 |
|------|------|
| `widgets/position_diagram.dart` | 俯视方向示意图 |
| `widgets/live_guidance_overlay.dart` | 实时构图匹配指示器 |
| `widgets/scene_analysis_panel.dart` | 集成方向示意图 |

---

## Phase 3: 照片分析 + 相册 ✅ 已完成

**提交:** `5b1b520` | **CI:** ✅ 通过 | **日期:** 2026-04-07

### 完成内容

| 文件 | 说明 |
|------|------|
| `gallery/data/photo_storage.dart` | 照片存储层（SavedPhoto + 增删改查） |
| `gallery/providers/gallery_provider.dart` | 状态管理（加载/保存/分析/删除） |
| `gallery/presentation/pages/gallery_page.dart` | 相册页面（网格 + 评分标签 + 空状态） |
| `gallery/presentation/pages/photo_detail_page.dart` | 照片详情页（AI 分析报告 + 优缺点） |
| `camera/presentation/pages/camera_page.dart` | 拍照后自动保存 + AI 分析 |

### 功能说明
- 拍照后自动保存到 `photos/` 目录，附带 JSON 元数据
- 拍照后自动触发 AI 分析（调用 `VisionAIService.analyzePhoto`）
- 相册网格显示构图评分标签（颜色编码）
- 照片详情页展示：评分、总结、优点、改进建议、下次提示
- 支持手动分析/重新分析

---

## Phase 4: 学习页 + 技巧库 ✅ 已完成

**提交:** `e4026a1` | **CI:** ✅ 通过 | **日期:** 2026-04-07

### 完成内容

| 文件 | 说明 |
|------|------|
| `learn/data/tips_repository.dart` | 技巧数据（25个场景）+ 查询接口 |
| `learn/models/shooting_tip.dart` | 数据模型 |
| `learn/providers/learning_provider.dart` | 学习记录状态管理 |
| `learn/presentation/pages/learn_page.dart` | 学习主页（技巧库 + 筛选） |
| `learn/presentation/pages/tip_detail_page.dart` | 技巧详情页 |
| `learn/presentation/widgets/tip_card.dart` | 技巧卡片组件 |
| `learn/presentation/widgets/scene_filter_chips.dart` | 场景筛选标签 |
| `learn/presentation/widgets/learning_stats_card.dart` | 学习统计卡片 |
| `learn/widgets/position_diagram.dart` | 机位图示组件 |

### 功能说明
- 25 个预设拍摄技巧覆盖室内/户外/特殊场景/人像类型
- 场景标签筛选
- 技巧详情：机位图示 + 核心要点 + 焦距/光圈建议
- 学习统计：拍摄数量 + 场景分布

---

## Phase 5: 打磨 + 上线 🔄 进行中

**提交:** `3d07c8e` | **CI:** ✅ 通过 | **日期:** 2026-04-08

### P0 已修复 ✅

| 问题 | 修复 |
|------|------|
| 两个同名 `MainCameraPage` 类 | 删除旧类 + `main_camera_page.dart` |
| 图片"压缩"截断损坏图片 | 改用 `image` 包做真正 resize |
| Camera Controller 生命周期泄漏 | 添加 `resetCamera()` |
| 静默假数据掩盖错误 | 显示用户错误提示 |

### P1 已修复 ✅

| 问题 | 修复 |
|------|------|
| 分辨率设置无效 | 映射到 `ResolutionPreset` |
| GLM 请求无超时 | 添加 30s timeout |
| 学习进度不持久化 | SharedPreferences 持久化 |

### 待处理

- [ ] ~~API Key 安全存储（`flutter_secure_storage`）~~ ✅ 已完成
- [ ] ~~单元测试~~ 暂搁置

---

## 技术债 + 稳定性 + 性能 优化 ✅ 已完成 (2026-04-08)

**提交:** `97bf9db` | **CI:** ✅ 通过

### 死代码清理 (-1320 行)
| 文件 | 原因 |
|------|------|
| `mock_ai_service.dart` | 从未被 import |
| `ml_composition_analyzer*.dart` (4个) | 写了但从未接入 |
| `professional_guidance_overlay.dart` | 未被引用 |

### 性能优化
| 优化 | 说明 |
|------|------|
| AI 分析 debounce | 3s 冷却，防止连点 |
| Gallery savePhoto | 前插新照片，不重载全部 |
| Gallery analyzePhoto | 就地更新单张，不重载全部 |
| Gallery deletePhoto | 列表移除，不重载全部 |

### 安全
| 安全 | 说明 |
|------|------|
| API Key 加密存储 | 移动端用 flutter_secure_storage，Web 回退 SharedPreferences |
| 条件导入 | `dart.library.io` 分平台实现 |

### 稳定性
| 稳定性 | 说明 |
|------|------|
| PhotoStorage 容错 | 单张解析失败不阻塞整体加载 |
| 全局 try-catch | loadAllPhotos 外层兜底 |
- [ ] UI/UX 统一打磨
- [ ] App 图标和启动页

---

## Code Review 发现的问题（待处理）

详见 `CODE_REVIEW.md`

**P0 严重问题:**
1. 两个同名 `MainCameraPage` 类导致编译冲突
2. 重复的 `GuidanceDirection` / `CompositionAnalysis` 模型定义
3. 图片"压缩"实际截断字节损坏图片
4. Camera Controller 生命周期泄漏
5. 静默用假数据掩盖错误

**P1 应该修复:**
6. 分辨率设置无效
7. GLM 请求无超时
8. API Key 明文存储
9. 学习进度不持久化
10. 缺少单元测试
