import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabase {
  static const String _tokenKey = "jwt_token";
  static const String _householdKey = "household_id";
  static const String _userIdKey = "user_id";
  static const String _emailKey = "user_email";

  Future<void> saveSession(String token, String householdId, int userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_householdKey, householdId);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_emailKey, email);
  }

  Future<String?> getToken() async => (await SharedPreferences.getInstance()).getString(_tokenKey);
  Future<String?> getHouseholdId() async => (await SharedPreferences.getInstance()).getString(_householdKey);
  Future<int?> getUserId() async => (await SharedPreferences.getInstance()).getInt(_userIdKey);
  Future<String?> getEmail() async => (await SharedPreferences.getInstance()).getString(_emailKey);

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}