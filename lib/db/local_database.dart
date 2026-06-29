import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabase {
  static const String _tokenKey = "jwt_token";
  static const String _householdKey = "household_id";
  static const String _userIdKey = "user_id";
  static const String _emailKey = "user_email";
  static const String _settingsKey = "settings_cache";

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

  Future<void> saveSettings(int id, String language, bool darkMode, bool notificationEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      "id": id,
      "userId": await getUserId() ?? 0,
      "language": language,
      "darkMode": darkMode,
      "notificationEnabled": notificationEnabled,
    };
    await prefs.setString(_settingsKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getCachedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_settingsKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  static const String _dashboardCacheKey = "dashboard_cache_data";
  static const String _quotasCacheKey = "quotas_cache_data";
  static const String _incomeCacheKey = "income_cache_data";

  Future<void> saveDashboardDataToCache(String jsonStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dashboardCacheKey, jsonStr);
  }

  Future<String?> getCachedDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dashboardCacheKey);
  }

  Future<void> saveQuotasCache(String jsonStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quotasCacheKey, jsonStr);
  }

  Future<String?> getCachedQuotas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_quotasCacheKey);
  }

  Future<void> saveIncomeCache(String jsonStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_incomeCacheKey, jsonStr);
  }

  Future<String?> getCachedIncome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_incomeCacheKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}