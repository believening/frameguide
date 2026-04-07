// Live guidance overlay - real-time composition match indicator

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../data/photographer_ai_service.dart';
import '../../providers/camera_provider.dart';

class LiveGuidanceOverlay extends ConsumerStatefulWidget {
  const LiveGuidanceOverlay({super.key});

  @override
  ConsumerState<LiveGuidanceOverlay> createState() => _LiveGuidanceState();
}

class _LiveGuidanceState extends ConsumerState<LiveGuidanceOverlay> {
  CompositionAnalysis? _analysis;
  bool _busy = false;
  int _frames = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _begin();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _begin() {
    try {
      final cs = ref.read(cameraProvider);
      if (cs.controller == null || !cs.isInitialized) return;

      // Try real image stream on mobile
      if (!Platform.isAndroid && !Platform.isIOS) {
        _startMock();
        return;
      }

      cs.controller!.startImageStream((img) {
        if (_busy) return;
        _frames++;
        if (_frames % 20 != 0) return;
        _busy = true;

        // Use mock analysis for now (ML Kit integration can be enhanced later)
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _analysis = ProfessionalPhotographerAI.analyze();
            });
          }
          _busy = false;
        });
      });
    } catch (e) {
      _startMock();
    }
  }

  void _startMock() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _analysis = ProfessionalPhotographerAI.analyze();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_analysis == null) return const SizedBox.shrink();

    final score = _analysis!.score;
    final pct = score / 100.0;
    final tip = _analysis!.guidances.isNotEmpty
        ? _analysis!.guidances.first.instruction
        : null;

    return MatchIndicator(pct: pct, tip: tip);
  }
}

/// Shows a composition match progress bar at the bottom of camera view
class MatchIndicator extends StatelessWidget {
  final double pct; // 0.0 - 1.0
  final String? tip;

  const MatchIndicator({super.key, required this.pct, this.tip});

  Color get barColor {
    if (pct >= 0.8) return AppColors.guidanceGood;
    if (pct >= 0.6) return AppColors.guidanceAdjusting;
    return AppColors.guidanceFar;
  }

  String get statusText {
    if (pct >= 0.85) return '构图到位！可以拍了';
    if (pct >= 0.7) return '快到位了，微调一下';
    if (pct >= 0.5) return '还需要调整';
    return '距离目标较远';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 220,
      left: AppDimensions.spacingMd,
      right: AppDimensions.spacingMd,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.overlayBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: barColor.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  pct >= 0.8
                      ? Icons.check_circle
                      : pct >= 0.6
                          ? Icons.trending_up
                          : Icons.adjust,
                  color: barColor,
                  size: 18,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 14,
                      color: barColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${(pct * 100).round()}%',
                  style: TextStyle(
                    fontSize: 16,
                    color: barColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.white10,
                color: barColor,
                minHeight: 5,
              ),
            ),
            if (tip != null) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              Row(
                children: [
                  const Icon(Icons.subdirectory_arrow_right,
                      color: Colors.white54, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tip!,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
