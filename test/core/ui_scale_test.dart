import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:eletrolab/core/ui_scale.dart';

void main() {
  group('UiScale - Responsiveness Across Screen Resolutions', () {
    test('semantic typography tokens meet readable desktop minimums', () {
      final desktop = UiScale.fromSize(1366, 768);

      expect(
        UiTypography.title * desktop.textScale,
        inInclusiveRange(24.0, 28.0),
      );
      expect(
        UiTypography.panelTitle * desktop.textScale,
        inInclusiveRange(20.0, 22.0),
      );
      expect(UiTypography.body * desktop.textScale, greaterThanOrEqualTo(16.0));
      expect(
        UiTypography.button * desktop.textScale,
        greaterThanOrEqualTo(15.0),
      );
      expect(
        UiTypography.label * desktop.textScale,
        greaterThanOrEqualTo(13.0),
      );
      expect(
        UiTypography.caption * desktop.textScale,
        greaterThanOrEqualTo(12.0),
      );
    });

    test(
      '1920x1080 (Reference Design Resolution) should have scale == 1.0',
      () {
        final ui = UiScale.fromSize(1920, 1080);
        expect(ui.scale, closeTo(1.0, 0.001));
        expect(ui.scaleX, closeTo(1.0, 0.001));
        expect(ui.scaleY, closeTo(1.0, 0.001));
        expect(ui.isDesktop, isTrue);
        expect(ui.is2K, isFalse);
        expect(ui.is4K, isFalse);
        expect(ui.isUltrawide, isFalse);
        expect(ui.size(100), closeTo(100.0, 0.01));
        expect(ui.textScale, closeTo(1.19, 0.01));
        expect(ui.font(16), 16);
        expect(ui.spacing(12), closeTo(12.0, 0.01));
      },
    );

    test('2560x1440 (2K / QHD) grows the interface only to its safe cap', () {
      final ui = UiScale.fromSize(2560, 1440);
      expect(ui.canvasScale, closeTo(1.333, 0.01));
      expect(ui.scale, 1.25);
      expect(ui.is2K, isTrue);
      expect(ui.is4K, isFalse);
      expect(ui.size(100), greaterThan(100));
      expect(ui.textScale, greaterThan(1.2));
      expect(ui.spacing(12), greaterThan(12));
    });

    test('3840x2160 (4K / UHD) scales up proportionately (~2.0x)', () {
      final ui = UiScale.fromSize(3840, 2160);
      expect(ui.canvasScale, closeTo(2.0, 0.01));
      expect(ui.scale, 1.25);
      expect(ui.is4K, isTrue);
      expect(ui.isDesktop, isTrue);
      expect(ui.size(100), closeTo(125.0, 1.0));
      expect(ui.textScale, 1.24);
    });

    test('1366x768 (Standard Laptop) increases typography for readability', () {
      final ui = UiScale.fromSize(1366, 768);
      expect(ui.scale, 1.0);
      expect(ui.isDesktop, isTrue);
      expect(ui.textScale, greaterThan(1.15));
      expect(14 * ui.textScale, greaterThan(16.0));
    });

    test('1440x900 (16:10 Laptop) scales smoothly without distortion', () {
      final ui = UiScale.fromSize(1440, 900);
      expect(ui.scale, 1.0);
      expect(ui.isDesktop, isTrue);
    });

    test('1280x720 (720p HD) keeps desktop typography legible', () {
      final ui = UiScale.fromSize(1280, 720);
      expect(ui.scale, 1.0);
      expect(16 * ui.textScale, greaterThan(18.0));
    });

    test('mobile landscape improves the minimum readable typography', () {
      final ui = UiScale.fromSize(844, 390);
      expect(ui.isMobile, isTrue);
      expect(ui.textScale, 1.08);
      expect(14 * ui.textScale, greaterThanOrEqualTo(15.0));
    });

    test(
      'tablet typography grows moderately and large desktops are capped',
      () {
        final tablet = UiScale.fromSize(800, 1280);
        final largeDesktop = UiScale.fromSize(3840, 2160);

        expect(tablet.textScale, inInclusiveRange(1.10, 1.14));
        expect(largeDesktop.textScale, 1.24);
      },
    );

    test(
      '2560x1080 (Ultrawide 21:9) preserves vertical scale without overflow',
      () {
        final ui = UiScale.fromSize(2560, 1080);
        expect(ui.isUltrawide, isTrue);
        // Canvas preserves the vertical scale; interface keeps natural size.
        expect(ui.canvasScale, closeTo(1.0, 0.01));
        expect(ui.scale, 1.0);
      },
    );

    test('3440x1440 (Ultrawide QHD) scales according to vertical bound', () {
      final ui = UiScale.fromSize(3440, 1440);
      expect(ui.isUltrawide, isTrue);
      // Canvas follows the vertical bound, while interface growth is capped.
      expect(ui.canvasScale, closeTo(1.333, 0.01));
      expect(ui.scale, 1.25);
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
