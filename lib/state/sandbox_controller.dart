import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/first_step_component.dart';
import '../models/sandbox_component.dart';
import '../models/sandbox_wire.dart';
import '../models/sandbox_state.dart';
import 'progress_controller.dart';

class SandboxController extends Notifier<SandboxState> {
  @override
  SandboxState build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    final compString = prefs.getString('sandbox_components');
    final wireString = prefs.getString('sandbox_wires');
    final isSimulating = prefs.getBool('sandbox_is_simulating') ?? false;

    List<SandboxComponent> components = [];
    List<SandboxWire> wires = [];

    if (compString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(compString);
        components = decoded
            .map((item) => SandboxComponent.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    if (wireString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(wireString);
        wires = decoded
            .map((item) => SandboxWire.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    final initialState = SandboxState(
      components: components,
      wires: wires,
      isSimulating: isSimulating,
    );

    return _calculateSimulationForState(initialState);
  }

  void _persistState() {
    final prefs = ref.read(sharedPreferencesProvider);

    final compList = state.components.map((c) => c.toMap()).toList();
    final wireList = state.wires.map((w) => w.toMap()).toList();

    prefs.setString('sandbox_components', jsonEncode(compList));
    prefs.setString('sandbox_wires', jsonEncode(wireList));
    prefs.setBool('sandbox_is_simulating', state.isSimulating);
  }

  final List<SandboxState> _undoStack = [];
  final List<SandboxState> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void _pushSnapshot() {
    _undoStack.add(state);
    if (_undoStack.length > 30) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(state);
    state = _undoStack.removeLast();
    _recalculateCircuit();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(state);
    state = _redoStack.removeLast();
    _recalculateCircuit();
  }

  void addComponent(SandboxComponent component) {
    _pushSnapshot();
    final updated = [...state.components, component];
    state = state.copyWith(components: updated);
    _recalculateCircuit();
  }

  void moveComponent(String componentId, int newX, int newY) {
    _pushSnapshot();
    final updated = state.components.map((c) {
      if (c.id == componentId) {
        return c.copyWith(gridX: newX, gridY: newY);
      }
      return c;
    }).toList();

    state = state.copyWith(components: updated);
    _recalculateCircuit();
  }

  void removeComponent(String componentId) {
    _pushSnapshot();
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
    _pushSnapshot();
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
    _pushSnapshot();
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
    _pushSnapshot();
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

    _pushSnapshot();
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
    _pushSnapshot();
    final updated = state.wires.where((w) => w.id != wireId).toList();
    state = state.copyWith(wires: updated);
    _recalculateCircuit();
  }

  void clearCanvas() {
    _pushSnapshot();
    state = const SandboxState();
    _persistState();
  }

  void loadCircuit(List<SandboxComponent> components, List<SandboxWire> wires) {
    _pushSnapshot();
    state = SandboxState(
      components: components,
      wires: wires,
      isSimulating: state.isSimulating,
    );
    _recalculateCircuit();
  }

  void loadPreset(String presetKey) {
    _pushSnapshot();
    final now = DateTime.now().millisecondsSinceEpoch;

    List<SandboxComponent> newComponents = [];
    List<SandboxWire> newWires = [];

    switch (presetKey) {
      case 'simple_bulb':
        final b = SandboxComponent(id: 'bat_$now', type: ComponentType.battery, gridX: 1, gridY: 2, value: 4.5);
        final s = SandboxComponent(id: 'sw_$now', type: ComponentType.switchComponent, gridX: 3, gridY: 2, isActive: true);
        final l = SandboxComponent(id: 'bulb_$now', type: ComponentType.bulb, gridX: 5, gridY: 2, value: 10.0);
        newComponents = [b, s, l];
        newWires = [
          SandboxWire(id: 'w1_$now', fromComponentId: b.id, fromTerminal: 'B', toComponentId: s.id, toTerminal: 'A'),
          SandboxWire(id: 'w2_$now', fromComponentId: s.id, fromTerminal: 'B', toComponentId: l.id, toTerminal: 'A'),
          SandboxWire(id: 'w3_$now', fromComponentId: l.id, fromTerminal: 'B', toComponentId: b.id, toTerminal: 'A'),
        ];
        break;

      case 'switch_motor':
        final b = SandboxComponent(id: 'bat_$now', type: ComponentType.battery, gridX: 1, gridY: 2, value: 9.0);
        final s = SandboxComponent(id: 'sw_$now', type: ComponentType.switchComponent, gridX: 3, gridY: 2, isActive: true);
        final m = SandboxComponent(id: 'mot_$now', type: ComponentType.motor, gridX: 5, gridY: 2, value: 12.0);
        newComponents = [b, s, m];
        newWires = [
          SandboxWire(id: 'w1_$now', fromComponentId: b.id, fromTerminal: 'B', toComponentId: s.id, toTerminal: 'A'),
          SandboxWire(id: 'w2_$now', fromComponentId: s.id, fromTerminal: 'B', toComponentId: m.id, toTerminal: 'A'),
          SandboxWire(id: 'w3_$now', fromComponentId: m.id, fromTerminal: 'B', toComponentId: b.id, toTerminal: 'A'),
        ];
        break;

      case 'led_resistor':
        final b = SandboxComponent(id: 'bat_$now', type: ComponentType.battery, gridX: 1, gridY: 2, value: 9.0);
        final r = SandboxComponent(id: 'res_$now', type: ComponentType.resistor, gridX: 3, gridY: 2, value: 50.0);
        final led = SandboxComponent(id: 'led_$now', type: ComponentType.led, gridX: 5, gridY: 2, value: 10.0);
        newComponents = [b, r, led];
        newWires = [
          SandboxWire(id: 'w1_$now', fromComponentId: b.id, fromTerminal: 'B', toComponentId: r.id, toTerminal: 'A'),
          SandboxWire(id: 'w2_$now', fromComponentId: r.id, fromTerminal: 'B', toComponentId: led.id, toTerminal: 'A'),
          SandboxWire(id: 'w3_$now', fromComponentId: led.id, fromTerminal: 'B', toComponentId: b.id, toTerminal: 'A'),
        ];
        break;

      case 'parallel_bulbs':
        final b = SandboxComponent(id: 'bat_$now', type: ComponentType.battery, gridX: 1, gridY: 2, value: 9.0);
        final l1 = SandboxComponent(id: 'b1_$now', type: ComponentType.bulb, gridX: 4, gridY: 1, value: 10.0);
        final l2 = SandboxComponent(id: 'b2_$now', type: ComponentType.bulb, gridX: 4, gridY: 3, value: 10.0);
        newComponents = [b, l1, l2];
        newWires = [
          SandboxWire(id: 'w1_$now', fromComponentId: b.id, fromTerminal: 'B', toComponentId: l1.id, toTerminal: 'A'),
          SandboxWire(id: 'w2_$now', fromComponentId: b.id, fromTerminal: 'B', toComponentId: l2.id, toTerminal: 'A'),
          SandboxWire(id: 'w3_$now', fromComponentId: l1.id, fromTerminal: 'B', toComponentId: b.id, toTerminal: 'A'),
          SandboxWire(id: 'w4_$now', fromComponentId: l2.id, fromTerminal: 'B', toComponentId: b.id, toTerminal: 'A'),
        ];
        break;
    }

    state = state.copyWith(
      components: newComponents,
      wires: newWires,
      isSimulating: true,
    );
    _recalculateCircuit();
  }

  void toggleSimulation() {
    state = state.copyWith(isSimulating: !state.isSimulating);
    _recalculateCircuit();
  }

  void _recalculateCircuit() {
    state = _calculateSimulationForState(state);
    _persistState();
  }

  SandboxState _calculateSimulationForState(SandboxState targetState) {
    if (!targetState.isSimulating) {
      return targetState.copyWith(
        simulationValues: {},
        errorMessage: null,
      );
    }

    final powerSources = targetState.components.where((c) => c.type == ComponentType.battery || c.type == ComponentType.powerSupply).toList();
    if (powerSources.isEmpty) {
      return targetState.copyWith(
        simulationValues: {},
        errorMessage: 'Sem fonte de energia no circuito.',
      );
    }

    final Map<String, double> values = {};
    String? error;

    for (final source in powerSources) {
      final visited = <String>{source.id};
      final componentPath = <SandboxComponent>[];
      bool loopClosed = false;
      double totalResistance = 0.0;

      // Start traversal from positive terminal 'B'
      _traverseForState(
        targetState: targetState,
        currentComponent: source,
        currentTerminal: 'B',
        targetBattery: source,
        visited: visited,
        componentPath: componentPath,
        onLoopClosed: (pathComponents) {
          loopClosed = true;
          totalResistance = pathComponents
              .where((c) => c.type != ComponentType.battery && c.type != ComponentType.powerSupply)
              .fold(0.0, (sum, c) {
                if (c.type == ComponentType.fuse) return sum + 0.1;
                if (c.type == ComponentType.capacitor) return sum + 10.0;
                if (c.type == ComponentType.buzzer) return sum + 8.0;
                return sum + c.value;
              });
        },
      );

      if (loopClosed) {
        final Set<String> newBurnedSet = Set.from(targetState.burnedComponentIds);

        if (totalResistance <= 0.1) {
          error = 'CURTO-CIRCUITO DETECTADO! Conexão direta entre pólos sem carga!';
        } else {
          final current = source.value / totalResistance;
          values['active_${source.id}'] = 1.0;
          values['current_${source.id}'] = current;
          values['node_voltage_${source.id}_B'] = source.value;
          values['node_voltage_${source.id}_A'] = 0.0;
          
          double currentPotential = source.value;

          for (final comp in componentPath) {
            if (comp.type == ComponentType.battery || comp.type == ComponentType.powerSupply) continue;

            final compRes = (comp.type == ComponentType.fuse)
                ? 0.1
                : (comp.type == ComponentType.capacitor ? 10.0 : (comp.type == ComponentType.buzzer ? 8.0 : comp.value));
            final vDrop = current * compRes;
            final power = vDrop * current;

            values['active_${comp.id}'] = 1.0;
            values['current_${comp.id}'] = current;
            values['voltage_drop_${comp.id}'] = vDrop;
            values['power_${comp.id}'] = power;

            // Define potenciais nos terminais A e B de acordo com o sentido do fluxo
            values['node_voltage_${comp.id}_A'] = currentPotential;
            currentPotential -= vDrop;
            values['node_voltage_${comp.id}_B'] = currentPotential;

            // Verificação de Limites Físicos e Sobrecarga Educativa
            if (comp.type == ComponentType.led) {
              if (current > 0.05 || vDrop > 3.3) {
                newBurnedSet.add(comp.id);
                error = 'O LED QUEIMOU! Corrente (${(current * 1000).toStringAsFixed(0)}mA) excedeu o limite seguro (50mA). Conecte um resistor em série!';
              }
            } else if (comp.type == ComponentType.bulb) {
              if (power > 15.0) {
                newBurnedSet.add(comp.id);
                error = 'FILAMENTO ROMPIDO! A lâmpada queimou por excesso de potência (${power.toStringAsFixed(1)}W > 15W)!';
              }
            } else if (comp.type == ComponentType.motor) {
              if (vDrop > 18.0) {
                newBurnedSet.add(comp.id);
                error = 'BOBINA QUEIMADA! O motor sofreu sobretensão (${vDrop.toStringAsFixed(1)}V > 18V)!';
              }
            } else if (comp.type == ComponentType.fuse) {
              final maxCurrent = comp.value; // ex: 2.0A
              if (current > maxCurrent) {
                newBurnedSet.add(comp.id);
                error = 'FUSÍVEL QUEIMOU! Corrente de ${current.toStringAsFixed(2)}A excedeu o limite do fusível (${maxCurrent.toStringAsFixed(1)}A), desarmando o circuito!';
              }
            }
          }
        }

        return targetState.copyWith(
          simulationValues: values,
          errorMessage: error,
          burnedComponentIds: newBurnedSet,
        );
      }
    }

    return targetState.copyWith(
      simulationValues: values,
      errorMessage: error,
    );
  }

  void replaceBurnedComponent(String id) {
    _pushSnapshot();
    final updatedBurned = Set<String>.from(state.burnedComponentIds)..remove(id);
    state = state.copyWith(burnedComponentIds: updatedBurned);
    _recalculateCircuit();
  }

  void replaceAllBurnedComponents() {
    _pushSnapshot();
    state = state.copyWith(burnedComponentIds: {});
    _recalculateCircuit();
  }

  void _traverseForState({
    required SandboxState targetState,
    required SandboxComponent currentComponent,
    required String currentTerminal,
    required SandboxComponent targetBattery,
    required Set<String> visited,
    required List<SandboxComponent> componentPath,
    required void Function(List<SandboxComponent>) onLoopClosed,
  }) {
    componentPath.add(currentComponent);

    final wires = targetState.wires.where((w) {
      return (w.fromComponentId == currentComponent.id && w.fromTerminal == currentTerminal) ||
             (w.toComponentId == currentComponent.id && w.toTerminal == currentTerminal);
    }).toList();

    for (final wire in wires) {
      final nextId = wire.fromComponentId == currentComponent.id ? wire.toComponentId : wire.fromComponentId;
      final nextTerm = wire.fromComponentId == currentComponent.id ? wire.toTerminal : wire.fromTerminal;

      final nextComponentList = targetState.components.where((c) => c.id == nextId).toList();
      if (nextComponentList.isEmpty) continue;
      final nextComponent = nextComponentList.first;

      if (nextComponent.id == targetBattery.id && nextTerm == 'A') {
        onLoopClosed(List.from(componentPath));
        return;
      }

      if (visited.contains(nextComponent.id)) {
        continue;
      }

      if (targetState.burnedComponentIds.contains(nextComponent.id)) {
        continue; // Componente queimado interrompe o circuito (circuito aberto)
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
      _traverseForState(
        targetState: targetState,
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
