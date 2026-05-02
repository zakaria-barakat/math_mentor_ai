import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'problem_solution_screen.dart';
import '../providers/settings_provider.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, HistoryProvider>(
      builder: (context, settings, history, child) {
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
              settings.translate('آخر المسائل', 'History'),
              style: TextStyle(
                color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
              ),
            ),
            centerTitle: true,
            actions: [
              if (!history.isEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        title: Text(
                          settings.translate('مسح الكل', 'Clear All'),
                          style: TextStyle(
                            color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
                          ),
                        ),
                        content: Text(
                          settings.translate(
                            'هل أنت متأكد من مسح كل المسائل؟',
                            'Are you sure you want to clear all history?',
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
                            onPressed: () {
                              history.clearAllHistory();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828),
                            ),
                            child: Text(settings.translate('مسح', 'Clear')),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          body: history.isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: settings.isDarkMode ? const Color(0xFF4A6FA5) : const Color(0xFF0C206D),
            ),
          )
              : history.isEmpty
              ? _buildEmptyState(settings)
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.items.length,
            itemBuilder: (context, index) {
              final item = history.items[index];
              return Dismissible(
                key: Key(item.problem + item.date.toString()),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: const Color(0xFFC62828),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  history.removeProblem(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(settings.translate('تم الحذف', 'Deleted')),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: settings.isDarkMode
                          ? const Color(0xFF333333)
                          : const Color(0xFFE0E0E0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: settings.isDarkMode
                            ? const Color(0xFF1E3A5F)
                            : const Color(0xFFE3F2FD),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calculate,
                        color: settings.isDarkMode
                            ? const Color(0xFF4A6FA5)
                            : const Color(0xFF0C206D),
                      ),
                    ),
                    title: Text(
                      item.problem,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: settings.isDarkMode ? Colors.white : const Color(0xFF1E1E1E),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${settings.translate('الإجابة: ', 'Answer: ')}${item.solution}',
                          style: const TextStyle(color: Color(0xFF2E7D32)),
                        ),
                        Text(
                          item.formattedDate,
                          style: TextStyle(
                            color: settings.isDarkMode
                                ? Colors.grey.shade400
                                : const Color(0xFF757575),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: settings.isDarkMode
                          ? Colors.grey.shade400
                          : const Color(0xFF757575),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProblemSolutionScreen(
                            problem: item.problem,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(SettingsProvider settings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: settings.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            settings.translate('لا توجد مسائل بعد', 'No problems yet'),
            style: TextStyle(
              color: settings.isDarkMode ? Colors.white70 : Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            settings.translate('قم بحل مسألة لتظهر هنا', 'Solve a problem to see it here'),
            style: TextStyle(
              color: settings.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}