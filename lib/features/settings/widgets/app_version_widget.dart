import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Displays the current app version string (e.g., `'Munshi 1.0.0+1'`).
class AppVersionWidget extends StatefulWidget {
  /// Creates an [AppVersionWidget].
  ///
  /// [prefix] is prepended to the version string (defaults to `'Munshi'`).
  const AppVersionWidget({super.key, this.style, this.prefix = 'Munshi'});

  /// Optional text style to override the default.
  final TextStyle? style;

  /// Text prepended to the version number.
  final String prefix;

  @override
  State<AppVersionWidget> createState() => _AppVersionWidgetState();
}

class _AppVersionWidgetState extends State<AppVersionWidget> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _appVersion.isNotEmpty ? '${widget.prefix} v$_appVersion' : widget.prefix,
      style: widget.style,
    );
  }
}
