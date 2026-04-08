import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../camera/providers/analysis_provider.dart';
import '../../../camera/providers/camera_provider.dart';

/// 设置页面
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 延迟加载配置到输入框
    Future.microtask(() {
      final config = ref.read(aiConfigProvider);
      _apiKeyController.text = config.apiKey;
      _baseUrlController.text = config.baseUrl;
      _modelController.text = config.model;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gridStyle = ref.watch(gridStyleProvider);
    final showGuidance = ref.watch(showGuidanceProvider);
    final aiConfig = ref.watch(aiConfigProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          // === AI 服务配置 ===
          _sectionHeader('AI 服务'),
          const SizedBox(height: AppDimensions.spacingMd),
          _settingsCard([
            // 供应商选择
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI 供应商',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  ...AIProvider.values.map((provider) => RadioListTile<AIProvider>(
                        title: Text(provider.displayName),
                        value: provider,
                        groupValue: aiConfig.provider,
                        onChanged: (value) {
                          if (value != null) {
                            _updateProvider(value);
                          }
                        },
                        activeColor: AppColors.accent,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      )),
                ],
              ),
            ),
            const Divider(height: 1),
            // API Key（Mock 模式下隐藏）
            if (aiConfig.provider != AIProvider.mock)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Key',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '输入 API Key',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: AppColors.primary,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                          borderSide:
                              const BorderSide(color: AppColors.accent),
                        ),
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                      onChanged: (_) => _saveConfig(),
                    ),
                  ],
                ),
              ),
            // Base URL（高级配置）
            if (aiConfig.provider != AIProvider.mock)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API 地址',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    TextField(
                      controller: _baseUrlController,
                      decoration: InputDecoration(
                        hintText: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.primary,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                          borderSide:
                              const BorderSide(color: AppColors.accent),
                        ),
                      ),
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 13),
                      onChanged: (_) => _saveConfig(),
                    ),
                  ],
                ),
              ),
            // 模型名称
            if (aiConfig.provider != AIProvider.mock)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '模型',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    TextField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        hintText: 'glm-4v-flash',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.primary,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                          borderSide:
                              const BorderSide(color: AppColors.accent),
                        ),
                      ),
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 13),
                      onChanged: (_) => _saveConfig(),
                    ),
                  ],
                ),
              ),
          ]),

          const SizedBox(height: AppDimensions.spacingXl),

          // === 构图辅助 ===
          _sectionHeader('构图辅助'),
          const SizedBox(height: AppDimensions.spacingMd),
          _settingsCard([
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '构图线样式',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Wrap(
                    spacing: AppDimensions.spacingSm,
                    runSpacing: AppDimensions.spacingSm,
                    children: GridStyle.values.map((style) {
                      final isSelected = style == gridStyle;
                      return GestureDetector(
                        onTap: () {
                          ref.read(gridStyleProvider.notifier).state = style;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingMd,
                            vertical: AppDimensions.spacingSm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSm),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                            ),
                          ),
                          child: Text(
                            style.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('实时构图指引'),
              subtitle: const Text('在取景框上显示构图微调提示'),
              value: showGuidance,
              onChanged: (value) {
                ref.read(showGuidanceProvider.notifier).state = value;
              },
              activeColor: AppColors.accent,
            ),
          ]),

          const SizedBox(height: AppDimensions.spacingXl),

          // === 关于 ===
          _sectionHeader('关于'),
          const SizedBox(height: AppDimensions.spacingMd),
          _settingsCard([
            const ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.accent),
              title: Text('FrameGuide'),
              subtitle: Text('版本 2.0.0'),
            ),
            const Divider(height: 1),
            const ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.accent),
              title: Text('智能机位推荐'),
              subtitle: Text('AI 驱动的拍摄机位和角度推荐'),
            ),
          ]),
        ],
      ),
    );
  }

  void _updateProvider(AIProvider provider) {
    final config = ref.read(aiConfigProvider);
    ref.read(aiConfigProvider.notifier).updateConfig(
          config.copyWith(provider: provider),
        );
  }

  void _saveConfig() {
    // 延迟保存，避免每次按键都保存
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final config = ref.read(aiConfigProvider);
      ref.read(aiConfigProvider.notifier).updateConfig(
            config.copyWith(
              apiKey: _apiKeyController.text,
              baseUrl: _baseUrlController.text,
              model: _modelController.text,
            ),
          );
    });
  }

  Widget _sectionHeader(String title) {
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

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(children: children),
    );
  }
}
