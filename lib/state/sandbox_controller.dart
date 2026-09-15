import 'dart:async';
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
  SandboxController({CircuitSolverService? solverService})
    : _solverService = solverService ?? CircuitSolverService();

  late final SandboxPersistenceRepository _persistence;
  final HistoryManager<SandboxState> _history = HistoryManager<SandboxState>(
    maxDepth: 30,
  );
  final CircuitSolverService _solverService;
  int _solveRevision = 0;
  Timer? _recalculateTimer;

  void _scheduleRecalculation({
  required void Function() action,
}) {
  _recalculateTimer?.cancel();
  _recalculateTimer = Timer(const Duration(milliseconds: 300), action);
}

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

  bool canPlaceComponentAt(
    int gridX,
    int gridY, {
    String? movingComponentId,
    int gridCols = 20,
    int gridRows = 16,
  }) {
    if (gridX < 0 || gridX >= gridCols || gridY < 0 || gridY >= gridRows) {
      return false;
    }

    return !state.components.any((c) {
      if (c.id == movingComponentId) return false;
      return c.gridX == gridX && c.gridY == gridY;
    });
  }

  bool canMoveComponents(
    Set<String> componentIds,
    int deltaX,
    int deltaY, {
    int gridCols = 20,
    int gridRows = 16,
  }) {
    if (componentIds.isEmpty) return false;

    final targetCells = <String>{};
    for (final c in state.components) {
      if (!componentIds.contains(c.id)) continue;

      final targetX = c.gridX + deltaX;
      final targetY = c.gridY + deltaY;
      if (targetX < 0 ||
          targetX >= gridCols ||
          targetY < 0 ||
          targetY >= gridRows) {
        return false;
      }

      if (!targetCells.add('$targetX,$targetY')) {
        return false;
      }
    }

    if (targetCells.isEmpty) return false;

    return !state.components.any((c) {
      if (componentIds.contains(c.id)) return false;
      return targetCells.contains('${c.gridX},${c.gridY}');
    });
  }

  bool addComponent(
    SandboxComponent component, {
    int gridCols = 20,
    int gridRows = 16,
  }) {
    if (!canPlaceComponentAt(
      component.gridX,
      component.gridY,
      gridCols: gridCols,
      gridRows: gridRows,
    )) {
      return false;
    }

    _history.pushSnapshot(state);
    final updated = [...state.components, component];
    state = state.copyWith(components: updated);
    _recalculateCircuit();
    return true;
  }

  bool moveComponent(
    String componentId,
    int newX,
    int newY, {
    int gridCols = 20,
    int gridRows = 16,
  }) {
    final componentExists = state.components.any((c) => c.id == componentId);
    if (!componentExists ||
        !canPlaceComponentAt(
          newX,
          newY,
          movingComponentId: componentId,
          gridCols: gridCols,
          gridRows: gridRows,
        )) {
      return false;
    }

    _history.pushSnapshot(state);
    final updated = state.components.map((c) {
      if (c.id == componentId) {
        return c.copyWith(gridX: newX, gridY: newY);
      }
      return c;
    }).toList();

    state = state.copyWith(components: updated);
    _scheduleRecalculation(action: _recalculateCircuit);
    return true;
  }

  bool moveComponents(
    Set<String> componentIds,
    int deltaX,
    int deltaY, {
    int gridCols = 20,
    int gridRows = 16,
  }) {
    if (componentIds.isEmpty || (deltaX == 0 && deltaY == 0)) return false;
    if (!canMoveComponents(
      componentIds,
      deltaX,
      deltaY,
      gridCols: gridCols,
      gridRows: gridRows,
    ))
      return false;

    _history.pushSnapshot(state);
    final updated = state.components.map((c) {
      if (componentIds.contains(c.id)) {
        return c.copyWith(gridX: c.gridX + deltaX, gridY: c.gridY + deltaY);
      }
      return c;
    }).toList();

    state = state.copyWith(components: updated);
    _scheduleRecalculation(action: _recalculateCircuit);
    return true;
  }

  void removeComponent(String componentId) {
    removeComponents({componentId});
  }

  void removeComponents(Set<String> componentIds) {
    if (componentIds.isEmpty) return;
    _history.pushSnapshot(state);
    final updatedComponents = state.components
        .where((c) => !componentIds.contains(c.id))
        .toList();
    final updatedWires = state.wires.where((w) {
      return !componentIds.contains(w.fromComponentId) &&
          !componentIds.contains(w.toComponentId);
    }).toList();

    state = state.copyWith(components: updatedComponents, wires: updatedWires);
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
        final b = SandboxComponent(
          id: 'bat_$now',
          type: ComponentType.battery,
          gridX: 1,
          gridY: 2,
          value: 4.5,
        );
        final s = SandboxComponent(
          id: 'sw_$now',
          type: ComponentType.switchComponent,
          gridX: 3,
          gridY: 2,
          isActive: true,
        );
        final l = SandboxComponent(
          id: 'bulb_$now',
          type: ComponentType.bulb,
          gridX: 5,
          gridY: 2,
          value: 10.0,
        );
        newComponents = [b, s, l];
        newWires = [
          SandboxWire(
            id: 'w1_$now',
            fromComponentId: b.id,
            fromTerminal: 'B',
            toComponentId: s.id,
            toTerminal: 'A',
          ),
          SandboxWire(
            id: 'w2_$now',
            fromComponentId: s.id,
            fromTerminal: 'B',
            toComponentId: l.id,
            toTerminal: 'A',
          ),
          SandboxWire(
            id: 'w3_$now',
            fromComponentId: l.id,
            fromTerminal: 'B',
            toComponentId: b.id,
            toTerminal: 'A',
          ),
        ];
        break;

      case 'switch_motor':
        final b = SandboxComponent(
          id: 'bat_$now',
          type: ComponentType.battery,
          gridX: 1,
          gridY: 2,
          value: 9.0,
        );
        final s = SandboxComponent(
          id: 'sw_$now',
          type: ComponentType.switchComponent,
          gridX: 3,
          gridY: 2,
          isActive: true,
        );
        final m = SandboxComponent(
          id: 'mot_$now',
          type: ComponentType.motor,
          gridX: 5,
          gridY: 2,
          value: 12.0,
        );
        newComponents = [b, s, m];
        newWires = [
          SandboxWire(
            id: 'w1_$now',
            fromComponentId: b.id,
            fromTerminal: 'B',
            toComponentId: s.id,
            toTerminal: 'A',
          ),
          SandboxWire(
            id: 'w2_$now',
            fromComponentId: s.id,
            fromTerminal: 'B',
            toComponentId: m.id,
            toTerminal: 'A',
          ),
          SandboxWire(
            id: 'w3_$now',
            fromComponentId: m.id,
            fromTerminal: 'B',
            toComponentId: b.id,
            toTerminal: 'A',
          ),
        ];
        break;

      case 'led_resistor':
        final b = SandboxComponent(
          id: 'bat_$now',
          type: ComponentType.battery,
          gridX: 1,
          gridY: 2,
          value: 9.0,
        );
        final r = SandboxComponent(
          id: 'res_$now',
          type: ComponentType.resistor,
          gridX: 3,
          gridY: 2,
          value: 220.0,
        );
        final led = SandboxComponent(
          id: 'led_$now',
          type: ComponentType.led,
          gridX: 5,
          gridY: 2,
          value: 10.0,
        );
        newComponents = [b, r, led];
        newWires = [
          SandboxWire(
            id: 'w1_$now',
            fromComponentId: b.id,
            fromTerminal: 'B',
            toComponentId: r.id,
            toTerminal: 'A',
          ),
          SandboxWire(
            id: 'w2_$now',
            fromComponentId: r.id,
            fromTerminal: 'B',
            toComponentId: led.id,
            toTerminal: 'A',
          ),
          SandboxWire(
            id: 'w3_$now',
            fromComponentId: led.id,
            fromTerminal: 'B',
            toComponentId: b.id,
            toTerminal: 'A',
          ),
        ];
        break;

      case 'parallel_bulbs':
        final b = SandboxComponent(
          id: 'bat_$now',
          type: ComponentType.battery,
          gridX: 1,
          gridY: 2,
          value: 9.0,
        );
        final l1 = SandboxComponent(
          id: 'b1_$now',
          type: ComponentType.bulb,
          gridX: 4,
          gridY: 1,
          value: 10.0,
        );
        final l2 = SandboxComponent(
          id: 'b2_$now',
          type: ComponentType.bulb,
          gridX: 4,
          gridY: 3,
          value: 10.0,
        );
        newComponents = [b, l1, l2];
        newWires = [
          SandboxWire(
            id: 'w1_$now',
            fromComponentId: b.id,
            fromTerminal: 'B',
            toComponentId: l1.id,
            toTerminal: 'A',
          ),
          SandboxWire(
            id: 'w2_$now',
            fromComponentId: b.id,
            fromTerminal: 'B',
            toComponentId: l2.id,
            toTerminal: 'A',
          ),
          SandboxWire(
            id: 'w3_$now',
            fromComponentId: l1.id,
            fromTerminal: 'B',
            toComponentId: b.id,
            toTerminal: 'A',
          ),
          SandboxWire(
            id: 'w4_$now',
            fromComponentId: l2.id,
            fromTerminal: 'B',
            toComponentId: b.id,
            toTerminal: 'A',
          ),
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
    final revision = ++_solveRevision;
    final stateToSolve = state;
    final solved = await _solverService.solve(stateToSolve);
    if (revision != _solveRevision) return;

    state = state.copyWith(
      simulationValues: solved.simulationValues,
      errorMessage: solved.errorMessage,
      burnedComponentIds: solved.burnedComponentIds,
      isShortCircuit: solved.isShortCircuit,
      shortCircuitWireIds: solved.shortCircuitWireIds,
    );
    await _persistence.save(state);
  }

  String? duplicateComponent(
    String componentId, {
    int gridCols = 8,
    int gridRows = 5,
  }) {
    final comp = state.components.where((c) => c.id == componentId).firstOrNull;
    if (comp == null) return null;

    // Procura uma célula livre próxima
    final occupied = state.components
        .map((c) => '${c.gridX},${c.gridY}')
        .toSet();

    // Candidatos preferenciais: direita, baixo, esquerda, cima
    final candidates = [
      [comp.gridX + 1, comp.gridY],
      [comp.gridX, comp.gridY + 1],
      [comp.gridX - 1, comp.gridY],
      [comp.gridX, comp.gridY - 1],
      [comp.gridX + 1, comp.gridY + 1],
    ];

    int targetX = comp.gridX;
    int targetY = comp.gridY;
    bool found = false;

    for (final cand in candidates) {
      final x = cand[0];
      final y = cand[1];
      if (x >= 0 &&
          x < gridCols &&
          y >= 0 &&
          y < gridRows &&
          !occupied.contains('$x,$y')) {
        targetX = x;
        targetY = y;
        found = true;
        break;
      }
    }

    // Se nenhuma adjacente estiver livre, busca a primeira célula vazia do grid
    if (!found) {
      for (int y = 0; y < gridRows && !found; y++) {
        for (int x = 0; x < gridCols; x++) {
          if (!occupied.contains('$x,$y')) {
            targetX = x;
            targetY = y;
            found = true;
            break;
          }
        }
      }
    }

    if (!found) return null;

    final newId =
        '${comp.type.name}_${DateTime.now().millisecondsSinceEpoch}_${state.components.length}';
    final cloned = SandboxComponent(
      id: newId,
      type: comp.type,
      gridX: targetX,
      gridY: targetY,
      rotation: comp.rotation,
      isActive: comp.isActive,
      value: comp.value,
    );

    final added = addComponent(cloned, gridCols: gridCols, gridRows: gridRows);
    return added ? newId : null;
  }

  List<SavedProjectSummary> listSavedProjects() {
    return _persistence.listSavedProjects();
  }

  Future<void> saveNamedProject(String name, {String? existingId}) async {
    await _persistence.saveProjectSlot(
      name: name,
      state: state,
      existingId: existingId,
    );
  }

  bool loadNamedProject(String id) {
    final loaded = _persistence.loadProjectSlot(id);
    if (loaded != null) {
      _history.pushSnapshot(state);
      state = loaded;
      _recalculateCircuit();
      return true;
    }
    return false;
  }

  Future<void> deleteNamedProject(String id) async {
    await _persistence.deleteProjectSlot(id);
  }

  void replaceBurnedComponent(String id) {
    _history.pushSnapshot(state);
    final updatedBurned = Set<String>.from(state.burnedComponentIds)
      ..remove(id);
    state = state.copyWith(burnedComponentIds: updatedBurned);
    _recalculateCircuit();
  }

  void replaceAllBurnedComponents() {
    _history.pushSnapshot(state);
    state = state.copyWith(burnedComponentIds: {});
    _recalculateCircuit();
  }
}

final sandboxControllerProvider =
    NotifierProvider<SandboxController, SandboxState>(SandboxController.new);
