import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Locale _locale = const Locale('ar');
  bool _isLoading = true;
  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    loadSettings(); 
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      _isDarkMode = prefs.getBool('darkMode') ?? false;

      String languageCode = prefs.getString('language') ?? 'ar';
      _locale = Locale(languageCode);

      print('تم تحميل الإعدادات: DarkMode=$_isDarkMode, Language=$languageCode');
    } catch (e) {
      print('خطأ في تحميل الإعدادات: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', value);
      print('تم حفظ الوضع الليلي: $value');
    } catch (e) {
      print('خطأ في حفظ الوضع الليلي: $e');
    }

    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      print('تم حفظ اللغة: $languageCode');
    } catch (e) {
      print('خطأ في حفظ اللغة: $e');
    }

    notifyListeners();
  }

  String translate(String arabic, String english) {
    return _locale.languageCode == 'ar' ? arabic : english;
  }

  Future<void> resetToDefault() async {
    _isDarkMode = false;
    _locale = const Locale('ar');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', false);
      await prefs.setString('language', 'ar');
      print('تم إعادة تعيين الإعدادات');
    } catch (e) {
      print('خطأ في إعادة تعيين الإعدادات: $e');
    }

    notifyListeners();
  }
}
