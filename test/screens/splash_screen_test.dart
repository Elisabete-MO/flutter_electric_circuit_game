import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eletrolab/app/routes.dart';
import 'package:eletrolab/screens/splash/splash_screen.dart';
import 'package:eletrolab/state/progress_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildSplashScreen({
    required SharedPreferences prefs,
    Duration minDuration = const Duration(milliseconds: 100),
    bool preloadAssets = false,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp(
        initialRoute: Routes.splash,
        routes: {
          Routes.splash: (_) => SplashScreen(
                minDuration: minDuration,
                preloadAssets: preloadAssets,
              ),
          Routes.intro: (_) => const Scaffold(body: Text('Tela Professora Nuri')),
          Routes.menu: (_) => const Scaffold(body: Text('Tela Menu Principal')),
        },
      ),
    );
  }

  group('SplashScreen', () {
    testWidgets('renderiza marca EletroLab, medidor de voltagem e barra de carga', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        buildSplashScreen(
          prefs: prefs,
          minDuration: const Duration(seconds: 10),
        ),
      );

      // Render inicial
      await tester.pump();

      expect(find.text('JOGO 1 • VOLUME 1'), findsOneWidget);
      expect(find.text('EletroLab'), findsOneWidget);
      expect(find.text('MISSÃO: ENERGIZAR A FEIRA DE CIÊNCIAS'), findsOneWidget);
      expect(find.byIcon(Icons.bolt_rounded), findsWidgets);
      expect(find.textContaining('0.0 V'), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);
    });

    testWidgets('direciona para o Menu Principal após a conclusão do carregamento', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        buildSplashScreen(
          prefs: prefs,
          minDuration: const Duration(milliseconds: 80),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Tela Menu Principal'), findsOneWidget);
    });
  });
}
