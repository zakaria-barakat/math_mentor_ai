import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryItem {
  final String problem;
  final String solution;
  final DateTime date;
  final String status;

  HistoryItem({
    required this.problem,
    required this.solution,
    required this.date,
    this.status = 'تم الحل',
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعات';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }

  Map<String, dynamic> toJson() => {
    'problem': problem,
    'solution': solution,
    'date': date.toIso8601String(),
    'status': status,
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    problem: json['problem'],
    solution: json['solution'],
    date: DateTime.parse(json['date']),
    status: json['status'] ?? 'تم الحل',
  );
}

class HistoryProvider extends ChangeNotifier {
  List<HistoryItem> _items = [];
  bool _isLoading = false;

  List<HistoryItem> get items => List.unmodifiable(_items);
  List<HistoryItem> get recentItems => _items.take(5).toList();
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;

  HistoryProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString('problem_history');

      if (historyJson != null) {
        final List<dynamic> jsonList = jsonDecode(historyJson);
        _items = jsonList
            .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
            .toList();

        _items.sort((a, b) => b.date.compareTo(a.date));

        print('تم تحميل ${_items.length} مسألة من التاريخ');
      }
    } catch (e) {
      print('خطأ في تحميل التاريخ: $e');
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

      _items.insert(0, newItem); // أضف في البداية

      await _saveToPrefs();

      notifyListeners();
      print('تمت إضافة المسألة: $problem');
    } catch (e) {
      print('خطأ في إضافة المسألة: $e');
    }
  }

  Future<void> removeProblem(int index) async {
    if (index < 0 || index >= _items.length) return;

    try {
      final removed = _items.removeAt(index);
      await _saveToPrefs();
      notifyListeners();
      print('تم حذف المسألة: ${removed.problem}');
    } catch (e) {
      print('خطأ في حذف المسألة: $e');
    }
  }

  Future<void> clearAllHistory() async {
    try {
      _items.clear();
      await _saveToPrefs();
      notifyListeners();
      print('تم مسح كل التاريخ');
    } catch (e) {
      print('خطأ في مسح التاريخ: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _items.map((item) => item.toJson()).toList();
    await prefs.setString('problem_history', jsonEncode(jsonList));
  }

  List<HistoryItem> search(String query) {
    if (query.isEmpty) return _items;

    return _items.where((item) =>
    item.problem.contains(query) ||
        item.solution.contains(query)
    ).toList();
  }
}
