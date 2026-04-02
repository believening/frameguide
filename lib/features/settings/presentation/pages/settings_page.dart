import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../camera/providers/camera_provider.dart';
import '../../../camera/presentation/widgets/composition_overlay.dart';

/// Settings page
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridStyle = ref.watch(gridStyleProvider);
    final showGuidance = ref.watch(showGuidanceProvider);
    final voiceGuidance = ref.watch(voiceGuidanceProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          // Composition settings section
          _SectionHeader(title: '构图辅助'),
          const SizedBox(height: AppDimensions.spacingMd),
          _SettingsCard(
            children: [
              _GridStylePreview(
                currentStyle: gridStyle,
                onChanged: (style) {
                  ref.read(gridStyleProvider.notifier).state = style;
                },
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Guidance settings section
          _SectionHeader(title: 'AI 指导'),
          const SizedBox(height: AppDimensions.spacingMd),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: const Text('显示构图指导'),
                subtitle: const Text('在取景框上显示方向箭头和提示'),
                value: showGuidance,
                onChanged: (value) {
                  ref.read(showGuidanceProvider.notifier).state = value;
                },
                activeColor: AppColors.accent,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('语音播报'),
                subtitle: const Text('通过语音提供构图建议'),
                value: voiceGuidance,
                onChanged: (value) {
                  ref.read(voiceGuidanceProvider.notifier).state = value;
                },
                activeColor: AppColors.accent,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Preview section
          _SectionHeader(title: '构图线预览'),
          const SizedBox(height: AppDimensions.spacingMd),
          _GridPreviewCard(gridStyle: gridStyle),

          const SizedBox(height: AppDimensions.spacingXl),

          // About section
          _SectionHeader(title: '关于'),
          const SizedBox(height: AppDimensions.spacingMd),
          _SettingsCard(
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline, color: AppColors.accent),
                title: Text('FrameGuide'),
                subtitle: Text('版本 0.1.0'),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.code, color: AppColors.accent),
                title: Text('智能构图相机'),
                subtitle: Text('AI 驱动的机位和角度推荐'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimensions.spacingXs),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _GridStylePreview extends StatelessWidget {
  final GridStyle currentStyle;
  final ValueChanged<GridStyle> onChanged;

  const _GridStylePreview({
    required this.currentStyle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '构图线样式',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: GridStyle.values.map((style) {
              final isSelected = style == currentStyle;
              return GestureDetector(
                onTap: () => onChanged(style),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                    vertical: AppDimensions.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.textSecondary,
                    ),
                  ),
                  child: Text(
                    style.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _GridPreviewCard extends StatelessWidget {
  final GridStyle gridStyle;

  const _GridPreviewCard({required this.gridStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
              ),
            ),
            // Grid overlay
            Positioned.fill(
              child: CompositionOverlay(style: gridStyle),
            ),
            // Label
            Positioned(
              bottom: AppDimensions.spacingSm,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                    vertical: AppDimensions.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.overlayBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    gridStyle.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
