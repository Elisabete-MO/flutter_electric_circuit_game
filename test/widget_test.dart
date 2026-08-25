import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eletrolab/app/app.dart';
import 'package:eletrolab/models/settings_model.dart';
import 'package:eletrolab/services/settings_service.dart';
import 'package:eletrolab/state/settings_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    SettingsModel settings = const SettingsModel(),
  }) async {
    await tester.binding.setSurfaceSize(const Size(900, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(SettingsService()),
          settingsControllerProvider.overrideWith(
            () => SettingsController(initial: settings),
          ),
        ],
        child: const EletroLabApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapSection(WidgetTester tester, String label) async {
    final finder = find.text(label);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('Home', () {
    testWidgets('exibe a identidade do EletroLab', (tester) async {
      await pumpApp(tester);

      expect(find.text('EletroLab'), findsOneWidget);
      expect(
        find.text('Seu laboratório virtual de circuitos'),
        findsOneWidget,
      );
      expect(find.text('EletroLab v1.0.0'), findsOneWidget);
    });

    testWidgets('exibe as quatro opções principais', (tester) async {
      await pumpApp(tester);

      expect(find.text('Primeiros passos'), findsOneWidget);
      expect(find.text('Começar'), findsOneWidget);
      expect(find.text('Banqueta'), findsOneWidget);
      expect(find.text('Configurações'), findsOneWidget);
    });

    testWidgets('navega das seções de volta para a home', (tester) async {
      await pumpApp(tester);

      await tapSection(tester, 'Banqueta');
      expect(find.text('Em construção'), findsOneWidget);

      final navigator =
          tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.text('Banqueta'), findsOneWidget);
    });
  });

  group('Settings', () {
    testWidgets('abre a tela de configurações', (tester) async {
      await pumpApp(tester);

      await tapSection(tester, 'Configurações');

      expect(find.text('Aparência e Idioma'), findsOneWidget);
      expect(find.text('Simulação'), findsOneWidget);
      expect(find.text('Acessibilidade'), findsOneWidget);
      expect(find.text('Dados'), findsOneWidget);
      expect(find.text('Versão 1.0.0'), findsOneWidget);
    });

    testWidgets('troca o tema para escuro e persiste', (tester) async {
      await pumpApp(tester);

      await tapSection(tester, 'Configurações');

      await tapSection(tester, 'Escuro');

      final service = SettingsService();
      final saved = await service.load();
      expect(saved.themeMode, AppThemeMode.dark);
    });
  });
}