import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/circuit_validator.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import 'second_bench_tokens.dart';
import 'widgets/second_bench_action_bar.dart';
import 'widgets/second_bench_item_grid.dart';
import 'widgets/second_bench_phase_scaffold.dart';
import 'widgets/second_bench_side_panel.dart';

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

/// Componente posicionado na bancada da Fase 4.
class PlacedComponent {
  final String id;
  final Phase4LibraryItem item;
  Offset relativePos;
  bool isSwitchClosed;
  bool isLedReversed;

  PlacedComponent({
    required this.id,
    required this.item,
    required this.relativePos,
    this.isSwitchClosed = false,
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
      Phase4LibraryItem.wireTool => 'Ferramenta Fio',
      Phase4LibraryItem.removeWireTool => 'Remover Conexão',
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

class _Phase4Snapshot {
  final List<PlacedComponent> placed;
  final List<CircuitConnection> connections;

  _Phase4Snapshot({
    required List<PlacedComponent> placed,
    required List<CircuitConnection> connections,
  })  : placed = placed.map((c) => c.copyWith()).toList(),
        connections = List.from(connections);
}

/// Tela da Fase 4 do Segundo Estande (Acende Aí): Bancada livre.
class SecondBenchPhase4 extends StatefulWidget {
  final VoidCallback onPhaseComplete;

  const SecondBenchPhase4({
    super.key,
    required this.onPhaseComplete,
  });

  @override
  State<SecondBenchPhase4> createState() => _SecondBenchPhase4State();
}

class _SecondBenchPhase4State extends State<SecondBenchPhase4> {
  final List<PlacedComponent> _placed = [];
  final List<CircuitConnection> _connections = [];
  final List<_Phase4Snapshot> _undoStack = [];

  ActiveToolMode _activeToolMode = ActiveToolMode.none;
  CircuitTerminal? _wireStartTerminal;

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
    });
  }

  void _clearBench() {
    _saveSnapshot();
    setState(() {
      _placed.clear();
      _connections.clear();
      _wireStartTerminal = null;
      _activeToolMode = ActiveToolMode.none;
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
      final existingIndex = _placed.indexWhere((c) => c.kind == CircuitComponentKind.resistor);

      if (existingIndex != -1) {
        _saveSnapshot();
        setState(() {
          final old = _placed[existingIndex];
          _placed[existingIndex] = old.copyWith(
            item: item,
            relativePos: relativePos,
          );
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
          relativePos.dx.clamp(0.12, 0.85),
          relativePos.dy.clamp(0.15, 0.85),
        ),
      ));
    });
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
    });
    _showMessage('${comp.label} removido(a).');
  }

  void _toggleSwitch(PlacedComponent comp) {
    if (comp.kind == CircuitComponentKind.switchComponent) {
      _saveSnapshot();
      setState(() {
        comp.isSwitchClosed = !comp.isSwitchClosed;
      });
    }
  }

  void _toggleLedPolarity(PlacedComponent comp) {
    if (comp.kind == CircuitComponentKind.led) {
      _saveSnapshot();
      setState(() {
        comp.isLedReversed = !comp.isLedReversed;
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
          final exists = _connections.any((c) => c.connects(_wireStartTerminal!, terminal));
          if (!exists) {
            _saveSnapshot();
            _connections.add(CircuitConnection(_wireStartTerminal!, terminal));
          }
        }
        _wireStartTerminal = null;
      }
    });
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

    final isSuccess = result.status == CircuitStatus.safeAndLit;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isSuccess,
        message: result.message,
        onAction: () {
          Navigator.of(context).pop();
          if (isSuccess) {
            _showFinalQuestionDialog();
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

  void _showHelpModal() {
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
      builder: (context) => KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: (event) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        },
        child: AlertDialog(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SecondBenchPhaseScaffold(
      phase: 4,
      title: 'Bancada livre',
      instruction: 'Monte o circuito livremente, conecte os fios e teste seu funcionamento.',
      introIcon: Icons.handyman_rounded,
      backgroundAsset: 'assets/backgrounds/background_fase_03_prancheta_tecnica.png',
      onHelpTap: _showHelpModal,
      workspace: _buildBenchWorkspace(),
      sidePanel: _buildSidePanel(),
      actionBar: SecondBenchActionBar(
        statusText: _placed.isEmpty
            ? 'Arraste componentes da biblioteca para começar.'
            : 'Modo ativo: ${_activeToolMode == ActiveToolMode.wire ? "Conectar fios" : (_activeToolMode == ActiveToolMode.removeWire ? "Remover conexões" : "Posicionamento")}',
        progressText: '${_placed.length} componentes, ${_connections.length} fios',
        actions: [
          OutlinedButton.icon(
            onPressed: _undoStack.isNotEmpty ? _undo : null,
            icon: const Icon(Icons.undo_rounded, size: 18),
            label: const Text('Desfazer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white30),
            ),
          ),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: _placed.isNotEmpty ? _clearBench : null,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Limpar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white30),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _placed.length >= 3 ? _startTestAndPrediction : null,
            icon: const Icon(Icons.bolt_rounded),
            label: Text(
              'TESTAR CIRCUITO',
              style: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: SecondBenchLayoutTokens.primaryGreen,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white12,
              disabledForegroundColor: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WORKSPACE DA BANCADA LIVRE (73-75% de largura no Desktop)
  // ==========================================
  Widget _buildBenchWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final benchSize = Size(constraints.maxWidth, constraints.maxHeight);

        return DragTarget<Phase4LibraryItem>(
          onAcceptWithDetails: (details) {
            final box = context.findRenderObject() as RenderBox?;
            if (box != null) {
              final localPos = box.globalToLocal(details.offset);
              final relPos = Offset(
                localPos.dx / benchSize.width,
                localPos.dy / benchSize.height,
              );
              _addComponentAtRelativePosition(details.data, relPos);
            }
          },
          builder: (context, candidateData, rejectedData) {
            return Stack(
              children: [
                // Renderização de Fios Desenhados
                CustomPaint(
                  size: benchSize,
                  painter: _Phase4WirePainter(
                    connections: _connections,
                    calculateTerminalPos: (term) => _calculateTerminalPos(term, benchSize),
                    activeWireStartPos: _wireStartTerminal != null
                        ? _calculateTerminalPos(_wireStartTerminal!, benchSize)
                        : null,
                  ),
                ),

                // Componentes Posicionados
                ..._placed.map((comp) {
                  final absX = comp.relativePos.dx * benchSize.width;
                  final absY = comp.relativePos.dy * benchSize.height;

                  return Positioned(
                    left: absX - 40,
                    top: absY - 40,
                    child: GestureDetector(
                      onLongPress: () => _removeComponent(comp),
                      onTap: () {
                        if (comp.kind == CircuitComponentKind.switchComponent) {
                          _toggleSwitch(comp);
                        } else if (comp.kind == CircuitComponentKind.led) {
                          _toggleLedPolarity(comp);
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: SecondBenchLayoutTokens.primaryGreen.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Image.asset(
                              comp.assetPath,
                              width: 64,
                              height: 64,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F3D30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              comp.label,
                              style: TextStyle(
                                fontFamily: GoogleFonts.rajdhani().fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Terminais Clicáveis dos Componentes para Fiação
                ..._placed.expand((comp) {
                  final term1 = CircuitTerminal(comp.id, comp.kind == CircuitComponentKind.battery ? 'pos' : (comp.kind == CircuitComponentKind.led ? 'anode' : 't1'));
                  final term2 = CircuitTerminal(comp.id, comp.kind == CircuitComponentKind.battery ? 'neg' : (comp.kind == CircuitComponentKind.led ? 'cathode' : 't2'));

                  final pos1 = _calculateTerminalPos(term1, benchSize);
                  final pos2 = _calculateTerminalPos(term2, benchSize);

                  return [
                    _buildTerminalWidget(term1, pos1),
                    _buildTerminalWidget(term2, pos2),
                  ];
                }),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTerminalWidget(CircuitTerminal term, Offset pos) {
    final isSelected = _wireStartTerminal == term;

    return Positioned(
      left: pos.dx - 12,
      top: pos.dy - 12,
      child: GestureDetector(
        onTap: () => _onTerminalTap(term),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isSelected ? SecondBenchLayoutTokens.accentGreen : const Color(0xFF10B981),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PAINEL LATERAL COM GRADE DE COMPONENTES FÍSICOS (Escala Aumentada)
  // ==========================================
  Widget _buildSidePanel() {
    final libraryGridItems = [
      const SecondBenchGridItemData(
        id: 'lib_battery',
        value: Phase4LibraryItem.battery9V,
        label: 'Bateria 9 V',
        assetPath: 'assets/components/battery.png',
        badgeText: '9V Fonte',
      ),
      const SecondBenchGridItemData(
        id: 'lib_switch',
        value: Phase4LibraryItem.switchSPST,
        label: 'Interruptor SPST',
        assetPath: 'assets/components/switch_open.png',
      ),
      const SecondBenchGridItemData(
        id: 'lib_led',
        value: Phase4LibraryItem.ledRed,
        label: 'LED vermelho',
        assetPath: 'assets/components/led_off.png',
      ),
      const SecondBenchGridItemData(
        id: 'lib_r680',
        value: Phase4LibraryItem.resistor680,
        label: 'Resistor 680 Ω',
        assetPath: 'assets/components/resistor.png',
        badgeText: 'Ideal',
        badgeColor: SecondBenchLayoutTokens.primaryGreen,
      ),
      const SecondBenchGridItemData(
        id: 'lib_r68',
        value: Phase4LibraryItem.resistor68,
        label: 'Resistor 68 Ω',
        assetPath: 'assets/components/resistor.png',
        badgeText: 'Baixo',
        badgeColor: Color(0xFFD97706),
      ),
      const SecondBenchGridItemData(
        id: 'lib_r6800',
        value: Phase4LibraryItem.resistor6800,
        label: 'Resistor 6,8 kΩ',
        assetPath: 'assets/components/resistor.png',
        badgeText: 'Alto',
        badgeColor: Color(0xFFD97706),
      ),
      SecondBenchGridItemData(
        id: 'lib_wire',
        value: Phase4LibraryItem.wireTool,
        label: 'Ferramenta Fio',
        assetPath: 'assets/components/wires.png',
        isSelected: _activeToolMode == ActiveToolMode.wire,
      ),
      SecondBenchGridItemData(
        id: 'lib_remove_wire',
        value: Phase4LibraryItem.removeWireTool,
        label: 'Remover Conexão',
        customPainterWidget: const Icon(Icons.content_cut_rounded, size: 36, color: Color(0xFFEF4444)),
        isSelected: _activeToolMode == ActiveToolMode.removeWire,
      ),
    ];

    return SecondBenchSidePanel(
      title: 'Biblioteca de Peças',
      subtitle: 'Arraste os componentes para a bancada para montar o circuito.',
      icon: Icons.inventory_2_rounded,
      child: SecondBenchItemGrid<Phase4LibraryItem>(
        items: libraryGridItems,
        assetHeight: 64, // Escala perceptiva aumentada para excelente visibilidade
        onItemTap: (item) {
          _addComponentFromLibrary(item.value);
        },
      ),
    );
  }

  void _addComponentFromLibrary(Phase4LibraryItem item) {
    final count = _placed.length;
    final relX = 0.20 + (count % 3) * 0.22;
    final relY = 0.30 + (count ~/ 3) * 0.28;
    _addComponentAtRelativePosition(item, Offset(relX, relY));
  }
}

class _Phase4WirePainter extends CustomPainter {
  final List<CircuitConnection> connections;
  final Offset Function(CircuitTerminal) calculateTerminalPos;
  final Offset? activeWireStartPos;

  _Phase4WirePainter({
    required this.connections,
    required this.calculateTerminalPos,
    this.activeWireStartPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    for (final conn in connections) {
      final p1 = calculateTerminalPos(conn.from);
      final p2 = calculateTerminalPos(conn.to);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _Phase4WirePainter oldDelegate) => true;
}
