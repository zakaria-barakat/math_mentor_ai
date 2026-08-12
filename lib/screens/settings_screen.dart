import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
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
              settings.translate('الإعدادات', 'Settings'),
              style: TextStyle(
                color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
              ),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSettingsItem(
                icon: Icons.dark_mode,
                title: settings.translate('الوضع الليلي', 'Dark Mode'),
                trailing: Switch(
                  value: settings.isDarkMode,
                  onChanged: (value) => settings.toggleDarkMode(value),
                  activeColor: const Color(0xFF0C206D),
                  activeTrackColor: const Color(0xFF4A6FA5).withValues(alpha: 0.5),
                ),
                settings: settings,
              ),
              const Divider(color: Color(0xFFE0E0E0)),

              _buildSettingsItem(
                icon: Icons.language,
                title: settings.translate('اللغة', 'Language'),
                trailing: DropdownButton<String>(
                  value: settings.locale.languageCode,
                  items: const [
                    DropdownMenuItem(
                      value: 'ar',
                      child: Text('العربية'),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      settings.changeLanguage(value);
                    }
                  },
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: settings.isDarkMode ? Colors.grey.shade400 : const Color(0xFF757575),
                  ),
                  dropdownColor: settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  style: TextStyle(
                    color: settings.isDarkMode ? Colors.white : const Color(0xFF1E1E1E),
                  ),
                ),
                settings: settings,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Widget trailing,
    required SettingsProvider settings,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: settings.isDarkMode ? const Color(0xFF1E3A5F) : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: settings.isDarkMode ? const Color(0xFF4A6FA5) : const Color(0xFF0C206D),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: settings.isDarkMode ? Colors.white : const Color(0xFF1E1E1E),
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
