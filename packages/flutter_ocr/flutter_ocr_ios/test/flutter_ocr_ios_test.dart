import 'package:flutter/services.dart';
import 'package:flutter_ocr_ios/flutter_ocr_ios.dart';
import 'package:flutter_ocr_platform_interface/flutter_ocr_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterOcrIOS', () {
    const kPlatformName = 'iOS';
    late FlutterOcrIOS flutterOcr;
    late List<MethodCall> log;

    setUp(() async {
      flutterOcr = FlutterOcrIOS();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(flutterOcr.methodChannel, (
            methodCall,
          ) async {
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
      FlutterOcrIOS.registerWith();
      expect(FlutterOcrPlatform.instance, isA<FlutterOcrIOS>());
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
