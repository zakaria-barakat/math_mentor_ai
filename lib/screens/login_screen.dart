import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class LoginScreen extends StatefulWidget {
  final bool isSignUp;

  const LoginScreen({super.key, this.isSignUp = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final settings = Provider.of<SettingsProvider>(context, listen: false);

      bool success;

      if (widget.isSignUp) {
        success = await authProvider.signUp(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
      } else {
        success = await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );
      }

      setState(() => _isLoading = false);

      if (success) {
        if (widget.isSignUp) {
          Navigator.pushReplacementNamed(context, '/login');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(settings.translate(
                'تم إنشاء الحساب بنجاح! يمكنك تسجيل الدخول الآن',
                'Account created successfully! You can now login',
              )),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/main');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(settings.translate(
                'تم تسجيل الدخول بنجاح!',
                'Login successful!',
              )),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ??
                settings.translate('حدث خطأ غير متوقع', 'An unexpected error occurred')),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: settings.isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // زر الرجوع
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: settings.isDarkMode
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: settings.isDarkMode
                          ? Colors.white
                          : const Color(0xFF0C206D),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                ),

                const SizedBox(height: 20),

                // العنوان
                Text(
                  settings.translate(
                    widget.isSignUp ? 'إنشاء حساب جديد' : 'مرحباً بعودتك!',
                    widget.isSignUp ? 'Create New Account' : 'Welcome Back!',
                  ),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: settings.isDarkMode
                        ? Colors.white
                        : const Color(0xFF0C206D),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                Text(
                  settings.translate(
                    widget.isSignUp
                        ? 'أنشئ حسابك وابدأ رحلة تعلم الرياضيات'
                        : 'سجل دخولك للاستمرار في التعلم',
                    widget.isSignUp
                        ? 'Create your account and start learning math'
                        : 'Login to continue your learning journey',
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: settings.isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // النموذج
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // حقل الاسم
                      if (widget.isSignUp) ...[
                        _buildTextField(
                          controller: _nameController,
                          hint: settings.translate('الاسم الكامل', 'Full Name'),
                          icon: Icons.person_outline,
                          settings: settings,
                          validator: (value) {
                            if (widget.isSignUp && (value == null || value.isEmpty)) {
                              return settings.translate(
                                'الرجاء إدخال الاسم',
                                'Please enter your name',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // حقل البريد الإلكتروني
                      _buildTextField(
                        controller: _emailController,
                        hint: settings.translate('البريد الإلكتروني', 'Email'),
                        icon: Icons.email_outlined,
                        settings: settings,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return settings.translate(
                              'الرجاء إدخال البريد الإلكتروني',
                              'Please enter your email',
                            );
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return settings.translate(
                              'الرجاء إدخال بريد إلكتروني صحيح',
                              'Please enter a valid email',
                            );
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // حقل كلمة المرور
                      _buildTextField(
                        controller: _passwordController,
                        hint: settings.translate('كلمة المرور', 'Password'),
                        icon: Icons.lock_outline,
                        settings: settings,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: settings.isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return settings.translate(
                              'الرجاء إدخال كلمة المرور',
                              'Please enter your password',
                            );
                          }
                          if (widget.isSignUp && value.length < 6) {
                            return settings.translate(
                              'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                              'Password must be at least 6 characters',
                            );
                          }
                          return null;
                        },
                      ),

                      if (widget.isSignUp) ...[
                        const SizedBox(height: 16),

                        // تأكيد كلمة المرور
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: settings.translate('تأكيد كلمة المرور', 'Confirm Password'),
                          icon: Icons.lock_outline,
                          settings: settings,
                          obscureText: !_isConfirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: settings.isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return settings.translate(
                                'الرجاء تأكيد كلمة المرور',
                                'Please confirm your password',
                              );
                            }
                            if (value != _passwordController.text) {
                              return settings.translate(
                                'كلمة المرور غير متطابقة',
                                'Passwords do not match',
                              );
                            }
                            return null;
                          },
                        ),
                      ],

                      if (!widget.isSignUp) ...[
                        const SizedBox(height: 16),

                        // تذكرني ونسيت كلمة المرور
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: const Color(0xFF0C206D),
                                    checkColor: Colors.white,
                                    side: BorderSide(
                                      color: settings.isDarkMode
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                  Text(
                                    settings.translate('تذكرني', 'Remember me'),
                                    style: TextStyle(
                                      color: settings.isDarkMode
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _showForgotPasswordDialog,
                              child: Text(
                                settings.translate('نسيت كلمة المرور؟', 'Forgot Password?'),
                                style: const TextStyle(
                                  color: Color(0xFF0C206D),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // زر التقديم
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
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
                    boxShadow: [
                      BoxShadow(
                        color: (settings.isDarkMode
                            ? const Color(0xFF4A6FA5)
                            : const Color(0xFF0C206D)).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      settings.translate(
                        widget.isSignUp ? 'إنشاء حساب' : 'تسجيل الدخول',
                        widget.isSignUp ? 'Sign Up' : 'Login',
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // خط مع "أو"
                Row(
                  children: [
                    Expanded(child: Divider(color: settings.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        settings.translate('أو', 'OR'),
                        style: TextStyle(
                          color: settings.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: settings.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300)),
                  ],
                ),

                const SizedBox(height: 20),

                // أزرار التواصل الاجتماعي
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      imagePath: 'assets/images/facebook_logo.svg',
                      onPressed: () {},
                      settings: settings,
                    ),
                    _buildSocialButton(
                      imagePath: 'assets/images/google_logo.svg',
                      onPressed: () {},
                      settings: settings,
                    ),
                    _buildSocialButton(
                      imagePath: 'assets/images/gmail_logo.svg',
                      onPressed: () {},
                      settings: settings,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // رابط التبديل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      settings.translate(
                        widget.isSignUp ? 'لديك حساب بالفعل؟ ' : 'ليس لديك حساب؟ ',
                        widget.isSignUp ? 'Already have an account? ' : 'Don\'t have an account? ',
                      ),
                      style: TextStyle(
                        color: settings.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(
                              isSignUp: !widget.isSignUp,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        settings.translate(
                          widget.isSignUp ? 'تسجيل الدخول' : 'إنشاء حساب جديد',
                          widget.isSignUp ? 'Login' : 'Sign Up',
                        ),
                        style: const TextStyle(
                          color: Color(0xFF0C206D),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required SettingsProvider settings,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: settings.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: settings.isDarkMode
              ? const Color(0xFF333333)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: settings.isDarkMode ? Colors.white : const Color(0xFF1E1E1E),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: settings.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
          ),
          prefixIcon: Icon(
            icon,
            color: settings.isDarkMode ? Colors.grey.shade500 : const Color(0xFF9E9E9E),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSocialButton({
    required String imagePath,
    required VoidCallback onPressed,
    required SettingsProvider settings,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: settings.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: settings.isDarkMode
                ? const Color(0xFF333333)
                : const Color(0xFFE0E0E0),
          ),
          boxShadow: [
            BoxShadow(
              color: settings.isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SvgPicture.asset(
          imagePath,
          fit: BoxFit.contain,
          color: settings.isDarkMode ? Colors.white : null,
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          settings.translate('استعادة كلمة المرور', 'Reset Password'),
          style: TextStyle(
            color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              settings.translate(
                'أدخل بريدك الإلكتروني وسنرسل لك رابط استعادة كلمة المرور',
                'Enter your email and we\'ll send you a reset link',
              ),
              style: TextStyle(
                color: settings.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: emailController,
              hint: settings.translate('البريد الإلكتروني', 'Email'),
              icon: Icons.email_outlined,
              settings: settings,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              settings.translate('إلغاء', 'Cancel'),
              style: TextStyle(
                color: settings.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(settings.translate(
                    'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني',
                    'Reset link has been sent to your email',
                  )),
                  backgroundColor: const Color(0xFF2E7D32),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C206D),
            ),
            child: Text(settings.translate('إرسال', 'Send')),
          ),
        ],
      ),
    );
  }
}