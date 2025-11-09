import 'package:flutter_ocr/flutter_ocr.dart';
import 'package:flutter_ocr_platform_interface/flutter_ocr_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterOcrPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FlutterOcrPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(FlutterOcrPlatform, () {
    late FlutterOcrPlatform flutterOcrPlatform;

    setUp(() {
      flutterOcrPlatform = MockFlutterOcrPlatform();
      FlutterOcrPlatform.instance = flutterOcrPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => flutterOcrPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => flutterOcrPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(getPlatformName, throwsException);
      });
    });
  });
}
