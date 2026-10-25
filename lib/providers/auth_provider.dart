import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local (on-device) accounts. Passwords are stored as a SHA-256 hash.
class AuthProvider extends ChangeNotifier {
  static const _usersKey = 'auth_users';
  static const _currentKey = 'auth_current_user';

  Map<String, dynamic> _users = {};
  String? _currentUser;
  bool _ready = false;

  bool get isReady => _ready;
  bool get isLoggedIn => _currentUser != null;

  String get displayName {
    final user = _users[_currentUser];
    if (user is Map) return (user['name'] as String?) ?? '';
    return '';
  }

  String _hash(String username, String password) =>
      sha256.convert(utf8.encode('$username:$password')).toString();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    _users = raw == null ? {} : jsonDecode(raw) as Map<String, dynamic>;
    final current = prefs.getString(_currentKey);
    _currentUser = _users.containsKey(current) ? current : null;
    _ready = true;
    notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> register({
    required String name,
    required String username,
    required String password,
  }) async {
    final key = username.trim().toLowerCase();
    if (_users.containsKey(key)) return 'That username is already taken';
    _users[key] = <String, dynamic>{
      'name': name.trim(),
      'hash': _hash(key, password),
    };
    _currentUser = key;
    await _save();
    notifyListeners();
    return null;
  }

  /// Returns an error message, or null on success.
  Future<String?> login(String username, String password) async {
    final key = username.trim().toLowerCase();
    final user = _users[key];
    if (user is! Map || user['hash'] != _hash(key, password)) {
      return 'Incorrect username or password';
    }
    _currentUser = key;
    await _save();
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(_users));
    if (_currentUser == null) {
      await prefs.remove(_currentKey);
    } else {
      await prefs.setString(_currentKey, _currentUser!);
    }
  }
}
