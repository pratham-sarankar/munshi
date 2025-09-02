# Munshi - Personal Finance Tracker

Munshi is a Flutter mobile application for personal expense tracking and financial management. It features a modern Material Design UI with transaction management, spending analytics, and settings configuration.

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Prerequisites and Environment Setup
- Install Flutter SDK (minimum version 3.8.1 as per pubspec.yaml):
  - `git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter`
  - `export PATH="/tmp/flutter/bin:$PATH"`
  - `flutter doctor` -- diagnoses Flutter environment issues
- CRITICAL: Network connectivity required for Flutter SDK downloads. If downloads fail with connectivity issues, document the limitation and work with available tools.

### Bootstrap, Build, and Test Commands
- **Initial setup**: `flutter pub get` -- downloads dependencies. Takes 2-5 minutes. NEVER CANCEL. Set timeout to 10+ minutes.
- **Code analysis**: `flutter analyze` -- runs static analysis using rules from analysis_options.yaml. Takes 30-60 seconds.
- **Format code**: `flutter format .` -- formats all Dart files according to Dart style guide.
- **Build for Android**: `flutter build apk` -- takes 5-15 minutes depending on device. NEVER CANCEL. Set timeout to 30+ minutes.
- **Build for iOS**: `flutter build ios` -- takes 10-25 minutes. NEVER CANCEL. Set timeout to 45+ minutes. Requires macOS and Xcode.
- **Run tests**: `flutter test` -- runs unit tests in test/ directory. Takes 30-90 seconds. NEVER CANCEL. Set timeout to 5+ minutes.

### Development and Running
- **Hot reload development**: `flutter run` -- launches app on connected device/emulator with hot reload. NEVER CANCEL. Set timeout to 15+ minutes for initial build.
- **Run on specific device**: `flutter run -d <device_id>` -- use `flutter devices` to list available devices
- **Debug mode**: `flutter run --debug` -- default mode with debugging enabled
- **Profile mode**: `flutter run --profile` -- for performance testing
- **Release mode**: `flutter run --release` -- optimized production build

### Validation Scenarios
**ALWAYS manually validate your changes by running through these complete user scenarios after making code changes:**

1. **Navigation Flow**: Launch app → verify bottom navigation works → tap through Home, Transactions, Settings tabs
2. **Home Screen Interaction**: Verify greeting displays → check month selector arrows work → confirm transaction list animates properly
3. **Transaction Management**: Go to Transactions tab → test search functionality → try filter chips → verify "Add Transaction" button works
4. **Settings Configuration**: Navigate to Settings → toggle notification switches → change dropdown values → verify changes persist
5. **UI Responsiveness**: Test all animations and transitions → verify Material Design theming → check dark/light mode if implemented

## Project Structure and Navigation

### Key Directories
```
lib/
├── main.dart              # App entry point and theme setup
├── core/
│   └── theme.dart        # Material Design 3 theme configuration
├── screens/
│   ├── main_screen.dart  # Bottom navigation controller
│   ├── home_screen.dart  # Dashboard with spending summary
│   ├── transactions_screen.dart  # Transaction list and management
│   └── settings_screen.dart      # App configuration
└── widgets/
    └── transaction_tile.dart      # Reusable transaction list item

test/
└── widget_test.dart      # Basic widget tests (currently placeholder)

android/                  # Android-specific configurations
ios/                      # iOS-specific configurations
```

### Important Files to Know
- **pubspec.yaml**: Dependencies and app metadata. Key dependencies: `google_fonts`, `icons_plus`, `cupertino_icons`
- **analysis_options.yaml**: Linting rules based on `flutter_lints` package
- **lib/main.dart**: App initialization with Material theme setup using Google Fonts (Manrope)
- **lib/screens/home_screen.dart**: Main dashboard with sample transaction data and animations (670+ lines)
- **lib/screens/transactions_screen.dart**: Transaction list with search, filtering, and detail modals (800+ lines)

### Code Patterns and Architecture
- **State Management**: Uses StatefulWidget with setState for local state
- **Navigation**: Bottom navigation with MaterialApp router
- **Animations**: Extensive use of AnimationController and custom transitions (multiple controllers per screen)
- **Design System**: Material Design 3 with custom color schemes (comprehensive theme.dart)
- **Sample Data**: Currently uses hardcoded transaction data (no backend integration)
- **Currency Formatting**: Custom `_formatCurrency()` methods for Indian Rupee display
- **Consistent Imports**: Uses relative imports (package:munshi/...) and external packages (flutter, icons_plus, google_fonts)

### Key Implementation Patterns Found
- **Animation Disposal**: All screens properly dispose AnimationControllers in dispose() method
- **Color Scheme Usage**: Consistent use of `Theme.of(context).colorScheme` throughout
- **Hero Animations**: Used for transaction icons in navigation transitions
- **Staggered Animations**: Multiple items animate in sequence (transactions, settings sections)
- **Material Design**: Extensive use of Material 3 components (NavigationBar, Cards, Chips, etc.)

## Common Development Tasks

### Making UI Changes
- Always check home_screen.dart (670 lines) and transactions_screen.dart (799 lines) for UI components
- Use Material Design 3 components and follow existing color scheme patterns
- Test animations and transitions after changes
- Verify both light and dark theme support (though current app defaults to light mode)

### Adding New Features
- Follow existing file structure: create screens in lib/screens/, widgets in lib/widgets/
- Import Iconsax icons from icons_plus package for consistency (used throughout the app)
- Use existing animation patterns for smooth transitions
- Always add proper null safety and error handling

### Understanding the Codebase (8 Dart files total)
- **main_screen.dart** (59 lines): Simple bottom navigation setup
- **home_screen.dart** (670 lines): Complex dashboard with animations, sample data, and currency formatting
- **transactions_screen.dart** (799 lines): Full-featured transaction management with search, filters, and modals
- **settings_screen.dart** (485 lines): Settings UI with dropdowns, switches, and animations
- **transaction_tile.dart** (97 lines): Reusable widget for transaction list items
- **theme.dart** (387 lines): Comprehensive Material Design 3 theme with light/dark variants

### Debugging Common Issues
- **Build failures**: Run `flutter clean && flutter pub get` then rebuild
- **Animation glitches**: Check AnimationController disposal in dispose() methods
- **Theme inconsistencies**: Reference MaterialTheme class in lib/core/theme.dart
- **Import errors**: Ensure proper relative imports from lib/ directory

### Linting and Code Quality
- **ALWAYS run before committing**: `flutter analyze` followed by `flutter format .`
- Fix all analyzer warnings - the CI will fail if linting issues exist
- Follow existing code style patterns in the codebase
- Use meaningful variable names and add comments for complex business logic

## Build Times and Timeouts
- **Initial build**: 10-20 minutes (includes dependency resolution and code generation)
- **Incremental builds**: 2-5 minutes
- **Hot reload**: 1-3 seconds (development only)
- **Tests**: 30-90 seconds
- **APK generation**: 5-15 minutes
- **iOS build**: 10-25 minutes (requires macOS)

**CRITICAL**: NEVER CANCEL long-running commands. Set timeouts of 30+ minutes for builds, 15+ minutes for `flutter run`, and 10+ minutes for dependency installation.

## Known Limitations
- No backend integration - uses sample/hardcoded data
- No persistent storage - data resets on app restart
- Transaction adding is placeholder functionality (shows modal but doesn't save)
- Network restrictions may prevent Flutter SDK installation in some environments
- iOS builds require macOS environment with Xcode installed

## Troubleshooting
- **"flutter: command not found"**: Flutter SDK not installed or not in PATH
- **"Waiting for another flutter command to release the startup lock"**: Kill other Flutter processes or wait for completion
- **Gradle build failures on Android**: Run `flutter clean` and ensure Android SDK is properly configured
- **iOS build issues**: Verify Xcode installation and iOS deployment target compatibility
- **Dependency conflicts**: Delete pubspec.lock and run `flutter pub get` again

Always test your changes on both Android and iOS if possible, but prioritize Android testing if only one platform is available.

## Quick Reference

### Frequently Used Commands
```bash
# Essential development commands (copy-paste ready)
flutter pub get               # Install dependencies
flutter analyze              # Run static analysis
flutter format .             # Format code
flutter run                  # Start development with hot reload
flutter test                 # Run tests
flutter clean                # Clean build cache
flutter doctor               # Check Flutter installation
```

### File Contents Summary
The following are outputs from frequently accessed files to save time:

#### Root Directory Structure
```
.
├── README.md                 # Basic Flutter project description
├── pubspec.yaml             # Dependencies: google_fonts ^6.3.1, icons_plus ^5.0.0
├── analysis_options.yaml    # Linting config with flutter_lints ^5.0.0
├── lib/                     # Main source code (8 .dart files)
├── test/                    # Test files (widget_test.dart)
├── android/                 # Android build configuration
├── ios/                     # iOS build configuration
└── .github/                 # GitHub configurations and this file
```

#### pubspec.yaml Key Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.3.1        # Used for Manrope font
  icons_plus: ^5.0.0          # Iconsax icons throughout app

dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^5.0.0       # Enforced linting rules
```