/// 安全存储 barrel 文件
/// 
/// 统一导出接口 + 条件实现
/// - SecureStorageInterface: 接口类型
/// - getSecureStorage(): 获取平台对应实例
/// 
/// 移动端 (dart:io): flutter_secure_storage 加密存储
/// Web/桌面: SharedPreferences 回退

// 接口始终可用
export 'secure_storage_interface.dart';

// 条件导入实现
export 'secure_storage_prefs.dart' // 默认（Web/桌面）
  if (dart.library.io) 'secure_storage_native.dart'; // 移动端
