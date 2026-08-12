import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String problem;
  final String solution;
  final DateTime date;
  final String status;

  const HistoryItem({
    required this.problem,
    required this.solution,
    required this.date,
    this.status = 'تم الحل',
  });

  String formattedDate({bool english = false}) {
    final difference = DateTime.now().difference(date);
    if (difference.isNegative || difference.inMinutes < 1) return english ? 'Just now' : 'الآن';
    if (difference.inMinutes < 60) return english ? '${difference.inMinutes} min ago' : 'منذ ${difference.inMinutes} دقيقة';
    if (difference.inHours < 24) return english ? '${difference.inHours} hr ago' : 'منذ ${difference.inHours} ساعات';
    if (difference.inDays < 7) return english ? '${difference.inDays} days ago' : 'منذ ${difference.inDays} أيام';
    return '${date.year}/${date.month}/${date.day}';
  }

  Map<String, dynamic> toJson() => {
    'problem': problem,
    'solution': solution,
    'date': date.toIso8601String(),
    'status': status,
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date']?.toString();
    final parsedDate = rawDate == null ? null : DateTime.tryParse(rawDate);
    return HistoryItem(
      problem: json['problem']?.toString() ?? '',
      solution: json['solution']?.toString() ?? '',
      date: parsedDate ?? DateTime.now(),
      status: json['status']?.toString() ?? 'تم الحل',
    );
  }
}

class HistoryProvider extends ChangeNotifier {
  List<HistoryItem> _items = [];
  bool _isLoading = false;

  List<HistoryItem> get items => List.unmodifiable(_items);
  List<HistoryItem> get recentItems => List.unmodifiable(_items.take(5));
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;

  HistoryProvider() { loadHistory(); }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('problem_history');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _items = decoded
              .whereType<Map>()
              .map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e)))
              .where((e) => e.problem.isNotEmpty || e.solution.isNotEmpty)
              .toList();
          _items.sort((a, b) => b.date.compareTo(a.date));
        }
      }
      debugPrint('تم تحميل ${_items.length} مسألة من التاريخ');
    } catch (e) {
      debugPrint('خطأ في تحميل التاريخ: $e');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProblem(String problem, String solution) async {
    try {
      final newItem = HistoryItem(
        problem: problem,
        solution: solution,
        date: DateTime.now(),
      );
      _items.insert(0, newItem);
      await _saveToPrefs();
      notifyListeners();
      debugPrint('تمت إضافة المسألة: $problem');
    } catch (e) {
      debugPrint('خطأ في إضافة المسألة: $e');
    }
  }

  Future<void> removeProblem(HistoryItem item) async {
    final index = _items.indexOf(item);
    if (index == -1) return;
    try {
      final removed = _items.removeAt(index);
      await _saveToPrefs();
      notifyListeners();
      debugPrint('تم حذف المسألة: ${removed.problem}');
    } catch (e) {
      debugPrint('خطأ في حذف المسألة: $e');
    }
  }

  Future<void> clearAllHistory() async {
    try {
      _items.clear();
      await _saveToPrefs();
      notifyListeners();
      debugPrint('تم مسح كل التاريخ');
    } catch (e) {
      debugPrint('خطأ في مسح التاريخ: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'problem_history',
      jsonEncode(_items.map((item) => item.toJson()).toList()),
    );
  }
}
