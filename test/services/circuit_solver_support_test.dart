import 'package:eletrolab/models/first_step_component.dart';
import 'package:eletrolab/models/sandbox_component.dart';
import 'package:eletrolab/models/sandbox_state.dart';
import 'package:eletrolab/models/sandbox_wire.dart';
import 'package:eletrolab/services/circuit_solver/circuit_solver_service.dart';
import 'package:eletrolab/services/circuit_solver/dfs_circuit_solver.dart';
import 'package:eletrolab/services/circuit_solver/mna_circuit_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Circuit solver sandbox support matrix', () {
    test('DFS recognizes AA battery as a 1.5V voltage source', () {
      final state = _seriesCircuit(sourceType: ComponentType.batteryAA);

      final result = DfsCircuitSolver().solve(state);

      expect(result.errorMessage, isNull);
      expect(result.simulationValues['active_src'], equals(1.0));
      expect(result.simulationValues['active_load'], equals(1.0));
      expect(
        result.simulationValues['node_voltage_src_B'],
        closeTo(1.5, 0.001),
      );
      expect(result.simulationValues['current_load'], closeTo(0.15, 0.001));
    });

    test('DFS recognizes 4.5V battery pack as a voltage source', () {
      final state = _seriesCircuit(sourceType: ComponentType.batteryPack4_5V);

      final result = DfsCircuitSolver().solve(state);

      expect(result.errorMessage, isNull);
      expect(result.simulationValues['active_src'], equals(1.0));
      expect(
        result.simulationValues['node_voltage_src_B'],
        closeTo(4.5, 0.001),
      );
      expect(result.simulationValues['current_load'], closeTo(0.45, 0.001));
    });

    test('MNA recognizes AA and 4.5V pack as independent voltage sources', () {
      final aaResult = MnaCircuitSolver().solve(
        _seriesCircuit(sourceType: ComponentType.batteryAA),
      );
      final packResult = MnaCircuitSolver().solve(
        _seriesCircuit(sourceType: ComponentType.batteryPack4_5V),
      );

      expect(aaResult.errorMessage, isNull);
      expect(aaResult.simulationValues['active_src'], equals(1.0));
      expect(aaResult.simulationValues['current_load'], closeTo(0.15, 0.001));

      expect(packResult.errorMessage, isNull);
      expect(packResult.simulationValues['active_src'], equals(1.0));
      expect(packResult.simulationValues['current_load'], closeTo(0.45, 0.001));
    });

    test('solver selection treats multiple AA-family sources as complex', () {
      final state = SandboxState(
        isSimulating: true,
        components: [
          _component('aa', ComponentType.batteryAA),
          _component('pack', ComponentType.batteryPack4_5V, gridX: 2),
        ],
      );

      expect(CircuitSolverService.selectSolver(state), isA<MnaCircuitSolver>());
    });

    test('advanced visual-only relay remains intentionally non-conductive', () {
      final state = SandboxState(
        isSimulating: true,
        components: [
          _component('src', ComponentType.batteryAA),
          _component('relay', ComponentType.relay, gridX: 1, isActive: true),
          _component('load', ComponentType.resistor, gridX: 2, value: 10.0),
        ],
        wires: const [
          SandboxWire(
            id: 'w1',
            fromComponentId: 'src',
            fromTerminal: 'B',
            toComponentId: 'relay',
            toTerminal: 'A',
          ),
          SandboxWire(
            id: 'w2',
            fromComponentId: 'relay',
            fromTerminal: 'B',
            toComponentId: 'load',
            toTerminal: 'A',
          ),
          SandboxWire(
            id: 'w3',
            fromComponentId: 'load',
            fromTerminal: 'B',
            toComponentId: 'src',
            toTerminal: 'A',
          ),
        ],
      );

      final result = DfsCircuitSolver().solve(state);

      expect(result.errorMessage, isNull);
      expect(result.simulationValues['active_relay'], isNull);
      expect(result.simulationValues['active_load'], isNull);
      expect(result.simulationValues['current_load'], isNull);
    });
  });
}

SandboxState _seriesCircuit({required ComponentType sourceType}) {
  return SandboxState(
    isSimulating: true,
    components: [
      _component('src', sourceType),
      _component('load', ComponentType.resistor, gridX: 1, value: 10.0),
    ],
    wires: const [
      SandboxWire(
        id: 'w1',
        fromComponentId: 'src',
        fromTerminal: 'B',
        toComponentId: 'load',
        toTerminal: 'A',
      ),
      SandboxWire(
        id: 'w2',
        fromComponentId: 'load',
        fromTerminal: 'B',
        toComponentId: 'src',
        toTerminal: 'A',
      ),
    ],
  );
}

SandboxComponent _component(
  String id,
  ComponentType type, {
  int gridX = 0,
  bool isActive = false,
  double? value,
}) {
  return SandboxComponent(
    id: id,
    type: type,
    gridX: gridX,
    gridY: 0,
    isActive: isActive,
    value: value,
  );
}
