import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/study_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/language_selector_screen.dart';
import 'screens/tutorial_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'services/cosmetics_service.dart';
import 'services/kuma_service.dart';
import 'services/supabase_service.dart';
import 'screens/customization_screen.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Language Study App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.mode,
          routes: {
            '/home': (context) => const HomeScreen(),
            '/tutorial': (context) => const TutorialScreen(),
            '/language-selector': (context) => const LanguageSelectorScreen(),
            '/welcome': (context) => const WelcomeScreen(),
          },
          home: const AuthGate(),
        ),
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
  bool _tutorialCompleted = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    final kumaService = KumaService();
    final cosmeticsService = CosmeticsService();

    try {
      await provider.loadData();
      await kumaService.load();
      await cosmeticsService.load();
      _tutorialCompleted = kumaService.tutorialCompleted;
    } catch (_) {
      // Data load failed - will use defaults
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _checkSeasonalContent();
      }
    }
  }

  Future<void> _checkSeasonalContent() async {
    final cosmeticsService = CosmeticsService();
    final seasonalOutfits = await cosmeticsService.checkSeasonalUnlocks();

    if (seasonalOutfits.isNotEmpty && mounted) {
      final outfit = seasonalOutfits.first;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Seasonal Outfits Available!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('New ${outfit.name} unlocked!'),
              const SizedBox(height: 16),
              Image.asset(
                outfit.imagePath,
                width: 100,
                height: 100,
                errorBuilder: (_, _, _) => Icon(
                  Icons.pets,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Check out the Customize screen!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomizationScreen(),
                  ),
                );
              },
              child: const Text('View Now!'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      final primary = Theme.of(context).colorScheme.primary;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading your progress...',
                style: TextStyle(
                  color: primary,
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

        // Show tutorial if not completed yet
        if (!_tutorialCompleted) {
          return const TutorialScreen();
        }

        // Show home screen
        return const HomeScreen();
      },
    );
  }
}
