import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../../core/constants/colors.dart';

/// Camera state
class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final bool isFrontCamera;
  final String? error;

  const CameraState({
    this.controller,
    this.isInitialized = false,
    this.isFrontCamera = true,
    this.error,
  });

  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    bool? isFrontCamera,
    String? error,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      error: error,
    );
  }
}

/// Camera state notifier
class CameraNotifier extends StateNotifier<CameraState> {
  final Ref ref;
  List<CameraDescription> _cameras = [];

  CameraNotifier(this.ref) : super(const CameraState());

  Future<void> initializeCamera(List<CameraDescription> cameras) async {
    _cameras = cameras;
    await _setupCamera();
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    
    state = state.copyWith(isInitialized: false);
    await state.controller?.dispose();
    
    state = state.copyWith(isFrontCamera: !state.isFrontCamera);
    await _setupCamera();
  }

  /// 重置相机状态（生命周期变化时使用）
  void resetCamera() {
    // 释放现有 controller
    state.controller?.dispose();
    // 重置状态，避免持有已释放的 controller 引用
    state = const CameraState(isFrontCamera: true);
  }

  Future<void> _setupCamera() async {
    if (_cameras.isEmpty) {
      state = state.copyWith(error: 'No cameras available');
      return;
    }

    final camera = state.isFrontCamera
        ? _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras.first,
          )
        : _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras.first,
          );

    // 获取用户配置的分辨率设置
    final resolution = ref.read(cameraResolutionProvider);
    final preset = resolution.resolutionPreset;

    final controller = CameraController(
      camera,
      preset,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      state = state.copyWith(
        controller: controller,
        isInitialized: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<XFile?> takePicture() async {
    if (state.controller == null || !state.isInitialized) return null;
    return await state.controller!.takePicture();
  }

  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}

/// Camera provider
final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  return CameraNotifier(ref);
});

/// Composition grid style provider
final gridStyleProvider = StateProvider<GridStyle>((ref) => GridStyle.ruleOfThirds);

/// Guidance visibility provider
final showGuidanceProvider = StateProvider<bool>((ref) => true);

/// Voice guidance provider
final voiceGuidanceProvider = StateProvider<bool>((ref) => true);

/// Camera resolution provider
final cameraResolutionProvider = StateProvider<CameraResolution>((ref) => CameraResolution.high);

/// Camera resolution options
enum CameraResolution {
  low,
  medium,
  high,
  veryHigh,
}

extension CameraResolutionExtension on CameraResolution {
  String get displayName {
    switch (this) {
      case CameraResolution.low:
        return '低 (480p)';
      case CameraResolution.medium:
        return '中 (720p)';
      case CameraResolution.high:
        return '高 (1080p)';
      case CameraResolution.veryHigh:
        return '最高 (max)';
    }
  }

  String get description {
    switch (this) {
      case CameraResolution.low:
        return '节省存储空间';
      case CameraResolution.medium:
        return '平衡画质与大小';
      case CameraResolution.high:
        return '推荐画质';
      case CameraResolution.veryHigh:
        return '最佳画质';
    }
  }

  /// 映射到 CameraController 的 ResolutionPreset
  ResolutionPreset get resolutionPreset {
    switch (this) {
      case CameraResolution.low:
        return ResolutionPreset.low;
      case CameraResolution.medium:
        return ResolutionPreset.medium;
      case CameraResolution.high:
        return ResolutionPreset.high;
      case CameraResolution.veryHigh:
        return ResolutionPreset.max;
    }
  }
}
