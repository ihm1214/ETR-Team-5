import 'package:shared_preferences/shared_preferences.dart';

/// Tiny wrapper around browser/device storage.
class Storage {
  static late SharedPreferences _p;

  static Future<void> init() async => _p = await SharedPreferences.getInstance();

  static String? read(String key) => _p.getString(key);

  static Future<void> write(String key, String value) => _p.setString(key, value);

  static Future<void> clear() => _p.clear();
}