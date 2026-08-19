import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// Pantalla de Login.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _lockCountdown;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final authState = ref.read(authProvider);
      final lockedUntil = authState.lockedUntil;
      if (lockedUntil == null) {
        setState(() => _lockCountdown = null);
        _countdownTimer?.cancel();
        return;
      }
      final remaining = lockedUntil - DateTime.now().millisecondsSinceEpoch;
      if (remaining <= 0) {
        setState(() => _lockCountdown = null);
        _countdownTimer?.cancel();
      } else {
        final minutes = (remaining / 60000).ceil();
        setState(() => _lockCountdown = 'Cuenta bloqueada. Espera $minutes min.');
      }
    });
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await ref.read(authProvider.notifier).login(username, password);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _error = error;
      });

      if (error != null && ref.read(authProvider).lockedUntil != null) {
        _startCountdown();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDisabled = _isLoading || _lockCountdown != null;
    final attemptsLeft = 5 - authState.loginAttempts;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const Text(
                  'ë·vora',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Instaladores',
                  style: TextStyle(fontSize: 16, color: AppColors.textDisabled),
                ),
                const SizedBox(height: 48),

                // Username
                TextField(
                  controller: _usernameController,
                  enabled: !isDisabled,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Usuario',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  enabled: !isDisabled,
                  obscureText: true,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 16),

                // Error
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFfc8181), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),

                // Countdown
                if (_lockCountdown != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _lockCountdown!,
                      style: const TextStyle(
                        color: Color(0xFFfbd38d),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Intentos restantes
                if (authState.loginAttempts > 0 && _lockCountdown == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '$attemptsLeft intento${attemptsLeft != 1 ? 's' : ''} restante${attemptsLeft != 1 ? 's' : ''}',
                      style: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),

                // Botón login
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isDisabled ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Entrar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  'v1.0.0',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
