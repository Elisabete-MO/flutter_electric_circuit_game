import 'dart:async';

import 'package:eletrolab/models/first_step_component.dart';
import 'package:eletrolab/models/sandbox_component.dart';
import 'package:eletrolab/models/sandbox_state.dart';
import 'package:eletrolab/services/circuit_solver/circuit_solver_service.dart';
import 'package:eletrolab/state/progress_controller.dart';
import 'package:eletrolab/state/sandbox_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer createContainer({CircuitSolverService? solverService}) {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sandboxControllerProvider.overrideWith(
          () => SandboxController(
            solverService: solverService ?? _ImmediateSolver(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  SandboxComponent component(String id, int gridX, int gridY) {
    return SandboxComponent(
      id: id,
      type: ComponentType.bulb,
      gridX: gridX,
      gridY: gridY,
    );
  }

  group('SandboxController placement invariants', () {
    test('rejects moving a component into an occupied cell', () async {
      final container = createContainer();
      final controller = container.read(sandboxControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      expect(controller.addComponent(component('a', 0, 0)), isTrue);
      expect(controller.addComponent(component('b', 1, 0)), isTrue);

      final moved = controller.moveComponent('a', 1, 0);

      expect(moved, isFalse);
      final state = container.read(sandboxControllerProvider);
      expect(
        state.components.where((c) => c.gridX == 1 && c.gridY == 0),
        hasLength(1),
      );
      expect(state.components.singleWhere((c) => c.id == 'a').gridX, 0);
      expect(state.components.singleWhere((c) => c.id == 'a').gridY, 0);
    });

    test('allows valid single-component moves', () async {
      final container = createContainer();
      final controller = container.read(sandboxControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      expect(controller.addComponent(component('a', 0, 0)), isTrue);

      final moved = controller.moveComponent(
        'a',
        2,
        3,
        gridCols: 4,
        gridRows: 4,
      );

      expect(moved, isTrue);
      final movedComponent = container
          .read(sandboxControllerProvider)
          .components
          .single;
      expect(movedComponent.gridX, 2);
      expect(movedComponent.gridY, 3);
    });

    test('rejects selected group moves into occupied cells', () async {
      final container = createContainer();
      final controller = container.read(sandboxControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      expect(controller.addComponent(component('a', 0, 0)), isTrue);
      expect(controller.addComponent(component('b', 1, 0)), isTrue);
      expect(controller.addComponent(component('blocker', 2, 0)), isTrue);

      final moved = controller.moveComponents(
        {'a', 'b'},
        1,
        0,
        gridCols: 4,
        gridRows: 4,
      );

      expect(moved, isFalse);
      final state = container.read(sandboxControllerProvider);
      expect(state.components.singleWhere((c) => c.id == 'a').gridX, 0);
      expect(state.components.singleWhere((c) => c.id == 'b').gridX, 1);
      expect(state.components.singleWhere((c) => c.id == 'blocker').gridX, 2);
    });

    test('rejects selected group moves outside configurable bounds', () async {
      final container = createContainer();
      final controller = container.read(sandboxControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      expect(controller.addComponent(component('a', 0, 0)), isTrue);
      expect(controller.addComponent(component('b', 1, 0)), isTrue);

      final moved = controller.moveComponents(
        {'a', 'b'},
        -1,
        0,
        gridCols: 4,
        gridRows: 4,
      );

      expect(moved, isFalse);
      final state = container.read(sandboxControllerProvider);
      expect(state.components.singleWhere((c) => c.id == 'a').gridX, 0);
      expect(state.components.singleWhere((c) => c.id == 'b').gridX, 1);
    });

    test('allows valid selected group moves', () async {
      final container = createContainer();
      final controller = container.read(sandboxControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      expect(controller.addComponent(component('a', 0, 0)), isTrue);
      expect(controller.addComponent(component('b', 1, 0)), isTrue);

      final moved = controller.moveComponents(
        {'a', 'b'},
        1,
        1,
        gridCols: 4,
        gridRows: 4,
      );

      expect(moved, isTrue);
      final state = container.read(sandboxControllerProvider);
      expect(state.components.singleWhere((c) => c.id == 'a').gridX, 1);
      expect(state.components.singleWhere((c) => c.id == 'a').gridY, 1);
      expect(state.components.singleWhere((c) => c.id == 'b').gridX, 2);
      expect(state.components.singleWhere((c) => c.id == 'b').gridY, 1);
    });
  });

  test('stale async solver results do not overwrite newer structure', () async {
    final solver = _QueuedSolver();
    final container = createContainer(solverService: solver);
    final controller = container.read(sandboxControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    expect(controller.addComponent(component('old', 0, 0)), isTrue);
    expect(controller.addComponent(component('new', 1, 0)), isTrue);

    expect(solver.pendingSolves, hasLength(2));

    solver.completeSolve(
      1,
      solver.pendingSolves[1].copyWith(simulationValues: {'current_new': 2.0}),
    );
    await Future<void>.delayed(Duration.zero);

    solver.completeSolve(
      0,
      solver.pendingSolves[0].copyWith(simulationValues: {'current_old': 1.0}),
    );
    await Future<void>.delayed(Duration.zero);

    final state = container.read(sandboxControllerProvider);
    expect(state.components.map((c) => c.id), ['old', 'new']);
    expect(state.simulationValues, {'current_new': 2.0});
  });
}

class _ImmediateSolver extends CircuitSolverService {
  @override
  Future<SandboxState> solve(SandboxState state) async => state;
}

class _QueuedSolver extends CircuitSolverService {
  final pendingSolves = <SandboxState>[];
  final _completers = <Completer<SandboxState>>[];

  @override
  Future<SandboxState> solve(SandboxState state) {
    if (state.components.isEmpty) {
      return Future.value(state);
    }

    pendingSolves.add(state);
    final completer = Completer<SandboxState>();
    _completers.add(completer);
    return completer.future;
  }

  void completeSolve(int index, SandboxState state) {
    _completers[index].complete(state);
  }
}
