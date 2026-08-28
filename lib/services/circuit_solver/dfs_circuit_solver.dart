import '../../models/first_step_component.dart';
import '../../models/sandbox_component.dart';
import '../../models/sandbox_wire.dart';
import '../../models/sandbox_state.dart';
import 'circuit_solver_strategy.dart';

class DfsCircuitSolver implements CircuitSolverStrategy {
  @override
  SandboxState solve(SandboxState targetState) {
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
      final componentPath = <SandboxComponent>[];
      final wirePath = <SandboxWire>[];
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
        onLoopClosed: (pathComponents, pathWires) {
          closedLoops.add(_ClosedLoopData(
              List.from(pathComponents), List.from(pathWires)));
        },
      );

      if (closedLoops.isNotEmpty) {
        double totalSourceCurrent = 0.0;

        for (final loop in closedLoops) {
          final loopPath = loop.components;
          final totalResistance = loopPath
              .where((c) =>
                  c.type != ComponentType.battery &&
                  c.type != ComponentType.powerSupply)
              .fold(0.0, (sum, c) {
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

          for (final comp in loopPath) {
            if (comp.type == ComponentType.battery ||
                comp.type == ComponentType.powerSupply) {
              continue;
            }

            final compRes = (comp.type == ComponentType.fuse)
                ? 0.1
                : (comp.type == ComponentType.capacitor
                    ? 10.0
                    : (comp.type == ComponentType.buzzer
                        ? 8.0
                        : (comp.type == ComponentType.motor
                            ? 2.0
                            : comp.value)));
            final vDrop = loopCurrent * compRes;
            final power = vDrop * loopCurrent;

            values['active_${comp.id}'] = 1.0;
            values['current_${comp.id}'] =
                (values['current_${comp.id}'] ?? 0.0) + loopCurrent;
            values['voltage_drop_${comp.id}'] = vDrop;
            values['power_${comp.id}'] = power;

            // Define potenciais nos terminais A e B de acordo com o sentido do fluxo
            values['node_voltage_${comp.id}_B'] = currentPotential;
            currentPotential -= vDrop;
            values['node_voltage_${comp.id}_A'] = currentPotential;

            // Verificação de Limites Físicos e Sobrecarga Educativa
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
    required List<SandboxWire> wirePath,
    required void Function(List<SandboxComponent>, List<SandboxWire>)
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

      if (nextComponent.type == ComponentType.switchComponent &&
          !nextComponent.isActive) {
        wirePath.removeLast();
        continue;
      }

      if (nextComponent.type == ComponentType.diode ||
          nextComponent.type == ComponentType.led) {
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
      _traverseForState(
        targetState: targetState,
        currentComponent: nextComponent,
        currentTerminal: nextOutTerm,
        targetBattery: targetBattery,
        visited: visited,
        componentPath: componentPath,
        wirePath: wirePath,
        onLoopClosed: onLoopClosed,
      );
      visited.remove(nextComponent.id);
      wirePath.removeLast();
    }

    componentPath.removeLast();
  }
}

class _ClosedLoopData {
  final List<SandboxComponent> components;
  final List<SandboxWire> wires;
  _ClosedLoopData(this.components, this.wires);
}
