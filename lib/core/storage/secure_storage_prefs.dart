export 'secure_storage_interface.dart';
import 'secure_storage_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 回退实现（Web / 桌面端）
class PrefsSecureStorage implements SecureStorageInterface {
  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('secure_$key');
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('secure_$key', value);
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('secure_$key');
  }
}

/// 工厂：获取安全存储实例
Future<SecureStorageInterface> getSecureStorage() async {
  return PrefsSecureStorage();
}
