import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:flutter_ocr_platform_interface/flutter_ocr_platform_interface.dart';

/// An implementation of [FlutterOcrPlatform] that uses method channels.
class MethodChannelFlutterOcr extends FlutterOcrPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ocr');

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}
