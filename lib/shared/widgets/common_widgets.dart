import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

/// ============================================================================
/// 共用设计组件 - FrameGuide 统一 UI 风格
/// ============================================================================

/// --------------------------------------------------------------------------
/// 卡片组件
/// --------------------------------------------------------------------------

/// 标准内容卡片
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.secondary,
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusMd),
        border: border,
      ),
      child: child,
    );
  }
}

/// --------------------------------------------------------------------------
/// 分隔线
/// --------------------------------------------------------------------------

/// 标准分隔线（与 AppColors.divider 配合使用）
class AppDivider extends StatelessWidget {
  final double? height;
  final EdgeInsets? padding;

  const AppDivider({
    super.key,
    this.height = 1,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final line = Container(
      height: 1,
      color: AppColors.divider,
    );
    if (padding != null) {
      return Padding(padding: padding!, child: line);
    }
    return line;
  }
}

/// --------------------------------------------------------------------------
/// 空状态组件
/// --------------------------------------------------------------------------

/// 标准空状态视图
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// --------------------------------------------------------------------------
/// 按钮组件
/// --------------------------------------------------------------------------

/// 标准主按钮
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingXl,
          vertical: AppDimensions.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: AppDimensions.spacingSm),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

/// 标准次要按钮
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.textSecondary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingXl,
          vertical: AppDimensions.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppDimensions.spacingSm),
          ],
          Text(label),
        ],
      ),
    );
  }
}

/// --------------------------------------------------------------------------
/// 标签组件
/// --------------------------------------------------------------------------

/// 标准标签 Chip
class AppTag extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;

  const AppTag({
    super.key,
    required this.label,
    required this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(4),
        border: outlined ? Border.all(color: color) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: outlined ? color : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// --------------------------------------------------------------------------
/// Section 标题
/// --------------------------------------------------------------------------

/// Section 标题行（图标 + 文字）
class AppSectionTitle extends StatelessWidget {
  final String emoji;
  final String title;
  final Widget? trailing;

  const AppSectionTitle({
    super.key,
    required this.emoji,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
