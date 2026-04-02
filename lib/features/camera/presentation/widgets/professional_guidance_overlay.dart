import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../data/photographer_ai_service.dart';

/// 专业摄影师指导覆盖层
class ProfessionalGuidanceOverlay extends StatelessWidget {
  final CompositionAnalysis analysis;
  final bool showDetail;
  final VoidCallback onToggleDetail;

  const ProfessionalGuidanceOverlay({
    super.key,
    required this.analysis,
    required this.showDetail,
    required this.onToggleDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Score badge
        Positioned(
          top: MediaQuery.of(context).padding.top + AppDimensions.spacingLg,
          right: AppDimensions.spacingLg,
          child: _ScoreBadge(score: analysis.score),
        ),

        // Main guidance arrow
        if (analysis.guidances.isNotEmpty)
          Center(
            child: _GuidanceArrow(guidance: analysis.guidances.first),
          ),

        // Photographer tip card
        Positioned(
          bottom: 160,
          left: AppDimensions.spacingLg,
          right: AppDimensions.spacingLg,
          child: _TipCard(
            tip: analysis.tip,
            photographerNote: analysis.photographerNote,
            onTap: onToggleDetail,
          ),
        ),

        // Detail panel (expandable)
        if (showDetail && analysis.guidances.length > 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: AppDimensions.spacingLg,
            right: AppDimensions.spacingLg,
            child: _GuidanceDetailPanel(
              guidances: analysis.guidances,
            ),
          ),

        // Toggle hint
        Positioned(
          top: MediaQuery.of(context).padding.top + AppDimensions.spacingLg,
          left: AppDimensions.spacingLg,
          child: GestureDetector(
            onTap: onToggleDetail,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.overlayBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    showDetail ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${analysis.guidances.length} 条建议',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(),
        ),
      ],
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  Color get _color {
    if (score >= 85) return AppColors.guidanceGood;
    if (score >= 70) return AppColors.guidanceAdjusting;
    return AppColors.guidanceFar;
  }

  String get _label {
    if (score >= 85) return '优秀';
    if (score >= 70) return '良好';
    if (score >= 50) return '一般';
    return '需调整';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.camera_alt,
            size: AppDimensions.iconSm,
            color: Colors.white,
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Text(
            _label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

class _GuidanceArrow extends StatelessWidget {
  final Guidance guidance;

  const _GuidanceArrow({required this.guidance});

  Offset get _offset {
    final direction = guidance.direction;
    if (direction.contains('左')) {
      return direction.contains('前') 
          ? const Offset(-60, -40)
          : direction.contains('后')
              ? const Offset(-60, 40)
              : const Offset(-80, 0);
    }
    if (direction.contains('右')) {
      return direction.contains('前')
          ? const Offset(60, -40)
          : direction.contains('后')
              ? const Offset(60, 40)
              : const Offset(80, 0);
    }
    if (direction.contains('前')) {
      return const Offset(0, -60);
    }
    if (direction.contains('后')) {
      return const Offset(0, 60);
    }
    return Offset.zero;
  }

  double get _rotation {
    final direction = guidance.direction;
    if (direction.contains('左') && !direction.contains('前') && !direction.contains('后')) {
      return pi;
    }
    if (direction.contains('右') && !direction.contains('前') && !direction.contains('后')) {
      return 0;
    }
    if (direction.contains('前')) {
      return -pi / 2;
    }
    if (direction.contains('后')) {
      return pi / 2;
    }
    if (direction.contains('左前')) {
      return -pi / 4;
    }
    if (direction.contains('右前')) {
      return -3 * pi / 4;
    }
    if (direction.contains('左后')) {
      return pi / 4;
    }
    if (direction.contains('右后')) {
      return 3 * pi / 4;
    }
    return 0;
  }

  IconData get _icon {
    return Icons.arrow_forward;
  }

  @override
  Widget build(BuildContext context) {
    if (guidance.direction.isEmpty) {
      return const SizedBox.shrink();
    }

    return Transform.translate(
      offset: _offset,
      child: Transform.rotate(
        angle: _rotation,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent, width: 3),
          ),
          child: Icon(
            _icon,
            size: AppDimensions.iconXl,
            color: AppColors.accent,
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        ).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          duration: 600.ms,
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  final String photographerNote;
  final VoidCallback onTap;

  const _TipCard({
    required this.tip,
    required this.photographerNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.overlayBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.accent.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: AppColors.accent,
                  size: AppDimensions.iconMd,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                const Text(
                  '摄影师建议',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              tip,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              photographerNote,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '点击查看详情',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.accent.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.touch_app,
                  size: 12,
                  color: AppColors.accent.withOpacity(0.7),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.3, end: 0),
    );
  }
}

class _GuidanceDetailPanel extends StatelessWidget {
  final List<Guidance> guidances;

  const _GuidanceDetailPanel({required this.guidances});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(
                Icons.list_alt,
                color: AppColors.accent,
                size: 18,
              ),
              SizedBox(width: AppDimensions.spacingSm),
              Text(
                '调整清单',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ...guidances.asMap().entries.map((entry) {
            final index = entry.key;
            final guidance = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guidance.type.text,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          guidance.instruction,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }
}
