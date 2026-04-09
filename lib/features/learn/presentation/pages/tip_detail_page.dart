import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frame_guide/core/constants/colors.dart';
import 'package:frame_guide/core/constants/dimensions.dart';
import 'package:frame_guide/core/widgets/position_diagram.dart';
import '../../data/tips_repository.dart';
import '../../providers/learning_provider.dart';
import '../widgets/tip_card.dart';

/// 技巧详情页
class TipDetailPage extends ConsumerWidget {
  final String tipId;

  const TipDetailPage({
    super.key,
    required this.tipId,
  });

  /// 解析 positionDiagram 字符串中的位置方向
  String _parsePosition(String diagram) {
    // 格式: "俯视: 人物坐在窗边，拍摄者在侧面45度，距离2-3米"
    final lower = diagram.toLowerCase();

    // 提取拍摄者位置
    if (lower.contains('侧面45') || lower.contains('侧45')) {
      return '侧面45°';
    } else if (lower.contains('正前方') || lower.contains('正面')) {
      return '正面';
    } else if (lower.contains('侧前方')) {
      return '侧前方';
    } else if (lower.contains('侧面')) {
      return '侧面';
    } else if (lower.contains('背后') || lower.contains('背')) {
      return '背面';
    } else if (lower.contains('对面')) {
      return '对面';
    } else if (lower.contains('低角度仰拍')) {
      return '低角度仰拍';
    }
    return '正面';
  }

  /// 解析 positionDiagram 字符串中的角度
  String _parseAngle(String diagram) {
    // 格式: "俯视: ..."
    final parts = diagram.split(':');
    if (parts.isNotEmpty) {
      final angle = parts[0].trim();
      if (angle.contains('俯')) return '俯拍';
      if (angle.contains('仰')) return '仰拍';
      if (angle.contains('侧')) return '侧拍';
    }
    return '平拍';
  }

  /// 解析 positionDiagram 字符串中的距离
  String _parseDistance(String diagram) {
    final lower = diagram.toLowerCase();

    if (lower.contains('50-80cm') || lower.contains('50cm')) {
      return '50-80cm';
    } else if (lower.contains('30-50cm')) {
      return '30-50cm';
    } else if (lower.contains('1-2米') || lower.contains('1.5')) {
      return '1-2米';
    } else if (lower.contains('2-3米') || lower.contains('2米')) {
      return '2-3米';
    } else if (lower.contains('3-5米') || lower.contains('3米')) {
      return '3-5米';
    } else if (lower.contains('5-8米') || lower.contains('5米')) {
      return '5-8米';
    }
    return '2-3米';
  }

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
                  PositionDiagram(
                    position: _parsePosition(tip.positionDiagram),
                    angle: _parseAngle(tip.positionDiagram),
                    height: '平视',
                    distance: _parseDistance(tip.positionDiagram),
                  ),

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
