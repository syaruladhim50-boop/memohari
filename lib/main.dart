import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/notification_service.dart';
import 'utils/settings_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize settings
  final settingsManager = SettingsManager.instance;
  await settingsManager.init();
  
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(const MemoHariApp());
}

class MemoHariApp extends StatelessWidget {
  const MemoHariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsManager.instance,
      builder: (context, _) {
        final settings = SettingsManager.instance;
        return MaterialApp(
          title: 'MemoHari Notes',
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1DB954), // Soft Green
              secondary: Color(0xFF00C86F), // Deep Green
              background: Color(0xFFF9F9F9), // Light background
              surface: Colors.white, // White card backgrounds
              error: Color(0xFFD32F2F),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onBackground: Color(0xFF1F1F1F),
              onSurface: Color(0xFF1F1F1F),
            ),
            scaffoldBackgroundColor: const Color(0xFFF9F9F9),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.black.withOpacity(0.04),
                  width: 1,
                ),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF9F9F9),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Color(0xFF1F1F1F),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
              iconTheme: IconThemeData(color: Color(0xFF1F1F1F)),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF00C86F),
              foregroundColor: Colors.white,
              elevation: 6,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF00C86F), width: 1.5),
              ),
              labelStyle: const TextStyle(color: Color(0xFF6B7280)),
              floatingLabelStyle: const TextStyle(color: Color(0xFF00C86F)),
              hintStyle: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00FF88), // Neon Green
              secondary: Color(0xFF1DB954), // Soft Green
              background: Color(0xFF0D0D0D), // AMOLED Black
              surface: Color(0xFF151515), // Secondary Background
              error: Color(0xFFCF6679),
              onPrimary: Colors.black,
              onSecondary: Colors.black,
              onBackground: Color(0xFFF5F5F5), // Text Primary
              onSurface: Color(0xFFF5F5F5), // Text Primary
            ),
            scaffoldBackgroundColor: const Color(0xFF0D0D0D),
            cardTheme: CardThemeData(
              color: const Color(0xFF151515),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFF00FF88).withOpacity(0.04),
                  width: 1,
                ),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D0D0D),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Color(0xFFF5F5F5),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
              iconTheme: IconThemeData(color: Color(0xFFF5F5F5)),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF00FF88),
              foregroundColor: Colors.black,
              elevation: 6,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF151515),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
              ),
              labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              floatingLabelStyle: const TextStyle(color: Color(0xFF00FF88)),
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            // Support modern textScaler parameter
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: TextScaler.linear(1.0 + (settings.fontSizeOffset / 10.0)),
              ),
              child: child!,
            );
          },
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}