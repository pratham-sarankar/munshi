import 'package:flutter_ocr_platform_interface/flutter_ocr_platform_interface.dart';

/// This class provides access to OCR functionalities.
class FlutterOcr {
  FlutterOcr._();

  static FlutterOcrPlatform get _platform => FlutterOcrPlatform.instance;

  /// Returns the name of the current platform.
  static Future<String> getPlatformName() async {
    final platformName = await _platform.getPlatformName();
    if (platformName == null) throw Exception('Unable to get platform name.');
    return platformName;
  }

  /// Recognizes text from an image file located at [imagePath].
  static Future<String?> recognizeTextFromImage(String imagePath) async {
    return _platform.recognizeTextFromImage(imagePath);
  }
}
