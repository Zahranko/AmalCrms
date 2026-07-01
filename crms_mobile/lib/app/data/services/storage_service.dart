import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_session.dart';

/// Mirrors saveSession/getSession/clearSession in CRMS/wwwroot/js/api.js,
/// backed by SharedPreferences instead of localStorage.
class StorageService {
  static const _key = 'crms.session';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  UserSession? readSession() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return UserSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession(UserSession session) =>
      _prefs.setString(_key, jsonEncode(session.toJson()));

  Future<void> clearSession() => _prefs.remove(_key);
}
