import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class User {
  final String name;
  final String email;

  final String? profileImage;
  final int problemsSolved; 
  final int studyDays;
  final double accuracy; 
  
  User({
    required this.name,
    required this.email,
    this.profileImage,
    this.problemsSolved = 0,
    this.studyDays = 0,
    this.accuracy = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'profileImage': profileImage,
    'problemsSolved': problemsSolved,
    'studyDays': studyDays,
    'accuracy': accuracy,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    profileImage: json['profileImage'],
    problemsSolved: json['problemsSolved'] ?? 0,
    studyDays: json['studyDays'] ?? 0,
    accuracy: json['accuracy'] ?? 0.0,
  );
}

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loginAsGuest() async {
    _setLoading(true);
    try {
      _currentUser = User(
        name: 'زائر',
        email: 'guest@temp.com',
        problemsSolved: 0,
        studyDays: 0,
        accuracy: 0.0,
      );

      await _saveUserToPrefs();

      _errorMessage = null;
      _setLoading(false);
    } catch (e) {
      _setError('فشل تسجيل الدخول كزائر: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      // هنا بنربطه بالـ API بعدين
      // حاليا نستخدم بيانات وهمية عشان الاختبار

      await Future.delayed(const Duration(seconds: 1)); 

      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('current_user');

      if (userJson != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJson);

        if (userMap['email'] == email) {
          _currentUser = User.fromJson(userMap);
          _errorMessage = null;
          _setLoading(false);

          print('مرحباً بعودة ${_currentUser!.name}');
          return true;
        } else {
          _setError('البريد الإلكتروني أو كلمة المرور غير صحيحة');
          _setLoading(false);
          return false;
        }
      } else {
        if (email == 'test@test.com' && password == '123456') {
          _currentUser = User(
            name: 'أحمد محمد',
            email: email,
            profileImage: null,
            problemsSolved: 156,
            studyDays: 30,
            accuracy: 0.95,
          );
          await _saveUserToPrefs();
          _errorMessage = null;
          _setLoading(false);
          return true;
        } else {
          _setError('البريد الإلكتروني أو كلمة المرور غير صحيحة');
          _setLoading(false);
          return false;
        }
      }
    } catch (e) {
      _setError('حدث خطأ في تسجيل الدخول: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1)); // محاكاة

      _currentUser = User(
        name: name,
        email: email,
        profileImage: null,
        problemsSolved: 0,
        studyDays: 0,
        accuracy: 0.0,
      );

      await _saveUserToPrefs();
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('فشل إنشاء الحساب: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      _currentUser = null;
      _errorMessage = null;
      _setLoading(false);
    } catch (e) {
      _setError('فشل تسجيل الخروج: $e');
    }
  }

  Future<void> loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');

      if (userJson != null) {
        final Map<String, dynamic> userMap = Map.from(jsonDecode(userJson));
        _currentUser = User.fromJson(userMap);
      }

      notifyListeners();
    } catch (e) {
      print('خطأ في تحميل المستخدم: $e');
    }
  }

  Future<void> updateUserProfile({String? name, String? profileImage}) async {
    if (_currentUser == null) return;

    try {
      _currentUser = User(
        name: name ?? _currentUser!.name,
        email: _currentUser!.email,
        profileImage: profileImage ?? _currentUser!.profileImage,
        problemsSolved: _currentUser!.problemsSolved,
        studyDays: _currentUser!.studyDays,
        accuracy: _currentUser!.accuracy,
      );

      await _saveUserToPrefs();
      notifyListeners();
    } catch (e) {
      print('خطأ في تحديث الملف الشخصي: $e');
    }
  }

  void incrementProblemsSolved() {
    if (_currentUser != null) {
      _currentUser = User(
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImage: _currentUser!.profileImage,
        problemsSolved: _currentUser!.problemsSolved + 1,
        studyDays: _currentUser!.studyDays,
        accuracy: _currentUser!.accuracy,
      );
      _saveUserToPrefs();
      notifyListeners();
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

  Future<void> _saveUserToPrefs() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
    }
  }
}


