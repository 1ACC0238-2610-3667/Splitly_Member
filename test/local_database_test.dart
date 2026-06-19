import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitly_member/db/local_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de Local Database', () {

    setUp(() {
      // Simulamos SharedPreferences vacío antes de cada test
      SharedPreferences.setMockInitialValues({});
    });

    test('Debe guardar la sesión y recuperar el token correctamente', () async {
      // Arrange
      const testToken = 'jwt_token_12345';
      const testHousehold = 'HH001';
      const testUserId = 1;
      const testEmail = 'test@splitly.com';

      // Act (AQUÍ LLAMAMOS A LA CLASE)
      await LocalDatabase().saveSession(testToken, testHousehold, testUserId, testEmail);
      final retrievedToken = await LocalDatabase().getToken();

      // Assert
      expect(retrievedToken, testToken);
    });

    test('Debe limpiar la sesión correctamente al hacer logout', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'tokenKey': 'old_token',
        'user_email': 'test@splitly.com'
      });

      // Act (AQUÍ LLAMAMOS A LA CLASE)
      await LocalDatabase().clearSession();
      final retrievedToken = await LocalDatabase().getToken();

      // Assert
      expect(retrievedToken, null);
    });
  });
}