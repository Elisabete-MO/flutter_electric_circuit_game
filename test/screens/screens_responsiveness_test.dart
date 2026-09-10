import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/app/routes.dart';
import 'package:eletrolab/screens/intro_screen.dart';
import 'package:eletrolab/screens/main_menu/main_menu_screen.dart';
import 'package:eletrolab/screens/splash/splash_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:eletrolab/state/progress_controller.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  const List<Size> testResolutions = [
    Size(1920, 1080), // Desktop Full HD
    Size(1280, 720),  // Desktop HD
    Size(1024, 768),  // Tablet 4:3 Landscape
    Size(768, 1024),  // Tablet 4:3 Portrait
    Size(844, 390),   // Mobile Landscape (iPhone 14 / modern Android)
    Size(800, 360),   // Mobile Landscape curto
    Size(667, 375),   // Mobile Landscape (iPhone SE)
    Size(390, 844),   // Mobile Portrait
    Size(360, 780),   // Mobile Portrait padrão
    Size(320, 568),   // Mobile Portrait compacto
    Size(320, 480),   // Mobile Portrait ultra-curto (iPhone 4)
    Size(600, 300),   // Mobile Landscape ultra-curto
  ];

  Widget createTestApp(Widget home) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == Routes.menu) {
            return MaterialPageRoute(builder: (_) => const MainMenuScreen());
          }
          if (settings.name == Routes.intro) {
            return MaterialPageRoute(builder: (_) => const IntroScreen());
          }
          if (settings.name == Routes.home) {
            return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Home')));
          }
          return null;
        },
        home: home,
      ),
    );
  }

  group('Responsividade - SplashScreen', () {
    for (final size in testResolutions) {
      testWidgets('Renderiza sem overflow em ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createTestApp(const SplashScreen()));
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(SplashScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Responsividade - MainMenuScreen', () {
    for (final size in testResolutions) {
      testWidgets('Renderiza sem overflow em ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createTestApp(const MainMenuScreen()));
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(MainMenuScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Testa também a transição para o submenu Modos de Jogo
        final modosBtn = find.text('Modos de Jogo');
        if (modosBtn.evaluate().isNotEmpty) {
          await tester.tap(modosBtn.first);
          await tester.pump(const Duration(milliseconds: 250));
          expect(tester.takeException(), isNull);
        }
      });
    }
  });

  group('Responsividade - IntroScreen', () {
    for (final size in testResolutions) {
      testWidgets('Renderiza sem overflow em ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createTestApp(const IntroScreen()));
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(IntroScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Toca no card para acelerar o texto
        final nuriFinder = find.text('Professora Nuri');
        if (nuriFinder.evaluate().isNotEmpty) {
          await tester.tap(nuriFinder.first);
          await tester.pump(const Duration(milliseconds: 200));
          expect(tester.takeException(), isNull);
        }
      });
    }
  });
}
