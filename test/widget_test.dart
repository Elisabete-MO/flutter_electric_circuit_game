import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eletrolab/app/app.dart';
import 'package:eletrolab/app/routes.dart';
import 'package:eletrolab/models/settings_model.dart';
import 'package:eletrolab/models/first_step_component.dart';
import 'package:eletrolab/models/sandbox_component.dart';
import 'package:eletrolab/services/settings_service.dart';
import 'package:eletrolab/state/progress_controller.dart';
import 'package:eletrolab/state/settings_controller.dart';
import 'package:eletrolab/state/sandbox_controller.dart';
import 'package:eletrolab/services/sandbox_persistence_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  /// Avança o tempo de forma controlada.
  ///
  /// Não utiliza pumpAndSettle porque o aplicativo possui animações contínuas,
  /// que podem impedir o teste de atingir um estado completamente estável.
  Future<void> pumpSettle(WidgetTester tester) async {
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    SettingsModel settings = const SettingsModel(),
    bool skipIntro = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.binding.setSurfaceSize(const Size(900, 2000));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(
            SettingsService(),
          ),
          settingsControllerProvider.overrideWith(
            () => SettingsController(initial: settings),
          ),
        ],
        child: const EletroLabApp(),
      ),
    );

    await pumpSettle(tester);

    if (skipIntro) {
      final mapFinder = find.textContaining('Mapa');
      if (mapFinder.evaluate().isNotEmpty) {
        await tester.tap(mapFinder.first);
        await pumpSettle(tester);
      }
    } else {
      final playFinder = find.textContaining('Entrar na Feira');
      if (playFinder.evaluate().isNotEmpty) {
        await tester.tap(playFinder.first);
        await pumpSettle(tester);
      }
    }
  }

  group('Intro Screen', () {
    testWidgets('exibe boas-vindas da Professora Nuri e permite avançar ou pular', (tester) async {
      await pumpApp(tester, skipIntro: false);

      expect(find.text('Professora Nuri'), findsWidgets);
      expect(find.text('Pular'), findsOneWidget);

      await tester.tap(find.text('Professora Nuri').first);
      await pumpSettle(tester);
      await tester.tap(find.text('Próximo'));
      await pumpSettle(tester);
      await tester.tap(find.text('Professora Nuri').first);
      await pumpSettle(tester);

      expect(find.text('Continuar'), findsOneWidget);
    });
  });

  Future<void> tapSection(
    WidgetTester tester,
    String label,
  ) async {
    final Finder finder;
    if (label == 'Configurações') {
      finder = find.byIcon(Icons.settings_rounded);
    } else {
      finder = find.textContaining(label);
    }

    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder.first);
      await pumpSettle(tester);
    }
  }

  group('Home', () {
    testWidgets(
      'exibe a identidade do EletroLab',
      (tester) async {
        await pumpApp(tester, skipIntro: false);

        expect(
          find.text('EletroLab'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'exibe o mapa da feira de ciências e o estande selecionado',
      (tester) async {
        await pumpApp(tester);

        expect(
          find.text('Primeiros Passos'),
          findsWidgets,
        );

        expect(
          find.text('Iniciar Tutorial'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'navega das seções de volta para a home',
      (tester) async {
        await pumpApp(tester);

        await tapSection(tester, 'Configurações');

        expect(
          find.text('Aparência e Idioma'),
          findsOneWidget,
        );

        final navigator = tester.state<NavigatorState>(
          find.byType(Navigator).first,
        );

        navigator.pop();

        await pumpSettle(tester);

        expect(
          find.text('EletroLab'),
          findsWidgets,
        );
      },
    );
  });

  group('Settings', () {
    testWidgets(
      'abre a tela de configurações',
      (tester) async {
        await pumpApp(tester);

        await tapSection(tester, 'Configurações');

        expect(
          find.text('Aparência e Idioma'),
          findsOneWidget,
        );

        expect(
          find.text('Simulação'),
          findsOneWidget,
        );

        expect(
          find.text('Acessibilidade'),
          findsOneWidget,
        );

        expect(
          find.text('Dados'),
          findsOneWidget,
        );

        expect(
          find.text('Versão 1.0.0'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'troca o tema para escuro e persiste',
      (tester) async {
        await pumpApp(tester);

        await tapSection(tester, 'Configurações');
        await tapSection(tester, 'Escuro');

        final service = SettingsService();
        final savedSettings = await service.load();

        expect(
          savedSettings.themeMode,
          AppThemeMode.dark,
        );
      },
    );
  });

  group('Sandbox', () {
    testWidgets(
      'entra na tela de sandbox e verifica o painel de detalhes inicial',
      (tester) async {
        await pumpApp(tester);

        final navigator = tester.state<NavigatorState>(
          find.byType(Navigator).first,
        );
        navigator.pushNamed(Routes.sandbox);
        await pumpSettle(tester);

        expect(
          find.text('Bancada Livre'),
          findsWidgets,
        );

        expect(
          find.textContaining('Arraste componentes da paleta'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'persiste e recupera estado do sandbox do SharedPreferences',
      (tester) async {
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
        );
        addTearDown(container.dispose);

        // Adiciona um componente via SandboxController
        final controller = container.read(sandboxControllerProvider.notifier);
        final component = SandboxComponent(
          id: 'test_comp',
          type: ComponentType.bulb,
          gridX: 2,
          gridY: 3,
        );
        controller.addComponent(component);
        await SandboxPersistenceRepository(prefs).save(container.read(sandboxControllerProvider));

        // Verifica que salvou no SharedPreferences
        final savedComponents = prefs.getString('sandbox_components');
        expect(savedComponents, isNotNull);
        expect(savedComponents, contains('test_comp'));
        expect(savedComponents, contains('bulb'));

        // Cria um novo container simulando restart do app
        final container2 = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
        );
        addTearDown(container2.dispose);

        final state2 = container2.read(sandboxControllerProvider);
        expect(state2.components.length, 1);
        expect(state2.components.first.id, 'test_comp');
        expect(state2.components.first.type, ComponentType.bulb);
      },
    );

    testWidgets(
      'arrasta componente da paleta para o grid',
      (tester) async {
        await pumpApp(tester);
        final navigator = tester.state<NavigatorState>(
          find.byType(Navigator).first,
        );
        navigator.pushNamed(Routes.sandbox);
        await pumpSettle(tester);

        final draggableFinder = find.byType(Draggable<ComponentType>).first;
        final targetFinder = find.byType(DragTarget<Object>).first;

        expect(draggableFinder, findsOneWidget);
        expect(find.byType(DragTarget<Object>), findsWidgets);

        final draggableCenter = tester.getCenter(draggableFinder);
        final targetCenter = tester.getCenter(targetFinder);

        await tester.dragFrom(draggableCenter, targetCenter - draggableCenter);
        await pumpSettle(tester);

        final element = tester.element(find.byType(EletroLabApp));
        final container = ProviderScope.containerOf(element);
        final state = container.read(sandboxControllerProvider);
        expect(state.components, isNotEmpty);
      },
    );
  });
}