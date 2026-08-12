import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'problem_solution_screen.dart';
import 'camera_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// إرسال المسألة النصية إلى شاشة الحل
  void _submitProblem() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    _focusNode.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProblemSolutionScreen(problem: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor:
              settings.isDarkMode ? const Color(0xFF121212) : Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const SizedBox.shrink(),
            title: Image.asset(
              'assets/images/logo.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) => Text(
                'Math Mentor AI',
                style: TextStyle(
                  color: settings.isDarkMode
                      ? Colors.white
                      : const Color(0xFF0C206D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(
              color:
                  settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu, size: 28),
                onSelected: (value) {
                  if (value == 'settings') {
                    Navigator.pushNamed(context, '/settings');
                  } else if (value == 'history') {
                    Navigator.pushNamed(context, '/history');
                  } else if (value == 'profile') {
                    Navigator.pushNamed(context, '/profile');
                  } else if (value == 'back_to_splash') {
                    context.read<AuthProvider>().logout().then((_) {
                      if (!mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    });
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings,
                            color: Color(0xFF0C206D)),
                        const SizedBox(width: 8),
                        Text(settings.translate('الإعدادات', 'Settings')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        const Icon(Icons.history,
                            color: Color(0xFF0C206D)),
                        const SizedBox(width: 8),
                        Text(settings.translate('آخر المسائل', 'History')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person,
                            color: Color(0xFF0C206D)),
                        const SizedBox(width: 8),
                        Text(settings.translate(
                            'الملف الشخصي', 'Profile')),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'back_to_splash',
                    child: Row(
                      children: [
                        const Icon(Icons.exit_to_app, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          settings.translate('خروج', 'Leave'),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: settings.isDarkMode
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF121212), Color(0xFF1A1A1A)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE3F2FD), Colors.white],
                    ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ── أيقونة الذكاء الاصطناعي ──────────────────────────
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: settings.isDarkMode
                                        ? const Color(0xFF4A6FA5)
                                            .withValues(alpha: 0.2)
                                        : const Color(0xFF0C206D)
                                            .withValues(alpha: 0.1),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 80,
                                color: settings.isDarkMode
                                    ? const Color(0xFF4A6FA5)
                                    : const Color(0xFF0C206D),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ── الأزرار الثلاثة الرئيسية ──────────────────────────
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMainButton(
                          context: context,
                          icon: Icons.camera_alt,
                          label: settings.translate(
                              'مسح بالكاميرا', 'Scan Camera'),
                          gradientStart: settings.isDarkMode
                              ? const Color(0xFF4A6FA5)
                              : const Color(0xFF0C206D),
                          gradientEnd: settings.isDarkMode
                              ? const Color(0xFF6D8CB0)
                              : const Color(0xFF2A3F8A),
                          onTap: () =>
                              Navigator.pushNamed(context, '/camera'),
                        ),
                        _buildMainButton(
                          context: context,
                          icon: Icons.photo_library,
                          label: settings.translate(
                              'رفع من المعرض', 'Upload from Gallery'),
                          gradientStart: const Color(0xFF2E7D32),
                          gradientEnd: const Color(0xFF4CAF50),
                          onTap: () => _pickImageFromGallery(context),
                        ),
                      ],
                    ),
                  ),

                  // ── مربع الكتابة النصي ────────────────────────────────
                  _buildTextInputArea(settings),

                  // ── نص تعريفي ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    child: Text(
                      settings.translate(
                        'حل المسائل الرياضية بالذكاء الاصطناعي',
                        'Solve math problems with AI',
                      ),
                      style: TextStyle(
                        color: settings.isDarkMode
                            ? Colors.grey.shade400
                            : const Color(0xFF757575),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── مربع إدخال النص ────────────────────────────────────────────────────
  Widget _buildTextInputArea(SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: settings.isDarkMode
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: settings.isDarkMode
                ? const Color(0xFF4A6FA5).withValues(alpha: 0.5)
                : const Color(0xFF0C206D).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: settings.isDarkMode
                  ? const Color(0xFF4A6FA5).withValues(alpha: 0.1)
                  : const Color(0xFF0C206D).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textDirection: TextDirection.rtl,
                textInputAction: TextInputAction.send,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  color: settings.isDarkMode
                      ? Colors.white
                      : const Color(0xFF1E1E1E),
                ),
                decoration: InputDecoration(
                  hintText: settings.translate(
                    'اكتب مسألتك هنا... مثال: 2x + 5 = 15',
                    'Type your problem... e.g. 2x + 5 = 15',
                  ),
                  hintStyle: TextStyle(
                    color: settings.isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                // إرسال بزر Enter من لوحة المفاتيح
                onSubmitted: (_) => _submitProblem(),
              ),
            ),
            // ── زر الإرسال ─────────────────────────────────────────
            GestureDetector(
              onTap: _submitProblem,
              child: Container(
                margin: const EdgeInsets.all(6),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: settings.isDarkMode
                        ? [
                            const Color(0xFF4A6FA5),
                            const Color(0xFF6D8CB0),
                          ]
                        : [
                            const Color(0xFF0C206D),
                            const Color(0xFF2A3F8A),
                          ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (settings.isDarkMode
                              ? const Color(0xFF4A6FA5)
                              : const Color(0xFF0C206D))
                          .withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── أزرار الوظائف الرئيسية ──────────────────────────────────────────────
  Widget _buildMainButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color gradientStart,
    required Color gradientEnd,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [gradientStart, gradientEnd],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: gradientStart.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.2),
              blurRadius: 5,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── اختيار صورة من المعرض ──────────────────────────────────────────────
  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 2048, maxHeight: 2048, imageQuality: 90);

      if (image != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProblemSolutionScreen(
              problem: 'جاري تحليل الصورة محلياً...',
              imagePath: image.path,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل اختيار الصورة: $e'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      }
    }
  }
}
