import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Guidance overlay showing AI direction arrows and tips
class GuidanceOverlay extends StatelessWidget {
  final String tip;
  final String direction;
  final int score;

  const GuidanceOverlay({
    super.key,
    required this.tip,
    required this.direction,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    if (direction.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        // Score badge
        Positioned(
          top: MediaQuery.of(context).padding.top + AppDimensions.spacingLg,
          right: AppDimensions.spacingLg,
          child: _ScoreBadge(score: score),
        ),
        // Tip card
        Positioned(
          bottom: 160,
          left: AppDimensions.spacingLg,
          right: AppDimensions.spacingLg,
          child: _TipCard(tip: tip),
        ),
        // Direction arrow
        Center(
          child: _DirectionArrow(direction: direction),
        ),
      ],
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  Color get _color {
    if (score >= 80) return AppColors.guidanceGood;
    if (score >= 60) return AppColors.guidanceAdjusting;
    return AppColors.guidanceFar;
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
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

class _TipCard extends StatelessWidget {
  final String tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.overlayBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.accent.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.accent,
            size: AppDimensions.iconMd,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, end: 0);
  }
}

class _DirectionArrow extends StatelessWidget {
  final String direction;

  const _DirectionArrow({required this.direction});

  Offset get _offset {
    switch (direction) {
      case '往左移':
        return const Offset(-80, 0);
      case '往右移':
        return const Offset(80, 0);
      case '往上移':
        return const Offset(0, -80);
      case '往下移':
        return const Offset(0, 80);
      case '往左上移':
        return const Offset(-60, -60);
      case '往右上移':
        return const Offset(60, -60);
      case '往左下移':
        return const Offset(-60, 60);
      case '往右下移':
        return const Offset(60, 60);
      default:
        return Offset.zero;
    }
  }

  double get _rotation {
    switch (direction) {
      case '往左移':
        return 0;
      case '往右移':
        return pi;
      case '往上移':
        return -pi / 2;
      case '往下移':
        return pi / 2;
      case '往左上移':
        return -pi / 4;
      case '往右上移':
        return -3 * pi / 4;
      case '往左下移':
        return pi / 4;
      case '往右下移':
        return 3 * pi / 4;
      default:
        return 0;
    }
  }

  IconData get _icon {
    switch (direction) {
      case '往左移':
        return Icons.arrow_back;
      case '往右移':
        return Icons.arrow_forward;
      case '往上移':
        return Icons.arrow_upward;
      case '往下移':
        return Icons.arrow_downward;
      case '往左上移':
      case '往右上移':
      case '往左下移':
      case '往右下移':
        return Icons.arrow_upward;
      default:
        return Icons.arrow_forward;
    }
  }

  @override
  Widget build(BuildContext context) {
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
