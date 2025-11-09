import 'package:flutter_ocr_platform_interface/flutter_ocr_platform_interface.dart';

FlutterOcrPlatform get _platform => FlutterOcrPlatform.instance;

/// Returns the name of the current platform.
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}
