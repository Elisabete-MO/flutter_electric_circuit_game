import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eletrolab/app/routes.dart';
import 'package:eletrolab/screens/common_stand/stand_flow_header.dart';
import 'package:eletrolab/screens/ruas_maquete/ruas_maquete_screen.dart';

void main() {
  group('StandNavigator Tests', () {
    testWidgets('Retorna ao Mapa (Routes.home) se Routes.home já estiver na pilha', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      final routes = <String, WidgetBuilder>{
        Routes.home: (_) => const Scaffold(body: Text('TELA DE MAQUETES DO MAPA')),
        Routes.ruasMaquete: (_) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => StandNavigator.navigateBackToFairMap(context),
                  child: const Text('VOLTAR'),
                ),
              ),
            ),
      };

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: Routes.home,
          routes: routes,
        ),
      );
      await tester.pump();
      expect(find.text('TELA DE MAQUETES DO MAPA'), findsOneWidget);

      // Navega para o estande
      final navState = tester.state<NavigatorState>(find.byType(Navigator));
      navState.pushNamed(Routes.ruasMaquete);
      await tester.pumpAndSettle();
      expect(find.text('VOLTAR'), findsOneWidget);

      // Clica em voltar
      await tester.tap(find.text('VOLTAR'));
      await tester.pumpAndSettle();

      // Deve estar na tela de maquetes
      expect(find.text('TELA DE MAQUETES DO MAPA'), findsOneWidget);
    });

    testWidgets('Navega para Routes.home mesmo se Routes.home NÃO estiver na pilha (recarga/abertura direta)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      final routes = <String, WidgetBuilder>{
        Routes.splash: (_) => const Scaffold(body: Text('SPLASH TELA DE CARREGAMENTO')),
        Routes.home: (_) => const Scaffold(body: Text('TELA DE MAQUETES DO MAPA')),
        Routes.ruasMaquete: (_) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => StandNavigator.navigateBackToFairMap(context),
                  child: const Text('VOLTAR'),
                ),
              ),
            ),
      };

      // Simula inicialização direta no estande (sem passar pelo mapa)
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: Routes.ruasMaquete,
          routes: routes,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('VOLTAR'), findsOneWidget);

      // Clica em voltar
      await tester.tap(find.text('VOLTAR'));
      await tester.pumpAndSettle();

      // Deve ir para o mapa das maquetes e NUNCA para a tela de carregamento (splash)
      expect(find.text('TELA DE MAQUETES DO MAPA'), findsOneWidget);
      expect(find.text('SPLASH TELA DE CARREGAMENTO'), findsNothing);
    });

    testWidgets('Setinha de voltar no StandFlowHeader de RuasMaqueteScreen retorna ao mapa', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      final routes = <String, WidgetBuilder>{
        Routes.home: (_) => const Scaffold(body: Text('MAPA_COM_MAQUETES')),
        Routes.ruasMaquete: (_) => const ProviderScope(child: RuasMaqueteScreen()),
      };

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: Routes.home,
          routes: routes,
        ),
      );
      await tester.pump();

      // Abre RuasMaqueteScreen
      final navState = tester.state<NavigatorState>(find.byType(Navigator));
      navState.pushNamed(Routes.ruasMaquete);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(StandFlowHeader), findsOneWidget);

      // Encontra a setinha de voltar no cabeçalho do estande
      final backArrowFinder = find.byIcon(Icons.arrow_back_rounded);
      expect(backArrowFinder, findsOneWidget);

      await tester.tap(backArrowFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Deve retornar para o mapa com as maquetes
      expect(find.text('MAPA_COM_MAQUETES'), findsOneWidget);
    });
  });
}
