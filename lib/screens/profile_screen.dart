import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/study_provider.dart';
import '../services/achievement_service.dart';
import '../services/auth_service.dart';
import 'achievements_screen.dart';
import 'customization_screen.dart';
import 'stats_screen.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AchievementService _achievementService = AchievementService();
  bool _achievementsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    await _achievementService.load();
    if (!mounted) return;
    final provider = Provider.of<StudyProvider>(context, listen: false);
    await _achievementService.checkAchievements(provider);
    if (mounted) setState(() => _achievementsLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          final stats = provider.userStats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gradient identity hero — avatar, name, level, stats & XP
                _ProfileHero(
                  userName: stats.userName,
                  level: stats.level,
                  xp: stats.xp,
                  xpInLevel: stats.xp % stats.xpForNextLevel,
                  xpForNextLevel: stats.xpForNextLevel,
                  currentStreak: stats.currentStreak,
                  onEdit: () => _showEditNameDialog(context, stats.userName),
                ),
                const SizedBox(height: 16),

                // Statistics Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learning Statistics',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.accent,
                              ),
                        ),
                        const SizedBox(height: 20),
                        _StatRow(
                          icon: Icons.book,
                          label: 'Vocabulary Mastered',
                          value: '${stats.totalWordsLearned}',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        _StatRow(
                          icon: Icons.chat_bubble,
                          label: 'Sentences Mastered',
                          value: '${stats.totalSentencesLearned}',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        _StatRow(
                          icon: Icons.library_books,
                          label: 'Total Items Learned',
                          value: '${stats.totalWordsLearned + stats.totalSentencesLearned}',
                          color: context.accent,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Achievements Card
                Card(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Achievements',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.accent,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                '${_achievementService.unlockedCount}/${AchievementService.allAchievements.length}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: context.textSecondary,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_achievementsLoaded && _achievementService.unlockedCount > 0)
                            _buildBadgePreview()
                          else
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  children: [
                                    Icon(Icons.emoji_events, size: 40, color: context.textFaint),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start studying to earn badges!',
                                      style: TextStyle(color: context.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Customize Kuma Button
                Card(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomizationScreen()),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B72CF).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(Icons.checkroom, color: Color(0xFF9B72CF), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Customize Kuma',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: context.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Outfits, themes & seasonal items',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: context.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: context.textFaint),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Detailed Stats Button
                Card(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatsScreen()),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2FA8A0).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(Icons.bar_chart, color: Color(0xFF2FA8A0), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Detailed Stats',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: context.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Streaks, heatmap & progress',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: context.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: context.textFaint),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Account Section
                if (provider.isSignedIn) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.accent,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: context.accent.withValues(alpha: 0.15),
                              child: Icon(
                                provider.isGuest ? Icons.person_outline : Icons.person,
                                color: context.accent,
                              ),
                            ),
                            title: Text(
                              provider.isGuest ? 'Guest Mode' : 'Signed In',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              provider.isGuest
                                  ? 'Data saved locally only'
                                  : 'Syncing to cloud',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => _handleSignOut(context),
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                          if (!provider.isGuest) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => _handleDeleteAccount(context),
                              icon: const Icon(Icons.delete_forever, size: 20),
                              label: const Text('Delete Account'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadgePreview() {
    final recent = _achievementService.recentUnlocked;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: recent.map((ua) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ua.achievement.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(ua.achievement.icon, size: 24, color: ua.achievement.color),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                ua.achievement.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Provider.of<StudyProvider>(context, listen: false)
                    .updateUserName(controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    // Store navigator before any async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(child: CircularProgressIndicator()),
      );

      // Sign out from Supabase
      await Supabase.instance.client.auth.signOut();

      // Navigate to WelcomeScreen and clear all previous routes
      navigator.pushNamedAndRemoveUntil('/welcome', (route) => false);
    } catch (e) {
      navigator.pop(); // Close loading dialog
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Require the user to type DELETE — this is irreversible and syncs to cloud.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController();
        var canDelete = false;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete Account'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This permanently deletes your account and all your '
                  'progress — vocabulary, streaks, stats, and achievements. '
                  'This cannot be undone.',
                ),
                const SizedBox(height: 16),
                const Text('Type DELETE to confirm:'),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'DELETE',
                  ),
                  onChanged: (value) => setState(
                    () => canDelete = value.trim().toUpperCase() == 'DELETE',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: canDelete
                    ? () => Navigator.pop(dialogContext, true)
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete Forever'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      await AuthService().deleteAccount();
      navigator.pushNamedAndRemoveUntil('/welcome', (route) => false);
    } catch (e) {
      navigator.pop(); // Close loading dialog
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Gradient identity hero: avatar, name, an edit affordance, three translucent
/// stat pods (Level · Total XP · Streak) and the XP-to-next-level bar.
class _ProfileHero extends StatelessWidget {
  final String userName;
  final int level;
  final int xp;
  final int xpInLevel;
  final int xpForNextLevel;
  final int currentStreak;
  final VoidCallback onEdit;

  const _ProfileHero({
    required this.userName,
    required this.level,
    required this.xp,
    required this.xpInLevel,
    required this.xpForNextLevel,
    required this.currentStreak,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpForNextLevel == 0 ? 0.0 : xpInLevel / xpForNextLevel;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'S';
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: context.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: BrandColors.coral.withValues(alpha: 0.26),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 3),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8b6f47),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Level $level',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit name',
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _HeroStatPod(icon: Icons.star_rounded, label: 'Level', value: '$level'),
              const SizedBox(width: 10),
              _HeroStatPod(icon: Icons.trending_up_rounded, label: 'Total XP', value: '$xp'),
              const SizedBox(width: 10),
              _HeroStatPod(icon: Icons.local_fire_department_rounded, label: 'Streak', value: '$currentStreak'),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$xpInLevel / $xpForNextLevel XP to Level ${level + 1}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One translucent stat pod inside [_ProfileHero].
class _HeroStatPod extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroStatPod({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isTotal;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
