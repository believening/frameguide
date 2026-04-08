import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../models/shooting_tip.dart';

/// 技巧卡片组件
class TipCard extends StatelessWidget {
  final ShootingTip tip;
  final bool isLearned;
  final VoidCallback onTap;

  const TipCard({
    super.key,
    required this.tip,
    required this.isLearned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: isLearned
              ? Border.all(color: AppColors.guidanceGood, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tip.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isLearned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingSm,
                        vertical: AppDimensions.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.guidanceGood.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AppColors.guidanceGood,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '已学',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.guidanceGood,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // 标签行
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
              ),
              child: Wrap(
                spacing: AppDimensions.spacingSm,
                runSpacing: AppDimensions.spacingXs,
                children: [
                  // 场景标签
                  ...tip.sceneTags.map((tag) => _TagChip(
                        label: tag,
                        color: AppColors.accent.withOpacity(0.8),
                      )),
                  // 风格标签
                  _TagChip(
                    label: tip.style,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  // 难度标签
                  _TagChip(
                    label: tip.difficulty,
                    color: _getDifficultyColor(tip.difficulty),
                  ),
                ],
              ),
            ),
            
            // 核心要点预览
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '核心要点',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    tip.keyPoints.take(2).map((p) => '• $p').join('\n'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // 机位提示
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppDimensions.radiusMd),
                  bottomRight: Radius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.camera_alt,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Expanded(
                    child: Text(
                      tip.positionDiagram,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '简单':
        return AppColors.guidanceGood.withOpacity(0.6);
      case '中等':
        return AppColors.guidanceAdjusting.withOpacity(0.6);
      case '高级':
        return AppColors.guidanceFar.withOpacity(0.6);
      default:
        return AppColors.textSecondary.withOpacity(0.5);
    }
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
