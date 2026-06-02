import 'dart:math';
import 'dart:async';

class MockApiService {
  Future<Map<String, dynamic>> solveProblem({
    required String problem,
    String? imagePath,
  }) async {

    await Future.delayed(Duration(seconds: 2 + Random().nextInt(2)));

    if (imagePath != null) {
      print('تم استلام صورة: $imagePath');
    }

    String solution = _generateMockSolution(problem);
    List<String> steps = _generateSteps(problem, solution);

    return {
      'success': true,
      'problem': problem,
      'solution': solution,
      'steps': steps,
      'isMock': true, 
    };
  }

  String _generateMockSolution(String problem) {
    problem = problem.toLowerCase();

    if (problem.contains('x') && (problem.contains('+') || problem.contains('-'))) {
      if (problem.contains('2x + 5 = 15')) return 'x = 5';
      if (problem.contains('3x - 7 = 8')) return 'x = 5';
      if (problem.contains('4x + 2 = 18')) return 'x = 4';
      if (problem.contains('5x - 3 = 22')) return 'x = 5';
      if (problem.contains('2x + 10 = 20')) return 'x = 5';
      return 'x = ${Random().nextInt(10) + 1}';
    }

    if (problem.contains('x²') || problem.contains('x^2') || problem.contains('x2')) {
      if (problem.contains('x² - 4 = 0')) return 'x = 2, x = -2';
      if (problem.contains('x² + 5x + 6 = 0')) return 'x = -2, x = -3';
      if (problem.contains('x² - 5x + 6 = 0')) return 'x = 2, x = 3';
      if (problem.contains('x² + 6x + 9 = 0')) return 'x = -3';
      if (problem.contains('2x² + 4x - 6 = 0')) return 'x = 1, x = -3';
      return 'x = ${Random().nextInt(5) + 1}, x = -${Random().nextInt(3) + 1}';
    }

    if (problem.contains('∫') || problem.contains('integral') || problem.contains('تكامل')) {
      if (problem.contains('x²')) return '∫ x² dx = x³/3 + C';
      if (problem.contains('x')) return '∫ x dx = x²/2 + C';
      if (problem.contains('sin')) return '∫ sin(x) dx = -cos(x) + C';
      if (problem.contains('cos')) return '∫ cos(x) dx = sin(x) + C';
      if (problem.contains('1/x') || problem.contains('1÷x')) return '∫ 1/x dx = ln|x| + C';
      return 'x³/3 + 2x + C';
    }
    if (problem.contains('d/dx') || problem.contains('derivative') || problem.contains('تفاضل') || problem.contains('اشتقاق')) {
      if (problem.contains('x²')) return 'd/dx (x²) = 2x';
      if (problem.contains('x³')) return 'd/dx (x³) = 3x²';
      if (problem.contains('sin')) return 'd/dx (sin x) = cos x';
      if (problem.contains('cos')) return 'd/dx (cos x) = -sin x';
      if (problem.contains('ln') || problem.contains('log')) return 'd/dx (ln x) = 1/x';
      return '2x + 5';
    }

    if ((problem.contains('و') || problem.contains('and')) && problem.contains('y')) {
      if (problem.contains('x + y = 5') && problem.contains('x - y = 1')) return 'x = 3, y = 2';
      if (problem.contains('2x + y = 10') && problem.contains('x - y = 2')) return 'x = 4, y = 2';
      return 'x = ${Random().nextInt(5) + 1}, y = ${Random().nextInt(5) + 1}';
    }

    if (problem.contains('عمر') || problem.contains('سنة') || (problem.contains('أكبر') && problem.contains('أصغر'))) {
      return 'الأول = 25 سنة، الثاني = 15 سنة';
    }

    if (problem.contains('مساحة') || problem.contains('محيط')) {
      if (problem.contains('مربع')) return 'مساحة المربع = 25 سم²';
      if (problem.contains('مستطيل')) return 'مساحة المستطيل = 24 سم²';
      if (problem.contains('دائرة')) return 'مساحة الدائرة = 78.5 سم²';
    }

    return 'الحل: ${Random().nextInt(20)}';
  }

  List<String> _generateSteps(String problem, String solution) {
    problem = problem.toLowerCase();
    List<String> steps = [];

    steps.add('🔍 تحليل المسألة: $problem');

    if (problem.contains('x') && (problem.contains('+') || problem.contains('-'))) {
      steps.add('📝 نقل الثوابت إلى طرف والمتغيرات إلى طرف آخر');
      steps.add('🧮 تبسيط المعادلة بجمع أو طرح الأعداد');
      steps.add('✂️ قسمة الطرفين على معامل x');
    } else if (problem.contains('x²') || problem.contains('x^2')) {
      steps.add('📝 فتح القوسين أو استخدام القانون العام');
      steps.add('🧮 حساب المميز (b² - 4ac)');
      steps.add('📐 تطبيق قانون الجذور: x = (-b ± √(b² - 4ac)) / 2a');
    } else if (problem.contains('∫') || problem.contains('integral')) {
      steps.add('📝 تحديد دالة التكامل');
      steps.add('🔢 تطبيق قواعد التكامل الأساسية');
      steps.add('➕ إضافة ثابت التكامل C');
    } else if (problem.contains('d/dx') || problem.contains('derivative')) {
      steps.add('📝 تحديد الدالة المراد اشتقاقها');
      steps.add('📐 تطبيق قواعد الاشتقاق');
      steps.add('✅ تبسيط الناتج');
    } else {
      steps.add('📝 تطبيق القوانين الرياضية المناسبة');
      steps.add('🧮 تبسيط المعادلة خطوة بخطوة');
    }

    steps.add('✅ الوصول للحل: $solution');

    return steps;
  }
}
