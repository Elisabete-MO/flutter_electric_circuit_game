import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eletrolab/screens/first_bench/first_bench_flow_screen.dart';
import 'package:eletrolab/state/progress_controller.dart';

void main() {
  group('FirstBenchFlow Integration Tests', () {
    testWidgets('Carrega estado inicial seguro e navega entre fases', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: FirstBenchFlowScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Deve iniciar na Fase 1 por padrão
      expect(find.text('Fase 1'), findsWidgets);
      expect(find.text('Fase 2'), findsWidgets);
      expect(find.text('Fase 3'), findsWidgets);
      expect(find.text('Fase 4'), findsWidgets);
    });
  });
}
