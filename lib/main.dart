import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/history_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/problem_solution_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/calculator_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => HistoryProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Math Mentor AI',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: const Color(0xFF0C206D),
              fontFamily: 'Cairo',
              scaffoldBackgroundColor: Colors.white,
              brightness: Brightness.light,
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF0C206D),
                secondary: Color(0xFF4A6FA5),
                surface: Color(0xFFF5F7FA),
                background: Colors.white,
                error: Color(0xFFC62828),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Color(0xFF1E1E1E),
                onBackground: Color(0xFF1E1E1E),
                onError: Colors.white,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xFF0C206D)),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C206D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0C206D),
                  side: const BorderSide(color: Color(0xFF0C206D), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            darkTheme: ThemeData(
              primaryColor: const Color(0xFF4A6FA5),
              fontFamily: 'Cairo',
              scaffoldBackgroundColor: const Color(0xFF121212),
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF4A6FA5),
                secondary: Color(0xFF90CAF9),
                surface: Color(0xFF1E1E1E),
                background: Color(0xFF121212),
                error: Color(0xFFEF5350),
                onPrimary: Colors.white,
                onSecondary: Color(0xFF121212),
                onSurface: Colors.white,
                onBackground: Colors.white,
                onError: Color(0xFF121212),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6FA5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF90CAF9),
                  side: const BorderSide(color: Color(0xFF4A6FA5), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: settings.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'AE'),
              Locale('en', 'US'),
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => SplashScreen(),
              '/login': (context) => LoginScreen(),
              '/signup': (context) => LoginScreen(isSignUp: true),
              '/main': (context) => MainScreen(),
              '/camera': (context) => CameraScreen(),
              '/solution': (context) => ProblemSolutionScreen(problem: ''),
              '/history': (context) => HistoryScreen(),
              '/profile': (context) => ProfileScreen(),
              '/settings': (context) => SettingsScreen(),
              '/calculator': (context) => CalculatorScreen(),
            },
          );
        },
      ),
    );
  }
}