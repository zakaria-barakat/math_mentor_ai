import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _logoAnimation;
  late final Animation<double> _buttonsAnimation;
  bool _restored = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..forward();
    _logoAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.3)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _buttonsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.65, 1, curve: Curves.easeOut)),
    );
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final auth = context.read<AuthProvider>();
    await auth.loadSavedUser();
    if (!mounted || _restored) return;
    _restored = true;
    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  Future<void> _navigateToHomeAsGuest() async {
    final auth = context.read<AuthProvider>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    await auth.loginAsGuest();
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: settings.isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          if (!settings.isDarkMode)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE3F2FD), Colors.white, Color(0xFFE3F2FD)],
                ),
              ),
              child: SizedBox.expand(),
            ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Transform.translate(
              offset: Offset(0, MediaQuery.sizeOf(context).height * _logoAnimation.value.dy),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 20),
                    Text('Math Mentor AI', style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold,
                      color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
                    )),
                    Text('تعلم الرياضيات بذكاء', style: TextStyle(
                      fontSize: 16, color: settings.isDarkMode ? const Color(0xFF90CAF9) : const Color(0xFF4A6FA5),
                    )),
                  ],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _buttonsAnimation,
            builder: (context, _) => Center(
              child: Opacity(
                opacity: _buttonsAnimation.value,
                child: Transform.translate(
                  offset: const Offset(0, 120),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _buttonsAnimation.value == 1 ? () => Navigator.pushNamed(context, '/login') : null,
                            child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton(
                            onPressed: _buttonsAnimation.value == 1 ? () => Navigator.pushNamed(context, '/signup') : null,
                            child: const Text('إنشاء حساب جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: _buttonsAnimation.value == 1 ? _navigateToHomeAsGuest : null,
                          child: Text('الدخول كزائر', style: TextStyle(color: settings.isDarkMode ? Colors.grey.shade400 : const Color(0xFF757575), fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
