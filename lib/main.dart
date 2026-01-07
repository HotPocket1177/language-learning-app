import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/study_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StudyProvider()..loadData(),
      child: MaterialApp(
        title: 'Japanese Study App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF8b6f47),
          scaffoldBackgroundColor: const Color(0xFFF5EBE0),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8b6f47),
            surface: const Color(0xFFF5EBE0),
          ),
          fontFamily: 'serif',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF8b6f47),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: const Color(0xFF8b6f47).withValues(alpha: 0.3), width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8b6f47),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8b6f47),
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8b6f47),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Color(0xFF4a4a4a),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
