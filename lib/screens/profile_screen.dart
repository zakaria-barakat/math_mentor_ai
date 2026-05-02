import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, AuthProvider>(
      builder: (context, settings, auth, child) {

        if (!auth.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const SizedBox();
        }

        final user = auth.currentUser!;

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
              settings.translate('الملف الشخصي', 'Profile'),
              style: TextStyle(
                color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // الصورة الشخصية
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: settings.isDarkMode
                                ? const Color(0xFF4A6FA5).withOpacity(0.3)
                                : const Color(0xFF0C206D).withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: settings.isDarkMode
                            ? const Color(0xFF1E3A5F)
                            : const Color(0xFFE3F2FD),
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user.profileImage == null
                            ? Icon(
                          Icons.person,
                          size: 60,
                          color: settings.isDarkMode
                              ? const Color(0xFF4A6FA5)
                              : const Color(0xFF0C206D),
                        )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                settings.translate('قريباً...', 'Coming soon...'),
                              ),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0C206D),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // اسم المستخدم
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
                  ),
                ),

                const SizedBox(height: 8),

                // البريد الإلكتروني
                Text(
                  user.email,
                  style: TextStyle(
                    color: settings.isDarkMode ? Colors.grey.shade400 : const Color(0xFF757575),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                // زر تسجيل الخروج
                Container(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          title: Text(
                            settings.translate('تسجيل الخروج', 'Logout'),
                            style: TextStyle(
                              color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
                            ),
                          ),
                          content: Text(
                            settings.translate(
                              'هل أنت متأكد من تسجيل الخروج؟',
                              'Are you sure you want to logout?',
                            ),
                            style: TextStyle(
                              color: settings.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
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
                              onPressed: () async {
                                Navigator.pop(context);
                                await auth.logout();

                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/',
                                      (route) => false,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(settings.translate(
                                      'تم تسجيل الخروج بنجاح',
                                      'Logged out successfully',
                                    )),
                                    backgroundColor: const Color(0xFF2E7D32),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: settings.isDarkMode
                                    ? const Color(0xFFB71C1C).withOpacity(0.8)
                                    : const Color(0xFFFFEBEE),
                                foregroundColor: settings.isDarkMode
                                    ? Colors.white
                                    : const Color(0xFFC62828),
                              ),
                              child: Text(settings.translate('تسجيل خروج', 'Logout')),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: settings.isDarkMode
                          ? const Color(0xFFB71C1C).withOpacity(0.2)
                          : const Color(0xFFFFEBEE),
                      foregroundColor: settings.isDarkMode
                          ? const Color(0xFFEF5350)
                          : const Color(0xFFC62828),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      settings.translate('تسجيل الخروج', 'Logout'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}