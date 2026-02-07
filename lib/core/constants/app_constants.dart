/// Application-wide constants and configuration values
library;

/// Animation duration constants
class AnimationDurations {
  AnimationDurations._();

  static const Duration fast = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration verySlow = Duration(milliseconds: 1000);
  
  // Staggered animation delays
  static const Duration staggerDelay = Duration(milliseconds: 120);
  static const Duration initialDelay = Duration(milliseconds: 400);
}

/// UI spacing constants
class Spacing {
  Spacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

/// Border radius constants
class BorderRadii {
  BorderRadii._();

  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 24.0;
}

/// App configuration
class AppConfig {
  AppConfig._();

  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'support@sarankar.com',
  );

  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://munshi.sarankar.com/privacy.html',
  );

  static const String termsOfServiceUrl = String.fromEnvironment(
    'TERMS_OF_SERVICE_URL',
    defaultValue: 'https://munshi.sarankar.com/terms.html',
  );
}

/// Theme options
class ThemeOptions {
  ThemeOptions._();

  static const List<String> modes = ['Light', 'Dark', 'Auto'];
}

/// Period/Timeframe options
class TimeframeOptions {
  TimeframeOptions._();

  static const List<String> options = [
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
  ];
}
