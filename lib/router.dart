import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/app_shell.dart';
import 'screens/cuestionario_screen.dart';
import 'screens/login_screen.dart';

/// Router con guard de autenticación.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isLoginRoute = state.matchedLocation == '/login';

      // Esperando verificación de auth
      if (isLoading) return null;

      // No autenticado y no en login → redirigir a login
      if (!isAuth && !isLoginRoute) return '/login';

      // Autenticado y en login → redirigir a home
      if (isAuth && isLoginRoute) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const AppShell(),
        routes: [
          GoRoute(
            path: 'cuestionario/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return CuestionarioScreen(peticionId: id);
            },
          ),
        ],
      ),
    ],
  );
});
