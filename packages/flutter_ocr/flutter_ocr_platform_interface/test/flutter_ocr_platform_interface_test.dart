import 'package:flutter_ocr_platform_interface/flutter_ocr_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class FlutterOcrMock extends FlutterOcrPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;

  @override
  Future<String> recognizeTextFromImage(String imagePath) async {
    return 'Recognized text from $imagePath';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('FlutterOcrPlatformInterface', () {
    late FlutterOcrPlatform flutterOcrPlatform;

    setUp(() {
      flutterOcrPlatform = FlutterOcrMock();
      FlutterOcrPlatform.instance = flutterOcrPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await FlutterOcrPlatform.instance.getPlatformName(),
          equals(FlutterOcrMock.mockPlatformName),
        );
      });
    });
  });
}
