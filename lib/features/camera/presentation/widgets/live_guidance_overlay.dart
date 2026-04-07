import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// 实时构图微调指引覆盖层
/// 当用户走到推荐位置后，叠加在画面上给出微调提示
class LiveGuidanceOverlay extends StatelessWidget {
  const LiveGuidanceOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 接入 ML Kit 人脸检测数据，显示实时构图匹配度
    // 当前是占位 UI
    return const SizedBox.shrink();
  }
}

/// 构图匹配度指示器
class CompositionMatchIndicator extends StatelessWidget {
  final double matchPercent; // 0.0 - 1.0
  final String? tip;

  const CompositionMatchIndicator({
    super.key,
    required this.matchPercent,
    this.tip,
  });

  Color get _color {
    if (matchPercent >= 0.85) return AppColors.guidanceGood;
    if (matchPercent >= 0.6) return AppColors.guidanceAdjusting;
    return AppColors.guidanceFar;
  }

  String get _label {
    if (matchPercent >= 0.85) return '完美！可以拍了';
    if (matchPercent >= 0.7) return '快到位了，微调一下';
    if (matchPercent >= 0.5) return '还需要调整';
    return '距离目标较远';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 200,
      left: AppDimensions.spacingMd,
      right: AppDimensions.spacingMd,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.overlayBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: _color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: matchPercent,
                backgroundColor: Colors.white12,
                color: _color,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            // 标签
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _label,
                  style: TextStyle(
                    fontSize: 13,
                    color: _color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(matchPercent * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    color: _color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // 微调提示
            if (tip != null) ...[
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                tip!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
