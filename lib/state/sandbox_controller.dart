import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/first_step_component.dart';
import '../models/sandbox_component.dart';
import '../models/sandbox_wire.dart';
import '../models/sandbox_state.dart';

class SandboxController extends Notifier<SandboxState> {
  @override
  SandboxState build() {
    return const SandboxState();
  }

  void addComponent(SandboxComponent component) {
    final updated = [...state.components, component];
    state = state.copyWith(components: updated);
    _recalculateCircuit();
  }

  void removeComponent(String componentId) {
    final updatedComponents = state.components.where((c) => c.id != componentId).toList();
    // Remove wires connected to the deleted component
    final updatedWires = state.wires.where((w) {
      return w.fromComponentId != componentId && w.toComponentId != componentId;
    }).toList();

    state = state.copyWith(
      components: updatedComponents,
      wires: updatedWires,
    );
    _recalculateCircuit();
  }

  void rotateComponent(String componentId) {
    final updated = state.components.map((c) {
      if (c.id == componentId) {
        return c.copyWith(rotation: (c.rotation + 90.0) % 360.0);
      }
      return c;
    }).toList();

    state = state.copyWith(components: updated);
    _recalculateCircuit();
  }

  void toggleComponentActive(String componentId) {
    final updated = state.components.map((c) {
      if (c.id == componentId) {
        return c.copyWith(isActive: !c.isActive);
      }
      return c;
    }).toList();

    state = state.copyWith(components: updated);
    _recalculateCircuit();
  }

  void updateComponentValue(String componentId, double newValue) {
    final updated = state.components.map((c) {
      if (c.id == componentId) {
        return c.copyWith(value: newValue);
      }
      return c;
    }).toList();

    state = state.copyWith(components: updated);
    _recalculateCircuit();
  }

  void addWire(String fromId, String fromTerm, String toId, String toTerm) {
    // Avoid connecting a terminal to itself
    if (fromId == toId && fromTerm == toTerm) return;

    // Avoid duplicate wires
    final exists = state.wires.any((w) {
      return (w.fromComponentId == fromId &&
              w.fromTerminal == fromTerm &&
              w.toComponentId == toId &&
              w.toTerminal == toTerm) ||
          (w.fromComponentId == toId &&
              w.fromTerminal == toTerm &&
              w.toComponentId == fromId &&
              w.toTerminal == fromTerm);
    });
    if (exists) return;

    final wire = SandboxWire(
      id: 'wire_${DateTime.now().millisecondsSinceEpoch}_${state.wires.length}',
      fromComponentId: fromId,
      fromTerminal: fromTerm,
      toComponentId: toId,
      toTerminal: toTerm,
    );

    final updated = [...state.wires, wire];
    state = state.copyWith(wires: updated);
    _recalculateCircuit();
  }

  void removeWire(String wireId) {
    final updated = state.wires.where((w) => w.id != wireId).toList();
    state = state.copyWith(wires: updated);
    _recalculateCircuit();
  }

  void clearCanvas() {
    state = const SandboxState();
  }

  void toggleSimulation() {
    state = state.copyWith(isSimulating: !state.isSimulating);
    _recalculateCircuit();
  }

  void _recalculateCircuit() {
    if (!state.isSimulating) {
      state = state.copyWith(
        simulationValues: {},
        errorMessage: null,
      );
      return;
    }

    final batteries = state.components.where((c) => c.type == ComponentType.battery).toList();
    if (batteries.isEmpty) {
      state = state.copyWith(
        simulationValues: {},
        errorMessage: 'Sem fonte de energia no circuito.',
      );
      return;
    }

    final Map<String, double> values = {};
    String? error;

    for (final battery in batteries) {
      final visited = <String>{battery.id};
      final componentPath = <SandboxComponent>[];
      bool loopClosed = false;
      double totalResistance = 0.0;

      // Start traversal from positive terminal 'B'
      _traverse(
        currentComponent: battery,
        currentTerminal: 'B',
        targetBattery: battery,
        visited: visited,
        componentPath: componentPath,
        onLoopClosed: (pathComponents) {
          loopClosed = true;
          totalResistance = pathComponents
              .where((c) => c.type != ComponentType.battery)
              .fold(0.0, (sum, c) => sum + c.value);
        },
      );

      if (loopClosed) {
        if (totalResistance <= 0.1) {
          error = 'Curto-circuito detectado!';
          break;
        } else {
          final current = battery.value / totalResistance;
          values['active_${battery.id}'] = 1.0;
          values['current_${battery.id}'] = current;
          
          for (final comp in componentPath) {
            values['active_${comp.id}'] = 1.0;
            values['current_${comp.id}'] = current;
            values['voltage_drop_${comp.id}'] = current * comp.value;
          }
        }
      }
    }

    state = state.copyWith(
      simulationValues: values,
      errorMessage: error,
    );
  }

  void _traverse({
    required SandboxComponent currentComponent,
    required String currentTerminal,
    required SandboxComponent targetBattery,
    required Set<String> visited,
    required List<SandboxComponent> componentPath,
    required void Function(List<SandboxComponent>) onLoopClosed,
  }) {
    componentPath.add(currentComponent);

    final wires = state.wires.where((w) {
      return (w.fromComponentId == currentComponent.id && w.fromTerminal == currentTerminal) ||
             (w.toComponentId == currentComponent.id && w.toTerminal == currentTerminal);
    }).toList();

    for (final wire in wires) {
      final nextId = wire.fromComponentId == currentComponent.id ? wire.toComponentId : wire.fromComponentId;
      final nextTerm = wire.fromComponentId == currentComponent.id ? wire.toTerminal : wire.fromTerminal;

      final nextComponentList = state.components.where((c) => c.id == nextId).toList();
      if (nextComponentList.isEmpty) continue;
      final nextComponent = nextComponentList.first;

      if (nextComponent.id == targetBattery.id && nextTerm == 'A') {
        onLoopClosed(List.from(componentPath));
        return;
      }

      if (visited.contains(nextComponent.id)) {
        continue;
      }

      if (nextComponent.type == ComponentType.switchComponent && !nextComponent.isActive) {
        continue;
      }

      if (nextComponent.type == ComponentType.diode || nextComponent.type == ComponentType.led) {
        if (nextTerm == 'B') {
          continue;
        }
      }

      final nextOutTerm = nextTerm == 'A' ? 'B' : 'A';

      visited.add(nextComponent.id);
      _traverse(
        currentComponent: nextComponent,
        currentTerminal: nextOutTerm,
        targetBattery: targetBattery,
        visited: visited,
        componentPath: componentPath,
        onLoopClosed: onLoopClosed,
      );
      visited.remove(nextComponent.id);
    }

    componentPath.removeLast();
  }
}

final sandboxControllerProvider = NotifierProvider<SandboxController, SandboxState>(
  SandboxController.new,
);
