import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A friendly, centered empty state: a soft-tinted circular icon badge over a
/// bold title and a supporting line. Keeps "nothing here yet" screens warm and
/// on-brand instead of feeling like a dead end.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  /// Accent tint for the badge + icon. Defaults to the brand coral.
  final Color? color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.coral;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: tint),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
