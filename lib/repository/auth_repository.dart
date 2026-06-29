import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/http_client.dart';
import '../models/sign_up_request.dart';
import '../models/sign_in_request.dart';
import '../models/auth_response.dart';

class AuthRepository {
  final String baseUrl = dotenv.get('BASE_URL');
  final SharedHttpClient client = SharedHttpClient();

  Future<void> signUpMember(SignUpRequest request) async {
    final url = Uri.parse('$baseUrl/authentication/sign-up');
    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['message'] ?? 'Error al registrar');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<AuthResponse> signIn(SignInRequest request) async {
    final url = Uri.parse('$baseUrl/authentication/sign-in');
    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return AuthResponse.fromJson(decoded);
      } else {
        throw Exception('Correo o contraseña incorrectos');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}