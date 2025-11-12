import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/models/period_type.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/features/auth/screens/login_screen.dart';
import 'package:munshi/features/auth/services/auth_service.dart';
import 'package:munshi/features/settings/screens/currency_selection_screen.dart';
import 'package:munshi/features/settings/widgets/app_version_widget.dart';
import 'package:munshi/providers/currency_provider.dart';
import 'package:munshi/providers/period_provider.dart';
import 'package:munshi/providers/theme_provider.dart';
import 'package:munshi/widgets/rounded_dropdown.dart';
import 'package:munshi/widgets/webview_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _dailyReport = true;
  bool _emailTransactionExtraction = true;

  final List<String> _themeOptions = ['Light', 'Dark', 'Auto'];

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

    if (result ?? false && mounted) {
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
              content: Text('Logout failed: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _reportBug() async {
    try {
      // Get app information
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final version = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;

      // Get platform information
      final platform = Platform.isIOS ? 'iOS' : 'Android';

      // Get support email from environment
      const supportEmail = String.fromEnvironment(
        'SUPPORT_EMAIL',
        defaultValue: 'support@sarankar.com',
      );

      // Prepare email content
      final subject = Uri.encodeComponent('Bug Report - $appName');
      final body = Uri.encodeComponent('''
Hello Munshi Support Team,

I would like to report a bug in the $appName mobile application.

APP INFORMATION:
- App Name: $appName
- Version: $version ($buildNumber)
- Platform: $platform

BUG DESCRIPTION:
[Please describe the bug you encountered in detail]

STEPS TO REPRODUCE:
1. [Step 1]
2. [Step 2]
3. [Step 3]

EXPECTED BEHAVIOR:
[What did you expect to happen?]

ACTUAL BEHAVIOR:
[What actually happened?]

ADDITIONAL INFORMATION:
[Any additional details, screenshots, or context that might help]

Thank you for your time and support!

Best regards,
[Your Name]
''');

      final emailUri = Uri.parse(
        'mailto:$supportEmail?subject=$subject&body=$body',
      );
      await launchUrl(emailUri);
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _sendFeedback() async {
    try {
      // Get app information
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final version = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;

      // Get platform information
      final platform = Platform.isIOS ? 'iOS' : 'Android';

      // Get support email from environment
      const supportEmail = String.fromEnvironment(
        'SUPPORT_EMAIL',
        defaultValue: 'support@sarankar.com',
      );

      // Prepare email content
      final subject = Uri.encodeComponent('Feedback - $appName');
      final body = Uri.encodeComponent('''
Hello Munshi Team,

I would like to share my feedback about the $appName mobile application.

APP INFORMATION:
- App Name: $appName
- Version: $version ($buildNumber)
- Platform: $platform

FEEDBACK TYPE:
[ ] Feature Request
[ ] Improvement Suggestion
[ ] General Feedback
[ ] User Experience

FEEDBACK DETAILS:
[Please share your thoughts, suggestions, or ideas for improvement]

WHAT I LIKE:
[Tell us what you enjoy about the app]

WHAT COULD BE IMPROVED:
[Share any suggestions for improvement]

ADDITIONAL COMMENTS:
[Any other thoughts or comments]

Thank you for making Munshi better!

Best regards,
[Your Name]
''');

      final emailUri = Uri.parse(
        'mailto:$supportEmail?subject=$subject&body=$body',
      );

      await launchUrl(emailUri);
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
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
                        Consumer<CurrencyProvider>(
                          builder: (context, currencyProvider, child) {
                            return _SettingsTile(
                              title: 'Currency',
                              subtitle:
                                  currencyProvider.selectedCurrency.displayName,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const CurrencySelectionScreen(),
                                  ),
                                );
                              },
                              trailing: Icon(
                                Icons.chevron_right,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            );
                          },
                        ),
                        _SettingsTile(
                          title: 'Preferred Dashboard View',
                          subtitle: 'Restart to apply changes',
                          trailing: Consumer<PeriodProvider>(
                            builder: (context, periodProvider, child) {
                              return RoundedDropdown<String>(
                                value: periodProvider.defaultPeriodDisplayName,
                                onChanged: (String? value) {
                                  if (value != null) {
                                    periodProvider
                                        .setDefaultPeriodByDisplayName(value);
                                    HapticFeedback.lightImpact();
                                  }
                                },
                                items: PeriodType.values
                                    .map<DropdownMenuItem<String>>((
                                      PeriodType option,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: option.displayName,
                                        child: Text(
                                          option.displayName,
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

                        _SettingsTile(
                          title: 'Theme',
                          subtitle: 'Light, Dark, or Auto',
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
                          title: 'Email Sync',
                          subtitle: 'Auto-sync transactions from emails',
                          trailing: Switch(
                            value: _emailTransactionExtraction,
                            onChanged: (bool value) {
                              setState(
                                () => _emailTransactionExtraction = value,
                              );
                              HapticFeedback.lightImpact();
                            },
                            activeThumbColor: colorScheme.primary,
                          ),
                        ),
                        _SettingsTile(
                          title: 'Daily Report',
                          subtitle: 'Receive daily expense summary',
                          trailing: Switch(
                            value: _dailyReport,
                            onChanged: (bool value) {
                              setState(() => _dailyReport = value);
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
                            const privacyPolicyUrl = String.fromEnvironment(
                              'PRIVACY_POLICY_URL',
                              defaultValue:
                                  'https://munshi.sarankar.com/privacy.html',
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const WebViewScreen(
                                  url: privacyPolicyUrl,
                                  title: 'Privacy Policy',
                                ),
                              ),
                            );
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
                            // Navigate to FAQ
                            const faqUrl = String.fromEnvironment(
                              'FAQ_URL',
                              defaultValue:
                                  'https://munshi.sarankar.com/faq.html',
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WebViewScreen(url: faqUrl, title: 'FAQ'),
                              ),
                            );
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
                            _reportBug();
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
                            _sendFeedback();
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
            ),
          ),
          color: colorScheme.surface,
          margin: EdgeInsets.zero,
          child: Column(
            children: List<Widget>.generate(tiles.length, (index) {
              final tile = tiles[index];
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

  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.hasDivider = true,
    super.key,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
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
