export 'secure_storage_interface.dart';
import 'secure_storage_interface.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// flutter_secure_storage 实现（移动端加密存储）
class FlutterSecureStorageImpl implements SecureStorageInterface {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// 工厂：获取安全存储实例
Future<SecureStorageInterface> getSecureStorage() async {
  return FlutterSecureStorageImpl();
}
