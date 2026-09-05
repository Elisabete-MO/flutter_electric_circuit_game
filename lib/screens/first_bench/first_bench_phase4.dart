import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/circuit_validator.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';

/// Itens disponíveis na biblioteca controlada da Fase 4.
enum Phase4LibraryItem {
  battery9V,
  switchSPST,
  ledRed,
  resistor68,
  resistor680,
  resistor6800,
  wireTool,
  removeWireTool,
}

/// Modos de ferramenta ativos.
enum ActiveToolMode {
  none,
  wire,
  removeWire,
}

/// Previsão do estudante sobre o circuito.
enum StudentPrediction {
  safeAndLit,
  openCircuit,
  excessiveCurrent,
  shortCircuit,
}

/// Representa um componente posicionado livremente na bancada controlada da Fase 4.
class PlacedComponent {
  final String id;
  final Phase4LibraryItem item;
  Offset relativePos; // (0.0 a 1.0) relativo ao tamanho da prancheta
  bool isSwitchClosed;
  bool isLedReversed;

  PlacedComponent({
    required this.id,
    required this.item,
    required this.relativePos,
    this.isSwitchClosed = false, // Começa aberto conforme especificação
    this.isLedReversed = false,
  });

  PlacedComponent copyWith({
    String? id,
    Phase4LibraryItem? item,
    Offset? relativePos,
    bool? isSwitchClosed,
    bool? isLedReversed,
  }) {
    return PlacedComponent(
      id: id ?? this.id,
      item: item ?? this.item,
      relativePos: relativePos ?? this.relativePos,
      isSwitchClosed: isSwitchClosed ?? this.isSwitchClosed,
      isLedReversed: isLedReversed ?? this.isLedReversed,
    );
  }

  CircuitComponentKind get kind {
    return switch (item) {
      Phase4LibraryItem.battery9V => CircuitComponentKind.battery,
      Phase4LibraryItem.switchSPST => CircuitComponentKind.switchComponent,
      Phase4LibraryItem.ledRed => CircuitComponentKind.led,
      Phase4LibraryItem.resistor68 ||
      Phase4LibraryItem.resistor680 ||
      Phase4LibraryItem.resistor6800 =>
        CircuitComponentKind.resistor,
      _ => CircuitComponentKind.resistor,
    };
  }

  double get resistanceOhms {
    return switch (item) {
      Phase4LibraryItem.resistor68 => 68.0,
      Phase4LibraryItem.resistor680 => 680.0,
      Phase4LibraryItem.resistor6800 => 6800.0,
      _ => 0.0,
    };
  }

  String get label {
    return switch (item) {
      Phase4LibraryItem.battery9V => 'Bateria 9 V',
      Phase4LibraryItem.switchSPST => 'Interruptor',
      Phase4LibraryItem.ledRed => isLedReversed ? 'LED (Invertido)' : 'LED vermelho',
      Phase4LibraryItem.resistor68 => '68 Ω',
      Phase4LibraryItem.resistor680 => '680 Ω',
      Phase4LibraryItem.resistor6800 => '6,8 kΩ',
      Phase4LibraryItem.wireTool => 'Fio',
      Phase4LibraryItem.removeWireTool => 'Remover conexão',
    };
  }

  String get assetPath {
    return switch (item) {
      Phase4LibraryItem.battery9V => 'assets/components/battery.png',
      Phase4LibraryItem.switchSPST =>
        isSwitchClosed ? 'assets/components/switch_closed.png' : 'assets/components/switch_open.png',
      Phase4LibraryItem.ledRed => 'assets/components/led_off.png',
      Phase4LibraryItem.resistor68 ||
      Phase4LibraryItem.resistor680 ||
      Phase4LibraryItem.resistor6800 =>
        'assets/components/resistor.png',
      _ => 'assets/components/wires.png',
    };
  }
}

/// Snapshot para histórico de Desfazer (Undo)
class _Phase4Snapshot {
  final List<PlacedComponent> placed;
  final List<CircuitConnection> connections;

  _Phase4Snapshot({
    required List<PlacedComponent> placed,
    required List<CircuitConnection> connections,
  })  : placed = placed.map((c) => c.copyWith()).toList(),
        connections = List.from(connections);
}

/// Tela da Fase 4 — Bancada livre do Primeiro Estande
class FirstBenchPhase4 extends StatefulWidget {
  final VoidCallback onPhaseComplete;

  const FirstBenchPhase4({
    super.key,
    required this.onPhaseComplete,
  });

  @override
  State<FirstBenchPhase4> createState() => _FirstBenchPhase4State();
}

class _FirstBenchPhase4State extends State<FirstBenchPhase4> {
  // Estado da Bancada (Inicia COMPLETAMENTE vazia)
  final List<PlacedComponent> _placed = [];
  final List<CircuitConnection> _connections = [];
  final List<_Phase4Snapshot> _undoStack = [];

  ActiveToolMode _activeToolMode = ActiveToolMode.none;
  CircuitTerminal? _wireStartTerminal;
  Offset? _currentPointerPosition;

  bool _isEnergized = false;
  bool _maquetteBulbLit = false;
  bool _showResultPanel = false;
  CircuitValidationResult? _lastResult;

  StudentPrediction? _studentPrediction;
  int _hintLevel = 0;

  void _saveSnapshot() {
    _undoStack.add(_Phase4Snapshot(
      placed: _placed,
      connections: _connections,
    ));
    if (_undoStack.length > 20) {
      _undoStack.removeAt(0);
    }
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    final last = _undoStack.removeLast();
    setState(() {
      _placed.clear();
      _placed.addAll(last.placed.map((c) => c.copyWith()));
      _connections.clear();
      _connections.addAll(last.connections);
      _wireStartTerminal = null;
      _isEnergized = false;
      _maquetteBulbLit = false;
      _showResultPanel = false;
    });
  }

  void _clearBench() {
    _saveSnapshot();
    setState(() {
      _placed.clear();
      _connections.clear();
      _wireStartTerminal = null;
      _activeToolMode = ActiveToolMode.none;
      _isEnergized = false;
      _maquetteBulbLit = false;
      _showResultPanel = false;
      _lastResult = null;
    });
  }

  void _addComponentAtRelativePosition(Phase4LibraryItem item, Offset relativePos) {
    if (item == Phase4LibraryItem.wireTool) {
      setState(() {
        _activeToolMode = _activeToolMode == ActiveToolMode.wire
            ? ActiveToolMode.none
            : ActiveToolMode.wire;
        _wireStartTerminal = null;
      });
      return;
    }

    if (item == Phase4LibraryItem.removeWireTool) {
      setState(() {
        _activeToolMode = _activeToolMode == ActiveToolMode.removeWire
            ? ActiveToolMode.none
            : ActiveToolMode.removeWire;
        _wireStartTerminal = null;
      });
      return;
    }

    // Regras de limite para o Primeiro Estande
    if (item == Phase4LibraryItem.battery9V) {
      if (_placed.any((c) => c.item == Phase4LibraryItem.battery9V)) {
        _showMessage('O desafio utiliza apenas uma bateria por vez.');
        return;
      }
    } else if (item == Phase4LibraryItem.switchSPST) {
      if (_placed.any((c) => c.item == Phase4LibraryItem.switchSPST)) {
        _showMessage('O desafio utiliza apenas um interruptor por vez.');
        return;
      }
    } else if (item == Phase4LibraryItem.ledRed) {
      if (_placed.any((c) => c.item == Phase4LibraryItem.ledRed)) {
        _showMessage('O desafio utiliza apenas um LED por vez.');
        return;
      }
    } else if (item == Phase4LibraryItem.resistor68 ||
        item == Phase4LibraryItem.resistor680 ||
        item == Phase4LibraryItem.resistor6800) {
      final existingResistorIndex =
          _placed.indexWhere((c) => c.kind == CircuitComponentKind.resistor);

      if (existingResistorIndex != -1) {
        _saveSnapshot();
        setState(() {
          final old = _placed[existingResistorIndex];
          _placed[existingResistorIndex] = old.copyWith(
            item: item,
            relativePos: relativePos,
          );
          _isEnergized = false;
          _showResultPanel = false;
        });
        final name = item == Phase4LibraryItem.resistor68
            ? '68 Ω'
            : (item == Phase4LibraryItem.resistor680 ? '680 Ω' : '6,8 kΩ');
        _showMessage('Resistor substituído pelo de $name.');
        return;
      }
    }

    _saveSnapshot();
    final id = '${item.name}_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _placed.add(PlacedComponent(
        id: id,
        item: item,
        relativePos: Offset(
          relativePos.dx.clamp(0.08, 0.85),
          relativePos.dy.clamp(0.12, 0.85),
        ),
      ));
      _isEnergized = false;
      _showResultPanel = false;
    });
  }

  void _addComponentFromLibrary(Phase4LibraryItem item) {
    final count = _placed.length;
    final relX = 0.20 + (count % 3) * 0.20;
    final relY = 0.35 + (count ~/ 3) * 0.25;
    _addComponentAtRelativePosition(item, Offset(relX, relY));
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: const Color(0xFF0F2E23),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeComponent(PlacedComponent comp) {
    _saveSnapshot();
    setState(() {
      _placed.removeWhere((c) => c.id == comp.id);
      _connections.removeWhere(
          (conn) => conn.from.componentId == comp.id || conn.to.componentId == comp.id);
      if (_wireStartTerminal?.componentId == comp.id) {
        _wireStartTerminal = null;
      }
      _isEnergized = false;
      _showResultPanel = false;
    });
    _showMessage('${comp.label} removido(a).');
  }

  void _toggleSwitch(PlacedComponent comp) {
    if (comp.kind == CircuitComponentKind.switchComponent) {
      _saveSnapshot();
      setState(() {
        comp.isSwitchClosed = !comp.isSwitchClosed;
        _isEnergized = false;
        _showResultPanel = false;
      });
    }
  }

  void _toggleLedPolarity(PlacedComponent comp) {
    if (comp.kind == CircuitComponentKind.led) {
      _saveSnapshot();
      setState(() {
        comp.isLedReversed = !comp.isLedReversed;
        _isEnergized = false;
        _showResultPanel = false;
      });
    }
  }

  void _onTerminalTap(CircuitTerminal terminal) {
    if (_activeToolMode != ActiveToolMode.wire) return;

    setState(() {
      if (_wireStartTerminal == null) {
        _wireStartTerminal = terminal;
      } else {
        if (_wireStartTerminal != terminal &&
            _wireStartTerminal!.componentId != terminal.componentId) {
          // Verificar se a conexão já existe
          final exists = _connections.any((c) => c.connects(_wireStartTerminal!, terminal));
          if (!exists) {
            _saveSnapshot();
            _connections.add(CircuitConnection(_wireStartTerminal!, terminal));
            _isEnergized = false;
            _showResultPanel = false;
          }
        }
        _wireStartTerminal = null;
      }
    });
  }

  void _removeConnection(CircuitConnection conn) {
    _saveSnapshot();
    setState(() {
      _connections.removeWhere((c) => c == conn);
      _isEnergized = false;
      _showResultPanel = false;
    });
    _showMessage('Conexão removida.');
  }

  Offset _calculateTerminalPos(CircuitTerminal terminal, Size benchSize) {
    final comp = _placed.firstWhere(
      (c) => c.id == terminal.componentId,
      orElse: () => PlacedComponent(
        id: '',
        item: Phase4LibraryItem.battery9V,
        relativePos: const Offset(0.5, 0.5),
      ),
    );

    final absX = comp.relativePos.dx * benchSize.width;
    final absY = comp.relativePos.dy * benchSize.height;

    // Offsets relativos aos terminais na base do card do componente (100x85)
    if (terminal.name == 'pos' || terminal.name == 'anode' || terminal.name == 't1') {
      return Offset(absX - 25, absY + 30);
    } else {
      return Offset(absX + 25, absY + 30);
    }
  }

  CircuitGraph _buildGraph() {
    final circuitComps = _placed.map((p) {
      return CircuitComponentInstance(
        id: p.id,
        kind: p.kind,
        isSwitchClosed: p.isSwitchClosed,
        resistanceOhms: p.resistanceOhms,
      );
    }).toList();

    // Mapear conexões considerando inversão do LED se aplicável
    final adjustedConnections = _connections.map((c) {
      CircuitTerminal from = c.from;
      CircuitTerminal to = c.to;

      for (final p in _placed) {
        if (p.kind == CircuitComponentKind.led && p.isLedReversed) {
          if (from.componentId == p.id) {
            from = CircuitTerminal(p.id, from.name == 'anode' ? 'cathode' : 'anode');
          }
          if (to.componentId == p.id) {
            to = CircuitTerminal(p.id, to.name == 'anode' ? 'cathode' : 'anode');
          }
        }
      }
      return CircuitConnection(from, to);
    }).toList();

    return CircuitGraph(
      components: circuitComps,
      connections: adjustedConnections,
    );
  }

  void _startTestAndPrediction() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _buildPredictionDialog(),
    );
  }

  Widget _buildPredictionDialog() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: GlassContainer(
              borderRadius: 24,
              accentColor: const Color(0xFF00FF9D),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_rounded, color: Color(0xFF00FF9D), size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Previsão de Comportamento',
                          style: TextStyle(
                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'O que você acha que acontecerá quando o circuito for energizado?',
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPredictionOption(
                    setModalState,
                    StudentPrediction.safeAndLit,
                    'O LED acenderá normalmente e com segurança.',
                    Icons.lightbulb_rounded,
                  ),
                  _buildPredictionOption(
                    setModalState,
                    StudentPrediction.openCircuit,
                    'O LED permanecerá apagado (circuito aberto/incompleto).',
                    Icons.power_off_rounded,
                  ),
                  _buildPredictionOption(
                    setModalState,
                    StudentPrediction.excessiveCurrent,
                    'Haverá corrente excessiva (risco de queimar o LED).',
                    Icons.warning_amber_rounded,
                  ),
                  _buildPredictionOption(
                    setModalState,
                    StudentPrediction.shortCircuit,
                    'Existe risco de curto-circuito direto na bateria.',
                    Icons.flash_on_rounded,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('CANCELAR', style: TextStyle(color: Colors.white54, fontFamily: GoogleFonts.rajdhani().fontFamily, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _studentPrediction != null
                            ? () {
                                Navigator.of(context).pop();
                                _energizeAndEvaluate();
                              }
                            : null,
                        icon: const Icon(Icons.bolt_rounded),
                        label: Text(
                          'ENERGIZAR CIRCUITO',
                          style: TextStyle(
                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF9D),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPredictionOption(
    StateSetter setModalState,
    StudentPrediction value,
    String label,
    IconData icon,
  ) {
    final isSelected = _studentPrediction == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setModalState(() {
            _studentPrediction = value;
          });
          setState(() {});
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00FF9D).withValues(alpha: 0.15)
                : const Color(0xFF081C15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF00FF9D) : const Color(0xFF1E3A2F),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF00FF9D) : Colors.white54, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 13,
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Icon(
                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                color: isSelected ? const Color(0xFF00FF9D) : Colors.white38,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _energizeAndEvaluate() {
    final graph = _buildGraph();
    const validator = CircuitValidator();
    final result = validator.validate(graph);
    _lastResult = result;

    bool predictionWasCorrect = false;
    if (_studentPrediction != null) {
      switch (_studentPrediction!) {
        case StudentPrediction.safeAndLit:
          predictionWasCorrect = result.status == CircuitStatus.safeAndLit;
        case StudentPrediction.openCircuit:
          predictionWasCorrect =
              result.status == CircuitStatus.openCircuit || result.status == CircuitStatus.validButOpen;
        case StudentPrediction.excessiveCurrent:
          predictionWasCorrect = result.status == CircuitStatus.excessiveCurrent;
        case StudentPrediction.shortCircuit:
          predictionWasCorrect = result.status == CircuitStatus.shortCircuit;
      }
    }

    final isSuccess = result.status == CircuitStatus.safeAndLit;

    setState(() {
      _isEnergized = isSuccess;
      _maquetteBulbLit = isSuccess;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isSuccess,
        message: '${result.message}\n\n'
            '${_studentPrediction != null ? (predictionWasCorrect ? "Sua previsão estava CORRETA!" : "Sua previsão foi diferente do comportamento do circuito.") : ""}',
        onAction: () {
          Navigator.of(context).pop();
          if (isSuccess) {
            setState(() {
              _showResultPanel = true;
            });
            _showFinalQuestionDialog();
          } else {
            // Mantém a bancada intacta para correção imediata sem reiniciar!
            setState(() {
              _showResultPanel = false;
            });
          }
        },
      ),
    );
  }

  void _showFinalQuestionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: GlassContainer(
              borderRadius: 24,
              accentColor: const Color(0xFF00FF9D),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.help_outline_rounded, color: Color(0xFF00FF9D), size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Avaliação Final do Estande',
                        style: TextStyle(
                          fontFamily: GoogleFonts.rajdhani().fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Por que o LED apagará quando o interruptor for aberto?',
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFinalQuestionOption(
                    'Porque o caminho da corrente elétrica será interrompido.',
                    true,
                  ),
                  _buildFinalQuestionOption(
                    'Porque a bateria descarregará instantaneamente.',
                    false,
                  ),
                  _buildFinalQuestionOption(
                    'Porque o resistor consumirá toda a energia disponível.',
                    false,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinalQuestionOption(String optionText, bool isCorrect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).pop();
          if (isCorrect) {
            widget.onPhaseComplete();
          } else {
            _showMessage('Resposta incorreta. Tente analisar o caminho da corrente.');
            _showFinalQuestionDialog();
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1E3A2F)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFF081C15),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            optionText,
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  void _showHintDialog() {
    setState(() {
      _hintLevel = (_hintLevel % 3) + 1;
    });

    final hintText = switch (_hintLevel) {
      1 => 'Nível 1 — Conceitual:\nA corrente elétrica precisa percorrer um caminho fechado e contínuo saindo do polo (+) até retornar ao polo (-) da bateria.',
      2 => 'Nível 2 — Direcionada:\nConfira se o LED está com o ânodo no sentido da bateria (+), se o resistor selecionado é o de 680 Ω e se o interruptor está fechado.',
      _ => 'Nível 3 — Visual:\nObserve os terminais destacados na bancada e os fios conectando Bateria 9V → Interruptor → Resistor (680 Ω) → LED vermelho → Bateria (-).',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF081C15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF00FF9D)),
        ),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF00FF9D)),
            const SizedBox(width: 8),
            Text(
              'Dica Pedagógica ($_hintLevel/3)',
              style: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          hintText,
          style: TextStyle(
            fontFamily: GoogleFonts.outfit().fontFamily,
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ENTENDI', style: TextStyle(color: const Color(0xFF00FF9D), fontFamily: GoogleFonts.rajdhani().fontFamily, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 750;

        return Column(
          children: [
            // Cabeçalho da Fase 4
            _buildPhaseHeader(),

            // Área Principal: Bancada (Left) + Biblioteca Creme (Right)
            Expanded(
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 74, // ~74% Bancada
                          child: _buildWorkbenchArea(),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 280, // ~26% Biblioteca Creme
                          child: _buildLibraryPanel(),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          flex: 65,
                          child: _buildWorkbenchArea(),
                        ),
                        SizedBox(
                          height: 200,
                          child: _buildLibraryPanel(),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 8),

            // Rodapé de Ações Integrado
            _buildFooterActionPanel(),
          ],
        );
      },
    );
  }

  Widget _buildPhaseHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fase 4 — Bancada livre',
            style: TextStyle(
              fontFamily: GoogleFonts.rajdhani().fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Monte e teste o circuito que acenderá a primeira luz da maquete.',
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkbenchArea() {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, benchConstraints) {
            final benchSize = Size(benchConstraints.maxWidth, benchConstraints.maxHeight);

            return DragTarget<Phase4LibraryItem>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final localOffset = renderBox.globalToLocal(details.offset);
                  final relX = (localOffset.dx / benchSize.width).clamp(0.08, 0.85);
                  final relY = (localOffset.dy / benchSize.height).clamp(0.12, 0.85);
                  _addComponentAtRelativePosition(details.data, Offset(relX, relY));
                } else {
                  _addComponentFromLibrary(details.data);
                }
              },
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;

                return Listener(
                  onPointerMove: (event) {
                    if (_wireStartTerminal != null) {
                      setState(() {
                        _currentPointerPosition = event.localPosition;
                      });
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Fundo Técnico (background_fase_03_prancheta_tecnica.png)
                      Image.asset(
                        'assets/backgrounds/background_fase_03_prancheta_tecnica.png',
                        fit: BoxFit.cover,
                        width: benchSize.width,
                        height: benchSize.height,
                      ),

                      // Overlay visual quando arrastando um componente sobre a bancada
                      if (isHovering)
                        Container(
                          color: const Color(0xFF00FF9D).withValues(alpha: 0.08),
                        ),

                      // Fios Conectados e Prévia (Desenhados atrás dos componentes)
                      CustomPaint(
                        size: benchSize,
                        painter: _Phase4FreeWiresPainter(
                          connections: _connections,
                          placedComponents: _placed,
                          benchSize: benchSize,
                          activeToolMode: _activeToolMode,
                          wireStartTerminal: _wireStartTerminal,
                          currentPointerPos: _currentPointerPosition,
                          isEnergized: _isEnergized,
                        ),
                      ),

                      // Botões de Remoção Interativos sobre os fios quando a ferramenta "Remover conexão" estiver ativa
                      if (_activeToolMode == ActiveToolMode.removeWire)
                        ..._connections.map((conn) {
                          final p1 = _calculateTerminalPos(conn.from, benchSize);
                          final p2 = _calculateTerminalPos(conn.to, benchSize);
                          final controlX = (p1.dx + p2.dx) / 2;
                          final controlY = math.min(p1.dy, p2.dy) - 30;

                          final midX = 0.25 * p1.dx + 0.5 * controlX + 0.25 * p2.dx;
                          final midY = 0.25 * p1.dy + 0.5 * controlY + 0.25 * p2.dy;

                          return Positioned(
                            left: midX - 18,
                            top: midY - 18,
                            child: GestureDetector(
                              onTap: () => _removeConnection(conn),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
                              ),
                            ),
                          );
                        }),

                      // Soquete da 1ª Luz da Maquete (Top Right da bancada)
                      Positioned(
                        top: benchSize.height * 0.12,
                        right: benchSize.width * 0.08,
                        child: _buildMaquetteSocket(),
                      ),

                      // Componentes Posicionados Livremente
                      ..._placed.map((comp) => _buildPlacedComponentWidget(comp, benchSize)),

                      // Status Pill da Bancada (Bottom Right)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: _buildStatusPill(),
                      ),

                      // Painel Didático de Resultados (Quando energizado com sucesso)
                      if (_showResultPanel && _lastResult != null)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 180,
                          child: _buildDidacticResultPanel(),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMaquetteSocket() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              _maquetteBulbLit ? 'assets/components/bulb_on.png' : 'assets/components/bulb_off.png',
              width: 54,
              height: 54,
            ),
            if (_maquetteBulbLit)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withValues(alpha: 0.35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.8),
                      blurRadius: 24,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
          ),
          child: Text(
            '1º luz da maquete',
            style: TextStyle(
              fontFamily: GoogleFonts.rajdhani().fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFDE68A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill() {
    final text = _placed.isEmpty
        ? 'Bancada vazia'
        : '${_placed.length} componente(s) • ${_connections.length} fio(s)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF061A12).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E3A2F)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _placed.isEmpty ? Colors.grey : const Color(0xFF00FF9D),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacedComponentWidget(PlacedComponent comp, Size benchSize) {
    final absX = comp.relativePos.dx * benchSize.width;
    final absY = comp.relativePos.dy * benchSize.height;

    const cardWidth = 104.0;
    const cardHeight = 88.0;

    return Positioned(
      left: absX - (cardWidth / 2),
      top: absY - (cardHeight / 2),
      child: GestureDetector(
        onPanUpdate: (details) {
          _saveSnapshot();
          setState(() {
            final newDx = (absX + details.delta.dx) / benchSize.width;
            final newDy = (absY + details.delta.dy) / benchSize.height;
            comp.relativePos = Offset(newDx.clamp(0.08, 0.85), newDy.clamp(0.12, 0.85));
            _isEnergized = false;
            _showResultPanel = false;
          });
        },
        child: Container(
          width: cardWidth,
          height: cardHeight,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF091F17).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _activeToolMode == ActiveToolMode.wire
                  ? const Color(0xFF00FF9D)
                  : const Color(0xFF1E3A2F),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Nome e Botão Remover (Topo)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        comp.label,
                        style: TextStyle(
                          fontFamily: GoogleFonts.rajdhani().fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeComponent(comp),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Imagem / Ação Interativa Central
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 18),
                  child: GestureDetector(
                    onTap: () {
                      if (comp.kind == CircuitComponentKind.switchComponent) {
                        _toggleSwitch(comp);
                      } else if (comp.kind == CircuitComponentKind.led) {
                        _toggleLedPolarity(comp);
                      }
                    },
                    child: Image.asset(
                      comp.assetPath,
                      fit: BoxFit.contain,
                      height: 38,
                    ),
                  ),
                ),
              ),

              // Terminais Elétricos (Base do Componente)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTerminalWidget(comp, 'terminalA'),
                    _buildTerminalWidget(comp, 'terminalB'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalWidget(PlacedComponent comp, String termKey) {
    final termName = comp.kind == CircuitComponentKind.battery
        ? (termKey == 'terminalA' ? 'pos' : 'neg')
        : (comp.kind == CircuitComponentKind.led
            ? (termKey == 'terminalA' ? 'anode' : 'cathode')
            : (termKey == 'terminalA' ? 't1' : 't2'));

    final terminal = CircuitTerminal(comp.id, termName);
    final isSelected = _wireStartTerminal == terminal;
    final isWiringMode = _activeToolMode == ActiveToolMode.wire;

    final label = comp.kind == CircuitComponentKind.battery
        ? (termKey == 'terminalA' ? '+' : '−')
        : (comp.kind == CircuitComponentKind.led
            ? (termKey == 'terminalA' ? 'A' : 'K')
            : (termKey == 'terminalA' ? 'T1' : 'T2'));

    return GestureDetector(
      onTap: () => _onTerminalTap(terminal),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00FF9D)
              : (isWiringMode ? const Color(0xFF0A3B2A) : const Color(0xFF06150F)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00FF9D)
                : (isWiringMode ? const Color(0xFF00FF9D) : const Color(0xFF1E3A2F)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : (isWiringMode ? const Color(0xFF00FF9D) : Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryPanel() {
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE), // Painel creme idêntico à referência
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C4C3E), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peças disponíveis',
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A3326),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.05,
              children: [
                _buildLibraryCard(Phase4LibraryItem.battery9V, 'Bateria 9 V', 'assets/components/battery.png'),
                _buildLibraryCard(Phase4LibraryItem.switchSPST, 'Interruptor', 'assets/components/switch_open.png'),
                _buildLibraryCard(Phase4LibraryItem.ledRed, 'LED vermelho', 'assets/components/led_off.png'),
                _buildLibraryCard(Phase4LibraryItem.resistor68, '68 Ω', 'assets/components/resistor.png'),
                _buildLibraryCard(Phase4LibraryItem.resistor680, '680 Ω', 'assets/components/resistor.png'),
                _buildLibraryCard(Phase4LibraryItem.resistor6800, '6,8 kΩ', 'assets/components/resistor.png'),
                _buildLibraryCard(Phase4LibraryItem.wireTool, 'Fio', 'assets/components/wires.png', isTool: true),
                _buildLibraryCard(Phase4LibraryItem.removeWireTool, 'Remover conexão', null, isTool: true, toolIcon: Icons.content_cut_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryCard(
    Phase4LibraryItem item,
    String title,
    String? assetPath, {
    bool isTool = false,
    IconData? toolIcon,
  }) {
    final isSelectedTool = (item == Phase4LibraryItem.wireTool && _activeToolMode == ActiveToolMode.wire) ||
        (item == Phase4LibraryItem.removeWireTool && _activeToolMode == ActiveToolMode.removeWire);

    Widget cardWidget = InkWell(
      onTap: () => _addComponentFromLibrary(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelectedTool ? const Color(0xFFD8EADF) : const Color(0xFFEFEAD8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelectedTool ? const Color(0xFF1B4D3E) : const Color(0xFFD4CEBD),
            width: isSelectedTool ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (assetPath != null)
              Image.asset(assetPath, height: 32, fit: BoxFit.contain)
            else
              Icon(toolIcon ?? Icons.build_rounded, size: 28, color: const Color(0xFF1B4D3E)),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B4D3E),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

    if (isTool) {
      return cardWidget;
    }

    return Draggable<Phase4LibraryItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 100,
          height: 85,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF091F17).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00FF9D), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (assetPath != null)
                Image.asset(assetPath, height: 36, fit: BoxFit.contain),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: cardWidget,
      ),
      child: cardWidget,
    );
  }

  Widget _buildFooterActionPanel() {
    final hasComponents = _placed.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF082218),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A4D3B)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 750;
          return Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF00FF9D), size: 20),
              const SizedBox(width: 10),
              if (!isCompact)
                Expanded(
                  child: Text(
                    'Arraste os componentes para a bancada e conecte seus terminais.',
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _undoStack.isNotEmpty ? _undo : null,
                        icon: const Icon(Icons.undo_rounded, size: 16),
                        label: Text('Desfazer', style: TextStyle(fontFamily: GoogleFonts.rajdhani().fontFamily, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF1E3A2F)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: hasComponents ? _clearBench : null,
                        icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                        label: Text('Limpar bancada', style: TextStyle(fontFamily: GoogleFonts.rajdhani().fontFamily, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF1E3A2F)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: hasComponents ? _startTestAndPrediction : null,
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: Text('Testar circuito', style: TextStyle(fontFamily: GoogleFonts.rajdhani().fontFamily, fontWeight: FontWeight.bold)),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF9D),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showHintDialog,
                        icon: const Icon(Icons.help_outline_rounded, color: Colors.white70),
                        tooltip: 'Ajuda',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDidacticResultPanel() {
    final res = _lastResult!;

    return GlassContainer(
      borderRadius: 16,
      accentColor: const Color(0xFF00FF9D),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: Color(0xFF00FF9D), size: 18),
              const SizedBox(width: 8),
              Text(
                'PAINEL DE RESULTADOS DIDÁTICOS',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FF9D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResultMetric('Tensão Bateria', '9 V'),
              _buildResultMetric('LED Vd', '2 V'),
              _buildResultMetric('Resistor', '680 Ω'),
              _buildResultMetric('Corrente I', '${res.currentmA.toStringAsFixed(1)} mA'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Fórmula: I = (9 V − 2 V) ÷ 680 Ω ≈ 10,3 mA (Circuito seguro e funcional)',
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

/// Painter para desenhar conexões por fios em curvas suaves (Bezier)
class _Phase4FreeWiresPainter extends CustomPainter {
  final List<CircuitConnection> connections;
  final List<PlacedComponent> placedComponents;
  final Size benchSize;
  final ActiveToolMode activeToolMode;
  final CircuitTerminal? wireStartTerminal;
  final Offset? currentPointerPos;
  final bool isEnergized;

  _Phase4FreeWiresPainter({
    required this.connections,
    required this.placedComponents,
    required this.benchSize,
    required this.activeToolMode,
    required this.wireStartTerminal,
    required this.currentPointerPos,
    required this.isEnergized,
  });

  Offset _getTerminalPos(CircuitTerminal terminal) {
    final comp = placedComponents.firstWhere(
      (c) => c.id == terminal.componentId,
      orElse: () => PlacedComponent(
        id: '',
        item: Phase4LibraryItem.battery9V,
        relativePos: const Offset(0.5, 0.5),
      ),
    );

    final absX = comp.relativePos.dx * benchSize.width;
    final absY = comp.relativePos.dy * benchSize.height;

    // Offsets relativos aos terminais na base do card do componente (100x85)
    if (terminal.name == 'pos' || terminal.name == 'anode' || terminal.name == 't1') {
      return Offset(absX - 25, absY + 30);
    } else {
      return Offset(absX + 25, absY + 30);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = isEnergized ? const Color(0xFF00FF9D) : const Color(0xFFEDE7D7)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    // Desenhar fios existentes
    for (final conn in connections) {
      final p1 = _getTerminalPos(conn.from);
      final p2 = _getTerminalPos(conn.to);

      final path = Path();
      path.moveTo(p1.dx, p1.dy);

      final controlX = (p1.dx + p2.dx) / 2;
      final controlY = math.min(p1.dy, p2.dy) - 30;

      path.quadraticBezierTo(controlX, controlY, p2.dx, p2.dy);

      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, wirePaint);
    }

    // Prévia de fio durante criação
    if (wireStartTerminal != null && currentPointerPos != null) {
      final p1 = _getTerminalPos(wireStartTerminal!);
      final previewPaint = Paint()
        ..color = const Color(0xFF00FF9D)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(p1, currentPointerPos!, previewPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
