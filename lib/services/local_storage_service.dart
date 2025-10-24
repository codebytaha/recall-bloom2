import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<void> saveData(String key, dynamic value) async {
    if (value is String) {
      await _preferences!.setString(key, value);
    } else if (value is int) {
      await _preferences!.setInt(key, value);
    } else if (value is bool) {
      await _preferences!.setBool(key, value);
    } else if (value is double) {
      await _preferences!.setDouble(key, value);
    } else if (value is List<String>) {
      await _preferences!.setStringList(key, value);
    } else {
      await _preferences!.setString(key, jsonEncode(value));
    }
  }

  dynamic getData(String key) => _preferences!.get(key);

  String? getString(String key) => _preferences!.getString(key);

  int? getInt(String key) => _preferences!.getInt(key);

  bool? getBool(String key) => _preferences!.getBool(key);

  double? getDouble(String key) => _preferences!.getDouble(key);

  List<String>? getStringList(String key) => _preferences!.getStringList(key);

  Future<bool> remove(String key) async => await _preferences!.remove(key);

  Future<bool> clear() async => await _preferences!.clear();

  bool containsKey(String key) => _preferences!.containsKey(key);
}
