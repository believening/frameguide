import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../camera/providers/analysis_provider.dart';
import '../../camera/models/scene_analysis.dart';
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
        error: e.toString(),
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

      // Reload photos
      await loadPhotos();

      // Auto-analyze if requested
      if (autoAnalyze) {
        await analyzePhoto(photo);
      }

      return photo;
    } catch (e) {
      state = state.copyWith(
        status: GalleryStatus.error,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Analyze a single photo with AI
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

      // Reload photos
      await loadPhotos();
    } catch (e) {
      state = state.copyWith(
        status: GalleryStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Delete a photo
  Future<void> deletePhoto(SavedPhoto photo) async {
    try {
      await _storage.deletePhoto(photo);
      await loadPhotos();
    } catch (e) {
      state = state.copyWith(
        status: GalleryStatus.error,
        error: e.toString(),
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