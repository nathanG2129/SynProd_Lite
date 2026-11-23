import 'package:flutter_test/flutter_test.dart';
import 'package:synprod_lite/core/services/app_updater_service.dart';

void main() {
  group('AppUpdaterService.isNewerVersion', () {
    test('detects newer major, minor, and patch versions', () {
      expect(AppUpdaterService.isNewerVersion('1.0.0', '1.1.0'), isTrue);
      expect(AppUpdaterService.isNewerVersion('1.1.0', '1.1.1'), isTrue);
      expect(AppUpdaterService.isNewerVersion('1.1.0', '2.0.0'), isTrue);
    });

    test('returns false when remote version is equal or older (including build numbers and v prefixes)', () {
      expect(AppUpdaterService.isNewerVersion('1.1.0', '1.1.0'), isFalse);
      expect(AppUpdaterService.isNewerVersion('1.1.0+4', 'v1.1.0'), isFalse);
      expect(AppUpdaterService.isNewerVersion('1.1.1', '1.1.0'), isFalse);
      expect(AppUpdaterService.isNewerVersion('2.0.0', '1.9.9'), isFalse);
    });
  });
}
