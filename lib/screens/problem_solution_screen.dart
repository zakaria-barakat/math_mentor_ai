import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import 'dart:io';

class ProblemSolutionScreen extends StatefulWidget {
  final String problem;
  final String? imagePath;
  final bool saveToHistory;

  const ProblemSolutionScreen({
    super.key,
    required this.problem,
    this.imagePath,
    this.saveToHistory = true,
  });

  @override
  _ProblemSolutionScreenState createState() => _ProblemSolutionScreenState();
}

class _ProblemSolutionScreenState extends State<ProblemSolutionScreen> {
  bool _showSolution = false;
  bool _isLoading = false;
  final AiService _service = AiService();
  Map<String, dynamic>? _solutionData;
  List<String> _expandedSteps = [];

  @override
  void initState() {
    super.initState();
    _solveProblem();
  }

  Future<void> _solveProblem() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final result = await _service.solveProblem(
        problem: widget.problem,
        imagePath: widget.imagePath,
      );
      if (!mounted) return;
      final rawSteps = result['steps'];
      final steps = rawSteps is List ? rawSteps.map((e) => e.toString()).toList() : <String>[];
      setState(() {
        _isLoading = false;
        _showSolution = result['success'] == true;
        _solutionData = result;
        _expandedSteps = steps;
      });
      if (result['success'] == true && widget.saveToHistory) {
        final historyProvider = context.read<HistoryProvider>();
        await historyProvider.addProblem(
          result['problem']?.toString() ?? widget.problem,
          result['solution']?.toString() ?? '',
        );
        if (!mounted) return;
        final authProvider = context.read<AuthProvider>();
        if (authProvider.isLoggedIn) authProvider.incrementProblemsSolved();
      }
    } catch (e) {
      debugPrint('خطأ في حل المسألة: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showSolution = false;
        _solutionData = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء معالجة المسألة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: settings.isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          settings.translate('حل المسألة', 'Solution'),
          style: TextStyle(
            color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState(settings)
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.imagePath != null) ...[
              _buildImageCard(settings),
            ],

            _buildProblemCard(settings),

            const SizedBox(height: 25),

            if (_showSolution && _solutionData != null) ...[
              _buildSolutionHeader(settings),

              const SizedBox(height: 15),

              ..._buildDynamicSteps(settings),

              const SizedBox(height: 20),

              _buildResultCard(),

              const SizedBox(height: 20),

              _buildFeedbackButtons(settings),

              const SizedBox(height: 10),

              _buildSimilarProblemsButton(settings),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(SettingsProvider settings) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: settings.isDarkMode ? const Color(0xFF1E3A5F) : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: settings.isDarkMode
              ? const Color(0xFF4A6FA5).withValues(alpha: 0.3)
              : const Color(0xFFBBDEFB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            settings.translate('الصورة المرفوعة:', 'Uploaded image:'),
            style: TextStyle(
              color: settings.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(widget.imagePath!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              cacheWidth: 1600,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(settings.translate('فشل تحميل الصورة', 'Failed to load image')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemCard(SettingsProvider settings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: settings.isDarkMode ? const Color(0xFF1E3A5F) : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: settings.isDarkMode
              ? const Color(0xFF4A6FA5).withValues(alpha: 0.3)
              : const Color(0xFFBBDEFB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.imagePath != null
                ? settings.translate('المسألة المستخرجة:', 'Extracted problem:')
                : settings.translate('المسألة:', 'Problem:'),
            style: TextStyle(
              color: settings.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // نعرض المسألة المستخرجة من Gemini إن وجدت، وإلا النص الأصلي
            _solutionData?['problem'] ?? widget.problem,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
            ),
          ),
          if (_solutionData != null && _solutionData!['success'] == false)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                settings.translate('⚠️ فشل الحل - حاول مرة أخرى', '⚠️ Failed - try again'),
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSolutionHeader(SettingsProvider settings) {
    return Row(
      children: [
        Icon(
          Icons.auto_awesome,
          color: settings.isDarkMode ? const Color(0xFF4A6FA5) : const Color(0xFF0C206D),
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          settings.translate('الحل خطوة بخطوة:', 'Step by step solution:'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDynamicSteps(SettingsProvider settings) {
    List<Widget> stepWidgets = [];

    for (int i = 0; i < _expandedSteps.length; i++) {
      String step = _expandedSteps[i];

      // تنسيق الخطوات بشكل مختلف حسب محتواها
      bool isMathStep = step.contains('=') || step.contains('+') || step.contains('-') ||
          step.contains('×') || step.contains('÷') || step.contains('x');

      stepWidgets.add(
        _buildSolutionStep(
          stepNumber: i + 1,
          title: settings.translate(
            _getStepTitle(i, step),
            _getStepTitle(i, step, english: true),
          ),
          description: step,
          isMath: isMathStep,
          isLast: i == _expandedSteps.length - 1,
          settings: settings,
        ),
      );

      if (i < _expandedSteps.length - 1) {
        stepWidgets.add(const SizedBox(height: 15));
      }
    }

    return stepWidgets;
  }

  String _getStepTitle(int index, String step, {bool english = false}) {
    if (english) {
      switch (index) {
        case 0: return 'Analysis';
        case 1: return 'Apply Rules';
        case 2: return 'Simplify';
        case 3: return 'Final Step';
        default: return 'Step ${index + 1}';
      }
    } else {
      switch (index) {
        case 0: return 'تحليل';
        case 1: return 'تطبيق القوانين';
        case 2: return 'تبسيط';
        case 3: return 'الخطوة النهائية';
        default: return 'خطوة ${index + 1}';
      }
    }
  }

  Widget _buildSolutionStep({
    required int stepNumber,
    required String title,
    required String description,
    required bool isMath,
    required bool isLast,
    required SettingsProvider settings,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: settings.isDarkMode ? const Color(0xFF4A6FA5) : const Color(0xFF0C206D),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
                ),
              ),
              const SizedBox(height: 4),
              if (isMath)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: settings.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: settings.isDarkMode
                          ? const Color(0xFF333333)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'monospace',
                      height: 1.5,
                      color: settings.isDarkMode ? Colors.white : const Color(0xFF1E1E1E),
                    ),
                  ),
                )
              else
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: settings.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    if (_solutionData == null) return Container();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C206D), Color(0xFF1E3A8A)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C206D).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'الإجابة النهائية',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            _solutionData!['solution'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButtons(SettingsProvider settings) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.thumb_up,
            label: settings.translate('مفيد', 'Helpful'),
            color: const Color(0xFF2E7D32),
            settings: settings,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            icon: Icons.thumb_down,
            label: settings.translate('غير مفيد', 'Not helpful'),
            color: const Color(0xFFC62828),
            settings: settings,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required SettingsProvider settings,
  }) {
    return Container(
      height: 45,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(settings.translate('شكراً لتقييمك!', 'Thank you for your feedback!')),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarProblemsButton(SettingsProvider settings) {
    return OutlinedButton(
      onPressed: () {
        _showSimilarProblemsDialog(settings);
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: settings.isDarkMode
              ? const Color(0xFF4A6FA5)
              : const Color(0xFF0C206D),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.refresh,
            color: settings.isDarkMode
                ? const Color(0xFF4A6FA5)
                : const Color(0xFF0C206D),
          ),
          const SizedBox(width: 8),
          Text(
            settings.translate('مسائل مشابهة', 'Similar problems'),
            style: TextStyle(
              color: settings.isDarkMode
                  ? const Color(0xFF4A6FA5)
                  : const Color(0xFF0C206D),
            ),
          ),
        ],
      ),
    );
  }

  void _showSimilarProblemsDialog(SettingsProvider settings) {
    List<Map<String, String>> similarProblems = [
      {'problem': '2x + 5 = 15', 'solution': 'x = 5'},
      {'problem': '3x - 7 = 8', 'solution': 'x = 5'},
      {'problem': 'x² - 4 = 0', 'solution': 'x = 2, x = -2'},
      {'problem': 'x² + 5x + 6 = 0', 'solution': 'x = -2, x = -3'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          settings.translate('مسائل مشابهة', 'Similar Problems'),
          style: TextStyle(
            color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: similarProblems.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  similarProblems[index]['problem']!,
                  style: TextStyle(
                    color: settings.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'الحل: ${similarProblems[index]['solution']}',
                  style: TextStyle(
                    color: settings.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProblemSolutionScreen(
                        problem: similarProblems[index]['problem']!,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              settings.translate('إغلاق', 'Close'),
              style: const TextStyle(color: Color(0xFF0C206D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(SettingsProvider settings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: settings.isDarkMode ? const Color(0xFF4A6FA5) : const Color(0xFF0C206D),
          ),
          const SizedBox(height: 20),
          Text(
            widget.imagePath != null
                ? settings.translate(
              'جاري تحليل الصورة واستخراج المسألة محلياً...',
              'Analyzing image and extracting problem locally...',
            )
                : settings.translate(
              'جاري تحليل المسألة ذكياً...',
              'Analyzing problem smartly...',
            ),
            style: TextStyle(
              fontSize: 16,
              color: settings.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.problem,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: settings.isDarkMode ? const Color(0xFF4A6FA5) : const Color(0xFF0C206D),
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.imagePath != null) ...[
            const SizedBox(height: 20),
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: FileImage(File(widget.imagePath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
