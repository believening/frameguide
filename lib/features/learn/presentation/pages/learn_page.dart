import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../data/tips_repository.dart';
import '../../models/shooting_tip.dart';
import '../../providers/learning_provider.dart';
import '../widgets/tip_card.dart';
import '../widgets/scene_filter_chips.dart';
import '../widgets/learning_stats_card.dart';

/// 学习主页
class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTips = ref.watch(filteredTipsProvider);
    final learningRecord = ref.watch(learningProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '📸 拍摄技巧库',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingSm,
                            vertical: AppDimensions.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          ),
                          child: Text(
                            '${TipsRepository.instance.tipCount} 个技巧',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    const Text(
                      '学习专业拍摄技巧，提升构图和机位能力',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 学习统计卡片
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingLg,
                ),
                child: const LearningStatsCard(),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spacingLg),
            ),

            // 场景筛选
            const SliverToBoxAdapter(
              child: SceneFilterChips(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spacingMd),
            ),

            // 技巧列表
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLg,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tip = filteredTips[index] as ShootingTip;
                    final isLearned = learningRecord.learnedTipIds.contains(tip.id);
                    
                    return TipCard(
                      tip: tip,
                      isLearned: isLearned,
                      onTap: () {
                        context.push('/learn/tip/${tip.id}');
                      },
                    );
                  },
                  childCount: filteredTips.length,
                ),
              ),
            ),

            // 底部间距
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spacingXxl),
            ),
          ],
        ),
      ),
    );
  }
}
