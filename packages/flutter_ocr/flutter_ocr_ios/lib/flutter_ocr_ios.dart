import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ocr_platform_interface/flutter_ocr_platform_interface.dart';

/// The iOS implementation of [FlutterOcrPlatform].
class FlutterOcrIOS extends FlutterOcrPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ocr_ios');

  /// Registers this class as the default instance of [FlutterOcrPlatform]
  static void registerWith() {
    FlutterOcrPlatform.instance = FlutterOcrIOS();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}
