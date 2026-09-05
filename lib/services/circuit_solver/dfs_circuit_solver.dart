import '../../models/first_step_component.dart';
import '../../models/sandbox_component.dart';
import '../../models/sandbox_wire.dart';
import '../../models/sandbox_state.dart';
import 'circuit_solver_strategy.dart';

class _ComponentTraversal {
  final SandboxComponent component;
  final String inTerminal;
  final String outTerminal;
  _ComponentTraversal(this.component, this.inTerminal, this.outTerminal);
}

class _ClosedLoopData {
  final List<_ComponentTraversal> path;
  final List<SandboxWire> wires;
  _ClosedLoopData(this.path, this.wires);
}

class DfsCircuitSolver implements CircuitSolverStrategy {
  @override
  SandboxState solve(SandboxState targetState) {
    SandboxState currentState = targetState;
    bool changed = true;
    int iterations = 0;

    while (changed && iterations < 3) {
      changed = false;
      iterations++;

      final result = _solveIteration(currentState);
      
      // Update states of relays based on coil current
      final newComponents = <SandboxComponent>[];
      for (final comp in currentState.components) {
        if (comp.type == ComponentType.relay) {
          final hasCoilCurrent = (result.simulationValues['coil_current_${comp.id}'] ?? 0.0) >= 0.01;
          if (comp.isActive != hasCoilCurrent) {
            newComponents.add(comp.copyWith(isActive: hasCoilCurrent));
            changed = true; // State changed, need another pass
          } else {
            newComponents.add(comp);
          }
        } else {
          newComponents.add(comp);
        }
      }
      
      currentState = result.copyWith(components: newComponents);
    }
    
    return currentState;
  }

  SandboxState _solveIteration(SandboxState targetState) {
    if (!targetState.isSimulating) {
      return targetState.copyWith(
        simulationValues: {},
        errorMessage: null,
      );
    }

    final powerSources = targetState.components
        .where((c) =>
            c.type == ComponentType.battery ||
            c.type == ComponentType.powerSupply)
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
      final componentPath = <_ComponentTraversal>[
        _ComponentTraversal(source, 'A', 'B')
      ];
      final wirePath = <SandboxWire>[];
      final List<_ClosedLoopData> closedLoops = [];

      _traverseForState(
        targetState: targetState,
        currentComponent: source,
        currentTerminal: 'B', // start going OUT of B
        targetBattery: source,
        visited: visited,
        componentPath: componentPath,
        wirePath: wirePath,
        onLoopClosed: (pathComponents, pathWires) {
          closedLoops.add(_ClosedLoopData(
              List.from(pathComponents), List.from(pathWires)));
        },
      );

      if (closedLoops.isNotEmpty) {
        double totalSourceCurrent = 0.0;

        for (final loop in closedLoops) {
          final loopPath = loop.path;
          
          final totalResistance = loopPath
              .where((t) =>
                  t.component.type != ComponentType.battery &&
                  t.component.type != ComponentType.powerSupply)
              .fold(0.0, (sum, t) {
            final c = t.component;
            if (c.type == ComponentType.relay) {
              if (t.inTerminal == 'C1' || t.inTerminal == 'C2') {
                return sum + 100.0; // Resistência da bobina
              } else {
                return sum + 0.1; // Resistência do contato (chave)
              }
            }
            if (c.type == ComponentType.fuse) return sum + 0.1;
            if (c.type == ComponentType.capacitor) return sum + 10.0;
            if (c.type == ComponentType.buzzer) return sum + 8.0;
            if (c.type == ComponentType.motor) return sum + 2.0;
            return sum + c.value;
          });

          if (totalResistance <= 0.1) {
            error = 'CURTO-CIRCUITO DETECTADO! Conexão direta entre pólos sem carga!';
            isShortCircuit = true;
            for (final w in loop.wires) {
              shortCircuitWireIds.add(w.id);
            }
            break;
          }

          final loopCurrent = source.value / totalResistance;
          totalSourceCurrent += loopCurrent;

          double currentPotential = source.value;

          for (final traversal in loopPath) {
            final comp = traversal.component;
            if (comp.type == ComponentType.battery ||
                comp.type == ComponentType.powerSupply) {
              continue;
            }

            double compRes;
            if (comp.type == ComponentType.relay) {
              if (traversal.inTerminal == 'C1' || traversal.inTerminal == 'C2') {
                compRes = 100.0;
                values['coil_current_${comp.id}'] = (values['coil_current_${comp.id}'] ?? 0.0) + loopCurrent;
              } else {
                compRes = 0.1;
              }
            } else {
              compRes = (comp.type == ComponentType.fuse)
                  ? 0.1
                  : (comp.type == ComponentType.capacitor
                      ? 10.0
                      : (comp.type == ComponentType.buzzer
                          ? 8.0
                          : (comp.type == ComponentType.motor
                              ? 2.0
                              : comp.value)));
            }

            final vDrop = loopCurrent * compRes;
            final power = vDrop * loopCurrent;

            values['active_${comp.id}'] = 1.0;
            values['current_${comp.id}'] =
                (values['current_${comp.id}'] ?? 0.0) + loopCurrent;
            values['voltage_drop_${comp.id}'] = vDrop;
            values['power_${comp.id}'] = power;

            values['node_voltage_${comp.id}_${traversal.inTerminal}'] = currentPotential;
            currentPotential -= vDrop;
            values['node_voltage_${comp.id}_${traversal.outTerminal}'] = currentPotential;

            final totalCompCurrent = values['current_${comp.id}'] ?? loopCurrent;
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
              final maxCurrent = comp.value;
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
    required String currentTerminal, // Current output terminal from currentComponent
    required SandboxComponent targetBattery,
    required Set<String> visited,
    required List<_ComponentTraversal> componentPath,
    required List<SandboxWire> wirePath,
    required void Function(List<_ComponentTraversal>, List<SandboxWire>)
        onLoopClosed,
  }) {
    final wires = targetState.wires.where((w) {
      return (w.fromComponentId == currentComponent.id &&
              w.fromTerminal == currentTerminal) ||
          (w.toComponentId == currentComponent.id &&
              w.toTerminal == currentTerminal);
    }).toList();

    for (final wire in wires) {
      final nextId = wire.fromComponentId == currentComponent.id
          ? wire.toComponentId
          : wire.fromComponentId;
      final nextTerm = wire.fromComponentId == currentComponent.id
          ? wire.toTerminal
          : wire.fromTerminal;

      final nextComponentList =
          targetState.components.where((c) => c.id == nextId).toList();
      if (nextComponentList.isEmpty) continue;
      final nextComponent = nextComponentList.first;

      wirePath.add(wire);

      if (nextComponent.id == targetBattery.id && nextTerm == 'A') {
        onLoopClosed(List.from(componentPath), List.from(wirePath));
        wirePath.removeLast();
        return; // Retorna para continuar procurando outros caminhos
      }

      if (visited.contains(nextComponent.id)) {
        wirePath.removeLast();
        continue;
      }

      if (targetState.burnedComponentIds.contains(nextComponent.id)) {
        wirePath.removeLast();
        continue;
      }

      if (nextComponent.type == ComponentType.switchComponent &&
          !nextComponent.isActive) {
        wirePath.removeLast();
        continue;
      }

      if (nextComponent.type == ComponentType.diode ||
          nextComponent.type == ComponentType.led) {
        // Polarização de Diodo
        final isReversed =
            (nextComponent.rotation == 180.0 || nextComponent.rotation == 270.0)
                ? (nextTerm == 'A')
                : (nextTerm == 'B');
        if (isReversed) {
          wirePath.removeLast();
          continue;
        }
      }

      final nextOutTerms = nextComponent.getInternalConnections(nextTerm);

      visited.add(nextComponent.id);
      
      for (final outTerm in nextOutTerms) {
        componentPath.add(_ComponentTraversal(nextComponent, nextTerm, outTerm));
        
        _traverseForState(
          targetState: targetState,
          currentComponent: nextComponent,
          currentTerminal: outTerm,
          targetBattery: targetBattery,
          visited: visited,
          componentPath: componentPath,
          wirePath: wirePath,
          onLoopClosed: onLoopClosed,
        );
        
        componentPath.removeLast();
      }
      
      visited.remove(nextComponent.id);
      wirePath.removeLast();
    }
  }
}
