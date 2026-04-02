import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../data/photographer_ai_service.dart';

/// 专业摄影师指导覆盖层
class ProfessionalGuidanceOverlay extends StatelessWidget {
  final CompositionAnalysis analysis;

  const ProfessionalGuidanceOverlay({
    super.key,
    required this.analysis,
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

        // Main guidance arrow (show if only one guidance)
        if (analysis.guidances.length == 1)
          Center(
            child: _GuidanceArrow(guidance: analysis.guidances.first),
          ),

        // Multiple arrows for multiple guidances
        if (analysis.guidances.length > 1)
          Center(
            child: _MultipleGuidanceArrows(guidances: analysis.guidances),
          ),

        // Guidance panel (always visible when expanded)
        if (analysis.guidances.length > 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: AppDimensions.spacingLg,
            right: AppDimensions.spacingLg,
            child: _GuidanceDetailPanel(
              guidances: analysis.guidances,
            ),
          ),

        // Tip card
        Positioned(
          bottom: 160,
          left: AppDimensions.spacingLg,
          right: AppDimensions.spacingLg,
          child: _TipCard(
            tip: analysis.tip,
            photographerNote: analysis.photographerNote,
          ),
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

/// 多个方向箭头（同时显示多个调整建议）
class _MultipleGuidanceArrows extends StatelessWidget {
  final List<Guidance> guidances;

  const _MultipleGuidanceArrows({required this.guidances});

  @override
  Widget build(BuildContext context) {
    // 只显示前3个最重要的箭头
    final displayGuides = guidances.take(3).toList();
    
    return Stack(
      children: displayGuides.asMap().entries.map((entry) {
        final index = entry.key;
        final guidance = entry.value;
        return _GuidanceArrowWithIndex(
          guidance: guidance,
          index: index,
        );
      }).toList(),
    );
  }
}

class _GuidanceArrowWithIndex extends StatelessWidget {
  final Guidance guidance;
  final int index;

  const _GuidanceArrowWithIndex({
    required this.guidance,
    required this.index,
  });

  Offset get _offset {
    final direction = guidance.direction;
    // 不同索引的箭头分布在不同位置
    switch (index) {
      case 0:
        return _getOffsetForDirection(direction, 70.0);
      case 1:
        return _getOffsetForDirection(direction, 100.0) * 1.2;
      case 2:
        return _getOffsetForDirection(direction, 130.0) * 1.4;
      default:
        return Offset.zero;
    }
  }

  Offset _getOffsetForDirection(String direction, double distance) {
    if (direction.contains('左')) {
      return direction.contains('前')
          ? Offset(-distance * 0.8, -distance * 0.6)
          : direction.contains('后')
              ? Offset(-distance * 0.8, distance * 0.6)
              : Offset(-distance, 0);
    }
    if (direction.contains('右')) {
      return direction.contains('前')
          ? Offset(distance * 0.8, -distance * 0.6)
          : direction.contains('后')
              ? Offset(distance * 0.8, distance * 0.6)
              : Offset(distance, 0);
    }
    if (direction.contains('前')) {
      return Offset(0, -distance);
    }
    if (direction.contains('后')) {
      return Offset(0, distance);
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
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.25 + index * 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accent.withOpacity(0.8 - index * 0.2),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.arrow_forward,
            size: AppDimensions.iconLg - index * 4,
            color: AppColors.accent.withOpacity(1 - index * 0.2),
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        ).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: (800 - index * 100).ms,
        ),
      ),
    ).animate().fadeIn(delay: (200 + index * 100).ms);
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  final String photographerNote;

  const _TipCard({
    required this.tip,
    required this.photographerNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, end: 0);
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
