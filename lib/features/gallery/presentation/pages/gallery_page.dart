import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../providers/gallery_provider.dart';
import '../widgets/photo_detail_page.dart';

/// Gallery page showing captured photos in a grid
class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosState = ref.watch(galleryProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('相册'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(galleryProvider.notifier).loadPhotos(),
          ),
        ],
      ),
      body: photosState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, _) => Center(
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
                '加载失败',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              ElevatedButton(
                onPressed: () =>
                    ref.read(galleryProvider.notifier).loadPhotos(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        data: (photos) {
          if (photos.isEmpty) return _buildEmptyState();
          return _buildPhotoGrid(context, ref, photos);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            '暂无照片',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            '拍摄的照片将显示在这里',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(
      BuildContext context, WidgetRef ref, List<PhotoInfo> photos) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.secondary,
      onRefresh: () => ref.read(galleryProvider.notifier).loadPhotos(),
      child: GridView.builder(
        padding: const EdgeInsets.all(AppDimensions.spacingSm),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppDimensions.spacingXs,
          mainAxisSpacing: AppDimensions.spacingXs,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return _PhotoTile(photo: photo);
        },
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final PhotoInfo photo;

  const _PhotoTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PhotoDetailPage(photo: photo),
          ),
        );
      },
      onLongPress: () => _showDeleteDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Time label at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: AppDimensions.spacingXs,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
                child: Text(
                  _formatTime(photo.modifiedTime),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: const Text('删除照片', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('确定要删除这张照片吗？',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // GalleryNotifier will be accessed via provider in real usage
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.guidanceFar),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
