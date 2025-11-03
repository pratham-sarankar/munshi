import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:munshi/widgets/rounded_dropdown.dart';
import 'package:munshi/features/settings/widgets/app_version_widget.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/features/auth/services/auth_service.dart';
import 'package:munshi/features/auth/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _itemAnimations;

  // Settings state
  bool _expenseAlerts = true;
  bool _monthlySummary = false;
  String _selectedCurrency = '₹ (INR)';
  String _defaultMonthView = 'This Month';

  final List<String> _themeOptions = ['Light', 'Dark', 'Auto'];
  final List<String> _currencyOptions = [
    '₹ (INR)',
    '\$ (USD)',
    '€ (EUR)',
    '£ (GBP)',
  ];
  final List<String> _monthViewOptions = [
    'This Month',
    'Last Month',
    'Current Year',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for each section
    _itemAnimations = List<Animation<Offset>>.generate(
      6, // Number of animated sections (Preferences, Notifications, Security, Support, Logout, Footer)
      (int index) =>
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.1,
                0.5 + (index * 0.1),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await locator<AuthService>().signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Preferences Section
                SlideTransition(
                  position: _itemAnimations[0],
                  child: FadeTransition(
                    opacity: _animationController,
                    child: _buildSettingsSection(
                      colorScheme: colorScheme,
                      title: 'Preferences',
                      icon: Iconsax.setting_4_outline,
                      tiles: [
                        _SettingsTile(
                          title: 'Currency',
                          trailing: RoundedDropdown<String>(
                            value: _selectedCurrency,
                            onChanged: (String? value) =>
                                setState(() => _selectedCurrency = value!),
                            items: _currencyOptions
                                .map<DropdownMenuItem<String>>((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                        _SettingsTile(
                          title: 'Default Month View',
                          trailing: RoundedDropdown<String>(
                            value: _defaultMonthView,
                            onChanged: (String? value) =>
                                setState(() => _defaultMonthView = value!),
                            items: _monthViewOptions
                                .map<DropdownMenuItem<String>>((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                        _SettingsTile(
                          title: 'Theme',
                          trailing: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return RoundedDropdown<String>(
                                value: themeProvider.themeModeString,
                                onChanged: (String? value) {
                                  if (value != null) {
                                    themeProvider.setThemeMode(value);
                                    HapticFeedback.lightImpact();
                                  }
                                },
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                items: _themeOptions
                                    .map<DropdownMenuItem<String>>((
                                      String option,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: option,
                                        child: Text(
                                          option,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      );
                                    })
                                    .toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Notifications Section
                SlideTransition(
                  position: _itemAnimations[1],
                  child: FadeTransition(
                    opacity: _animationController,
                    child: _buildSettingsSection(
                      colorScheme: colorScheme,
                      title: 'Notifications',
                      icon: Iconsax.notification_outline,
                      tiles: [
                        _SettingsTile(
                          title: 'Expense Alerts',
                          subtitle: 'Get notified when you spend',
                          trailing: Switch(
                            value: _expenseAlerts,
                            onChanged: (bool value) {
                              setState(() => _expenseAlerts = value);
                              HapticFeedback.lightImpact();
                            },
                            activeThumbColor: colorScheme.primary,
                          ),
                        ),
                        _SettingsTile(
                          title: 'Monthly Summary',
                          subtitle: 'Monthly spending report',
                          trailing: Switch(
                            value: _monthlySummary,
                            onChanged: (bool value) {
                              setState(() => _monthlySummary = value);
                              HapticFeedback.lightImpact();
                            },
                            activeThumbColor: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Security Section
                SlideTransition(
                  position: _itemAnimations[2],
                  child: FadeTransition(
                    opacity: _animationController,
                    child: _buildSettingsSection(
                      colorScheme: colorScheme,
                      title: 'Security',
                      icon: Iconsax.security_user_outline,
                      tiles: [
                        _SettingsTile(
                          title: 'Privacy Policy & Terms',
                          subtitle: 'Read our privacy policy',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            // Navigate to privacy policy
                          },
                          trailing: Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Support Section
                SlideTransition(
                  position: _itemAnimations[3],
                  child: FadeTransition(
                    opacity: _animationController,
                    child: _buildSettingsSection(
                      colorScheme: colorScheme,
                      title: 'Support',
                      icon: Iconsax.support_outline,
                      tiles: [
                        _SettingsTile(
                          title: 'Help & FAQ',
                          subtitle: 'Get help and find answers',
                          onTap: () {
                            HapticFeedback.lightImpact();
                          },
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        _SettingsTile(
                          title: 'Report a Bug',
                          subtitle: 'Let us know about issues',
                          onTap: () {
                            HapticFeedback.lightImpact();
                          },
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        _SettingsTile(
                          title: 'Feedback',
                          subtitle: 'Share your thoughts',
                          onTap: () {
                            HapticFeedback.lightImpact();
                          },
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                SlideTransition(
                  position: _itemAnimations[4],
                  child: FadeTransition(
                    opacity: _animationController,
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _handleLogout,
                        icon: Icon(
                          Iconsax.logout_outline,
                          size: 20,
                          color: colorScheme.error,
                        ),
                        label: Text(
                          'Logout',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: colorScheme.error.withValues(alpha: 0.3),
                          ),
                          backgroundColor: colorScheme.error.withValues(
                            alpha: 0.08,
                          ),
                          overlayColor: colorScheme.error.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Footer
                SlideTransition(
                  position: _itemAnimations[5],
                  child: FadeTransition(
                    opacity: _animationController,
                    child: _buildFooter(colorScheme),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required ColorScheme colorScheme,
    required String title,
    required IconData icon,
    required List<Widget> tiles,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          clipBehavior: Clip.hardEdge,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          color: colorScheme.surface,
          margin: EdgeInsets.zero,
          child: Column(
            children: List<Widget>.generate(tiles.length, (index) {
              final Widget tile = tiles[index];
              if (tile is _SettingsTile) {
                return _SettingsTile(
                  key: tile.key,
                  title: tile.title,
                  subtitle: tile.subtitle,
                  trailing: tile.trailing,
                  onTap: tile.onTap,
                  hasDivider: index < tiles.length - 1,
                );
              }
              return tile;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AppVersionWidget(
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Made with ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text('❤️', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                ' in India',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool hasDivider;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.hasDivider = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            child: ListTile(
              title: Text(title),
              subtitle: subtitle == null ? null : Text(subtitle!),
              trailing: trailing,
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 12,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        if (hasDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: colorScheme.outline.withValues(alpha: 0.2),
              height: 1,
            ),
          ),
      ],
    );
  }
}
