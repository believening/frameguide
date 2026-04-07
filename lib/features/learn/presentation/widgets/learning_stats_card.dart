import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../providers/learning_provider.dart';

/// 学习统计卡片
class LearningStatsCard extends ConsumerWidget {
  const LearningStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(learningProvider);
    final totalTips = ref.watch(tipsRepositoryProvider).tipCount;
    final learnedCount = record.learnedTipIds.length;
    final progress = totalTips > 0 ? learnedCount / totalTips : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.secondary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和进度
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📚 我的学习进度',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$learnedCount / $totalTips',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primary.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.guidanceGood : AppColors.accent,
              ),
              minHeight: 8,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 统计数字行
          Row(
            children: [
              _StatItem(
                icon: Icons.school,
                value: '$learnedCount',
                label: '已学技巧',
                color: AppColors.accent,
              ),
              const SizedBox(width: AppDimensions.spacingLg),
              _StatItem(
                icon: Icons.camera_alt,
                value: '${record.totalShoots}',
                label: '拍摄次数',
                color: AppColors.guidanceGood,
              ),
              const SizedBox(width: AppDimensions.spacingLg),
              _StatItem(
                icon: Icons.category,
                value: '${record.sceneStats.length}',
                label: '涉及场景',
                color: AppColors.guidanceAdjusting,
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 进步提示
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    ref.read(learningProvider.notifier).getProgressTip(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 场景分布图表
          if (record.sceneStats.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            const Text(
              '场景分布',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            _SceneBarChart(sceneStats: record.sceneStats),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 简单柱状图
class _SceneBarChart extends StatelessWidget {
  final Map<String, int> sceneStats;

  const _SceneBarChart({required this.sceneStats});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = sceneStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = sortedEntries.take(5).toList();
    final maxValue = topEntries.isNotEmpty ? topEntries.first.value : 1;

    return Column(
      children: topEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        final widthRatio = data.value / maxValue;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  data.key,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: widthRatio,
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: _barColors[index % _barColors.length],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(
                          '${data.value}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static const _barColors = [
    AppColors.accent,
    AppColors.guidanceGood,
    AppColors.guidanceAdjusting,
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];
}
