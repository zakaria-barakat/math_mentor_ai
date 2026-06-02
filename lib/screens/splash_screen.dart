import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _logoAnimation;
  late Animation<double> _buttonsAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _logoAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _buttonsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHomeAsGuest() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: const Color(0xFF0C206D)),
      ),
    );

    await authProvider.loginAsGuest();

    if (mounted) {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: settings.isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          if (!settings.isDarkMode)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE3F2FD),
                    Colors.white,
                    Color(0xFFE3F2FD),
                  ],
                ),
              ),
            ),

          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, MediaQuery.of(context).size.height * _logoAnimation.value.dy),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: settings.isDarkMode
                              ? [
                            BoxShadow(
                              color: const Color(0xFF0C206D).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ]
                              : null,
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.abc,
                              size: 80,
                              color: settings.isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF0C206D),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Math Mentor AI',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: settings.isDarkMode
                              ? Colors.white
                              : const Color(0xFF0C206D),
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'تعلم الرياضيات بذكاء',
                        style: TextStyle(
                          fontSize: 16,
                          color: settings.isDarkMode
                              ? const Color(0xFF90CAF9)
                              : const Color(0xFF4A6FA5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _buttonsAnimation,
            builder: (context, child) {
              return Center(
                child: Opacity(
                  opacity: _buttonsAnimation.value,
                  child: Transform.translate(
                    offset: const Offset(0, 120),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _buttonsAnimation.value == 1.0
                                  ? () => Navigator.pushNamed(context, '/login')
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: settings.isDarkMode
                                    ? const Color(0xFF4A6FA5)
                                    : const Color(0xFF0C206D),
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: settings.isDarkMode
                                    ? const Color(0xFF4A6FA5).withOpacity(0.3)
                                    : const Color(0xFF0C206D).withOpacity(0.3),
                              ),
                              child: const Text(
                                'تسجيل الدخول',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              onPressed: _buttonsAnimation.value == 1.0
                                  ? () => Navigator.pushNamed(context, '/signup')
                                  : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: settings.isDarkMode
                                    ? const Color(0xFF90CAF9)
                                    : const Color(0xFF0C206D),
                                side: BorderSide(
                                  color: settings.isDarkMode
                                      ? const Color(0xFF4A6FA5)
                                      : const Color(0xFF0C206D),
                                  width: 2,
                                ),
                                elevation: 4,
                              ),
                              child: const Text(
                                'إنشاء حساب جديد',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          TextButton(
                            onPressed: _buttonsAnimation.value == 1.0
                                ? _navigateToHomeAsGuest
                                : null,
                            child: Text(
                              'الدخول كزائر',
                              style: TextStyle(
                                color: settings.isDarkMode
                                    ? Colors.grey.shade400
                                    : const Color(0xFF757575),
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
