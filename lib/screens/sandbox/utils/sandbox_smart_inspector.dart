import '../../../models/first_step_component.dart';
import '../../../models/sandbox_state.dart';

enum DiagnosticSeverity {
  critical, // Erro grave (curto-circuito, componente queimado ou sobretensão iminente)
  warning,  // Alerta (nó flutuante, falta de resistor de proteção, carga alta)
  info,     // Informação (chave aberta, circuito em aberto)
  success,  // Sucesso (circuito funcionando de forma ideal e equilibrada)
}

class CircuitDiagnosticIssue {
  final String titlePt;
  final String titleEn;
  final String descriptionPt;
  final String descriptionEn;
  final DiagnosticSeverity severity;
  final String? componentId;
  final String? recommendationPt;
  final String? recommendationEn;

  const CircuitDiagnosticIssue({
    required this.titlePt,
    required this.titleEn,
    required this.descriptionPt,
    required this.descriptionEn,
    required this.severity,
    this.componentId,
    this.recommendationPt,
    this.recommendationEn,
  });
}

class SandboxSmartInspector {
  static List<CircuitDiagnosticIssue> analyzeCircuit(SandboxState state) {
    final issues = <CircuitDiagnosticIssue>[];

    // 1. Verificação de Fonte de Energia
    final powerSources = state.components.where((c) => c.type == ComponentType.battery || c.type == ComponentType.powerSupply).toList();
    if (powerSources.isEmpty) {
      issues.add(const CircuitDiagnosticIssue(
        titlePt: 'Sem Fonte de Energia',
        titleEn: 'No Power Source',
        descriptionPt: 'O circuito não possui nenhuma bateria ou fonte regulável conectada.',
        descriptionEn: 'The circuit does not have any battery or regulated power supply connected.',
        severity: DiagnosticSeverity.warning,
        recommendationPt: 'Adicione uma Bateria de 9V ou Fonte Regulável a partir da paleta de componentes.',
        recommendationEn: 'Add a 9V Battery or Power Supply from the component palette.',
      ));
      return issues;
    }

    // 2. Componentes Queimados
    if (state.burnedComponentIds.isNotEmpty) {
      for (final burnedId in state.burnedComponentIds) {
        final comp = state.components.where((c) => c.id == burnedId).firstOrNull;
        if (comp != null) {
          issues.add(CircuitDiagnosticIssue(
            titlePt: 'Componente Danificado',
            titleEn: 'Damaged Component',
            descriptionPt: 'O componente ${comp.type.name.toUpperCase()} sofreu sobrecarga e está queimado.',
            descriptionEn: 'The ${comp.type.name.toUpperCase()} component suffered overload and is burned out.',
            severity: DiagnosticSeverity.critical,
            componentId: comp.id,
            recommendationPt: 'Clique em "Substituir Componente" e verifique a resistência ou limitação de corrente.',
            recommendationEn: 'Click "Replace Component" and check resistance or current limiting.',
          ));
        }
      }
    }

    // 3. Verificação de Nós Flutuantes (Terminais desconectados)
    for (final comp in state.components) {
      final termAWires = state.wires.where((w) => (w.fromComponentId == comp.id && w.fromTerminal == 'A') || (w.toComponentId == comp.id && w.toTerminal == 'A')).toList();
      final termBWires = state.wires.where((w) => (w.fromComponentId == comp.id && w.fromTerminal == 'B') || (w.toComponentId == comp.id && w.toTerminal == 'B')).toList();

      if (termAWires.isEmpty || termBWires.isEmpty) {
        final missingTerm = termAWires.isEmpty ? 'A' : 'B';
        issues.add(CircuitDiagnosticIssue(
          titlePt: 'Nó Flutuante / Terminal Desconectado',
          titleEn: 'Floating Node / Disconnected Terminal',
          descriptionPt: 'O terminal $missingTerm do componente ${comp.type.name.toUpperCase()} não possui nenhum fio ligado.',
          descriptionEn: 'Terminal $missingTerm of ${comp.type.name.toUpperCase()} has no wire connected.',
          severity: DiagnosticSeverity.warning,
          componentId: comp.id,
          recommendationPt: 'Conecte um fio no terminal $missingTerm para fechar o caminho elétrico.',
          recommendationEn: 'Connect a wire to terminal $missingTerm to complete the circuit path.',
        ));
      }
    }

    // 4. Análise de LED sem Resistor em Série
    final leds = state.components.where((c) => c.type == ComponentType.led).toList();
    for (final led in leds) {
      final source = powerSources.first;
      final sourceVoltage = source.value;
      if (sourceVoltage > 3.3) {
        final hasResistor = state.components.any((c) => c.type == ComponentType.resistor || c.type == ComponentType.potentiometer);
        if (!hasResistor) {
          issues.add(CircuitDiagnosticIssue(
            titlePt: 'LED Sem Resistor Limitador',
            titleEn: 'LED Without Current Limiting Resistor',
            descriptionPt: 'O LED está conectado a uma fonte de ${sourceVoltage.toStringAsFixed(1)}V sem resistor limitador em série.',
            descriptionEn: 'The LED is connected to a ${sourceVoltage.toStringAsFixed(1)}V source without a current limiting resistor.',
            severity: DiagnosticSeverity.critical,
            componentId: led.id,
            recommendationPt: 'Adicione um resistor de 220Ω ou potenciômetro em série com o LED para evitar a queima.',
            recommendationEn: 'Add a 220Ω resistor or potentiometer in series with the LED to prevent burnout.',
          ));
        }
      }
    }

    // 5. Interrupção por Chave Aberta
    final switches = state.components.where((c) => c.type == ComponentType.switchComponent).toList();
    for (final sw in switches) {
      if (!sw.isActive) {
        issues.add(CircuitDiagnosticIssue(
          titlePt: 'Interruptor Aberto',
          titleEn: 'Switch Open',
          descriptionPt: 'O interruptor está aberto, interrompendo a circulação de elétrons.',
          descriptionEn: 'The switch is open, interrupting the electron flow.',
          severity: DiagnosticSeverity.info,
          componentId: sw.id,
          recommendationPt: 'Feche o interruptor tocando nele para energizar o circuito.',
          recommendationEn: 'Close the switch by tapping it to energize the circuit.',
        ));
      }
    }

    // 6. Dissipação Térmica Elevada em Simulação
    if (state.isSimulating) {
      for (final comp in state.components) {
        final power = state.simulationValues['power_${comp.id}'] ?? 0.0;
        if (power > 10.0 && comp.type != ComponentType.battery && comp.type != ComponentType.powerSupply) {
          issues.add(CircuitDiagnosticIssue(
            titlePt: 'Aquecimento Térmico Elevado',
            titleEn: 'High Thermal Heat Dissipation',
            descriptionPt: 'O componente ${comp.type.name.toUpperCase()} está dissipando ${power.toStringAsFixed(1)}W de potência.',
            descriptionEn: 'The ${comp.type.name.toUpperCase()} component is dissipating ${power.toStringAsFixed(1)}W of power.',
            severity: DiagnosticSeverity.warning,
            componentId: comp.id,
            recommendationPt: 'Aumente a resistência do circuito para reduzir o aquecimento térmico.',
            recommendationEn: 'Increase circuit resistance to lower thermal heating.',
          ));
        }
      }
    }

    // 7. Circuito Perfeito / Sem Erros
    if (issues.isEmpty) {
      issues.add(const CircuitDiagnosticIssue(
        titlePt: 'Circuito Saudável & Equilibrado',
        titleEn: 'Healthy & Balanced Circuit',
        descriptionPt: 'Nenhuma falha de fiação ou sobretensão foi detectada no circuito.',
        descriptionEn: 'No wiring faults or overvoltage detected in the circuit.',
        severity: DiagnosticSeverity.success,
        recommendationPt: 'Inicie a simulação para observar o fluxo de corrente nos instrumentos.',
        recommendationEn: 'Start simulation to observe current flow on measurement instruments.',
      ));
    }

    return issues;
  }
}
