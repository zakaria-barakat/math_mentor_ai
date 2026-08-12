import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String name;
  final String email;
  final String? profileImage;
  final int problemsSolved;
  final int studyDays;
  final double accuracy;

  const User({
    required this.name,
    required this.email,
    this.profileImage,
    this.problemsSolved = 0,
    this.studyDays = 0,
    this.accuracy = 0.0,
  });

  User copyWith({
    String? name,
    String? email,
    String? profileImage,
    int? problemsSolved,
    int? studyDays,
    double? accuracy,
  }) => User(
    name: name ?? this.name,
    email: email ?? this.email,
    profileImage: profileImage ?? this.profileImage,
    problemsSolved: problemsSolved ?? this.problemsSolved,
    studyDays: studyDays ?? this.studyDays,
    accuracy: accuracy ?? this.accuracy,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'profileImage': profileImage,
    'problemsSolved': problemsSolved,
    'studyDays': studyDays,
    'accuracy': accuracy,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    final rawAccuracy = json['accuracy'];
    final accuracy = rawAccuracy is num
        ? rawAccuracy.toDouble()
        : double.tryParse(rawAccuracy?.toString() ?? '') ?? 0.0;
    final rawProblems = json['problemsSolved'];
    final rawDays = json['studyDays'];
    return User(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
      problemsSolved: rawProblems is num
          ? rawProblems.toInt()
          : int.tryParse(rawProblems?.toString() ?? '') ?? 0,
      studyDays: rawDays is num
          ? rawDays.toInt()
          : int.tryParse(rawDays?.toString() ?? '') ?? 0,
      accuracy: accuracy.clamp(0.0, 1.0),
    );
  }
}

class AuthProvider extends ChangeNotifier {
  static const _userKey = 'current_user';
  static const _rememberKey = 'remember_me';
  static const _guestKey = 'is_guest';

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuest = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loginAsGuest() async {
    _setLoading(true);
    try {
      _currentUser = const User(name: 'زائر', email: 'guest@temp.com');
      _isGuest = true;
      await _saveSession(remember: true);
      _errorMessage = null;
    } catch (e) {
      _setError('فشل تسجيل الدخول كزائر: $e');
    } finally {
      if (_isLoading) _setLoading(false);
    }
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _setLoading(true);
    try {
      final normalizedEmail = email.trim().toLowerCase();
      if (normalizedEmail.isEmpty || password.isEmpty) {
        _setError('البريد الإلكتروني وكلمة المرور مطلوبان');
        return false;
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      User? user;
      if (userJson != null) {
        try {
          final decoded = jsonDecode(userJson);
          if (decoded is Map<String, dynamic>) user = User.fromJson(decoded);
        } catch (e) {
          debugPrint('تعذر قراءة الجلسة المحفوظة: $e');
        }
      }

      if (user != null && user.email.toLowerCase() == normalizedEmail) {
        _currentUser = user;
      } else if (normalizedEmail == 'test@test.com' && password == '123456') {
        _currentUser = User(
          name: 'أحمد محمد',
          email: normalizedEmail,
          problemsSolved: 156,
          studyDays: 30,
          accuracy: 0.95,
        );
      } else {
        _setError('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        return false;
      }

      _isGuest = false;
      _errorMessage = null;
      await _saveSession(remember: rememberMe);
      debugPrint('مرحباً بعودة ${_currentUser!.name}');
      return true;
    } catch (e) {
      _setError('حدث خطأ في تسجيل الدخول: $e');
      return false;
    } finally {
      if (_isLoading) _setLoading(false);
    }
  }

  Future<bool> signUp(String name, String email, String password, {bool rememberMe = false}) async {
    _setLoading(true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      _currentUser = User(name: name.trim(), email: email.trim().toLowerCase());
      _isGuest = false;
      _errorMessage = null;
      await _saveSession(remember: rememberMe);
      return true;
    } catch (e) {
      _setError('فشل إنشاء الحساب: $e');
      return false;
    } finally {
      if (_isLoading) _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_rememberKey);
      await prefs.remove(_guestKey);
      _currentUser = null;
      _isGuest = false;
      _errorMessage = null;
    } catch (e) {
      _setError('فشل تسجيل الخروج: $e');
    } finally {
      if (_isLoading) _setLoading(false);
    }
  }

  Future<void> loadSavedUser() async {
    if (_isLoading) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_rememberKey) != true) {
        _currentUser = null;
        _isGuest = false;
      } else {
        final userJson = prefs.getString(_userKey);
        if (userJson != null) {
          final decoded = jsonDecode(userJson);
          if (decoded is Map<String, dynamic>) {
            _currentUser = User.fromJson(decoded);
            _isGuest = prefs.getBool(_guestKey) ?? false;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في تحميل المستخدم: $e');
    }
  }

  Future<void> updateUserProfile({String? name, String? profileImage}) async {
    final user = _currentUser;
    if (user == null) return;
    try {
      _currentUser = user.copyWith(name: name, profileImage: profileImage);
      await _saveSession(remember: true);
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في تحديث الملف الشخصي: $e');
    }
  }

  void incrementProblemsSolved() {
    final user = _currentUser;
    if (user == null) return;
    _currentUser = user.copyWith(problemsSolved: user.problemsSolved + 1);
    _saveSession(remember: true);
    notifyListeners();
  }

  Future<void> _saveSession({required bool remember}) async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser == null) return;
    if (remember) {
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
      await prefs.setBool(_rememberKey, true);
      await prefs.setBool(_guestKey, _isGuest);
    } else {
      await prefs.remove(_userKey);
      await prefs.setBool(_rememberKey, false);
      await prefs.setBool(_guestKey, false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
