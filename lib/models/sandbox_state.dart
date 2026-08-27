import 'sandbox_component.dart';
import 'sandbox_wire.dart';

class SandboxState {
  const SandboxState({
    this.components = const [],
    this.wires = const [],
    this.isSimulating = false,
    this.errorMessage,
    this.simulationValues = const {},
    this.burnedComponentIds = const {},
  });

  final List<SandboxComponent> components;
  final List<SandboxWire> wires;
  final bool isSimulating;
  final String? errorMessage;
  final Map<String, double> simulationValues; // values like current (Amps) or voltage drop (Volts) for components
  final Set<String> burnedComponentIds; // IDs of components overloaded/burned out

  SandboxState copyWith({
    List<SandboxComponent>? components,
    List<SandboxWire>? wires,
    bool? isSimulating,
    String? errorMessage,
    Map<String, double>? simulationValues,
    Set<String>? burnedComponentIds,
  }) {
    return SandboxState(
      components: components ?? this.components,
      wires: wires ?? this.wires,
      isSimulating: isSimulating ?? this.isSimulating,
      errorMessage: errorMessage, // can be set to null explicitly by passing null
      simulationValues: simulationValues ?? this.simulationValues,
      burnedComponentIds: burnedComponentIds ?? this.burnedComponentIds,
    );
  }
}
