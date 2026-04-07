import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../providers/learning_provider.dart';

/// 场景筛选 Chips
class SceneFilterChips extends ConsumerWidget {
  const SceneFilterChips({super.key});

  static const _popularTags = [
    '室内',
    '户外',
    '人像',
    '自拍',
    '合影',
    '咖啡馆',
    '公园',
    '街头',
    '夜景',
    '逆光',
    '美食',
    '花卉',
    '清新自然',
    '复古胶片',
    '高级感',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(selectedSceneTagsProvider);

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
        ),
        itemCount: _popularTags.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.spacingSm),
        itemBuilder: (context, index) {
          if (index == 0) {
            // 全部标签
            final isSelected = selectedTags.isEmpty;
            return _FilterChip(
              label: '全部',
              isSelected: isSelected,
              onTap: () {
                ref.read(selectedSceneTagsProvider.notifier).state = {};
              },
            );
          }

          final tag = _popularTags[index - 1];
          final isSelected = selectedTags.contains(tag);

          return _FilterChip(
            label: tag,
            isSelected: isSelected,
            onTap: () {
              final current = Set<String>.from(selectedTags);
              if (isSelected) {
                current.remove(tag);
              } else {
                current.add(tag);
              }
              ref.read(selectedSceneTagsProvider.notifier).state = current;
            },
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
