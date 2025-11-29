import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/constants/enums.dart';

/// Local data source for authentication (caching)
abstract class AuthLocalDataSource {
  Future<void> cacheUser({
    required String userId,
    required String email,
    required UserType userType,
  });

  Future<Map<String, dynamic>?> getCachedUser();

  Future<void> clearCache();

  Future<bool> isLoggedIn();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> cacheUser({
    required String userId,
    required String email,
    required UserType userType,
  }) async {
    try {
      await _prefs.setString(StorageKeys.userId, userId);
      await _prefs.setString(StorageKeys.userEmail, email);
      await _prefs.setString(StorageKeys.userType, userType.value);
      await _prefs.setBool(StorageKeys.isLoggedIn, true);
    } catch (e) {
      throw CacheException('Failed to cache user data');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedUser() async {
    try {
      final userId = _prefs.getString(StorageKeys.userId);
      final email = _prefs.getString(StorageKeys.userEmail);
      final userType = _prefs.getString(StorageKeys.userType);

      if (userId == null || email == null || userType == null) {
        return null;
      }

      return {'userId': userId, 'email': email, 'userType': userType};
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _prefs.remove(StorageKeys.userId);
      await _prefs.remove(StorageKeys.userEmail);
      await _prefs.remove(StorageKeys.userType);
      await _prefs.setBool(StorageKeys.isLoggedIn, false);
    } catch (e) {
      throw CacheException('Failed to clear cache');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return _prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }
}
