import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lms/data/model/login_model/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences prefs;

  AuthLocalDataSource({required this.secureStorage, required this.prefs});

  // save data to local storage Login response data
  Future<void> saveUserData(LoginModel model) async {
    final data = model.data;
    final user = data?.user;

    // /// ================= Access TOKEN =================
    // final accessToken = data?.accessToken;
    // if (accessToken != null && accessToken.isNotEmpty) {
    //   await secureStorage.write(key: 'access_token', value: accessToken);
    // }

    // // refresh token
    // final refreshToken = data?.refreshToken;
    // if (refreshToken != null && refreshToken.isNotEmpty) {
    //   await secureStorage.write(key: 'refresh_token', value: refreshToken);
    // }

    // final accessTokenExpiry = data?.accessTokenExpiry;
    // if (accessTokenExpiry != null) {
    //   await secureStorage.write(
    //     key: 'access_token_expiry',
    //     value: accessTokenExpiry.toString(),
    //   );
    // }

    /// ================= USER INFO =================
    await prefs.setString('userid', user?.userId ?? '');
    await prefs.setString('accessToken', data?.accessToken ?? '');
    await prefs.setString('refreshToken', data?.refreshToken ?? '');
    await prefs.setString('userName', user?.username ?? '');
    await prefs.setString('fullName', user?.fullName ?? '');
    await prefs.setString('email', user?.email ?? '');
    await prefs.setString('status', user?.status ?? '');
    await prefs.setString('role', user?.role ?? '');
    await prefs.setString('mustChangePassword', user?.mustChangePassword ?? '');
    await prefs.setString('lastLoginAt', user?.lastLoginAt.toString() ?? '');
  }

  Future<void> clearSession() async {
    // Delete everything from secure storage
    await secureStorage.deleteAll();

    // Keep onboard value
    final onboardData = prefs.getString('onboard');

    // Clear ALL SharedPreferences
    await prefs.clear();

    // Restore onboard
    if (onboardData != null) {
      await prefs.setString('onboard', onboardData);
    }
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'access_token');
  }
}
