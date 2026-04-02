import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'photographer_ai_service.dart';

/// 真实 AI 构图分析服务（基于 ML Kit 人像检测）
class MLCompositionAnalyzer {
  final FaceDetector _faceDetector;
  
  MLCompositionAnalyzer() : _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  /// 分析相机画面并返回构图建议
  Future<CompositionAnalysis> analyzeFrame(CameraImage image, int rotation) async {
    try {
      // 将 CameraImage 转换为 InputImage
      final inputImage = _convertCameraImage(image, rotation);
      if (inputImage == null) {
        return _getFallbackAnalysis();
      }

      // 检测人脸
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return _createNoFaceAnalysis();
      }

      if (faces.length > 1) {
        return _createMultipleFacesAnalysis(faces.length);
      }

      // 单人人像分析
      return _analyzeSingleFace(faces.first, inputImage.metadata?.size);

    } catch (e) {
      return _getFallbackAnalysis();
    }
  }

  /// 转换 CameraImage 为 InputImage
  InputImage? _convertCameraImage(CameraImage image, int rotation) {
    try {
      final rotationAngle = InputImageRotationValue.fromRawValue(rotation);
      if (rotationAngle == null) return null;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      final plane = image.planes.first;

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotationAngle,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// 分析单人人像
  CompositionAnalysis _analyzeSingleFace(Face face, Size? imageSize) {
    if (imageSize == null) return _getFallbackAnalysis();

    final faceRect = face.boundingBox;
    
    // 计算人脸在画面中的相对位置 (0-1)
    final faceCenterX = (faceRect.left + faceRect.right) / 2 / imageSize.width;
    final faceCenterY = (faceRect.top + faceRect.bottom) / 2 / imageSize.height;
    final faceWidth = faceRect.width / imageSize.width;
    final faceHeight = faceRect.height / imageSize.height;

    // 计算构图评分和指导
    List<Guidance> guidances = [];
    String tip;
    String photographerNote;
    int score;

    // 检查人脸大小（太远或太近）
    final faceAreaRatio = faceWidth * faceHeight;
    double sizeScore;
    if (faceAreaRatio < 0.03) {
      // 人脸太小，说明太远
      guidances.add(Guidance(
        type: GuidanceType.moveVertical,
        direction: '往前',
        instruction: '往前走近一点，人像太远了',
        priority: 0.9,
      ));
      sizeScore = 40;
    } else if (faceAreaRatio > 0.25) {
      // 人脸太大，说明太近
      guidances.add(Guidance(
        type: GuidanceType.moveVertical,
        direction: '往后',
        instruction: '往后退一步，画面太满了',
        priority: 0.9,
      ));
      sizeScore = 50;
    } else {
      sizeScore = 85;
    }

    // 检查水平位置（三分法）
    double horizontalScore;
    if (faceCenterX < 0.3) {
      guidances.add(Guidance(
        type: GuidanceType.moveHorizontal,
        direction: '往右',
        instruction: '往右移动一点，人像偏左了',
        priority: 0.8,
      ));
      horizontalScore = 55;
    } else if (faceCenterX > 0.7) {
      guidances.add(Guidance(
        type: GuidanceType.moveHorizontal,
        direction: '往左',
        instruction: '往左移动一点，人像偏右了',
        priority: 0.8,
      ));
      horizontalScore = 55;
    } else if (faceCenterX < 0.38 || faceCenterX > 0.62) {
      horizontalScore = 75;
      // 轻微偏左或偏右
      if (faceCenterX < 0.5) {
        guidances.add(Guidance(
          type: GuidanceType.moveHorizontal,
          direction: '往右',
          instruction: '轻微往右调一点会更平衡',
          priority: 0.5,
        ));
      } else {
        guidances.add(Guidance(
          type: GuidanceType.moveHorizontal,
          direction: '往左',
          instruction: '轻微往左调一点会更平衡',
          priority: 0.5,
        ));
      }
    } else {
      horizontalScore = 90;
    }

    // 检查上下位置（眼睛在三分线附近）
    double verticalScore;
    if (faceCenterY < 0.25) {
      guidances.add(Guidance(
        type: GuidanceType.adjustHeight,
        direction: '',
        instruction: '稍微蹲低一点，人像太高了',
        priority: 0.7,
      ));
      verticalScore = 50;
    } else if (faceCenterY > 0.65) {
      guidances.add(Guidance(
        type: GuidanceType.adjustHeight,
        direction: '',
        instruction: '站高一点或举高相机，人像太低了',
        priority: 0.7,
      ));
      verticalScore = 50;
    } else if (faceCenterY < 0.35 || faceCenterY > 0.55) {
      verticalScore = 75;
    } else {
      verticalScore = 90;
    }

    // 计算综合评分
    score = ((sizeScore + horizontalScore + verticalScore) / 3).round();

    // 生成摄影师建议
    if (guidances.isEmpty) {
      tip = '构图完美！保持当前机位';
      photographerNote = '人像位置理想，光线充足时可以拍摄了';
    } else if (guidances.length == 1) {
      tip = '基本到位，调整一下会更完美';
      photographerNote = _getAdjustmentNote(guidances.first.type);
    } else {
      tip = '需要调整几个方面来优化构图';
      photographerNote = '按照建议逐一调整，获得最佳构图效果';
    }

    return CompositionAnalysis(
      score: score,
      tip: tip,
      guidances: guidances,
      photographerNote: photographerNote,
    );
  }

  String _getAdjustmentNote(GuidanceType type) {
    switch (type) {
      case GuidanceType.moveHorizontal:
        return '三分法构图，将人物放在三分线附近会更协调';
      case GuidanceType.moveVertical:
        return '合适的拍摄距离让背景虚化效果更好看';
      case GuidanceType.adjustHeight:
        return '眼睛在画面上1/3处是经典人像构图';
      case GuidanceType.adjustAngle:
        return '45度侧脸是最立体的人像角度';
      case GuidanceType.zoom:
        return '合适的焦距避免畸变，85mm是经典人像焦段';
      case GuidanceType.recompose:
        return '重新构图可以让画面更有层次';
    }
  }

  CompositionAnalysis _createNoFaceAnalysis() {
    return const CompositionAnalysis(
      score: 20,
      tip: '未检测到人脸，请调整取景',
      guidances: [
        Guidance(
          type: GuidanceType.recompose,
          direction: '',
          instruction: '确保人脸在取景框内',
          priority: 1.0,
        ),
      ],
      photographerNote: '人像摄影首先要确保人脸可见，尝试调整角度或距离',
    );
  }

  CompositionAnalysis _createMultipleFacesAnalysis(int count) {
    return CompositionAnalysis(
      score: 40,
      tip: '检测到 $count 个人脸，构图有些拥挤',
      guidances: [
        const Guidance(
          type: GuidanceType.moveVertical,
          direction: '往后',
          instruction: '往后退一步，让所有人都在画面内',
          priority: 0.9,
        ),
        const Guidance(
          type: GuidanceType.zoom,
          direction: '',
          instruction: '也可以切换到广角镜头',
          priority: 0.6,
        ),
      ],
      photographerNote: '合影时确保每个人脸大小适中，光线均匀',
    );
  }

  CompositionAnalysis _getFallbackAnalysis() {
    return const CompositionAnalysis(
      score: 50,
      tip: '正在分析画面...',
      guidances: [
        Guidance(
          type: GuidanceType.recompose,
          direction: '',
          instruction: '请确保光线充足',
          priority: 0.5,
        ),
      ],
      photographerNote: '充足的光线有助于获得更清晰的人像',
    );
  }

  void dispose() {
    _faceDetector.close();
  }
}
