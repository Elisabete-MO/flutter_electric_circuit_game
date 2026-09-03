import '../../models/first_step_component.dart';
import '../../models/sandbox_component.dart';
import '../../models/sandbox_state.dart';
import '../../models/sandbox_wire.dart';
import 'circuit_solver_service.dart';

/// Resultado da simulação de um circuito de missão.
class MissionSimulationResult {
  const MissionSimulationResult({
    required this.isSuccess,
    required this.hasClosedLoop,
    this.current = 0.0,
    this.componentCurrents = const {},
    this.componentVoltages = const {},
    this.errorMessage,
    this.burnedComponentIds = const {},
    this.isShortCircuit = false,
  });

  final bool isSuccess;
  final bool hasClosedLoop;
  final double current;
  final Map<String, double> componentCurrents;
  final Map<String, double> componentVoltages;
  final String? errorMessage;
  final Set<String> burnedComponentIds;
  final bool isShortCircuit;
}

/// Builder simplificado para montar circuitos de missão e rodar o solver.
///
/// Uso:
/// ```dart
/// final result = await MissionCircuitBuilder()
///   .addBattery(id: 'bat1', voltage: 9.0)
///   .addResistor(id: 'r1', resistance: 680)
///   .addLed(id: 'led1')
///   .connect('bat1', 'B', 'r1', 'A')
///   .connect('r1', 'B', 'led1', 'A')
///   .connect('led1', 'B', 'bat1', 'A')
///   .simulate();
/// ```
class MissionCircuitBuilder {
  final List<SandboxComponent> _components = [];
  final List<SandboxWire> _wires = [];
  int _wireCounter = 0;

  /// Adiciona uma bateria com a tensão especificada.
  MissionCircuitBuilder addBattery({
    required String id,
    double voltage = 9.0,
    int gridX = 0,
    int gridY = 0,
  }) {
    _components.add(SandboxComponent(
      id: id,
      type: ComponentType.battery,
      gridX: gridX,
      gridY: gridY,
      value: voltage,
    ));
    return this;
  }

  /// Adiciona uma fonte de alimentação regulável.
  MissionCircuitBuilder addPowerSupply({
    required String id,
    double voltage = 12.0,
    int gridX = 0,
    int gridY = 0,
  }) {
    _components.add(SandboxComponent(
      id: id,
      type: ComponentType.powerSupply,
      gridX: gridX,
      gridY: gridY,
      value: voltage,
    ));
    return this;
  }

  /// Adiciona uma lâmpada.
  MissionCircuitBuilder addBulb({
    required String id,
    double resistance = 5.0,
    int gridX = 0,
    int gridY = 0,
  }) {
    _components.add(SandboxComponent(
      id: id,
      type: ComponentType.bulb,
      gridX: gridX,
      gridY: gridY,
      value: resistance,
    ));
    return this;
  }

  /// Adiciona um resistor.
  MissionCircuitBuilder addResistor({
    required String id,
    double resistance = 220.0,
    int gridX = 0,
    int gridY = 0,
  }) {
    _components.add(SandboxComponent(
      id: id,
      type: ComponentType.resistor,
      gridX: gridX,
      gridY: gridY,
      value: resistance,
    ));
    return this;
  }

  /// Adiciona um LED.
  MissionCircuitBuilder addLed({
    required String id,
    bool reversed = false,
    int gridX = 0,
    int gridY = 0,
  }) {
    _components.add(SandboxComponent(
      id: id,
      type: ComponentType.led,
      gridX: gridX,
      gridY: gridY,
      rotation: reversed ? 180.0 : 0.0,
    ));
    return this;
  }

  /// Adiciona um diodo.
  MissionCircuitBuilder addDiode({
    required String id,
    bool reversed = false,
    int gridX = 0,
    int gridY = 0,
  }) {
    _components.add(SandboxComponent(
      id: id,
      type: ComponentType.diode,
      gridX: gridX,
      gridY: gridY,
      rotation: reversed ? 180.0 : 0.0,
    ));
    return this;
  }

  /// Adiciona um interruptor.
  MissionCircuitBuilder addSwitch({
    required String id,
    bool closed = true,
    int gridX = 0,
    int gridY = 0,
  }) {
    _components.add(SandboxComponent(
      id: id,
      type: ComponentType.switchComponent,
      gridX: gridX,
      gridY: gridY,
      isActive: closed,
    ));
    return this;
  }

  /// Adiciona um motor CC.
  MissionCircuitBuilder addMotor({
    required String id,
    int gridX = 0,
    int gridY = 0,
  }) {
    _components.add(SandboxComponent(
      id: id,
      type: ComponentType.motor,
      gridX: gridX,
      gridY: gridY,
    ));
    return this;
  }

  /// Adiciona um fusível.
  MissionCircuitBuilder addFuse({
    required String id,
    double maxCurrent = 2.0,
    int gridX = 0,
    int gridY = 0,
  }) {
    _components.add(SandboxComponent(
      id: id,
      type: ComponentType.fuse,
      gridX: gridX,
      gridY: gridY,
      value: maxCurrent,
    ));
    return this;
  }

  /// Adiciona um capacitor.
  MissionCircuitBuilder addCapacitor({
    required String id,
    int gridX = 0,
    int gridY = 0,
  }) {
    _components.add(SandboxComponent(
      id: id,
      type: ComponentType.capacitor,
      gridX: gridX,
      gridY: gridY,
    ));
    return this;
  }

  /// Adiciona um buzzer.
  MissionCircuitBuilder addBuzzer({
    required String id,
    int gridX = 0,
    int gridY = 0,
  }) {
    _components.add(SandboxComponent(
      id: id,
      type: ComponentType.buzzer,
      gridX: gridX,
      gridY: gridY,
    ));
    return this;
  }

  /// Conecta o terminal de um componente ao terminal de outro.
  MissionCircuitBuilder connect(
    String fromId, String fromTerminal,
    String toId, String toTerminal,
  ) {
    _wires.add(SandboxWire(
      id: 'w${_wireCounter++}',
      fromComponentId: fromId,
      fromTerminal: fromTerminal,
      toComponentId: toId,
      toTerminal: toTerminal,
    ));
    return this;
  }

  /// Roda a simulação e retorna o resultado.
  Future<MissionSimulationResult> simulate() async {
    final state = SandboxState(
      components: List.from(_components),
      wires: List.from(_wires),
      isSimulating: true,
    );

    final result = await CircuitSolverService().solve(state);

    final currentMap = <String, double>{};
    final voltageMap = <String, double>{};
    double totalCurrent = 0.0;

    for (final comp in _components) {
      final current = result.simulationValues['current_${comp.id}'];
      if (current != null) {
        currentMap[comp.id] = current;
        totalCurrent += current;
      }
      final voltage = result.simulationValues['voltage_drop_${comp.id}'];
      if (voltage != null) {
        voltageMap[comp.id] = voltage;
      }
    }

    return MissionSimulationResult(
      isSuccess: result.errorMessage == null && !result.isShortCircuit,
      hasClosedLoop: currentMap.isNotEmpty,
      current: totalCurrent,
      componentCurrents: currentMap,
      componentVoltages: voltageMap,
      errorMessage: result.errorMessage,
      burnedComponentIds: result.burnedComponentIds,
      isShortCircuit: result.isShortCircuit,
    );
  }

  /// Verifica se um loop fechado existe (sem rodar simulação completa).
  bool hasClosedLoop() {
    final battery = _components.where((c) => c.type == ComponentType.battery).toList();
    if (battery.isEmpty) return false;

    // DFS simples para verificar conectividade
    final visited = <String>{};
    bool foundLoop = false;

    void dfs(String componentId, String terminal) {
      if (foundLoop) return;

      final comp = _components.firstWhere((c) => c.id == componentId);

      // Verificar se componente está bloqueado
      if (comp.type == ComponentType.switchComponent && !comp.isActive) return;

      final wires = _wires.where((w) =>
        (w.fromComponentId == componentId && w.fromTerminal == terminal) ||
        (w.toComponentId == componentId && w.toTerminal == terminal)
      ).toList();

      for (final wire in wires) {
        final nextId = wire.fromComponentId == componentId
            ? wire.toComponentId
            : wire.fromComponentId;
        final nextTerm = wire.fromComponentId == componentId
            ? wire.toTerminal
            : wire.fromTerminal;

        if (nextId == battery.first.id && nextTerm == 'A') {
          foundLoop = true;
          return;
        }

        if (visited.contains(nextId)) continue;
        visited.add(nextId);

        final outTerm = nextTerm == 'A' ? 'B' : 'A';
        dfs(nextId, outTerm);
        visited.remove(nextId);
      }
    }

    visited.add(battery.first.id);
    dfs(battery.first.id, 'B');

    return foundLoop;
  }
}
