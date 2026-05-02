import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/settings_provider.dart';
import 'problem_solution_screen.dart';
import 'camera_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: settings.isDarkMode ? const Color(0xFF121212) : Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(),
            title: Image.asset(
              'assets/images/logo.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) => Text(
                'Math Mentor AI',
                style: TextStyle(
                  color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(
              color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.menu,
                  size: 28,
                ),
                onSelected: (value) {
                  if (value == 'settings') {
                    Navigator.pushNamed(context, '/settings');
                  } else if (value == 'history') {
                    Navigator.pushNamed(context, '/history');
                  } else if (value == 'profile') {
                    Navigator.pushNamed(context, '/profile');
                  } else if (value == 'back_to_splash') {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                          (route) => false,
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: const Color(0xFF0C206D)),
                        const SizedBox(width: 8),
                        Text(settings.translate('الإعدادات', 'Settings')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        Icon(Icons.history, color: const Color(0xFF0C206D)),
                        const SizedBox(width: 8),
                        Text(settings.translate('آخر المسائل', 'History')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: const Color(0xFF0C206D)),
                        const SizedBox(width: 8),
                        Text(settings.translate('الملف الشخصي', 'Profile')),
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
                  ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF121212),
                  const Color(0xFF1A1A1A),
                ],
              )
                  : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFE3F2FD),
                  Colors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: settings.isDarkMode
                                        ? const Color(0xFF4A6FA5).withOpacity(0.2)
                                        : const Color(0xFF0C206D).withOpacity(0.1),
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
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMainButton(
                          context: context,
                          icon: Icons.camera_alt,
                          label: settings.translate('مسح بالكاميرا', 'Scan Camera'),
                          gradientStart: settings.isDarkMode
                              ? const Color(0xFF4A6FA5)
                              : const Color(0xFF0C206D),
                          gradientEnd: settings.isDarkMode
                              ? const Color(0xFF6D8CB0)
                              : const Color(0xFF2A3F8A),
                          onTap: () => Navigator.pushNamed(context, '/camera'),
                        ),
                        _buildMainButton(
                          context: context,
                          icon: Icons.photo_library,
                          label: settings.translate('رفع من المعرض', 'Upload from Gallery'),
                          gradientStart: settings.isDarkMode
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF2E7D32),
                          gradientEnd: settings.isDarkMode
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF4CAF50),
                          onTap: () => _pickImageFromGallery(context),
                        ),
                        _buildMainButton(
                          context: context,
                          icon: Icons.calculate,
                          label: settings.translate('آلة حاسبة ذكية', 'Smart Calculator'),
                          gradientStart: settings.isDarkMode
                              ? const Color(0xFFF57C00)
                              : const Color(0xFFF57C00),
                          gradientEnd: settings.isDarkMode
                              ? const Color(0xFFFF9800)
                              : const Color(0xFFFF9800),
                          onTap: () => Navigator.pushNamed(context, '/calculator'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          settings.translate(
                            'حل المسائل الرياضية بالذكاء الاصطناعي',
                            'Solve math problems with AI',
                          ),
                          style: TextStyle(
                            color: settings.isDarkMode
                                ? Colors.grey.shade400
                                : const Color(0xFF757575),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildMainButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color gradientStart,
    required Color gradientEnd,
    required VoidCallback onTap,
  }) {
    final settings = Provider.of<SettingsProvider>(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [gradientStart, gradientEnd],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: gradientStart.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(-2, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
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
                      color: Colors.black.withOpacity(0.2),
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
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
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

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProblemSolutionScreen(
              problem: 'جاري تحليل الصورة...',
              imagePath: image.path,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل اختيار الصورة: $e'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    }
  }
}