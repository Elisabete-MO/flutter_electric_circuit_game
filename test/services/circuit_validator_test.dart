import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/services/circuit_validator.dart';

void main() {
  group('CircuitValidator Tests', () {
    const validator = CircuitValidator();

    // Utilitário para construir componentes do primeiro estande
    const battery = CircuitComponentInstance(
      id: 'bat1',
      kind: CircuitComponentKind.battery,
    );
    const switchClosed = CircuitComponentInstance(
      id: 'sw1',
      kind: CircuitComponentKind.switchComponent,
      isSwitchClosed: true,
    );
    const switchOpen = CircuitComponentInstance(
      id: 'sw1',
      kind: CircuitComponentKind.switchComponent,
      isSwitchClosed: false,
    );
    const resistor680 = CircuitComponentInstance(
      id: 'res1',
      kind: CircuitComponentKind.resistor,
      resistanceOhms: 680.0,
    );
    const resistor68 = CircuitComponentInstance(
      id: 'res1',
      kind: CircuitComponentKind.resistor,
      resistanceOhms: 68.0,
    );
    const resistor6800 = CircuitComponentInstance(
      id: 'res1',
      kind: CircuitComponentKind.resistor,
      resistanceOhms: 6800.0,
    );
    const led = CircuitComponentInstance(
      id: 'led1',
      kind: CircuitComponentKind.led,
    );

    test('1. Circuito correto com interruptor fechado acende LED e maquete (safeAndLit)', () {
      final graph = CircuitGraph(
        components: [battery, switchClosed, resistor680, led],
        connections: [
          CircuitConnection(battery.terminalA, switchClosed.terminalA),
          CircuitConnection(switchClosed.terminalB, resistor680.terminalA),
          CircuitConnection(resistor680.terminalB, led.terminalA),
          CircuitConnection(led.terminalB, battery.terminalB),
        ],
      );

      final result = validator.validate(graph);
      expect(result.status, equals(CircuitStatus.safeAndLit));
      expect(result.energizationAllowed, isTrue);
      expect(result.currentmA, closeTo(10.3, 0.2));
    });

    test('2. Resistor antes ou depois do LED em série é válido', () {
      final graph = CircuitGraph(
        components: [battery, switchClosed, led, resistor680],
        connections: [
          CircuitConnection(battery.terminalA, switchClosed.terminalA),
          CircuitConnection(switchClosed.terminalB, led.terminalA),
          CircuitConnection(led.terminalB, resistor680.terminalA),
          CircuitConnection(resistor680.terminalB, battery.terminalB),
        ],
      );

      final result = validator.validate(graph);
      expect(result.status, equals(CircuitStatus.safeAndLit));
      expect(result.energizationAllowed, isTrue);
    });

    test('3. Circuito correto com interruptor aberto é válido porém sem corrente (validButOpen)', () {
      final graph = CircuitGraph(
        components: [battery, switchOpen, resistor680, led],
        connections: [
          CircuitConnection(battery.terminalA, switchOpen.terminalA),
          CircuitConnection(switchOpen.terminalB, resistor680.terminalA),
          CircuitConnection(resistor680.terminalB, led.terminalA),
          CircuitConnection(led.terminalB, battery.terminalB),
        ],
      );

      final result = validator.validate(graph);
      expect(result.status, equals(CircuitStatus.validButOpen));
      expect(result.energizationAllowed, isTrue);
      expect(result.currentmA, equals(0.0));
    });

    test('4. LED invertido bloqueia energização com feedback pedagógico (reversedLed)', () {
      final graph = CircuitGraph(
        components: [battery, switchClosed, resistor680, led],
        connections: [
          CircuitConnection(battery.terminalA, switchClosed.terminalA),
          CircuitConnection(switchClosed.terminalB, resistor680.terminalA),
          // Conectado no CÁTODO primeiro
          CircuitConnection(resistor680.terminalB, led.terminalB),
          CircuitConnection(led.terminalA, battery.terminalB),
        ],
      );

      final result = validator.validate(graph);
      expect(result.status, equals(CircuitStatus.reversedLed));
      expect(result.energizationAllowed, isFalse);
      expect(result.relatedComponentId, equals('led1'));
    });

    test('5. Resistor de 68 ohms gera corrente excessiva e bloqueia (excessiveCurrent)', () {
      final graph = CircuitGraph(
        components: [battery, switchClosed, resistor68, led],
        connections: [
          CircuitConnection(battery.terminalA, switchClosed.terminalA),
          CircuitConnection(switchClosed.terminalB, resistor68.terminalA),
          CircuitConnection(resistor68.terminalB, led.terminalA),
          CircuitConnection(led.terminalB, battery.terminalB),
        ],
      );

      final result = validator.validate(graph);
      expect(result.status, equals(CircuitStatus.excessiveCurrent));
      expect(result.energizationAllowed, isFalse);
      expect(result.currentmA, greaterThan(100.0));
    });

    test('6. Resistor de 6.8 k-ohms gera corrente muito baixa (lowCurrent)', () {
      final graph = CircuitGraph(
        components: [battery, switchClosed, resistor6800, led],
        connections: [
          CircuitConnection(battery.terminalA, switchClosed.terminalA),
          CircuitConnection(switchClosed.terminalB, resistor6800.terminalA),
          CircuitConnection(resistor6800.terminalB, led.terminalA),
          CircuitConnection(led.terminalB, battery.terminalB),
        ],
      );

      final result = validator.validate(graph);
      expect(result.status, equals(CircuitStatus.lowCurrent));
      expect(result.energizationAllowed, isFalse);
    });

    test('7. Resistor ausente bloqueia por falta de proteção (missingResistor)', () {
      final graph = CircuitGraph(
        components: [battery, switchClosed, led],
        connections: [
          CircuitConnection(battery.terminalA, switchClosed.terminalA),
          CircuitConnection(switchClosed.terminalB, led.terminalA),
          CircuitConnection(led.terminalB, battery.terminalB),
        ],
      );

      final result = validator.validate(graph);
      expect(result.status, equals(CircuitStatus.missingResistor));
      expect(result.energizationAllowed, isFalse);
    });

    test('8. Trecho incompleto ou sem fio gera circuito aberto (openCircuit)', () {
      final graph = CircuitGraph(
        components: [battery, switchClosed, resistor680, led],
        connections: [
          CircuitConnection(battery.terminalA, switchClosed.terminalA),
          // Falta conexão entre o switch e o resistor
          CircuitConnection(resistor680.terminalB, led.terminalA),
          CircuitConnection(led.terminalB, battery.terminalB),
        ],
      );

      final result = validator.validate(graph);
      expect(result.status, equals(CircuitStatus.openCircuit));
      expect(result.energizationAllowed, isFalse);
    });

    test('9. Ligação direta entre polos causa curto-circuito (shortCircuit)', () {
      final graph = CircuitGraph(
        components: [battery, switchClosed, resistor680, led],
        connections: [
          // Fio direto pos -> neg
          CircuitConnection(battery.terminalA, battery.terminalB),
        ],
      );

      final result = validator.validate(graph);
      expect(result.status, equals(CircuitStatus.shortCircuit));
      expect(result.energizationAllowed, isFalse);
    });
  });
}
