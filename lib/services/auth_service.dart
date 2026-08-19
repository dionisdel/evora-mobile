import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/secure_storage.dart';
import '../models/user.dart';

class LoginResponse {
  final String token;
  final String expiresAt;
  final User user;

  const LoginResponse({
    required this.token,
    required this.expiresAt,
    required this.user,
  });
}

/// Servicio de autenticación.
class AuthService {
  /// Autenticar usuario contra la API Evora.
  /// Valida que el perfil sea coach o colaborador.
  static Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      if (user.perfil != 'coach' && user.perfil != 'colaborador') {
        throw AuthException('PERFIL_NO_AUTORIZADO');
      }

      await SecureStorage.saveToken(data['token'] as String);
      return LoginResponse(
        token: data['token'] as String,
        expiresAt: data['expires_at'] as String,
        user: user,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final msg = e.response?.data?['error']?['message'] as String? ?? '';
        if (msg.contains('deshabilitada')) {
          throw AuthException('CUENTA_BLOQUEADA');
        }
        throw AuthException('PERFIL_NO_AUTORIZADO');
      }
      if (e.response?.statusCode == 429) {
        throw AuthException('DEMASIADOS_INTENTOS');
      }
      rethrow;
    }
  }

  /// Renovar token sin re-login.
  static Future<String> refreshToken() async {
    final response = await apiClient.post('/auth/refresh');
    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    await SecureStorage.saveToken(token);
    return token;
  }

  /// Cerrar sesión.
  static Future<void> logout() async {
    await SecureStorage.removeToken();
  }
}

class AuthException implements Exception {
  final String code;
  const AuthException(this.code);

  @override
  String toString() => 'AuthException: $code';
}
