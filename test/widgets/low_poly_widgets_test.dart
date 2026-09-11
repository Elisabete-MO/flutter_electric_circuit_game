import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/widgets/low_poly_button.dart';
import 'package:eletrolab/widgets/low_poly_badge.dart';

void main() {
  group('LowPolyButton Widget Tests', () {
    testWidgets('renderiza com texto e ícone e responde a cliques', (tester) async {
      bool clicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LowPolyButton(
              label: 'Iniciar Missão',
              icon: Icons.play_arrow_rounded,
              variant: LowPolyButtonVariant.primary,
              onPressed: () {
                clicked = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Iniciar Missão'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.tap(find.text('Iniciar Missão'));
      await tester.pumpAndSettle();

      expect(clicked, isTrue);
    });

    testWidgets('renderiza variantes accent, cyan e dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LowPolyButton(
                  label: 'Tutorial',
                  variant: LowPolyButtonVariant.accent,
                  onPressed: () {},
                ),
                LowPolyButton(
                  label: '3D Lab',
                  variant: LowPolyButtonVariant.cyan,
                  onPressed: () {},
                ),
                LowPolyButton(
                  label: 'Fechar',
                  variant: LowPolyButtonVariant.dark,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tutorial'), findsOneWidget);
      expect(find.text('3D Lab'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
    });
  });

  group('LowPolyBadge Widget Tests', () {
    testWidgets('renderiza badge com texto e variantes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LowPolyBadge(
                  label: 'Estande 01',
                  variant: LowPolyBadgeVariant.emerald,
                ),
                LowPolyBadge(
                  label: 'Tutorial',
                  variant: LowPolyBadgeVariant.amber,
                ),
                LowPolyBadge(
                  label: '3D Lab',
                  variant: LowPolyBadgeVariant.cyan,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('ESTANDE 01'), findsOneWidget);
      expect(find.text('TUTORIAL'), findsOneWidget);
      expect(find.text('3D LAB'), findsOneWidget);
    });
  });
}
