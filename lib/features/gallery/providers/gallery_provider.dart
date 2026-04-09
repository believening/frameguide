import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frame_guide/core/widgets/error_view.dart';
import '../../camera/providers/analysis_provider.dart';
import '../data/photo_storage.dart';

/// Gallery state
enum GalleryStatus {
  loading,
  loaded,
  analyzing,
  error,
}

/// Gallery state data
class GalleryState {
  final List<SavedPhoto> photos;
  final GalleryStatus status;
  final String? error;

  const GalleryState({
    this.photos = const [],
    this.status = GalleryStatus.loading,
    this.error,
  });

  GalleryState copyWith({
    List<SavedPhoto>? photos,
    GalleryStatus? status,
    String? error,
  }) {
    return GalleryState(
      photos: photos ?? this.photos,
      status: status ?? this.status,
      error: error,
    );
  }
}

/// Gallery notifier - manages photo list and AI analysis
class GalleryNotifier extends StateNotifier<GalleryState> {
  final Ref _ref;
  final PhotoStorage _storage = PhotoStorage();

  GalleryNotifier(this._ref) : super(const GalleryState()) {
    loadPhotos();
  }

  /// Load all photos from storage
  Future<void> loadPhotos() async {
    state = state.copyWith(status: GalleryStatus.loading);

    try {
      final photos = await _storage.loadAllPhotos();
      state = state.copyWith(
        photos: photos,
        status: GalleryStatus.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        status: GalleryStatus.error,
        error: AppErrorHandler.userMessage(e),
      );
    }
  }

  /// Save a new photo from bytes and optionally analyze it
  Future<SavedPhoto?> savePhoto({
    required Uint8List bytes,
    required DateTime takenAt,
    String? sceneType,
    bool autoAnalyze = false,
  }) async {
    try {
      final photo = await _storage.savePhotoFromBytes(
        bytes: bytes,
        takenAt: takenAt,
        sceneType: sceneType,
      );

      // 把新照片加到列表头部（不重载全部）
      state = state.copyWith(
        photos: [photo, ...state.photos],
        status: GalleryStatus.loaded,
      );

      // Auto-analyze if requested
      if (autoAnalyze) {
        await analyzePhoto(photo);
      }

      return photo;
    } catch (e) {
      state = state.copyWith(
        status: GalleryStatus.error,
        error: AppErrorHandler.userMessage(e),
      );
      return null;
    }
  }

  /// Analyze a single photo with AI (不重载全部照片，只更新当前照片)
  Future<void> analyzePhoto(SavedPhoto photo) async {
    state = state.copyWith(status: GalleryStatus.analyzing);

    try {
      // Read photo bytes
      final bytes = await File(photo.filePath).readAsBytes();

      // Call AI service
      final visionAI = _ref.read(visionAIProvider);
      final analysis = await visionAI.analyzePhoto(bytes);

      // Update photo metadata
      final updatedPhoto = photo.copyWith(analysis: analysis);
      await _storage.updatePhotoMetadata(updatedPhoto);

      // 只更新列表中对应的那张照片，不重载全部
      final updatedPhotos = state.photos.map((p) {
        return p.id == updatedPhoto.id ? updatedPhoto : p;
      }).toList();
      state = state.copyWith(
        photos: updatedPhotos,
        status: GalleryStatus.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        status: GalleryStatus.error,
        error: AppErrorHandler.userMessage(e),
      );
    }
  }

  /// Delete a photo (不重载全部，只从列表移除)
  Future<void> deletePhoto(SavedPhoto photo) async {
    try {
      await _storage.deletePhoto(photo);
      // 从列表中移除，不重载全部
      final updatedPhotos = state.photos.where((p) => p.id != photo.id).toList();
      state = state.copyWith(photos: updatedPhotos);
    } catch (e) {
      state = state.copyWith(
        status: GalleryStatus.error,
        error: AppErrorHandler.userMessage(e),
      );
    }
  }

  /// Get a photo by ID
  SavedPhoto? getPhotoById(String id) {
    try {
      return state.photos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Photo storage provider
final photoStorageProvider = Provider<PhotoStorage>((ref) {
  return PhotoStorage();
});

/// Gallery notifier provider
final galleryProvider =
    StateNotifierProvider<GalleryNotifier, GalleryState>((ref) {
  return GalleryNotifier(ref);
});