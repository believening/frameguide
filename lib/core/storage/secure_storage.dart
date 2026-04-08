/// 安全存储 - 条件导出
/// 
/// 移动端 (dart:io): 使用 flutter_secure_storage（加密存储）
/// Web/桌面: 使用 SharedPreferences 回退
/// 
/// 用法：import 'secure_storage.dart' 即可
export 'secure_storage_interface.dart'
  if (dart.library.io) 'secure_storage_native.dart'
  if (dart.library.html) 'secure_storage_prefs.dart';
