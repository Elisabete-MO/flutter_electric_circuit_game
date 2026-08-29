import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/first_step_component.dart';
import '../models/sandbox_component.dart';
import '../models/sandbox_wire.dart';
import '../models/sandbox_state.dart';
import '../services/circuit_solver_service.dart';
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

  void moveComponents(Set<String> componentIds, int deltaX, int deltaY) {
    if (componentIds.isEmpty || (deltaX == 0 && deltaY == 0)) return;

    // Verificar se todos os movimentos ficam dentro do grid
    bool valid = true;
    for (final c in state.components) {
      if (componentIds.contains(c.id)) {
        final targetX = c.gridX + deltaX;
        final targetY = c.gridY + deltaY;
        if (targetX < 0 || targetX >= 20 || targetY < 0 || targetY >= 16) {
          valid = false;
          break;
        }
      }
    }
    if (!valid) return;

    _pushSnapshot();
    final updated = state.components.map((c) {
      if (componentIds.contains(c.id)) {
        return c.copyWith(
          gridX: (c.gridX + deltaX).clamp(0, 19),
          gridY: (c.gridY + deltaY).clamp(0, 15),
        );
      }
      return c;
    }).toList();

    state = state.copyWith(components: updated);
    _recalculateCircuit();
  }

  void removeComponent(String componentId) {
    removeComponents({componentId});
  }

  void removeComponents(Set<String> componentIds) {
    if (componentIds.isEmpty) return;
    _pushSnapshot();
    final updatedComponents = state.components.where((c) => !componentIds.contains(c.id)).toList();
    final updatedWires = state.wires.where((w) {
      return !componentIds.contains(w.fromComponentId) && !componentIds.contains(w.toComponentId);
    }).toList();

    state = state.copyWith(
      components: updatedComponents,
      wires: updatedWires,
    );
    _recalculateCircuit();
  }

  void rotateComponent(String componentId) {
    rotateComponents({componentId});
  }

  void rotateComponents(Set<String> componentIds) {
    if (componentIds.isEmpty) return;
    _pushSnapshot();
    final updated = state.components.map((c) {
      if (componentIds.contains(c.id)) {
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
      isSimulating: true,
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
        final r = SandboxComponent(id: 'res_$now', type: ComponentType.resistor, gridX: 3, gridY: 2, value: 220.0);
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
    state = CircuitSolverService.calculateSimulation(state);
    _persistState();
  }

  SandboxState _calculateSimulationForState(SandboxState targetState) {
    return CircuitSolverService.calculateSimulation(targetState);
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
}

final sandboxControllerProvider = NotifierProvider<SandboxController, SandboxState>(
  SandboxController.new,
);
