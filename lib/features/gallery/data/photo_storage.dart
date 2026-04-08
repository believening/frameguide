import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../camera/models/scene_analysis.dart';

/// Photo info model
class SavedPhoto {
  final String id;
  final String filePath;
  final DateTime takenAt;
  final PhotoAnalysis? analysis;
  final String? sceneType;

  const SavedPhoto({
    required this.id,
    required this.filePath,
    required this.takenAt,
    this.analysis,
    this.sceneType,
  });

  factory SavedPhoto.fromJson(Map<String, dynamic> json) {
    return SavedPhoto(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      takenAt: DateTime.parse(json['takenAt'] as String),
      analysis: json['analysis'] != null
          ? PhotoAnalysis(
              score: json['analysis']['score'] as int,
              summary: json['analysis']['summary'] as String,
              strengths: (json['analysis']['strengths'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList(),
              improvements: (json['analysis']['improvements'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList(),
              nextTimeTip: json['analysis']['nextTimeTip'] as String,
            )
          : null,
      sceneType: json['sceneType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'takenAt': takenAt.toIso8601String(),
      'analysis': analysis != null
          ? {
              'score': analysis!.score,
              'summary': analysis!.summary,
              'strengths': analysis!.strengths,
              'improvements': analysis!.improvements,
              'nextTimeTip': analysis!.nextTimeTip,
            }
          : null,
      'sceneType': sceneType,
    };
  }

  SavedPhoto copyWith({
    String? id,
    String? filePath,
    DateTime? takenAt,
    PhotoAnalysis? analysis,
    String? sceneType,
  }) {
    return SavedPhoto(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      takenAt: takenAt ?? this.takenAt,
      analysis: analysis ?? this.analysis,
      sceneType: sceneType ?? this.sceneType,
    );
  }
}

/// Photo storage service - handles saving/loading photos and metadata
class PhotoStorage {
  static const String _photoExtension = '.jpg';
  static const String _metaExtension = '.json';

  /// Get the photos directory
  Future<Directory> get _photosDir async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${directory.path}/photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir;
  }

  /// Save a photo file and return the SavedPhoto object
  Future<SavedPhoto> savePhoto({
    required String sourcePath,
    required DateTime takenAt,
    String? sceneType,
  }) async {
    final dir = await _photosDir;
    final id = takenAt.millisecondsSinceEpoch.toString();
    final destPath = '${dir.path}/$id$_photoExtension';
    final metaPath = '${dir.path}/$id$_metaExtension';

    // Copy photo file
    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);

    // Create metadata file
    final photo = SavedPhoto(
      id: id,
      filePath: destPath,
      takenAt: takenAt,
      sceneType: sceneType,
    );
    await File(metaPath).writeAsString(jsonEncode(photo.toJson()));

    return photo;
  }

  /// Save photo from bytes and return the SavedPhoto object
  Future<SavedPhoto> savePhotoFromBytes({
    required List<int> bytes,
    required DateTime takenAt,
    String? sceneType,
  }) async {
    final dir = await _photosDir;
    final id = takenAt.millisecondsSinceEpoch.toString();
    final destPath = '${dir.path}/$id$_photoExtension';
    final metaPath = '${dir.path}/$id$_metaExtension';

    // Write photo file
    await File(destPath).writeAsBytes(bytes);

    // Create metadata file
    final photo = SavedPhoto(
      id: id,
      filePath: destPath,
      takenAt: takenAt,
      sceneType: sceneType,
    );
    await File(metaPath).writeAsString(jsonEncode(photo.toJson()));

    return photo;
  }

  /// Load all saved photos (sorted by time descending)
  /// 
  /// 容错：单张照片解析失败不影响整体加载
  Future<List<SavedPhoto>> loadAllPhotos() async {
    try {
      final dir = await _photosDir;
      if (!await dir.exists()) {
        return [];
      }

      final files = await dir.list().where((entity) {
        return entity is File && entity.path.endsWith(_photoExtension);
      }).toList();

      final photos = <SavedPhoto>[];
      for (final file in files) {
        try {
          final metaPath = file.path.replaceFirst(_photoExtension, _metaExtension);
          final metaFile = File(metaPath);

          if (await metaFile.exists()) {
            final json = jsonDecode(await metaFile.readAsString());
            photos.add(SavedPhoto.fromJson(json));
          } else {
            // 从文件信息重建元数据
            final stat = await File(file.path).stat();
            final id = file.path
                .split('/')
                .last
                .replaceFirst(_photoExtension, '');
            photos.add(SavedPhoto(
              id: id,
              filePath: file.path,
              takenAt: stat.modified,
            ));
          }
        } catch (e) {
          // 单张照片解析失败，跳过继续
          debugPrint('跳过损坏的照片元数据: $e');
        }
      }

      // 按时间降序排列（最新在前）
      photos.sort((a, b) => b.takenAt.compareTo(a.takenAt));
      return photos;
    } catch (e) {
      debugPrint('加载照片失败: $e');
      return [];
    }
  }

  /// Update photo metadata (e.g., after AI analysis)
  Future<void> updatePhotoMetadata(SavedPhoto photo) async {
    final metaPath = photo.filePath.replaceFirst(_photoExtension, _metaExtension);
    await File(metaPath).writeAsString(jsonEncode(photo.toJson()));
  }

  /// Delete a photo and its metadata
  Future<void> deletePhoto(SavedPhoto photo) async {
    // Delete photo file
    final photoFile = File(photo.filePath);
    if (await photoFile.exists()) {
      await photoFile.delete();
    }

    // Delete metadata file
    final metaPath = photo.filePath.replaceFirst(_photoExtension, _metaExtension);
    final metaFile = File(metaPath);
    if (await metaFile.exists()) {
      await metaFile.delete();
    }
  }

  /// Get a single photo by ID
  Future<SavedPhoto?> getPhoto(String id) async {
    final dir = await _photosDir;
    final photoPath = '${dir.path}/$id$_photoExtension';
    final metaPath = '${dir.path}/$id$_metaExtension';

    final photoFile = File(photoPath);
    if (!await photoFile.exists()) {
      return null;
    }

    final metaFile = File(metaPath);
    if (await metaFile.exists()) {
      try {
        final json = jsonDecode(await metaFile.readAsString());
        return SavedPhoto.fromJson(json);
      } catch (_) {
        // Fall through to create from file stats
      }
    }

    final stat = await photoFile.stat();
    return SavedPhoto(
      id: id,
      filePath: photoPath,
      takenAt: stat.modified,
    );
  }
}