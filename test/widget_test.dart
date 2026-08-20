import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_electric_circuit_game/main.dart';
import 'package:flutter_electric_circuit_game/mvp/activity_controller.dart';
import 'package:flutter_electric_circuit_game/mvp/mvp_contract.dart';

void main() {
  group('ActivityController validation', () {
    test('reports incomplete when a slot is empty', () {
      final controller = ActivityController();

      controller.verifyDiagram();

      expect(controller.validationStatus, ValidationStatus.incomplete);
      expect(controller.highlightedSlots, SlotId.values.toSet());
    });

    test('reports incorrect when all slots are filled with wrong symbols', () {
      final controller = ActivityController()
        ..setSlotSymbol(SlotId.battery, SymbolType.lamp)
        ..setSlotSymbol(SlotId.switchSpst, SymbolType.switchSpst)
        ..setSlotSymbol(SlotId.lamp, SymbolType.battery);

      expect(controller.validationStatus, ValidationStatus.incorrect);
      expect(controller.highlightedSlots, {SlotId.battery, SlotId.lamp});
    });

    test('reports correct independently of the physical switch state', () {
      final controller = ActivityController()
        ..setSlotSymbol(SlotId.battery, SymbolType.battery)
        ..setSlotSymbol(SlotId.switchSpst, SymbolType.switchSpst)
        ..setSlotSymbol(SlotId.lamp, SymbolType.lamp);

      expect(controller.currentAmps, 0.0);
      controller.setSwitchClosed(true);
      expect(controller.currentAmps, 0.5);
      controller.verifyDiagram();

      expect(controller.validationStatus, ValidationStatus.correct);
      expect(controller.highlightedSlots, isEmpty);
    });

    test('keeps symbols unique when moving and replacing slots', () {
      final controller = ActivityController()
        ..setSlotSymbol(SlotId.battery, SymbolType.battery)
        ..setSlotSymbol(SlotId.switchSpst, SymbolType.switchSpst);

      controller.moveSymbol(SymbolType.battery, SlotId.switchSpst);
      expect(controller.slotOccupancy, {
        SlotId.battery: SymbolType.switchSpst,
        SlotId.switchSpst: SymbolType.battery,
        SlotId.lamp: null,
      });

      controller.moveSymbol(SymbolType.lamp, SlotId.battery);
      expect(controller.slotOccupancy, {
        SlotId.battery: SymbolType.lamp,
        SlotId.switchSpst: SymbolType.battery,
        SlotId.lamp: null,
      });
      expect(controller.slotForSymbol(SymbolType.switchSpst), isNull);
    });

    test(
      'stays synchronized through repeated switch cycles and slot moves',
      () {
        final controller = ActivityController();

        for (var cycle = 0; cycle < 4; cycle++) {
          controller.toggleSwitch();
          expect(controller.currentAmps, 0.5);
          controller.toggleSwitch();
          expect(controller.currentAmps, 0.0);
        }

        controller.moveSymbol(SymbolType.battery, SlotId.battery);
        controller.moveSymbol(SymbolType.switchSpst, SlotId.battery);
        controller.moveSymbol(SymbolType.switchSpst, SlotId.lamp);
        controller.moveSymbol(SymbolType.lamp, SlotId.lamp);
        controller.moveSymbol(SymbolType.battery, SlotId.lamp);
        controller.moveSymbol(SymbolType.switchSpst, SlotId.battery);
        controller.moveSymbol(SymbolType.switchSpst, SlotId.lamp);

        expect(controller.slotOccupancy, {
          SlotId.battery: SymbolType.battery,
          SlotId.switchSpst: null,
          SlotId.lamp: SymbolType.switchSpst,
        });
        final symbolsInSlots = controller.slotOccupancy.values
            .whereType<SymbolType>()
            .toList();
        expect(symbolsInSlots.toSet().length, symbolsInSlots.length);
        expect(controller.slotForSymbol(SymbolType.lamp), isNull);
      },
    );
  });

  testWidgets('shows the base MVP activity structure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EletroLabApp());

    expect(find.text('Circuito físico'), findsOneWidget);
    expect(find.text('Diagrama criado'), findsOneWidget);
    expect(find.text('Análise do circuito'), findsOneWidget);

    expect(find.text('Tensão: 6 V'), findsOneWidget);
    expect(find.text('Resistência: 12 Ω'), findsOneWidget);
    expect(find.text('I = V ÷ R'), findsOneWidget);
    expect(find.text('Concluir atividade'), findsOneWidget);
  });
}
