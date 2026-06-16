import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sign_up_request.dart';
import '../models/sign_in_request.dart';
import '../models/auth_response.dart';

class AuthRepository {
  static const String baseUrl = "http://192.168.1.31:5070/api/v1";

  Future<void> signUpMember(SignUpRequest request) async {
    final url = Uri.parse('$baseUrl/authentication/sign-up');
    try {
      final response = await http.post(
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
      final response = await http.post(
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