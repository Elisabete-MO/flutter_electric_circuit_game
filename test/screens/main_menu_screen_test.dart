import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eletrolab/app/routes.dart';
import 'package:eletrolab/screens/main_menu/main_menu_screen.dart';
import 'package:eletrolab/state/progress_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildMainMenuScreen({
    required SharedPreferences prefs,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp(
        initialRoute: Routes.menu,
        routes: {
          Routes.menu: (_) => const MainMenuScreen(),
          Routes.intro: (_) => const Scaffold(body: Text('Tela Intro')),
          Routes.home: (_) => const Scaffold(body: Text('Tela Feira')),
          Routes.sandbox: (_) => const Scaffold(body: Text('Tela Sandbox')),
          Routes.firstSteps: (_) => const Scaffold(body: Text('Tela Primeiros Passos')),
          Routes.settings: (_) => const Scaffold(body: Text('Tela Settings')),
        },
      ),
    );
  }

  group('MainMenuScreen (Opção 1)', () {
    testWidgets('sem progresso prévio: exibe Entrar na Feira e Modos de Jogo', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(buildMainMenuScreen(prefs: prefs));
      await tester.pumpAndSettle();

      // Opção principal e botão de Modos de Jogo
      expect(find.text('Entrar na Feira'), findsOneWidget);
      expect(find.text('Modos de Jogo'), findsOneWidget);

      // Não deve exibir Continuar de Onde Parou
      expect(find.text('Continuar de Onde Parou'), findsNothing);

      // Não deve exibir opções do submenu antes de clicar
      expect(find.text('Bancada Livre'), findsNothing);
      expect(find.text('Primeiros Passos & Conceitos'), findsNothing);

      // Clicar em Modos de Jogo
      await tester.tap(find.text('Modos de Jogo'));
      await tester.pumpAndSettle();

      // Submenu deve estar visível
      expect(find.text('MODOS DE JOGO'), findsOneWidget);
      expect(find.text('Bancada Livre'), findsOneWidget);
      expect(find.text('Primeiros Passos & Conceitos'), findsOneWidget);
      expect(find.text('Voltar'), findsOneWidget);

      // Clicar em Voltar
      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      // Deve retornar para a tela principal do menu
      expect(find.text('Entrar na Feira'), findsOneWidget);
      expect(find.text('Modos de Jogo'), findsOneWidget);
      expect(find.text('Bancada Livre'), findsNothing);
    });

    testWidgets('com progresso prévio: exibe Continuar de Onde Parou', (tester) async {
      SharedPreferences.setMockInitialValues({
        'completed_challenges': ['stand_01', 'stand_02'],
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(buildMainMenuScreen(prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('Continuar de Onde Parou'), findsOneWidget);
      expect(find.textContaining('2 de 12 estandes concluídos'), findsOneWidget);
      expect(find.text('Entrar na Feira'), findsOneWidget);
      expect(find.text('Modos de Jogo'), findsOneWidget);

      // Tocar em Continuar navega para a feira
      await tester.tap(find.text('Continuar de Onde Parou'));
      await tester.pumpAndSettle();

      expect(find.text('Tela Feira'), findsOneWidget);
    });
  });
}
