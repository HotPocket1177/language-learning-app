import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/study_provider.dart';
import 'screens/home_screen.dart';
import 'screens/language_selector_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (app works offline if this fails)
  try {
    await SupabaseService.initialize();
  } catch (_) {
    // Continue in offline mode
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StudyProvider(),
      child: MaterialApp(
        title: 'Language Study App',
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
              side: BorderSide(
                color: const Color(0xFF8b6f47).withValues(alpha: 0.3),
                width: 1,
              ),
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
        routes: {
          '/home': (context) => const HomeScreen(),
          '/language-selector': (context) => const LanguageSelectorScreen(),
          '/welcome': (context) => const WelcomeScreen(),
        },
        home: const AuthGate(),
      ),
    );
  }
}

/// Simple auth gate that checks session state once at app start.
/// Post-login navigation is handled directly in SignInScreen/SignUpScreen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null ? const AppInitializer() : const WelcomeScreen();
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<StudyProvider>(context, listen: false);

    try {
      await provider.loadData();
    } catch (_) {
      // Data load failed - will use defaults
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5EBE0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8b6f47)),
              ),
              SizedBox(height: 20),
              Text(
                'Loading your progress...',
                style: TextStyle(
                  color: Color(0xFF8b6f47),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<StudyProvider>(
      builder: (context, provider, child) {
        // Check if language is selected
        if (provider.selectedLanguage == null) {
          return const LanguageSelectorScreen();
        }

        // Show home screen
        return const HomeScreen();
      },
    );
  }
}
