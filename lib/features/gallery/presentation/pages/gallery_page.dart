import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../providers/gallery_provider.dart';
import '../../data/photo_storage.dart';
import 'photo_detail_page.dart';

/// Gallery page showing captured photos in a grid
class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryState = ref.watch(galleryProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('相册'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(galleryProvider.notifier).loadPhotos(),
          ),
        ],
      ),
      body: _buildBody(context, ref, galleryState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, GalleryState state) {
    switch (state.status) {
      case GalleryStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );

      case GalleryStatus.error:
        return _buildErrorState(context, ref, state.error);

      case GalleryStatus.analyzing:
        return _buildLoadedState(context, ref, state.photos, isAnalyzing: true);

      case GalleryStatus.loaded:
        if (state.photos.isEmpty) {
          return _buildEmptyState();
        }
        return _buildLoadedState(context, ref, state.photos);
    }
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.guidanceFar,
              size: 48,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text(
              '加载失败',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              error ?? '未知错误',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            ElevatedButton(
              onPressed: () => ref.read(galleryProvider.notifier).loadPhotos(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
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
          const Text(
            '还没有照片',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          const Text(
            '去拍一张吧',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    WidgetRef ref,
    List<SavedPhoto> photos, {
    bool isAnalyzing = false,
  }) {
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
          return _PhotoTile(
            photo: photo,
            onDelete: () => _showDeleteDialog(context, ref, photo),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    SavedPhoto photo,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: const Text(
          '删除照片',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '确定要删除这张照片吗？删除后无法恢复。',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(galleryProvider.notifier).deletePhoto(photo);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.guidanceFar,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final SavedPhoto photo;
  final VoidCallback onDelete;

  const _PhotoTile({
    required this.photo,
    required this.onDelete,
  });

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
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo image
            Image.file(
              File(photo.filePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Score badge (top-right)
            if (photo.analysis != null)
              Positioned(
                top: 4,
                right: 4,
                child: _ScoreBadge(score: photo.analysis!.score),
              ),

            // Pending analysis badge (top-right)
            if (photo.analysis == null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '待分析',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // Time label (bottom)
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
                  _formatTime(photo.takenAt),
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
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: _getScoreColor(score),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$score',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.guidanceGood;
    if (score >= 60) return AppColors.guidanceAdjusting;
    return AppColors.guidanceFar;
  }
}