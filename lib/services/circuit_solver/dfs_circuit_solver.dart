import '../../models/first_step_component.dart';
import '../../models/sandbox_component.dart';
import '../../models/sandbox_wire.dart';
import '../../models/sandbox_state.dart';
import 'circuit_solver_strategy.dart';

class DfsCircuitSolver implements CircuitSolverStrategy {
  @override
  SandboxState solve(SandboxState targetState) {
    if (!targetState.isSimulating) {
      return targetState.copyWith(simulationValues: {}, errorMessage: null);
    }

    final powerSources = targetState.components
        .where((c) => CircuitElectricalSupport.isVoltageSource(c.type))
        .toList();
    if (powerSources.isEmpty) {
      return targetState.copyWith(
        simulationValues: {},
        errorMessage: 'Sem fonte de energia no circuito.',
      );
    }

    final Map<String, double> values = {};
    String? error;
    final Set<String> newBurnedSet = Set.from(targetState.burnedComponentIds);
    bool isShortCircuit = false;
    final Set<String> shortCircuitWireIds = {};

    for (final source in powerSources) {
      final visited = <String>{source.id};
      final componentPath = <SandboxComponent>[];
      final wirePath = <_TraversedWire>[];
      final inTerminals = <String, String>{};
      final List<_ClosedLoopData> closedLoops = [];

      // Start traversal from positive terminal 'B'
      _traverseForState(
        targetState: targetState,
        currentComponent: source,
        currentTerminal: 'B',
        targetBattery: source,
        visited: visited,
        componentPath: componentPath,
        wirePath: wirePath,
        inTerminals: inTerminals,
        onLoopClosed: (pathComponents, pathWires, termMap) {
          closedLoops.add(
            _ClosedLoopData(
              List.from(pathComponents),
              List.from(pathWires),
              Map.from(termMap),
            ),
          );
        },
      );

      if (closedLoops.isNotEmpty) {
        double totalSourceCurrent = 0.0;

        for (final loop in closedLoops) {
          final loopPath = loop.components;
          final totalResistance = loopPath
              .where((c) => !CircuitElectricalSupport.isVoltageSource(c.type))
              .fold(0.0, (sum, c) {
                return sum + (CircuitElectricalSupport.resistanceFor(c) ?? 0.0);
              });

          if (totalResistance <= 0.1) {
            error =
                'CURTO-CIRCUITO DETECTADO! Conexão direta entre pólos sem carga!';
            isShortCircuit = true;
            for (final tw in loop.wires) {
              shortCircuitWireIds.add(tw.wire.id);
            }
            break;
          }

          final loopCurrent = source.value / totalResistance;
          totalSourceCurrent += loopCurrent;

          double currentPotential = source.value;

          // Marca os fios ativos e o sentido de fluxo (+1.0 = from->to, -1.0 = to->from)
          for (final tw in loop.wires) {
            values['active_${tw.wire.id}'] = 1.0;
            values['wire_current_${tw.wire.id}'] =
                (values['wire_current_${tw.wire.id}'] ?? 0.0) + loopCurrent;
            values['wire_flow_${tw.wire.id}'] = tw.isForward ? 1.0 : -1.0;
          }

          for (final comp in loopPath) {
            if (CircuitElectricalSupport.isVoltageSource(comp.type)) {
              continue;
            }

            final compRes = CircuitElectricalSupport.resistanceFor(comp);
            if (compRes == null) continue;
            final vDrop = loopCurrent * compRes;
            final power = vDrop * loopCurrent;

            values['active_${comp.id}'] = 1.0;
            values['current_${comp.id}'] =
                (values['current_${comp.id}'] ?? 0.0) + loopCurrent;
            values['voltage_drop_${comp.id}'] = vDrop;
            values['power_${comp.id}'] = power;

            // Define potenciais nos terminais de acordo com o sentido REAL de entrada e saída
            final inTerm = loop.inTerminals[comp.id] ?? 'A';
            final outTerm = inTerm == 'A' ? 'B' : 'A';
            values['node_voltage_${comp.id}_$inTerm'] = currentPotential;
            currentPotential -= vDrop;
            values['node_voltage_${comp.id}_$outTerm'] = currentPotential;

            // Verificação de Limites Físicos e Sobrecarga Educativa
            final totalCompCurrent =
                values['current_${comp.id}'] ?? loopCurrent;
            if (comp.type == ComponentType.led) {
              if (totalCompCurrent > 0.05 || vDrop > 3.3) {
                newBurnedSet.add(comp.id);
                error =
                    'O LED QUEIMOU! Corrente (${(totalCompCurrent * 1000).toStringAsFixed(0)}mA) excedeu o limite seguro (50mA). Conecte um resistor em série!';
              }
            } else if (comp.type == ComponentType.bulb) {
              if (power > 15.0) {
                newBurnedSet.add(comp.id);
                error =
                    'FILAMENTO ROMPIDO! A lâmpada queimou por excesso de potência (${power.toStringAsFixed(1)}W > 15W)!';
              }
            } else if (comp.type == ComponentType.motor) {
              if (vDrop > 18.0) {
                newBurnedSet.add(comp.id);
                error =
                    'BOBINA QUEIMADA! O motor sofreu sobretensão (${vDrop.toStringAsFixed(1)}V > 18V)!';
              }
            } else if (comp.type == ComponentType.fuse) {
              final maxCurrent = comp.value; // ex: 2.0A
              if (totalCompCurrent > maxCurrent) {
                newBurnedSet.add(comp.id);
                error =
                    'FUSÍVEL QUEIMOU! Corrente de ${totalCompCurrent.toStringAsFixed(2)}A excedeu o limite do fusível (${maxCurrent.toStringAsFixed(1)}A), desarmando o circuito!';
              }
            }
          }
        }

        values['active_${source.id}'] = 1.0;
        values['current_${source.id}'] = totalSourceCurrent;
        values['node_voltage_${source.id}_B'] = source.value;
        values['node_voltage_${source.id}_A'] = 0.0;
      }
    }

    return targetState.copyWith(
      simulationValues: values,
      errorMessage: error,
      burnedComponentIds: newBurnedSet,
      isShortCircuit: isShortCircuit,
      shortCircuitWireIds: shortCircuitWireIds,
    );
  }

  void _traverseForState({
    required SandboxState targetState,
    required SandboxComponent currentComponent,
    required String currentTerminal,
    required SandboxComponent targetBattery,
    required Set<String> visited,
    required List<SandboxComponent> componentPath,
    required List<_TraversedWire> wirePath,
    required Map<String, String> inTerminals,
    required void Function(
      List<SandboxComponent>,
      List<_TraversedWire>,
      Map<String, String>,
    )
    onLoopClosed,
  }) {
    componentPath.add(currentComponent);

    final wires = targetState.wires.where((w) {
      return (w.fromComponentId == currentComponent.id &&
              w.fromTerminal == currentTerminal) ||
          (w.toComponentId == currentComponent.id &&
              w.toTerminal == currentTerminal);
    }).toList();

    for (final wire in wires) {
      final isForward = (wire.fromComponentId == currentComponent.id &&
          wire.fromTerminal == currentTerminal);
      final nextId = isForward ? wire.toComponentId : wire.fromComponentId;
      final nextTerm = isForward ? wire.toTerminal : wire.fromTerminal;

      final nextComponentList = targetState.components
          .where((c) => c.id == nextId)
          .toList();
      if (nextComponentList.isEmpty) continue;
      final nextComponent = nextComponentList.first;

      final traversedWire = _TraversedWire(wire, isForward);
      wirePath.add(traversedWire);

      if (nextComponent.id == targetBattery.id && nextTerm == 'A') {
        onLoopClosed(
          List.from(componentPath),
          List.from(wirePath),
          inTerminals,
        );
        wirePath.removeLast();
        return;
      }

      if (visited.contains(nextComponent.id)) {
        wirePath.removeLast();
        continue;
      }

      if (targetState.burnedComponentIds.contains(nextComponent.id)) {
        wirePath.removeLast();
        continue; // Componente queimado interrompe o circuito (circuito aberto)
      }

      if (!CircuitElectricalSupport.canConduct(nextComponent)) {
        wirePath.removeLast();
        continue;
      }

      if (CircuitElectricalSupport.isDiodeLike(nextComponent.type)) {
        final isReversed =
            (nextComponent.rotation == 180.0 || nextComponent.rotation == 270.0)
            ? (nextTerm == 'A')
            : (nextTerm == 'B');
        if (isReversed) {
          wirePath.removeLast();
          continue; // Bloqueia a corrente se ela tentar entrar pelo Cathode (-) - Polarização Reversa
        }
      }

      final nextOutTerm = nextTerm == 'A' ? 'B' : 'A';

      visited.add(nextComponent.id);
      inTerminals[nextComponent.id] = nextTerm;
      _traverseForState(
        targetState: targetState,
        currentComponent: nextComponent,
        currentTerminal: nextOutTerm,
        targetBattery: targetBattery,
        visited: visited,
        componentPath: componentPath,
        wirePath: wirePath,
        inTerminals: inTerminals,
        onLoopClosed: onLoopClosed,
      );
      inTerminals.remove(nextComponent.id);
      visited.remove(nextComponent.id);
      wirePath.removeLast();
    }

    componentPath.removeLast();
  }
}

class _TraversedWire {
  final SandboxWire wire;
  final bool isForward;
  _TraversedWire(this.wire, this.isForward);
}

class _ClosedLoopData {
  final List<SandboxComponent> components;
  final List<_TraversedWire> wires;
  final Map<String, String> inTerminals;
  _ClosedLoopData(this.components, this.wires, this.inTerminals);
}
