import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../db/local_database.dart';

class SettingsData {
  final int id;
  final int userId;
  final String language;
  final bool darkMode;
  final bool notificationEnabled;

  SettingsData({required this.id, required this.userId, required this.language, required this.darkMode, required this.notificationEnabled});

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      id: json['id'],
      userId: json['userId'],
      language: json['language'] ?? 'es',
      darkMode: json['darkMode'] ?? false,
      notificationEnabled: json['notificationEnabled'] ?? true,
    );
  }
}

class SettingsRepository {
  final String baseUrl = dotenv.get('BASE_URL');
  final LocalDatabase localDatabase;

  SettingsRepository({required this.localDatabase});

  Future<SettingsData> getOrCreateSettings() async {
    // 1. Try to read from local cache first
    final cached = await localDatabase.getCachedSettings();
    if (cached != null) {
      return SettingsData.fromJson(cached);
    }

    final token = await localDatabase.getToken();
    final userId = await localDatabase.getUserId();
    if (token == null || userId == null) throw Exception("Sesión inválida");

    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

    final getRes = await http.get(Uri.parse('$baseUrl/settings?userId=$userId'), headers: headers);
    if (getRes.statusCode == 200 && getRes.body.isNotEmpty) {
      final decoded = jsonDecode(getRes.body);
      final settings = SettingsData.fromJson(decoded);
      await localDatabase.saveSettings(settings.id, settings.language, settings.darkMode, settings.notificationEnabled);
      return settings;
    }

    final postRes = await http.post(
      Uri.parse('$baseUrl/settings'),
      headers: headers,
      body: jsonEncode({"userId": userId, "language": "es", "darkMode": false, "notificationEnabled": true}),
    );

    if (postRes.statusCode == 201 || postRes.statusCode == 200) {
      final settings = SettingsData.fromJson(jsonDecode(postRes.body));
      await localDatabase.saveSettings(settings.id, settings.language, settings.darkMode, settings.notificationEnabled);
      return settings;
    }
    throw Exception("Error al obtener configuraciones");
  }

  Future<void> updateSettings(int id, String language, bool darkMode, bool notifEnabled) async {
    // 1. Write through local cache first
    await localDatabase.saveSettings(id, language, darkMode, notifEnabled);

    // 2. Perform API update
    final token = await localDatabase.getToken();
    final userId = await localDatabase.getUserId();
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

    final response = await http.put(
      Uri.parse('$baseUrl/settings/$id'),
      headers: headers,
      body: jsonEncode({"id": id, "userId": userId, "language": language, "darkMode": darkMode, "notificationEnabled": notifEnabled}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al actualizar configuraciones");
    }
  }
}