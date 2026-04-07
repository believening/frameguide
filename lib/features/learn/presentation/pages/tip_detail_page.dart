import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../data/tips_repository.dart';
import '../../providers/learning_provider.dart';
import '../../widgets/position_diagram.dart';
import '../widgets/tip_card.dart';

/// 技巧详情页
class TipDetailPage extends ConsumerWidget {
  final String tipId;

  const TipDetailPage({
    super.key,
    required this.tipId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tip = TipsRepository.instance.getTipById(tipId);
    final learningRecord = ref.watch(learningProvider);
    
    if (tip == null) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
        ),
        body: const Center(
          child: Text(
            '技巧不存在',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final isLearned = learningRecord.learnedTipIds.contains(tip.id);
    final relatedTips = TipsRepository.instance.getRelatedTips(tip.relatedTipIds);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                tip.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              titlePadding: const EdgeInsets.only(
                left: AppDimensions.spacingLg,
                bottom: 16,
              ),
            ),
            actions: [
              if (!isLearned)
                TextButton.icon(
                  onPressed: () {
                    ref.read(learningProvider.notifier).markTipAsLearned(
                          tip.id,
                          tip.sceneTags.first,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.guidanceGood, size: 18),
                            SizedBox(width: 8),
                            Text('已标记为已学习'),
                          ],
                        ),
                        backgroundColor: AppColors.secondary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.guidanceGood,
                    size: 18,
                  ),
                  label: const Text(
                    '标记已学',
                    style: TextStyle(
                      color: AppColors.guidanceGood,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(right: AppDimensions.spacingMd),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.guidanceGood,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '已学习',
                        style: TextStyle(
                          color: AppColors.guidanceGood,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // 内容
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标签行
                  Wrap(
                    spacing: AppDimensions.spacingSm,
                    runSpacing: AppDimensions.spacingSm,
                    children: [
                      ...tip.sceneTags.map((tag) => _TagChip(
                            label: tag,
                            color: AppColors.accent.withOpacity(0.8),
                          )),
                      _TagChip(
                        label: tip.style,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      _TagChip(
                        label: tip.difficulty,
                        color: _getDifficultyColor(tip.difficulty),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // 机位图示
                  const Text(
                    '📍 推荐机位',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  TipPositionDiagram(positionDescription: tip.positionDiagram),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // 拍摄参数
                  if (tip.focalLength != null || tip.aperture != null) ...[
                    const Text(
                      '📷 拍摄参数建议',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingMd),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: Row(
                        children: [
                          if (tip.focalLength != null)
                            Expanded(
                              child: _ParameterItem(
                                icon: Icons.lens,
                                label: '焦距',
                                value: tip.focalLength!,
                              ),
                            ),
                          if (tip.focalLength != null && tip.aperture != null)
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.textSecondary.withOpacity(0.3),
                            ),
                          if (tip.aperture != null)
                            Expanded(
                              child: _ParameterItem(
                                icon: Icons.camera,
                                label: '光圈',
                                value: tip.aperture!,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),
                  ],

                  // 核心要点
                  const Text(
                    '💡 核心要点',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Column(
                      children: tip.keyPoints.asMap().entries.map((entry) {
                        final index = entry.key;
                        final point = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < tip.keyPoints.length - 1
                                ? AppDimensions.spacingSm
                                : 0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingSm),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    point,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // 示例描述
                  const Text(
                    '🖼️ 示例效果',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Expanded(
                          child: Text(
                            tip.exampleDesc,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 相关技巧推荐
                  if (relatedTips.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXl),
                    const Text(
                      '🔗 相关技巧',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    ...relatedTips.map((relatedTip) {
                      final isRelatedLearned = learningRecord.learnedTipIds.contains(relatedTip.id);
                      return TipCard(
                        tip: relatedTip,
                        isLearned: isRelatedLearned,
                        onTap: () {
                          context.push('/learn/tip/${relatedTip.id}');
                        },
                      );
                    }),
                  ],

                  const SizedBox(height: AppDimensions.spacingXxl),
                ],
              ),
            ),
          ),
        ],
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

class _ParameterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ParameterItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: AppColors.accent,
          size: 20,
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
