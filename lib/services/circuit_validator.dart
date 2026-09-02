import 'package:flutter/foundation.dart';

/// Tipos de componentes aceitos na validação didática do Estande 1.
enum CircuitComponentKind {
  battery,
  switchComponent,
  resistor,
  led,
}

/// Representa um terminal de um componente no circuito.
@immutable
class CircuitTerminal {
  final String componentId;
  final String name; // ex: 'pos', 'neg', 'in', 'out', 'anode', 'cathode'

  const CircuitTerminal(this.componentId, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircuitTerminal &&
          other.componentId == componentId &&
          other.name == name;

  @override
  int get hashCode => Object.hash(componentId, name);

  @override
  String toString() => '$componentId.$name';
}

/// Representa um componente instanciado na bancada.
@immutable
class CircuitComponentInstance {
  final String id;
  final CircuitComponentKind kind;
  final bool isSwitchClosed;
  final double resistanceOhms; // ex: 68, 680, 6800

  const CircuitComponentInstance({
    required this.id,
    required this.kind,
    this.isSwitchClosed = true,
    this.resistanceOhms = 680.0,
  });

  CircuitTerminal get terminalA {
    return switch (kind) {
      CircuitComponentKind.battery => CircuitTerminal(id, 'pos'),
      CircuitComponentKind.led => CircuitTerminal(id, 'anode'),
      _ => CircuitTerminal(id, 't1'),
    };
  }

  CircuitTerminal get terminalB {
    return switch (kind) {
      CircuitComponentKind.battery => CircuitTerminal(id, 'neg'),
      CircuitComponentKind.led => CircuitTerminal(id, 'cathode'),
      _ => CircuitTerminal(id, 't2'),
    };
  }
}

/// Conexão de fio entre dois terminais.
@immutable
class CircuitConnection {
  final CircuitTerminal from;
  final CircuitTerminal to;

  const CircuitConnection(this.from, this.to);

  bool connects(CircuitTerminal a, CircuitTerminal b) {
    return (from == a && to == b) || (from == b && to == a);
  }
}

/// Grafo completo do circuito montado.
@immutable
class CircuitGraph {
  final List<CircuitComponentInstance> components;
  final List<CircuitConnection> connections;

  const CircuitGraph({
    required this.components,
    required this.connections,
  });
}

/// Status do resultado da validação elétrica.
enum CircuitStatus {
  safeAndLit,
  validButOpen,
  reversedLed,
  excessiveCurrent,
  lowCurrent,
  missingResistor,
  openCircuit,
  shortCircuit,
}

/// Resultado detalhado da validação elétrica com feedback pedagógico.
@immutable
class CircuitValidationResult {
  final CircuitStatus status;
  final String message;
  final String? relatedComponentId;
  final bool energizationAllowed;
  final double currentmA;

  const CircuitValidationResult({
    required this.status,
    required this.message,
    this.relatedComponentId,
    required this.energizationAllowed,
    this.currentmA = 0.0,
  });
}

/// Serviço de validação de circuitos para o Estande 1.
/// Valida conexões elétricas e topologia em série, independente de posições visuais.
class CircuitValidator {
  const CircuitValidator();

  CircuitValidationResult validate(CircuitGraph graph) {
    // 1. Localizar bateria
    final battery = graph.components
        .where((c) => c.kind == CircuitComponentKind.battery)
        .firstOrNull;

    if (battery == null) {
      return const CircuitValidationResult(
        status: CircuitStatus.openCircuit,
        message: 'Adicione uma bateria para fornecer energia ao circuito.',
        energizationAllowed: false,
      );
    }

    final posTerm = battery.terminalA;
    final negTerm = battery.terminalB;

    // 2. Verificar curto-circuito (conexão direta entre pos e neg sem componentes de carga)
    if (_hasDirectConnection(graph, posTerm, negTerm)) {
      return CircuitValidationResult(
        status: CircuitStatus.shortCircuit,
        message:
            'Atenção! Curto-circuito detectado: os polos da bateria estão ligados diretamente. Isso causará sobreaquecimento.',
        relatedComponentId: battery.id,
        energizationAllowed: false,
      );
    }

    // 3. Buscar caminhos da bateria (+) até a bateria (-)
    final paths = _findPaths(graph, posTerm, negTerm);
    if (paths.isEmpty) {
      return const CircuitValidationResult(
        status: CircuitStatus.openCircuit,
        message:
            'Circuito aberto ou incompleto. Verifique se todos os fios conectam os terminais.',
        energizationAllowed: false,
      );
    }

    // Analisar o caminho principal encontrado
    final path = paths.first;

    // Verificar se há interruptor aberto no caminho
    bool hasOpenSwitch = false;
    String? openSwitchId;
    for (final comp in path.componentsInPath) {
      if (comp.kind == CircuitComponentKind.switchComponent && !comp.isSwitchClosed) {
        hasOpenSwitch = true;
        openSwitchId = comp.id;
        break;
      }
    }

    // Verificar LED e sua polaridade
    final led = path.componentsInPath
        .where((c) => c.kind == CircuitComponentKind.led)
        .firstOrNull;

    if (led == null) {
      return const CircuitValidationResult(
        status: CircuitStatus.openCircuit,
        message: 'O circuito precisa de um LED para acender o primeiro ponto da maquete.',
        energizationAllowed: false,
      );
    }

    // Verificar se a corrente entra no ânodo e sai pelo cátodo
    final isLedReversed = !path.isLedCorrectlyOriented(led);
    if (isLedReversed) {
      return CircuitValidationResult(
        status: CircuitStatus.reversedLed,
        message:
            'O LED está invertido! A corrente elétrica só flui do ânodo (+) para o cátodo (-). Vire o LED para acender.',
        relatedComponentId: led.id,
        energizationAllowed: false,
      );
    }

    // Verificar Resistor
    final resistor = path.componentsInPath
        .where((c) => c.kind == CircuitComponentKind.resistor)
        .firstOrNull;

    if (resistor == null) {
      return const CircuitValidationResult(
        status: CircuitStatus.missingResistor,
        message:
            'Cuidado! O LED precisa de um resistor em série para limitar a corrente e evitar ser queimado.',
        energizationAllowed: false,
      );
    }

    // Cálculo da corrente: I = (9V - 2V) / R (Tensão típica do LED = 2V)
    final resistance = resistor.resistanceOhms;
    final currentAmperes = (9.0 - 2.0) / resistance;
    final currentmA = currentAmperes * 1000.0;

    // Avaliação do valor do resistor
    if (resistance < 100.0) {
      // Ex: 68 ohms -> ~102.9 mA (excessiva)
      return CircuitValidationResult(
        status: CircuitStatus.excessiveCurrent,
        message:
            'Resistor muito baixo (68 Ω)! A corrente aproximada seria de ${currentmA.toStringAsFixed(1)} mA, o que danificaria o LED.',
        relatedComponentId: resistor.id,
        energizationAllowed: false,
        currentmA: currentmA,
      );
    } else if (resistance > 2000.0) {
      // Ex: 6.8k ohms -> ~1.03 mA (muito baixa)
      return CircuitValidationResult(
        status: CircuitStatus.lowCurrent,
        message:
            'Resistor muito alto (6,8 kΩ). A corrente de ${currentmA.toStringAsFixed(2)} mA é muito fraca para acender o LED.',
        relatedComponentId: resistor.id,
        energizationAllowed: false,
        currentmA: currentmA,
      );
    }

    // Resistor correto (ex: 680 ohms -> ~10.3 mA)
    if (hasOpenSwitch) {
      return CircuitValidationResult(
        status: CircuitStatus.validButOpen,
        message:
            'Circuito correto e seguro! Porém o interruptor está aberto, impedindo o fluxo de corrente.',
        relatedComponentId: openSwitchId,
        energizationAllowed: true,
        currentmA: 0.0,
      );
    }

    return CircuitValidationResult(
      status: CircuitStatus.safeAndLit,
      message:
          'Parabéns! Circuito seguro e funcional (I ≈ ${currentmA.toStringAsFixed(1)} mA). O LED e a maquete acenderam!',
      relatedComponentId: led.id,
      energizationAllowed: true,
      currentmA: currentmA,
    );
  }

  /// Verifica se há ligação direta por fios entre dois terminais sem passar por outros componentes
  bool _hasDirectConnection(
      CircuitGraph graph, CircuitTerminal start, CircuitTerminal end) {
    final visited = <CircuitTerminal>{};
    final queue = <CircuitTerminal>[start];

    while (queue.isNotEmpty) {
      final curr = queue.removeAt(0);
      if (curr == end) return true;
      visited.add(curr);

      for (final conn in graph.connections) {
        CircuitTerminal? next;
        if (conn.from == curr) next = conn.to;
        if (conn.to == curr) next = conn.from;

        if (next != null && !visited.contains(next)) {
          // Se o próximo terminal for da bateria pos/neg diretamente
          if (next == end) return true;
          // Se for terminal do mesmo componente (e não for fio), interrompe o curto direto
          if (next.componentId != start.componentId && next.componentId != end.componentId) {
            // passa por um componente
          } else {
            queue.add(next);
          }
        }
      }
    }
    return false;
  }

  /// Busca caminhos da bateria (+) até a bateria (-)
  List<_CircuitPath> _findPaths(
      CircuitGraph graph, CircuitTerminal start, CircuitTerminal end) {
    final results = <_CircuitPath>[];
    final compMap = {for (final c in graph.components) c.id: c};

    void dfs(
      CircuitTerminal currentTerminal,
      List<CircuitTerminal> visitedTerminals,
      List<CircuitComponentInstance> visitedComponents,
      List<CircuitTerminal> enterExitOrder,
    ) {
      if (currentTerminal == end) {
        results.add(_CircuitPath(
          terminalsPath: List.from(visitedTerminals),
          componentsInPath: List.from(visitedComponents),
          enterExitOrder: List.from(enterExitOrder),
        ));
        return;
      }

      // 1. Mover dentro do mesmo componente
      final currComp = compMap[currentTerminal.componentId];
      if (currComp != null && currComp.kind != CircuitComponentKind.battery) {
        final otherTerm = (currentTerminal == currComp.terminalA)
            ? currComp.terminalB
            : currComp.terminalA;

        if (!visitedTerminals.contains(otherTerm)) {
          final nextComponents = visitedComponents.contains(currComp)
              ? visitedComponents
              : [...visitedComponents, currComp];

          dfs(
            otherTerm,
            [...visitedTerminals, otherTerm],
            nextComponents,
            [...enterExitOrder, currentTerminal, otherTerm],
          );
        }
      }

      // 2. Mover através de fios (conexões externas)
      for (final conn in graph.connections) {
        CircuitTerminal? next;
        if (conn.from == currentTerminal) next = conn.to;
        if (conn.to == currentTerminal) next = conn.from;

        if (next != null && !visitedTerminals.contains(next)) {
          dfs(
            next,
            [...visitedTerminals, next],
            visitedComponents,
            enterExitOrder,
          );
        }
      }
    }

    dfs(start, [start], [], [start]);
    return results;
  }
}

class _CircuitPath {
  final List<CircuitTerminal> terminalsPath;
  final List<CircuitComponentInstance> componentsInPath;
  final List<CircuitTerminal> enterExitOrder;

  _CircuitPath({
    required this.terminalsPath,
    required this.componentsInPath,
    required this.enterExitOrder,
  });

  bool isLedCorrectlyOriented(CircuitComponentInstance led) {
    // Localizar a entrada no LED na ordem de percurso
    for (int i = 0; i < enterExitOrder.length - 1; i++) {
      final entry = enterExitOrder[i];
      final exit = enterExitOrder[i + 1];

      if (entry.componentId == led.id) {
        // Se entrou pelo ânodo e saiu pelo cátodo -> correto
        return entry.name == 'anode' && exit.name == 'cathode';
      }
    }
    return false;
  }
}
