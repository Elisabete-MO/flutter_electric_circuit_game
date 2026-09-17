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

    test('DFS sets correct wire_flow and node potentials for forward wires', () {
      final state = _seriesCircuit(sourceType: ComponentType.battery);
      final result = DfsCircuitSolver().solve(state);

      expect(result.errorMessage, isNull);
      expect(result.simulationValues['active_w1'], equals(1.0));
      expect(result.simulationValues['active_w2'], equals(1.0));
      // w1 connects src(B/+) -> load(A): forward flow (+1.0)
      expect(result.simulationValues['wire_flow_w1'], equals(1.0));
      // w2 connects load(B) -> src(A/-): forward flow (+1.0)
      expect(result.simulationValues['wire_flow_w2'], equals(1.0));
      // Potential at entry terminal A is high (9.0V), at exit terminal B is 0.0V
      expect(result.simulationValues['node_voltage_load_A'], closeTo(9.0, 0.001));
      expect(result.simulationValues['node_voltage_load_B'], closeTo(0.0, 0.001));
    });

    test('DFS sets correct wire_flow when wires are drawn in reverse direction', () {
      // Wires drawn from load to src instead of src to load
      final state = SandboxState(
        isSimulating: true,
        components: [
          _component('src', ComponentType.battery),
          _component('load', ComponentType.resistor, gridX: 1, value: 10.0),
        ],
        wires: const [
          SandboxWire(
            id: 'w1',
            fromComponentId: 'load',
            fromTerminal: 'B',
            toComponentId: 'src',
            toTerminal: 'B', // connects to + pole
          ),
          SandboxWire(
            id: 'w2',
            fromComponentId: 'src',
            fromTerminal: 'A', // connects from - pole
            toComponentId: 'load',
            toTerminal: 'A',
          ),
        ],
      );
      final result = DfsCircuitSolver().solve(state);

      expect(result.errorMessage, isNull);
      // w1: from=load(B), to=src(B/+). Current flows from src(+) to load(B), which is to->from (-1.0)
      expect(result.simulationValues['wire_flow_w1'], equals(-1.0));
      // w2: from=src(A/-), to=load(A). Current flows from load(A) to src(-), which is to->from (-1.0)
      expect(result.simulationValues['wire_flow_w2'], equals(-1.0));
      // Current entered load at terminal B: node_voltage_load_B is 9.0V, node_voltage_load_A is 0.0V
      expect(result.simulationValues['node_voltage_load_B'], closeTo(9.0, 0.001));
      expect(result.simulationValues['node_voltage_load_A'], closeTo(0.0, 0.001));
    });

    test('MNA sets correct wire_flow and wire_current', () {
      final state = _seriesCircuit(sourceType: ComponentType.battery);
      final result = MnaCircuitSolver().solve(state);

      expect(result.errorMessage, isNull);
      expect(result.simulationValues['active_w1'], equals(1.0));
      expect(result.simulationValues['active_w2'], equals(1.0));
      expect(result.simulationValues['wire_flow_w1'], equals(1.0));
      expect(result.simulationValues['wire_flow_w2'], equals(1.0));
      expect(result.simulationValues['wire_current_w1'], closeTo(0.9, 0.001));
      expect(result.simulationValues['wire_current_w2'], closeTo(0.9, 0.001));
    });

    test('MNA sets correct wire_flow when wire is drawn backwards', () {
      final state = SandboxState(
        isSimulating: true,
        components: [
          _component('src', ComponentType.battery),
          _component('load', ComponentType.resistor, gridX: 1, value: 10.0),
        ],
        wires: const [
          SandboxWire(
            id: 'w1',
            fromComponentId: 'load',
            fromTerminal: 'A',
            toComponentId: 'src',
            toTerminal: 'B', // connected to positive pole
          ),
          SandboxWire(
            id: 'w2',
            fromComponentId: 'load',
            fromTerminal: 'B',
            toComponentId: 'src',
            toTerminal: 'A', // connected to negative pole
          ),
        ],
      );
      final result = MnaCircuitSolver().solve(state);

      expect(result.errorMessage, isNull);
      // w1 drawn from load(A) to src(B/+): flow is from src(+) to load, so to->from (-1.0)
      expect(result.simulationValues['wire_flow_w1'], equals(-1.0));
      // w2 drawn from load(B) to src(A/-): flow is from load to src(-), so from->to (+1.0)
      expect(result.simulationValues['wire_flow_w2'], equals(1.0));
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
