import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kuma_outfit.dart';
import '../models/user_stats.dart';
import '../providers/study_provider.dart';
import '../services/cosmetics_service.dart';

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CosmeticsService _cosmetics = CosmeticsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCosmetics();
  }

  Future<void> _loadCosmetics() async {
    await _cosmetics.load();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Kuma'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.checkroom), text: 'Outfits'),
            Tab(icon: Icon(Icons.palette), text: 'Themes'),
          ],
        ),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, _) {
          final stats = provider.userStats;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOutfitsTab(stats),
              _buildThemesTab(stats),
            ],
          );
        },
      ),
    );
  }

  // ── Outfits Tab ────────────────────────────────────────────

  Widget _buildOutfitsTab(UserStats stats) {
    final outfits = _cosmetics.getAvailableOutfits(stats);

    final defaultOutfit = outfits
        .where((o) => o.unlockCondition.type == UnlockType.defaultUnlock)
        .toList();
    final seasonal = outfits
        .where((o) => o.unlockCondition.type == UnlockType.seasonal)
        .toList();
    final achievement = outfits
        .where((o) =>
            o.unlockCondition.type != UnlockType.seasonal &&
            o.unlockCondition.type != UnlockType.defaultUnlock)
        .toList();

    // Check if any seasonal outfits are currently active
    final hasActiveSeasonal = seasonal.any((o) => o.isUnlocked);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Preview
        _buildOutfitPreview(),
        const SizedBox(height: 24),

        // Default
        ...defaultOutfit.map((o) => _buildOutfitCard(o)),
        const SizedBox(height: 16),

        // Seasonal section
        if (seasonal.isNotEmpty) ...[
          Row(
            children: [
              Text(
                'Seasonal (Limited Time!)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (hasActiveSeasonal) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: seasonal.length,
            itemBuilder: (context, index) => _buildOutfitCard(seasonal[index]),
          ),
          const SizedBox(height: 24),
        ],

        // Achievement section
        Text(
          'Achievement Outfits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: achievement.length,
          itemBuilder: (context, index) =>
              _buildOutfitCard(achievement[index]),
        ),
      ],
    );
  }

  Widget _buildOutfitPreview() {
    final current = _cosmetics.getCurrentOutfit();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Current Look',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildOutfitImage(current.imagePath, 100),
            const SizedBox(height: 8),
            Text(
              current.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              current.description,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitCard(KumaOutfit outfit) {
    final isSelected = _cosmetics.selectedOutfit == outfit.type;
    final isUnlocked = outfit.isUnlocked;

    return GestureDetector(
      onTap: isUnlocked
          ? () async {
              await _cosmetics.selectOutfit(outfit.type);
              setState(() {});
            }
          : null,
      child: Card(
        color: isSelected
            ? const Color(0xFF8b6f47).withValues(alpha: 0.1)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF8b6f47)
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isUnlocked ? 1.0 : 0.3,
                    child: _buildOutfitImage(outfit.imagePath, 60),
                  ),
                  if (!isUnlocked)
                    const Icon(Icons.lock, size: 28, color: Colors.grey),
                  if (isSelected)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                outfit.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? null : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                isUnlocked
                    ? outfit.description
                    : _cosmetics.getOutfitUnlockHint(outfit),
                style: TextStyle(
                  fontSize: 11,
                  color: isUnlocked ? Colors.grey[600] : Colors.orange[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutfitImage(String imagePath, double size) {
    return Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(
        Icons.pets,
        size: size * 0.6,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  // ── Themes Tab ─────────────────────────────────────────────

  Widget _buildThemesTab(UserStats stats) {
    final themes = _cosmetics.getAvailableThemes(stats);

    final defaultThemes = themes
        .where((t) => t.unlockCondition.type == UnlockType.defaultUnlock)
        .toList();
    final seasonal = themes
        .where((t) => t.unlockCondition.type == UnlockType.seasonal)
        .toList();
    final achievement = themes
        .where((t) =>
            t.unlockCondition.type != UnlockType.seasonal &&
            t.unlockCondition.type != UnlockType.defaultUnlock)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current theme preview
        _buildThemePreview(),
        const SizedBox(height: 24),

        // Default
        ...defaultThemes.map((t) => _buildThemeCard(t)),
        const SizedBox(height: 16),

        // Seasonal
        if (seasonal.isNotEmpty) ...[
          Text(
            'Seasonal Themes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...seasonal.map((t) => _buildThemeCard(t)),
          const SizedBox(height: 16),
        ],

        // Achievement
        if (achievement.isNotEmpty) ...[
          Text(
            'Achievement Themes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...achievement.map((t) => _buildThemeCard(t)),
        ],
      ],
    );
  }

  Widget _buildThemePreview() {
    final current = _cosmetics.getCurrentTheme();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Current Theme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildThemeColorBar(current),
            const SizedBox(height: 8),
            Text(
              current.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(AppThemeData theme) {
    final isSelected = _cosmetics.selectedThemeId == theme.id;
    final isUnlocked = theme.isUnlocked;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: isUnlocked
            ? () async {
                await _cosmetics.selectTheme(theme.id);
                setState(() {});
              }
            : null,
        child: Card(
          color: isSelected
              ? const Color(0xFF8b6f47).withValues(alpha: 0.1)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF8b6f47)
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Color preview
                Opacity(
                  opacity: isUnlocked ? 1.0 : 0.4,
                  child: _buildThemeColorBar(theme),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            theme.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? null : Colors.grey,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUnlocked
                            ? 'Tap to apply'
                            : _cosmetics.getThemeUnlockHint(theme),
                        style: TextStyle(
                          fontSize: 12,
                          color: isUnlocked
                              ? Colors.grey[600]
                              : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isUnlocked)
                  const Icon(Icons.lock, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeColorBar(AppThemeData theme) {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Row(
          children: [
            Expanded(
              child: Container(color: Color(theme.primaryColor)),
            ),
            Expanded(
              child: Container(color: Color(theme.backgroundColor)),
            ),
            Expanded(
              child: Container(color: Color(theme.accentColor)),
            ),
          ],
        ),
      ),
    );
  }
}
