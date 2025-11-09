import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ocr_platform_interface/flutter_ocr_platform_interface.dart';

/// The Android implementation of [FlutterOcrPlatform].
class FlutterOcrAndroid extends FlutterOcrPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ocr_android');

  /// Registers this class as the default instance of [FlutterOcrPlatform]
  static void registerWith() {
    FlutterOcrPlatform.instance = FlutterOcrAndroid();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<String?> recognizeTextFromFile(String imagePath) {
    return methodChannel.invokeMethod<String>(
      'recognizeTextFromFile',
      {'imagePath': imagePath},
    );
  }
}
