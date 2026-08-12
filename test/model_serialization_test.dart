import 'package:flutter_test/flutter_test.dart';
import 'package:math_mentor_ai/providers/auth_provider.dart';
import 'package:math_mentor_ai/providers/history_provider.dart';

void main() {
  test('User.fromJson safely converts numeric values', () {
    final user = User.fromJson({
      'name': 'Test',
      'email': 'test@example.com',
      'accuracy': '0.95',
      'problemsSolved': '12',
      'studyDays': 7,
    });

    expect(user.accuracy, 0.95);
    expect(user.problemsSolved, 12);
    expect(user.studyDays, 7);
  });

  test('HistoryItem.fromJson tolerates malformed optional values', () {
    final item = HistoryItem.fromJson({'problem': null, 'solution': null, 'date': 'bad'});
    expect(item.problem, '');
    expect(item.solution, '');
    expect(item.status, 'تم الحل');
  });
}
