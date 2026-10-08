import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Appearance is a device preference, independent of account/session state.
class AppearanceController extends ChangeNotifier {
  AppearanceController({Future<String?> Function()? read,
    Future<void> Function(String)? write})
      : _read = read ?? (() => SharedPreferencesAsync().getString(_key)),
        _write = write ?? ((value) => SharedPreferencesAsync().setString(_key, value));

  static final instance = AppearanceController();
  static const _key = 'davochain.appearance';
  final Future<String?> Function() _read;
  final Future<void> Function(String) _write;
  ThemeMode _mode = ThemeMode.system;
  Future<void> _pendingSave = Future<void>.value();
  ThemeMode get mode => _mode;

  Future<void> restore() async {
    String? stored;
    try { stored = await _read(); } catch (_) { stored = null; }
    _mode = ThemeMode.values.firstWhere((mode) => mode.name == stored,
      orElse: () => ThemeMode.system);
    notifyListeners();
  }

  Future<void> setMode(ThemeMode value) {
    // Serialize writes so a slow earlier save cannot overwrite a newer choice.
    final save = _pendingSave.then((_) async {
      await _write(value.name);
      if (_mode == value) return;
      _mode = value;
      notifyListeners();
    });
    _pendingSave = save.catchError((Object _) {});
    return save;
  }
}
