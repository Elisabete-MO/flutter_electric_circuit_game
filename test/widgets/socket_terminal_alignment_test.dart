import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/models/first_step_component.dart';
import 'package:eletrolab/widgets/physical_blueprint_socket.dart';
import 'package:eletrolab/widgets/realistic_wire_painter.dart';

void main() {
  group('Socket and Terminal Alignment Tests', () {
    testWidgets('PhysicalBlueprintSocket default size is 95x95 and centers at given position',
        (tester) async {
      const center = Offset(200.0, 150.0);
      const socketSize = 95.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: center.dx - (socketSize / 2),
                  top: center.dy - (socketSize / 2),
                  child: PhysicalBlueprintSocket<String>(
                    expectedData: 'bulb',
                    isFilled: true,
                    onAccept: (_) {},
                    onTap: () {},
                    symbolWidget: const SizedBox(width: 80, height: 80),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final socketFinder = find.byType(PhysicalBlueprintSocket<String>);
      expect(socketFinder, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(socketFinder);
      expect(renderBox.size.width, equals(95.0));
      expect(renderBox.size.height, equals(95.0));

      final centerInGlobal = renderBox.localToGlobal(Offset(renderBox.size.width / 2, renderBox.size.height / 2));
      expect(centerInGlobal.dx, equals(center.dx));
      expect(centerInGlobal.dy, equals(center.dy));
    });

    test('Wire terminal calculation aligns with component center for switch and bulb', () {
      const switchCenter = Offset(300.0, 100.0);
      final switchPlacement = ComponentPlacement(
        position: switchCenter,
        rotation: 0.0,
        type: ComponentType.switchComponent,
      );

      final swTermA = switchPlacement.getTerminalPosition(0);
      final swTermB = switchPlacement.getTerminalPosition(1);

      // Switch terminals at 0° are horizontal at Y = center.dy
      expect(swTermA, equals(const Offset(300.0 - 32.0, 100.0)));
      expect(swTermB, equals(const Offset(300.0 + 32.0, 100.0)));

      const bulbCenter = Offset(500.0, 100.0);
      final bulbPlacement = ComponentPlacement(
        position: bulbCenter,
        rotation: 0.0,
        type: ComponentType.bulb,
      );

      final bulbTermA = bulbPlacement.getTerminalPosition(0);
      final bulbTermB = bulbPlacement.getTerminalPosition(1);

      // Bulb terminal pins at 0° are at (+-7, +24)
      expect(bulbTermA, equals(const Offset(500.0 - 7.0, 100.0 + 24.0)));
      expect(bulbTermB, equals(const Offset(500.0 + 7.0, 100.0 + 24.0)));

      // Dynamic wire between switch terminal B and bulb terminal A starts and ends exactly at those points
      final wire = DynamicWirePath.fromComponents(
        compA: switchPlacement,
        terminalIndexA: 1,
        compB: bulbPlacement,
        terminalIndexB: 0,
        color: Colors.orange,
      );

      expect(wire.start, equals(swTermB));
      expect(wire.end, equals(bulbTermA));
    });

    test('Battery rotated 270 degrees has exact terminal positions matching wire endpoints', () {
      const batteryCenter = Offset(100.0, 100.0);
      final batPlacement = ComponentPlacement(
        position: batteryCenter,
        rotation: 270.0,
        type: ComponentType.battery,
      );

      // At 0°, battery terminals are: (+): (-7.5, -25.0), (-): (7.5, -25.0)
      // At 270° (clockwise):
      // (+) becomes (-25.0, +7.5) -> (75.0, 107.5)
      // (-) becomes (-25.0, -7.5) -> (75.0, 92.5)
      final batTermPlus = batPlacement.getTerminalPosition(0);
      final batTermMinus = batPlacement.getTerminalPosition(1);

      expect(batTermPlus, equals(const Offset(75.0, 107.5)));
      expect(batTermMinus, equals(const Offset(75.0, 92.5)));
    });
  });
}
