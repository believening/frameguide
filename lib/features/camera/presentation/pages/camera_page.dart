import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
// ignore: unused_import
import '../../models/scene_analysis.dart';
import '../../providers/analysis_provider.dart';
import '../../providers/camera_provider.dart';
import '../widgets/composition_overlay.dart';
import '../widgets/scene_analysis_panel.dart';
import '../widgets/live_guidance_overlay.dart';

/// 主相机页面 - v2 重构
class MainCameraPage extends ConsumerStatefulWidget {
  const MainCameraPage({super.key});

  @override
  ConsumerState<MainCameraPage> createState() => _MainCameraPageState();
}

class _MainCameraPageState extends ConsumerState<MainCameraPage>
    with WidgetsBindingObserver {
  bool _isTakingPicture = false;
  bool _showAnalysisPanel = true;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoHideTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraState = ref.read(cameraProvider);
    if (cameraState.controller == null || !cameraState.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cameraState.controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (!mounted) return;
    ref.read(cameraProvider.notifier).initializeCamera(cameras);
  }

  /// 截取当前画面并让 AI 分析场景
  Future<void> _captureAndAnalyze() async {
    final cameraState = ref.read(cameraProvider);
    if (cameraState.controller == null || !cameraState.isInitialized) return;

    try {
      // 截帧
      final xFile = await cameraState.controller!.takePicture();
      final bytes = await xFile.readAsBytes();

      // 发给 AI 分析
      ref.read(analysisProvider.notifier).analyzeFromImage(bytes);
    } catch (e) {
      // 截帧失败时使用 Mock 分析
      debugPrint('截帧失败，使用 Mock: $e');
      final mockBytes = Uint8List(100);
      ref.read(analysisProvider.notifier).analyzeFromImage(mockBytes);
    }
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture) return;

    setState(() => _isTakingPicture = true);

    try {
      final cameraState = ref.read(cameraProvider);
      if (cameraState.controller == null || !cameraState.isInitialized) return;

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/IMG_$timestamp.jpg';

      final xFile = await cameraState.controller!.takePicture();
      await xFile.saveTo(path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('照片已保存'),
            backgroundColor: AppColors.guidanceGood,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拍照失败: $e'),
            backgroundColor: AppColors.guidanceFar,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTakingPicture = false);
      }
    }
  }

  void _toggleAnalysisPanel() {
    setState(() {
      _showAnalysisPanel = !_showAnalysisPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final gridStyle = ref.watch(gridStyleProvider);
    final analysisState = ref.watch(analysisProvider);
    final showGuidance = ref.watch(showGuidanceProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // 相机预览
          if (cameraState.isInitialized && cameraState.controller != null)
            Positioned.fill(
              child: CameraPreview(cameraState.controller!),
            )
          else if (cameraState.error != null)
            _buildErrorView(cameraState.error!)
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),

          // 构图辅助线
          if (cameraState.isInitialized)
            Positioned.fill(
              child: CompositionOverlay(style: gridStyle),
            ),

          // 实时构图微调指引（ML Kit）
          if (showGuidance && cameraState.isInitialized)
            const Positioned.fill(
              child: LiveGuidanceOverlay(),
            ),

          // 场景分析面板
          if (_showAnalysisPanel && cameraState.isInitialized) ...[
            // 分析成功时显示面板
            if (analysisState.status == AnalysisStatus.success &&
                analysisState.analysis != null)
              SceneAnalysisPanel(
                analysis: analysisState.analysis!,
                selectedRecommendation:
                    analysisState.selectedRecommendation,
                onNext: () =>
                    ref.read(analysisProvider.notifier).nextRecommendation(),
                onPrev: () =>
                    ref.read(analysisProvider.notifier).prevRecommendation(),
              ),

            // 分析中/失败 状态指示
            if (analysisState.status == AnalysisStatus.analyzing ||
                analysisState.status == AnalysisStatus.error)
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                left: 0,
                right: 0,
                child: AnalysisStatusIndicator(
                  status: analysisState.status,
                  error: analysisState.error,
                  onRetry: _captureAndAnalyze,
                ),
              ),
          ],

          // 底部控制栏
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ControlBar(
              onSwitchCamera: () =>
                  ref.read(cameraProvider.notifier).switchCamera(),
              onTakePicture: _takePicture,
              onAnalyzeScene: _captureAndAnalyze,
              onTogglePanel: _toggleAnalysisPanel,
              isTakingPicture: _isTakingPicture,
              showPanel: _showAnalysisPanel,
              isAnalyzing: analysisState.status == AnalysisStatus.analyzing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.guidanceFar, size: 48),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text('相机初始化失败', style: TextStyle(fontSize: 18)),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              error,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部控制栏
class _ControlBar extends StatelessWidget {
  final VoidCallback onSwitchCamera;
  final VoidCallback onTakePicture;
  final VoidCallback onAnalyzeScene;
  final VoidCallback onTogglePanel;
  final bool isTakingPicture;
  final bool showPanel;
  final bool isAnalyzing;

  const _ControlBar({
    required this.onSwitchCamera,
    required this.onTakePicture,
    required this.onAnalyzeScene,
    required this.onTogglePanel,
    required this.isTakingPicture,
    required this.showPanel,
    required this.isAnalyzing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.spacingMd,
        right: AppDimensions.spacingMd,
        top: AppDimensions.spacingLg,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.spacingLg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, AppColors.primary],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 分析场景按钮（大的、突出的）
          GestureDetector(
            onTap: isAnalyzing ? null : onAnalyzeScene,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXl,
                vertical: AppDimensions.spacingMd,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAnalyzing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  else
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Text(
                    isAnalyzing ? '分析中...' : '分析场景',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // 底部按钮行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 面板开关
              IconButton(
                onPressed: onTogglePanel,
                icon: Icon(
                  showPanel ? Icons.visibility : Icons.visibility_off,
                  color: showPanel ? AppColors.accent : AppColors.textSecondary,
                  size: AppDimensions.iconLg,
                ),
              ),

              // 快门按钮
              GestureDetector(
                onTap: isTakingPicture ? null : onTakePicture,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textPrimary, width: 4),
                  ),
                  child: Center(
                    child: isTakingPicture
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          )
                        : Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textPrimary,
                            ),
                          ),
                  ),
                ),
              ),

              // 切换摄像头
              IconButton(
                onPressed: onSwitchCamera,
                icon: const Icon(
                  Icons.flip_camera_ios,
                  color: AppColors.textPrimary,
                  size: AppDimensions.iconLg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
