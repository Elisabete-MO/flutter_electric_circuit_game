import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:eletrolab/core/ui_scale.dart';

void main() {
  group('UiScale - Responsiveness Across Screen Resolutions', () {
    test('1920x1080 (Reference Design Resolution) should have scale == 1.0', () {
      final ui = UiScale.fromSize(1920, 1080);
      expect(ui.scale, closeTo(1.0, 0.001));
      expect(ui.scaleX, closeTo(1.0, 0.001));
      expect(ui.scaleY, closeTo(1.0, 0.001));
      expect(ui.isDesktop, isTrue);
      expect(ui.is2K, isFalse);
      expect(ui.is4K, isFalse);
      expect(ui.isUltrawide, isFalse);
      expect(ui.size(100), closeTo(100.0, 0.01));
      expect(ui.font(16), closeTo(16.0, 0.01));
      expect(ui.spacing(12), closeTo(12.0, 0.01));
    });

    test('2560x1440 (2K / QHD) scales up proportionately (~1.33x)', () {
      final ui = UiScale.fromSize(2560, 1440);
      expect(ui.scale, closeTo(1.333, 0.01));
      expect(ui.is2K, isTrue);
      expect(ui.is4K, isFalse);
      expect(ui.size(100), greaterThan(100));
      expect(ui.font(16), greaterThan(16));
      expect(ui.spacing(12), greaterThan(12));
    });

    test('3840x2160 (4K / UHD) scales up proportionately (~2.0x)', () {
      final ui = UiScale.fromSize(3840, 2160);
      expect(ui.scale, closeTo(2.0, 0.01));
      expect(ui.is4K, isTrue);
      expect(ui.isDesktop, isTrue);
      expect(ui.size(100), closeTo(200.0, 1.0));
      expect(ui.font(16), greaterThan(25));
      expect(ui.font(16), lessThanOrEqualTo(32)); // Clamped reasonably
    });

    test('1366x768 (Standard Laptop) scales down safely without breaking legibility', () {
      final ui = UiScale.fromSize(1366, 768);
      expect(ui.scale, closeTo(0.72, 0.02)); // Clamped to min 0.72
      expect(ui.isDesktop, isTrue);
      expect(ui.font(14), greaterThanOrEqualTo(10.0));
    });

    test('1440x900 (16:10 Laptop) scales smoothly without distortion', () {
      final ui = UiScale.fromSize(1440, 900);
      expect(ui.scale, greaterThanOrEqualTo(0.72));
      expect(ui.scale, lessThan(1.0));
      expect(ui.isDesktop, isTrue);
    });

    test('1280x720 (720p HD) scales safely with minimum bounds', () {
      final ui = UiScale.fromSize(1280, 720);
      expect(ui.scale, closeTo(0.72, 0.01)); // Clamped
      expect(ui.font(16), greaterThanOrEqualTo(12.0));
    });

    test('2560x1080 (Ultrawide 21:9) preserves vertical scale without overflow', () {
      final ui = UiScale.fromSize(2560, 1080);
      expect(ui.isUltrawide, isTrue);
      // scaleY is 1.0, scaleX is 1.33 -> min is 1.0, preventing vertical overflow
      expect(ui.scale, closeTo(1.0, 0.01));
    });

    test('3440x1440 (Ultrawide QHD) scales according to vertical bound', () {
      final ui = UiScale.fromSize(3440, 1440);
      expect(ui.isUltrawide, isTrue);
      // scaleY is 1.333, scaleX is 1.79 -> min is 1.333
      expect(ui.scale, closeTo(1.333, 0.01));
    });

    test('EdgeInsets and dialog width scaling calculations', () {
      final ui = UiScale.fromSize(2560, 1440);
      final insets = ui.insetsAll(16);
      expect(insets.left, greaterThan(16));
      expect(insets.top, greaterThan(16));

      final dialogW = ui.dialogWidth(460);
      expect(dialogW, greaterThan(460));
      expect(dialogW, lessThan(2560 * 0.9));
    });

    testWidgets('UiScaleContext extension on BuildContext', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1920, 1080)),
            child: Builder(
              builder: (context) {
                final scale = context.uiScale.scale;
                final responsive = context.responsive.scale;
                expect(scale, closeTo(1.0, 0.001));
                expect(responsive, closeTo(1.0, 0.001));
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });
}
