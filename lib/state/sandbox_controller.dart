import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/first_step_component.dart';
import '../models/sandbox_component.dart';
import '../models/sandbox_wire.dart';
import '../models/sandbox_state.dart';
import '../services/history_manager.dart';
import '../services/sandbox_persistence_repository.dart';
import '../services/circuit_solver/circuit_solver_service.dart';
import 'progress_controller.dart';

class SandboxController extends Notifier<SandboxState> {
  late final SandboxPersistenceRepository _persistence;
  final HistoryManager<SandboxState> _history = HistoryManager<SandboxState>(maxDepth: 30);
  final CircuitSolverService _solverService = CircuitSolverService();

  @override
  SandboxState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    _persistence = SandboxPersistenceRepository(prefs);

    final initialState = _persistence.load();

    // Executa a simulação inicial de forma assíncrona para não travar a build
    Future.microtask(() => _recalculateCircuit());

    return initialState;
  }

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  void undo() {
    final previous = _history.undo(state);
    if (previous != null) {
      state = previous;
      _recalculateCircuit();
    }
  }

  void redo() {
    final nextState = _history.redo(state);
    if (nextState != null) {
      state = nextState;
      _recalculateCircuit();
    }
  }

  void addComponent(SandboxComponent component) {
    _history.pushSnapshot(state);
    final updated = [...state.components, component];
    state = state.copyWith(components: updated);
    _recalculateCircuit();
  }

  void moveComponent(String componentId, int newX, int newY) {
    _history.pushSnapshot(state);
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

    _history.pushSnapshot(state);
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
    _history.pushSnapshot(state);
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
    _history.pushSnapshot(state);
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
    _history.pushSnapshot(state);
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
    _history.pushSnapshot(state);
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
    // Evitar conexões de um terminal consigo mesmo
    if (fromId == toId && fromTerm == toTerm) return;

    // Evitar fios duplicados
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

    _history.pushSnapshot(state);
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
    _history.pushSnapshot(state);
    final updated = state.wires.where((w) => w.id != wireId).toList();
    state = state.copyWith(wires: updated);
    _recalculateCircuit();
  }

  void clearCanvas() {
    _history.pushSnapshot(state);
    state = const SandboxState();
    _recalculateCircuit();
  }

  void loadCircuit(List<SandboxComponent> components, List<SandboxWire> wires) {
    _history.pushSnapshot(state);
    state = SandboxState(
      components: components,
      wires: wires,
      isSimulating: true,
    );
    _recalculateCircuit();
  }

  void loadPreset(String presetKey) {
    _history.pushSnapshot(state);
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

  Future<void> _recalculateCircuit() async {
    final solved = await _solverService.solve(state);
    state = solved;
    await _persistence.save(state);
  }

  void replaceBurnedComponent(String id) {
    _history.pushSnapshot(state);
    final updatedBurned = Set<String>.from(state.burnedComponentIds)..remove(id);
    state = state.copyWith(burnedComponentIds: updatedBurned);
    _recalculateCircuit();
  }

  void replaceAllBurnedComponents() {
    _history.pushSnapshot(state);
    state = state.copyWith(burnedComponentIds: {});
    _recalculateCircuit();
  }
}

final sandboxControllerProvider = NotifierProvider<SandboxController, SandboxState>(
  SandboxController.new,
);
