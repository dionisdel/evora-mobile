import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper para almacenamiento seguro de credenciales.
/// - Android/iOS: usa flutter_secure_storage (Keychain / EncryptedSharedPreferences)
/// - Web: usa shared_preferences (localStorage) como fallback
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _tokenKey = 'evora_auth_token';
  static const _userKey = 'evora_user_data';

  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } else {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  static Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    }
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> removeToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } else {
      await _storage.delete(key: _tokenKey);
    }
  }

  static Future<void> saveUserData(Map<String, dynamic> user) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user));
    } else {
      await _storage.write(key: _userKey, value: jsonEncode(user));
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    String? data;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      data = prefs.getString(_userKey);
    } else {
      data = await _storage.read(key: _userKey);
    }
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } else {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    }
  }
}
