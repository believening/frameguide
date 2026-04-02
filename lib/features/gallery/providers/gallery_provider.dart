import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Photo info model
class PhotoInfo {
  final String path;
  final String name;
  final DateTime modifiedTime;
  final int? score;

  const PhotoInfo({
    required this.path,
    required this.name,
    required this.modifiedTime,
    this.score,
  });
}

/// Gallery state notifier - loads photos from app documents directory
class GalleryNotifier extends StateNotifier<AsyncValue<List<PhotoInfo>>> {
  GalleryNotifier() : super(const AsyncValue.loading()) {
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    state = const AsyncValue.loading();
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory(directory.path);

      if (!await dir.exists()) {
        state = const AsyncValue.data([]);
        return;
      }

      final files = await dir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.jpg'))
          .map((entity) => entity as File)
          .toList();

      // Sort by modified time descending (newest first)
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      final photos = files.map((file) {
        final stat = file.statSync();
        final name = file.path
            .split('/')
            .last
            .replaceFirst('.jpg', '')
            .replaceFirst('IMG_', 'IMG_');
        return PhotoInfo(
          path: file.path,
          name: name,
          modifiedTime: stat.modified,
        );
      }).toList();

      state = AsyncValue.data(photos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletePhoto(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        await loadPhotos();
      }
    } catch (_) {}
  }
}

/// Gallery photos provider
final galleryProvider =
    StateNotifierProvider<GalleryNotifier, AsyncValue<List<PhotoInfo>>>(
  (ref) => GalleryNotifier(),
);
