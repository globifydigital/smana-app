import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    if (Platform.isMacOS) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } else {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> getToken() async {
    if (Platform.isMacOS) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } else {
      return await _storage.read(key: _tokenKey);
    }
  }

  Future<void> deleteToken() async {
    if (Platform.isMacOS) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } else {
      await _storage.delete(key: _tokenKey);
    }
  }

  Future<void> deleteAll() async {
    if (Platform.isMacOS) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } else {
      await _storage.deleteAll();
    }
  }
}
