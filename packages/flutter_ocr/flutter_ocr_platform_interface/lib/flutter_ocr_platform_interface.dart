import 'package:flutter_ocr_platform_interface/src/method_channel_flutter_ocr.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// {@template flutter_ocr_platform}
/// The interface that implementations of flutter_ocr must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `FlutterOcr`.
///
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
/// this interface will be broken by newly added [FlutterOcrPlatform] methods.
/// {@endtemplate}
abstract class FlutterOcrPlatform extends PlatformInterface {
  /// {@macro flutter_ocr_platform}
  FlutterOcrPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterOcrPlatform _instance = MethodChannelFlutterOcr();

  /// The default instance of [FlutterOcrPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterOcr].
  static FlutterOcrPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterOcrPlatform] when they register themselves.
  static set instance(FlutterOcrPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the current platform name.
  Future<String?> getPlatformName();

  /// Recognize text from an image file at the given [imagePath].
  /// Returns the recognized text as a [String].
  /// Throws an [Exception] if recognition fails.
  Future<String?> recognizeTextFromFile(String imagePath);
}
