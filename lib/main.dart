import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/api_client.dart';
import 'providers/auth_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar orientación portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Estilo de barra de estado
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.primary,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: EvoraApp()));
}

class EvoraApp extends ConsumerStatefulWidget {
  const EvoraApp({super.key});

  @override
  ConsumerState<EvoraApp> createState() => _EvoraAppState();
}

class _EvoraAppState extends ConsumerState<EvoraApp> {
  @override
  void initState() {
    super.initState();
    // Registrar callback de logout forzado (401)
    setOnUnauthorized(() {
      ref.read(authProvider.notifier).logout();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authProvider);

    // Splash screen mientras verifica auth
    if (authState.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const Scaffold(
          backgroundColor: AppColors.primary,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Evora Instaladores',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
