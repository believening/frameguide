import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../camera/models/scene_analysis.dart';
import '../../providers/gallery_provider.dart';
import '../../data/photo_storage.dart';

/// Photo detail page with full-screen view and AI analysis
/// 
/// 支持两种构造方式：
/// - photo 参数：直接传入照片对象（推荐）
/// - photoId 参数：通过 ID 从 Provider 查找
class PhotoDetailPage extends ConsumerStatefulWidget {
  final SavedPhoto? photo;
  final String? photoId; // 备选：可通过 ID 查找

  const PhotoDetailPage({
    super.key,
    this.photo,
    this.photoId,
  }) : assert(photo != null || photoId != null, '必须提供 photo 或 photoId');

  @override
  ConsumerState<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends ConsumerState<PhotoDetailPage> {
  SavedPhoto? _photo;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    if (widget.photo != null) {
      _photo = widget.photo;
    } else if (widget.photoId != null) {
      _loadPhotoById();
    }
  }

  Future<void> _loadPhotoById() async {
    if (widget.photoId == null) return;
    final galleryState = ref.read(galleryProvider);
    final found = galleryState.photos.where((p) => p.id == widget.photoId).firstOrNull;
    if (found != null && mounted) {
      setState(() => _photo = found);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_photo == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }
    final photo = _photo!; // 空检查已通过，安全解包
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          _formatDateTime(photo.takenAt),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Photo display
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.file(
                  File(photo.filePath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: AppColors.textSecondary,
                        size: 64,
                      ),
                      SizedBox(height: AppDimensions.spacingMd),
                      Text(
                        '无法加载图片',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Analysis panel or analyze button
          _buildAnalysisSection(),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection() {
    // Watch gallery for changes to this photo's analysis using select
    // This only triggers rebuild when the specific photo's analysis changes
    ref.listen<GalleryState>(galleryProvider, (prev, next) {
      if (_photo == null) return;
      final prevAnalysis = prev?.photos
          .where((p) => p.id == _photo!.id)
          .firstOrNull
          ?.analysis;
      final nextAnalysis = next.photos
          .where((p) => p.id == _photo!.id)
          .firstOrNull
          ?.analysis;
      if (nextAnalysis != prevAnalysis) {
        final updatedPhoto = next.photos
            .where((p) => p.id == _photo!.id)
            .firstOrNull;
        if (updatedPhoto != null) {
          setState(() {
            _photo = updatedPhoto;
          });
        }
      }
    });

    if (_isAnalyzing) {
      return _buildAnalyzingIndicator();
    }

    if (_photo?.analysis != null) {
      return _buildAnalysisCard(_photo!.analysis!);
    }

    return _buildAnalyzeButton();
  }

  Widget _buildAnalyzingIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          const Text(
            'AI 分析中...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          const Text(
            '正在分析构图、光线、构图等',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _analyzePhoto,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('开始 AI 分析'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(PhotoAnalysis analysis) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score header
            Row(
              children: [
                // Score badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _getScoreColor(analysis.score),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Center(
                    child: Text(
                      '${analysis.score}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getScoreLabel(analysis.score),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(analysis.score),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        analysis.summary,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingLg),

            // Strengths
            if (analysis.strengths.isNotEmpty) ...[
              _buildSectionTitle('优点', Icons.thumb_up, AppColors.guidanceGood),
              const SizedBox(height: AppDimensions.spacingSm),
              ...analysis.strengths.map((s) => _buildListItem(s, AppColors.guidanceGood)),
              const SizedBox(height: AppDimensions.spacingMd),
            ],

            // Improvements
            if (analysis.improvements.isNotEmpty) ...[
              _buildSectionTitle('改进建议', Icons.lightbulb, AppColors.guidanceAdjusting),
              const SizedBox(height: AppDimensions.spacingSm),
              ...analysis.improvements.map((s) => _buildListItem(s, AppColors.guidanceAdjusting)),
              const SizedBox(height: AppDimensions.spacingMd),
            ],

            // Next time tip
            if (analysis.nextTimeTip.isNotEmpty) ...[
              _buildSectionTitle('下次拍摄建议', Icons.camera_alt, AppColors.accent),
              const SizedBox(height: AppDimensions.spacingSm),
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Expanded(
                      child: Text(
                        analysis.nextTimeTip,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.spacingLg),

            // Re-analyze button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _analyzePhoto,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重新分析'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.textSecondary),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: AppDimensions.spacingSm),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.spacingXl,
        top: AppDimensions.spacingXs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.guidanceGood;
    if (score >= 60) return AppColors.guidanceAdjusting;
    return AppColors.guidanceFar;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return '优秀';
    if (score >= 60) return '良好';
    if (score >= 40) return '一般';
    return '需改进';
  }

  Future<void> _analyzePhoto() async {
    if (_photo == null) return;
    setState(() => _isAnalyzing = true);

    try {
      await ref.read(galleryProvider.notifier).analyzePhoto(_photo!);
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showDeleteDialog() {
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
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(galleryProvider.notifier).deletePhoto(_photo!);
              if (mounted) {
                Navigator.pop(context);
              }
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

  String _formatDateTime(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}