import 'package:eletrolab/app/routes.dart';
import 'package:eletrolab/screens/home/home_screen.dart';
import 'package:eletrolab/screens/home/widgets/stand_marker.dart';
import 'package:eletrolab/state/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpHomeScreen(
    WidgetTester tester, {
    required SharedPreferences prefs,
  }) async {
    await tester.binding.setSurfaceSize(const Size(900, 2000));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          routes: {
            Routes.secondBench: (_) =>
                const Scaffold(body: Text('Tela Acende Aí')),
          },
          home: const HomeScreen(),
        ),
      ),
    );

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets(
    'reflete progresso persistido no card do estande sem duplicar aliases',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'completed_challenges': ['second_bench', 'acende_ai'],
      });
      final prefs = await SharedPreferences.getInstance();

      await pumpHomeScreen(tester, prefs: prefs);

      final marker = tester.widget<StandMarker>(
        find.byWidgetPredicate(
          (widget) => widget is StandMarker && widget.stand.id == 'acende_ai',
        ),
      );

      expect(marker.stand.completedMissions, 5);
      expect(marker.stand.totalMissions, 5);

      marker.onTap();
      await tester.pump();

      expect(find.text('Acende Aí'), findsWidgets);
      expect(find.text('5/5 missões'), findsOneWidget);
    },
  );
}
