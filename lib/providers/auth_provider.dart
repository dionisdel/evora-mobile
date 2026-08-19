import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/secure_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Estado de autenticación.
class AuthState {
  final User? user;
  final String? token;
  final bool isAuthenticated;
  final bool isLoading;
  final int loginAttempts;
  final int? lockedUntil; // timestamp ms

  const AuthState({
    this.user,
    this.token,
    this.isAuthenticated = false,
    this.isLoading = true,
    this.loginAttempts = 0,
    this.lockedUntil,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isAuthenticated,
    bool? isLoading,
    int? loginAttempts,
    int? lockedUntil,
    bool clearUser = false,
    bool clearLock = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: clearUser ? null : (token ?? this.token),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      loginAttempts: loginAttempts ?? this.loginAttempts,
      lockedUntil: clearLock ? null : (lockedUntil ?? this.lockedUntil),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  static const _maxAttempts = 5;
  static const _lockDurationMs = 15 * 60 * 1000; // 15 minutos

  AuthNotifier() : super(const AuthState()) {
    checkStoredAuth();
  }

  /// Verificar auth almacenada al iniciar.
  Future<void> checkStoredAuth() async {
    final token = await SecureStorage.getToken();
    final userData = await SecureStorage.getUserData();
    if (token != null && userData != null) {
      state = state.copyWith(
        user: User.fromJson(userData),
        token: token,
        isAuthenticated: true,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Login.
  Future<String?> login(String username, String password) async {
    if (isLocked) {
      return 'Demasiados intentos fallidos. Espera 15 minutos.';
    }

    try {
      final response = await AuthService.login(
        username: username,
        password: password,
      );
      await SecureStorage.saveUserData(response.user.toJson());
      state = state.copyWith(
        user: response.user,
        token: response.token,
        isAuthenticated: true,
        loginAttempts: 0,
        clearLock: true,
      );
      return null; // success
    } on AuthException catch (e) {
      _incrementAttempts();
      switch (e.code) {
        case 'PERFIL_NO_AUTORIZADO':
          return 'Acceso restringido a instaladores (coach/colaborador).';
        case 'CUENTA_BLOQUEADA':
          return 'Tu cuenta está deshabilitada. Contacta al administrador.';
        case 'DEMASIADOS_INTENTOS':
          return 'Demasiados intentos. Espera unos minutos.';
        default:
          return 'Credenciales incorrectas. Inténtalo de nuevo.';
      }
    } catch (_) {
      _incrementAttempts();
      return 'Credenciales incorrectas. Inténtalo de nuevo.';
    }
  }

  /// Logout.
  Future<void> logout() async {
    await SecureStorage.clearAll();
    state = state.copyWith(
      isAuthenticated: false,
      clearUser: true,
    );
  }

  void _incrementAttempts() {
    final attempts = state.loginAttempts + 1;
    final lockedUntil = attempts >= _maxAttempts
        ? DateTime.now().millisecondsSinceEpoch + _lockDurationMs
        : null;
    state = state.copyWith(loginAttempts: attempts, lockedUntil: lockedUntil);
  }

  bool get isLocked {
    final lock = state.lockedUntil;
    if (lock == null) return false;
    if (DateTime.now().millisecondsSinceEpoch >= lock) {
      state = state.copyWith(loginAttempts: 0, clearLock: true);
      return false;
    }
    return true;
  }

  int get attemptsLeft => _maxAttempts - state.loginAttempts;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
