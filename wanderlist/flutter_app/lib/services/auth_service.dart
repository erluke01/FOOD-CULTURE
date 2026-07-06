import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final String username;
  final String password;
  final String role;

  const AuthUser({
    required this.username,
    required this.password,
    required this.role,
  });

  String get displayName => username == 'luchino' ? '🧑 Luchino' : '👩 Alix';

  String get basicAuthHeader =>
      'Basic ${base64.encode(utf8.encode('$username:$password'))}';
}

class AuthService {
  static const _prefKey = 'wl_auth';

  static const Map<String, Map<String, String>> _users = {
    'luchino': {'password': 'luchino123', 'role': 'editor'},
    'alix':    {'password': 'alix123',    'role': 'editor'},
  };

  Future<AuthUser?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    return _verify(parts[0], parts[1]);
  }

  Future<AuthUser> login(String username, String password) async {
    final user = _verify(username, password);
    if (user == null) throw Exception('Credenziali non valide');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, '$username:$password');
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  AuthUser? _verify(String username, String password) {
    final found = _users[username];
    if (found == null || found['password'] != password) return null;
    return AuthUser(username: username, password: password, role: found['role']!);
  }
}
