import 'package:flutter/material.dart';
import 'package:frame_guide/core/constants/colors.dart';
import 'package:frame_guide/core/constants/dimensions.dart';

/// 统一错误视图组件
///
/// 项目中多处需要显示错误信息，此组件提供一致的错误展示样式。
/// 支持可选的重试按钮。
class ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool compact;

  const ErrorView({
    super.key,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact();
    }
    return _buildFull();
  }

  Widget _buildFull() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 48),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              message ?? '操作失败，请重试',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: AppDimensions.spacingSm),
          Flexible(
            child: Text(
              message ?? '操作失败',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppDimensions.spacingSm),
            GestureDetector(
              onTap: onRetry,
              child: const Text(
                '重试',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 统一错误处理工具
class AppErrorHandler {
  /// 将异常转换为用户友好的错误消息
  static String userMessage(dynamic error) {
    final msg = error.toString();

    if (msg.contains('SocketException') || msg.contains('Connection')) {
      return '网络连接失败，请检查网络设置';
    }
    if (msg.contains('TimeoutException') || msg.contains('timed out')) {
      return '请求超时，请稍后重试';
    }
    if (msg.contains('401') || msg.contains('Unauthorized')) {
      return 'API Key 无效，请在设置中检查';
    }
    if (msg.contains('429') || msg.contains('Too Many Requests')) {
      return '请求过于频繁，请稍后重试';
    }
    if (msg.contains('CameraException')) {
      return '相机异常，请重新打开相机';
    }
    if (msg.contains('FileSystemException') || msg.contains('No such file')) {
      return '文件操作失败，请重试';
    }

    // 截取有用的错误信息（去掉异常类型前缀）
    if (msg.contains(': ')) {
      return msg.split(': ').last;
    }
    return msg.length > 100 ? '${msg.substring(0, 100)}...' : msg;
  }

  /// 判断错误是否可重试
  static bool isRetryable(dynamic error) {
    final msg = error.toString();
    return msg.contains('SocketException') ||
        msg.contains('TimeoutException') ||
        msg.contains('timed out') ||
        msg.contains('429') ||
        msg.contains('500') ||
        msg.contains('502') ||
        msg.contains('503');
  }
}
