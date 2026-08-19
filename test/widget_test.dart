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

      controller.verifyDiagram();

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

    test('clears validation feedback after a symbol moves', () {
      final controller = ActivityController()
        ..setSlotSymbol(SlotId.battery, SymbolType.battery)
        ..setSlotSymbol(SlotId.switchSpst, SymbolType.switchSpst)
        ..setSlotSymbol(SlotId.lamp, SymbolType.lamp)
        ..verifyDiagram();

      controller.moveSymbol(SymbolType.battery, SlotId.lamp);

      expect(controller.validationStatus, ValidationStatus.idle);
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
  });

  testWidgets('shows the base MVP activity structure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EletroLabApp());

    expect(find.text('Circuito físico'), findsOneWidget);
    expect(find.text('Monte o diagrama'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Biblioteca de símbolos'), 300);
    expect(find.text('Biblioteca de símbolos'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Corrente: 0 A'), 300);
    expect(find.text('Corrente: 0 A'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Verificar diagrama'), 300);
    await tester.tap(find.text('Verificar diagrama'));
    await tester.pump();

    expect(
      find.text('Complete todas as posições antes de verificar.'),
      findsOneWidget,
    );
  });
}
