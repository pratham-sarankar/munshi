import 'package:flutter/services.dart';
import 'package:flutter_ocr_android/flutter_ocr_android.dart';
import 'package:flutter_ocr_platform_interface/flutter_ocr_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterOcrAndroid', () {
    const kPlatformName = 'Android';
    late FlutterOcrAndroid flutterOcr;
    late List<MethodCall> log;

    setUp(() async {
      flutterOcr = FlutterOcrAndroid();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(flutterOcr.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      FlutterOcrAndroid.registerWith();
      expect(FlutterOcrPlatform.instance, isA<FlutterOcrAndroid>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await flutterOcr.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
