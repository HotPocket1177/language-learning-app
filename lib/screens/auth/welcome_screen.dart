import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import '../../services/auth_service.dart';
import '../../services/kuma_service.dart';
import '../../widgets/kuma_mascot.dart';
import '../../widgets/kuma_speech_bubble.dart' show BubbleTailDirection;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    KumaService().load();
  }

  Future<void> _handleGuestMode() async {
    setState(() => _isLoading = true);

    try {
      await AuthService().signInAnonymously();
      // Navigation will be handled by auth state listener in main.dart
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kumaService = KumaService();
    final welcomeMsg = kumaService.welcomeMessage;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kuma mascot with welcome bubble
                Center(
                  child: KumaMascot(
                    size: 120,
                    emotion: welcomeMsg.emotion,
                    showMessage: true,
                    message: welcomeMsg.text,
                    bubbleTailDirection: BubbleTailDirection.bottom,
                  ),
                ),
                const SizedBox(height: 24),

                // App Title
                Text(
                  'Language Study',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8b6f47),
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF8b6f47).withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Master languages with ease',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF8b6f47).withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 60),

                // Sign In Button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8b6f47),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                    shadowColor: const Color(0xFF8b6f47).withValues(alpha: 0.4),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Create Account Button
                OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8b6f47),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(
                      color: Color(0xFF8b6f47),
                      width: 2.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Divider with OR
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: const Color(0xFF8b6f47).withValues(alpha: 0.25),
                        thickness: 1.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: const Color(0xFF8b6f47).withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: const Color(0xFF8b6f47).withValues(alpha: 0.25),
                        thickness: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Guest Mode Button
                TextButton.icon(
                  onPressed: _isLoading ? null : _handleGuestMode,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF8b6f47),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person_outline_rounded,
                          size: 24,
                        ),
                  label: Text(
                    _isLoading ? 'Loading...' : 'Continue as Guest',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8b6f47),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 40),

                // Footer Text
                Text(
                  'Your progress will sync across devices',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF8b6f47).withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
