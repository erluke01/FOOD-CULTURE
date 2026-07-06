import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repository.dart';
import 'auth_service.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncResult {
  final SyncStatus status;
  final String? message;
  const SyncResult(this.status, {this.message});
}

class SyncService {
  final Repository _repo;
  final AuthService _auth;

  static const _serverUrlKey = 'wl_server_url';
  static const _defaultUrl = 'http://192.168.1.100:8000'; // user configures this

  SyncService(this._repo, this._auth);

  Future<String> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverUrlKey) ?? _defaultUrl;
  }

  Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url.trimRight().replaceAll(RegExp(r'/$'), ''));
  }

  Future<SyncResult> sync(AuthUser user) async {
    try {
      final baseUrl = await getServerUrl();
      final local = await _repo.exportForSync();

      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': user.basicAuthHeader,
        },
        body: jsonEncode(local),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final serverData = jsonDecode(response.body) as Map<String, dynamic>;
        await _repo.mergeFromSync(serverData);
        return const SyncResult(SyncStatus.success);
      } else {
        final body = jsonDecode(response.body);
        return SyncResult(SyncStatus.error, message: body['detail']?.toString() ?? 'Errore ${response.statusCode}');
      }
    } on Exception catch (e) {
      return SyncResult(SyncStatus.error, message: 'Impossibile connettersi al server:\n$e');
    }
  }

  Future<bool> isServerReachable() async {
    try {
      final baseUrl = await getServerUrl();
      final response = await http.get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
