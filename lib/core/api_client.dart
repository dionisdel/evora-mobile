import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'secure_storage.dart';

/// URL base según entorno.
const String _devBaseUrl = 'http://10.0.2.2:8003/api/v2/mobile';
const String _prodBaseUrl = 'https://e-plataforma.com/api/v2/mobile';

String get apiBaseUrl => kDebugMode ? _devBaseUrl : _prodBaseUrl;

const int _timeoutMs = 15000;
const int _maxRetries = 2;
const int _retryDelayMs = 2000;

/// Callback para logout forzado (registrado por el provider de auth).
typedef OnUnauthorized = void Function();
OnUnauthorized? _onUnauthorized;

void setOnUnauthorized(OnUnauthorized cb) {
  _onUnauthorized = cb;
}

/// Cliente HTTP singleton configurado con interceptors.
final Dio apiClient = _createClient();

Dio _createClient() {
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(milliseconds: _timeoutMs),
    receiveTimeout: const Duration(milliseconds: _timeoutMs),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Interceptor: Bearer token
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await SecureStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      final response = error.response;
      final requestPath = error.requestOptions.path;

      // 401: Sesión expirada → limpiar y forzar logout
      if (response?.statusCode == 401) {
        final isAuthRoute = requestPath.contains('/auth/login') ||
            requestPath.contains('/auth/refresh');

        if (!isAuthRoute) {
          await SecureStorage.clearAll();
          _onUnauthorized?.call();
        }
        return handler.next(error);
      }

      // 429: Rate limit → esperar y reintentar
      if (response?.statusCode == 429) {
        final retryAfter =
            int.tryParse(response?.headers.value('retry-after') ?? '') ?? 5;
        await Future.delayed(Duration(seconds: retryAfter));
        try {
          final result = await dio.fetch(error.requestOptions);
          return handler.resolve(result);
        } catch (e) {
          return handler.next(error);
        }
      }

      // 5xx: Error de servidor → reintentar
      if (response != null && response.statusCode! >= 500) {
        final retryCount =
            error.requestOptions.extra['_retryCount'] as int? ?? 0;
        if (retryCount < _maxRetries) {
          error.requestOptions.extra['_retryCount'] = retryCount + 1;
          await Future.delayed(const Duration(milliseconds: _retryDelayMs));
          try {
            final result = await dio.fetch(error.requestOptions);
            return handler.resolve(result);
          } catch (e) {
            return handler.next(error);
          }
        }
      }

      handler.next(error);
    },
  ));

  return dio;
}
