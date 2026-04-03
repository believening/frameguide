import 'dart:async';
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../data/photographer_ai_service.dart';
import '../../data/ml_composition_analyzer.dart';
import '../../providers/camera_provider.dart';
import '../widgets/composition_overlay.dart';
import '../widgets/professional_guidance_overlay.dart';

export '../../data/photographer_ai_service.dart';
export '../../data/ml_composition_analyzer.dart';

/// Main camera page with ML-powered composition analysis
class MainCameraPage extends ConsumerStatefulWidget {
  const MainCameraPage({super.key});

  @override
  ConsumerState<MainCameraPage> createState() => _MainCameraPageState();
}

class _MainCameraPageState extends ConsumerState<MainCameraPage>
    with WidgetsBindingObserver {
  CompositionAnalysis? _currentAnalysis;
  bool _isTakingPicture = false;
  MLCompositionAnalyzer? _mlAnalyzer;
  bool _isAnalyzing = false;
  final int _analysisFrameSkip = 15; // 每15帧分析一次，避免性能问题
  int _frameCount = 0;
  Timer? _mockAnalysisTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mlAnalyzer?.dispose();
    _mockAnalysisTimer?.cancel();
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

    // 等待相机初始化完成后设置图像分析
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    _mlAnalyzer = MLCompositionAnalyzer();
    _startImageAnalysis();
  }

  void _startImageAnalysis() {
    final cameraState = ref.read(cameraProvider);
    if (cameraState.controller == null) return;

    // 启动 Mock AI 定时器作为后备
    _startMockAnalysis();

    // 尝试启动图像流（移动端）
    try {
      cameraState.controller!.startImageStream((CameraImage image) {
        if (!mounted || !ref.read(showGuidanceProvider)) return;

        _frameCount++;
        if (_frameCount % _analysisFrameSkip != 0) return;
        if (_isAnalyzing) return;

        _isAnalyzing = true;
        _analyzeImage(image).then((analysis) {
          if (mounted) {
            setState(() {
              _currentAnalysis = analysis;
            });
          }
          _isAnalyzing = false;
        }).catchError((_) {
          _isAnalyzing = false;
        });
      });
    } catch (e) {
      // Web 不支持 startImageStream，保持使用 Mock AI
    }
  }

  void _startMockAnalysis() {
    // Web 上使用 Mock AI，每2秒更新一次
    _mockAnalysisTimer?.cancel();
    _mockAnalysisTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || !ref.read(showGuidanceProvider)) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentAnalysis = ProfessionalPhotographerAI.analyze();
      });
    });
  }

  Future<CompositionAnalysis> _analyzeImage(CameraImage image) async {
    if (_mlAnalyzer != null) {
      final cameraState = ref.read(cameraProvider);
      if (cameraState.controller != null) {
        final rotation = inputImageRotationToInt(
          cameraState.controller!.description.sensorOrientation,
        );
        return await _mlAnalyzer!.analyzeFrame(image, rotation);
      }
    }
    // Fallback to mock if ML is not available
    return ProfessionalPhotographerAI.analyze();
  }

  int inputImageRotationToInt(int sensorOrientation) {
    // Convert sensor orientation to InputImageRotation
    switch (sensorOrientation) {
      case 90:
        return 90;
      case 180:
        return 180;
      case 270:
        return 270;
      default:
        return 0;
    }
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture) return;
    
    setState(() => _isTakingPicture = true);
    
    try {
      final cameraState = ref.read(cameraProvider);
      if (cameraState.controller == null || !cameraState.isInitialized) return;

      // 停止图像分析
      await cameraState.controller!.stopImageStream();

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
        // 恢复图像分析
        Future.delayed(const Duration(milliseconds: 500), () {
          _startImageAnalysis();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final gridStyle = ref.watch(gridStyleProvider);
    final showGuidance = ref.watch(showGuidanceProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Camera preview
          if (cameraState.isInitialized && cameraState.controller != null)
            Positioned.fill(
              child: CameraPreview(cameraState.controller!),
            )
          else if (cameraState.error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.guidanceFar,
                    size: 48,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  Text(
                    '相机初始化失败',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    cameraState.error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            ),

          // Composition overlay
          if (cameraState.isInitialized)
            Positioned.fill(
              child: CompositionOverlay(style: gridStyle),
            ),

          // AI Guidance overlay
          if (showGuidance && _currentAnalysis != null)
            Positioned.fill(
              child: ProfessionalGuidanceOverlay(
                analysis: _currentAnalysis!,
              ),
            ),

          // Loading indicator
          if (_isAnalyzing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.overlayBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI 分析中...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Control bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ControlBar(
              onSwitchCamera: () => ref.read(cameraProvider.notifier).switchCamera(),
              onTakePicture: _takePicture,
              isTakingPicture: _isTakingPicture,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  final VoidCallback onSwitchCamera;
  final VoidCallback onTakePicture;
  final bool isTakingPicture;

  const _ControlBar({
    required this.onSwitchCamera,
    required this.onTakePicture,
    required this.isTakingPicture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.spacingXl,
        right: AppDimensions.spacingXl,
        top: AppDimensions.spacingXl,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.spacingXl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, AppColors.primary],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button (placeholder)
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.photo_library_outlined,
              color: AppColors.textPrimary,
              size: AppDimensions.iconLg,
            ),
          ),
          
          // Shutter button
          GestureDetector(
            onTap: isTakingPicture ? null : onTakePicture,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textPrimary,
                  width: 4,
                ),
              ),
              child: Center(
                child: isTakingPicture
                    ? const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textPrimary,
                        ),
                      ),
              ),
            ),
          ),
          
          // Switch camera button
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
    );
  }
}
