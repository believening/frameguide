import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../data/photographer_ai_service.dart';
import '../../providers/camera_provider.dart';
import '../widgets/composition_overlay.dart';
import '../widgets/professional_guidance_overlay.dart';

export '../../data/photographer_ai_service.dart';

/// Main camera page with preview, composition overlay, and professional guidance
class MainCameraPage extends ConsumerStatefulWidget {
  const MainCameraPage({super.key});

  @override
  ConsumerState<MainCameraPage> createState() => _MainCameraPageState();
}

class _MainCameraPageState extends ConsumerState<MainCameraPage>
    with WidgetsBindingObserver {
  Timer? _analysisTimer;
  CompositionAnalysis? _currentAnalysis;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _startAnalysisTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _analysisTimer?.cancel();
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
    if (mounted) {
      ref.read(cameraProvider.notifier).initializeCamera(cameras);
    }
  }

  void _startAnalysisTimer() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && ref.read(showGuidanceProvider)) {
        _runAnalysis();
      }
    });
  }

  void _runAnalysis() {
    final analysis = ProfessionalPhotographerAI.analyze();
    if (mounted) {
      setState(() {
        _currentAnalysis = analysis;
      });
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
