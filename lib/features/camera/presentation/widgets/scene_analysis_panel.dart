import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../models/scene_analysis.dart';
import 'position_diagram.dart';

/// 场景分析面板 - 显示场景信息和机位推荐
class SceneAnalysisPanel extends StatelessWidget {
  final SceneAnalysis analysis;
  final int selectedRecommendation;
  final ValueChanged<int>? onRecommendationSelected;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;
  final VoidCallback? onRetry;

  const SceneAnalysisPanel({
    super.key,
    required this.analysis,
    this.selectedRecommendation = 0,
    this.onRecommendationSelected,
    this.onNext,
    this.onPrev,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: AppDimensions.spacingMd,
      right: AppDimensions.spacingMd,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 场景信息条
          _SceneInfoBar(scene: analysis.scene),
          const SizedBox(height: AppDimensions.spacingSm),
          // 推荐方案卡片
          if (analysis.recommendations.isNotEmpty)
            _RecommendationCard(
              recommendation:
                  analysis.recommendations[selectedRecommendation],
              index: selectedRecommendation,
              total: analysis.recommendations.length,
              onNext: onNext,
              onPrev: onPrev,
            ),
          // 总体建议
          if (analysis.overallTip.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            _OverallTipBar(tip: analysis.overallTip),
          ],
        ],
      ),
    );
  }
}

/// 场景信息条
class _SceneInfoBar extends StatelessWidget {
  final SceneInfo scene;

  const _SceneInfoBar({required this.scene});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlayBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: AppColors.accent,
            size: 16,
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Expanded(
            child: Text(
              '${scene.type} · ${scene.lighting}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 推荐方案卡片
class _RecommendationCard extends StatelessWidget {
  final PositionRecommendation recommendation;
  final int index;
  final int total;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;

  const _RecommendationCard({
    required this.recommendation,
    required this.index,
    required this.total,
    this.onNext,
    this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.overlayBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部：方案名 + 难度 + 翻页
          _buildHeader(),
          const Divider(height: 1, color: AppColors.divider),
          // 俯视方向示意图
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
            child: PositionDiagram(recommendation: recommendation),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // 内容
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 原因
                _buildInfoRow(Icons.lightbulb_outline, recommendation.reason,
                    AppColors.accent),
                const SizedBox(height: AppDimensions.spacingSm),
                // 站位 + 距离
                _buildInfoRow(
                    Icons.directions_walk, '${recommendation.position} · ${recommendation.distance}', Colors.white),
                const SizedBox(height: AppDimensions.spacingXs),
                // 取景
                _buildInfoRow(
                    Icons.crop_free, recommendation.framing, Colors.white70),
                // 专业提示
                if (recommendation.proTip.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingSm),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingSm),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.tips_and_updates,
                          color: AppColors.accent,
                          size: 14,
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Expanded(
                          child: Text(
                            recommendation.proTip,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.accent,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingSm,
        AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          // 难度标签
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: recommendation.difficultyColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(
                  color: recommendation.difficultyColor.withOpacity(0.5)),
            ),
            child: Text(
              recommendation.difficulty,
              style: TextStyle(
                fontSize: 11,
                color: recommendation.difficultyColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          // 方案名
          Expanded(
            child: Text(
              recommendation.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // 翻页
          if (total > 1) ...[
            IconButton(
              onPressed: onPrev,
              icon: const Icon(Icons.chevron_left, color: Colors.white70, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            Text(
              '${index + 1}/$total',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon:
                  const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: textColor.withOpacity(0.7), size: 16),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// 总体建议条
class _OverallTipBar extends StatelessWidget {
  final String tip;

  const _OverallTipBar({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.accent,
            size: 14,
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 分析状态指示器
class AnalysisStatusIndicator extends StatelessWidget {
  final AnalysisStatus status;
  final String? error;
  final VoidCallback? onRetry;

  const AnalysisStatusIndicator({
    super.key,
    required this.status,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AnalysisStatus.analyzing:
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.overlayBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'AI 分析场景中...',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      case AnalysisStatus.error:
        return Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.overlayBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.guidanceFar, size: 24),
                const SizedBox(height: 8),
                Text(
                  error ?? '分析失败',
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('重试', style: TextStyle(color: AppColors.accent)),
                  ),
                ],
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
