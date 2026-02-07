import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/user_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserSettings _settings;
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    final settings = await provider.loadSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<StudyProvider>(context, listen: false);
    await provider.saveSettings(_settings);
    setState(() {
      _isLoading = false;
      _hasChanges = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _updateSettings(UserSettings newSettings) {
    setState(() {
      _settings = newSettings;
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveSettings,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8b6f47)),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('Study Settings'),
                _buildCard([
                  _buildSliderTile(
                    title: 'New words per day',
                    subtitle: '${_settings.newWordsPerDay} words',
                    value: _settings.newWordsPerDay.toDouble(),
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(newWordsPerDay: value.round()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSliderTile(
                    title: 'Review words per day',
                    subtitle: '${_settings.reviewWordsPerDay} words',
                    value: _settings.reviewWordsPerDay.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(reviewWordsPerDay: value.round()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Auto-add to practice deck',
                    subtitle: 'Automatically add new words to practice',
                    value: _settings.autoAddToPractice,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(autoAddToPractice: value),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionHeader('Interval Multipliers'),
                _buildCard([
                  _buildSliderTile(
                    title: 'Easy multiplier',
                    subtitle: '${_settings.easyMultiplier.toStringAsFixed(1)}x',
                    value: _settings.easyMultiplier,
                    min: 1.5,
                    max: 4.0,
                    divisions: 25,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(
                          easyMultiplier: double.parse(value.toStringAsFixed(1)),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSliderTile(
                    title: 'Good multiplier',
                    subtitle: '${_settings.goodMultiplier.toStringAsFixed(1)}x',
                    value: _settings.goodMultiplier,
                    min: 1.0,
                    max: 3.0,
                    divisions: 20,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(
                          goodMultiplier: double.parse(value.toStringAsFixed(1)),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSliderTile(
                    title: 'Minimum interval',
                    subtitle: '${_settings.minInterval} day(s)',
                    value: _settings.minInterval.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(minInterval: value.round()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSliderTile(
                    title: 'Maximum interval',
                    subtitle: '${_settings.maxInterval} days',
                    value: _settings.maxInterval.toDouble(),
                    min: 30,
                    max: 365,
                    divisions: 67,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(maxInterval: value.round()),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionHeader('Notifications'),
                _buildCard([
                  _buildSwitchTile(
                    title: 'Daily reminder',
                    subtitle: 'Get reminded to study every day',
                    value: _settings.dailyReminderEnabled,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(dailyReminderEnabled: value),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionHeader('About'),
                _buildCard([
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Color(0xFF8b6f47)),
                    title: const Text('Spaced Repetition System'),
                    subtitle: const Text('Based on SM-2 algorithm'),
                    onTap: () => _showSrsInfoDialog(),
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8b6f47),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8b6f47).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8b6f47),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF8b6f47),
              inactiveTrackColor: const Color(0xFF8b6f47).withValues(alpha: 0.2),
              thumbColor: const Color(0xFF8b6f47),
              overlayColor: const Color(0xFF8b6f47).withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: const Color(0xFF8b6f47).withValues(alpha: 0.5),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF8b6f47);
        }
        return Colors.grey[400];
      }),
    );
  }

  void _showSrsInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Color(0xFF8b6f47)),
            SizedBox(width: 12),
            Text('Spaced Repetition'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How it works:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Words you know well are shown less often\n'
                '• Words you struggle with appear more frequently\n'
                '• The algorithm adapts to your learning pace',
              ),
              SizedBox(height: 16),
              Text(
                'Review buttons:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Hard: Short interval (struggle)\n'
                '• Good: Normal interval (remembered)\n'
                '• Easy: Long interval (too easy)',
              ),
              SizedBox(height: 16),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Review daily for best results\n'
                '• Be honest with difficulty ratings\n'
                '• Consistency beats intensity',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
