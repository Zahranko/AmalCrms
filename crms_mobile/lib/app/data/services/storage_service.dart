import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_session.dart';
import '../models/website.dart';

/// Mirrors saveSession/getSession/clearSession + the active-website helpers in
/// CRMS/wwwroot/js/api.js, backed by SharedPreferences instead of localStorage.
class StorageService {
  static const _key = 'crms.session';
  static const _activeWebsiteKey = 'crms.activeWebsite';

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

  Future<void> clearSession() async {
    await _prefs.remove(_key);
    await _prefs.remove(_activeWebsiteKey);
  }

  Website? readActiveWebsite() {
    final raw = _prefs.getString(_activeWebsiteKey);
    if (raw == null) return null;
    try {
      return Website.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActiveWebsite(Website website) =>
      _prefs.setString(_activeWebsiteKey, jsonEncode(website.toJson()));

  Future<void> clearActiveWebsite() => _prefs.remove(_activeWebsiteKey);
}
