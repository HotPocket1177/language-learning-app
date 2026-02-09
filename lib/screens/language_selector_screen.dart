import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language_content.dart';
import '../providers/study_provider.dart';
import '../services/kuma_service.dart';
import 'tutorial_screen.dart';

class LanguageSelectorScreen extends StatelessWidget {
  const LanguageSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.language,
                size: 80,
                color: Color(0xFF8b6f47),
              ),
              const SizedBox(height: 24),
              Text(
                'Choose Your Language',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Select the language you want to learn',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF8b6f47).withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: ListView.builder(
                  itemCount: SupportedLanguage.values.length,
                  itemBuilder: (context, index) {
                    final language = SupportedLanguage.values[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _LanguageCard(
                        language: language,
                        onTap: () async {
                          final provider = context.read<StudyProvider>();
                          final kumaService = KumaService();
                          await provider.selectLanguage(language);
                          await kumaService.load();
                          if (context.mounted) {
                            if (!kumaService.tutorialCompleted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const TutorialScreen()),
                                (route) => false,
                              );
                            } else {
                              Navigator.of(context)
                                  .pushReplacementNamed('/home');
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final SupportedLanguage language;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF8b6f47).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF8b6f47).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8b6f47),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language.nativeName,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF4a4a4a).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF8b6f47),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
