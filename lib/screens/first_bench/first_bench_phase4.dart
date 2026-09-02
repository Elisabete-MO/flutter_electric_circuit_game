import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/circuit_validator.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/prof_volts_speech.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';

/// Item disponível na biblioteca controlada da Fase 4.
enum Phase4LibraryItem {
  battery9V,
  switchSPST,
  ledRed,
  resistor68,
  resistor680,
  resistor6800,
  wire,
}

/// Representa um componente posicionado livremente na bancada controlada.
class PlacedComponent {
  final String id;
  final Phase4LibraryItem item;
  Offset position;
  bool isSwitchClosed;
  bool isLedReversed;

  PlacedComponent({
    required this.id,
    required this.item,
    required this.position,
    this.isSwitchClosed = true,
    this.isLedReversed = false,
  });

  CircuitComponentKind get kind {
    return switch (item) {
      Phase4LibraryItem.battery9V => CircuitComponentKind.battery,
      Phase4LibraryItem.switchSPST => CircuitComponentKind.switchComponent,
      Phase4LibraryItem.ledRed => CircuitComponentKind.led,
      Phase4LibraryItem.resistor68 ||
      Phase4LibraryItem.resistor680 ||
      Phase4LibraryItem.resistor6800 =>
        CircuitComponentKind.resistor,
      Phase4LibraryItem.wire => CircuitComponentKind.resistor,
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
}

/// Opções de previsão para o aluno antes de energizar.
enum StudentPrediction {
  safeAndLit,
  openCircuit,
  excessiveCurrent,
  shortCircuit,
}

/// Tela da Fase 4: Bancada livre controlada do Primeiro Estande.
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
  final List<PlacedComponent> _placed = [];
  final List<CircuitConnection> _connections = [];
  CircuitTerminal? _selectedTerminalForWiring;

  // Ciclo da Fase 4
  int _stepIndex = 1; // 1: Montar, 2: Prever, 3: Energizar/Resultado
  StudentPrediction? _studentPrediction;
  CircuitValidationResult? _lastValidationResult;
  bool _showResultPanel = false;

  void _addComponent(Phase4LibraryItem item) {
    setState(() {
      final id = '${item.name}_${DateTime.now().millisecondsSinceEpoch}';
      // Posicionar em cascata na bancada
      final count = _placed.length;
      final x = 40.0 + (count % 3) * 160.0;
      final y = 40.0 + (count ~/ 3) * 120.0;

      _placed.add(PlacedComponent(
        id: id,
        item: item,
        position: Offset(x, y),
      ));
    });
  }

  void _clearBench() {
    setState(() {
      _placed.clear();
      _connections.clear();
      _selectedTerminalForWiring = null;
      _stepIndex = 1;
      _studentPrediction = null;
      _lastValidationResult = null;
      _showResultPanel = false;
    });
  }

  void _toggleSwitch(PlacedComponent comp) {
    if (comp.kind == CircuitComponentKind.switchComponent) {
      setState(() {
        comp.isSwitchClosed = !comp.isSwitchClosed;
      });
    }
  }

  void _toggleLedPolarity(PlacedComponent comp) {
    if (comp.kind == CircuitComponentKind.led) {
      setState(() {
        comp.isLedReversed = !comp.isLedReversed;
      });
    }
  }

  void _onTerminalTap(CircuitTerminal terminal) {
    setState(() {
      if (_selectedTerminalForWiring == null) {
        _selectedTerminalForWiring = terminal;
      } else {
        if (_selectedTerminalForWiring != terminal) {
          _connections.add(CircuitConnection(_selectedTerminalForWiring!, terminal));
        }
        _selectedTerminalForWiring = null;
      }
    });
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

    // Se o LED estiver invertido no componente, inverter seus terminais nas conexões
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

  void _startPredictionStep() {
    final graph = _buildGraph();
    const validator = CircuitValidator();
    _lastValidationResult = validator.validate(graph);

    setState(() {
      _stepIndex = 2; // Ir para o passo de previsão
    });
  }

  void _confirmEnergizeAndEvaluate() {
    if (_studentPrediction == null || _lastValidationResult == null) return;

    final result = _lastValidationResult!;
    bool predictionWasCorrect = false;

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

    final isSuccess = result.status == CircuitStatus.safeAndLit;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isSuccess,
        message: '${result.message}\n\n'
            '${predictionWasCorrect ? "Sua previsão estava CORRETA!" : "Sua previsão foi diferente do comportamento real."}',
        onAction: () {
          Navigator.of(context).pop();
          if (isSuccess) {
            setState(() {
              _showResultPanel = true;
              _stepIndex = 3;
            });
          } else {
            setState(() {
              _stepIndex = 1; // Permanece na mesma bancada para corrigir!
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Balão Orientativo Prof. Volts
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ProfVoltsSpeech(
            text: _getStepInstructionText(),
          ),
        ),

        // Barra de Ferramentas / Catálogo Controlado
        _buildLibraryToolbar(),

        // Bancada Livre
        Expanded(
          child: Stack(
            children: [
              // Fios Conectados (Desenhados ao fundo)
              CustomPainterWidget(
                connections: _connections,
                placedComponents: _placed,
              ),

              // Componentes Posicionados
              ..._placed.map((comp) => _buildDraggableComponent(comp)),

              // Painel de ResultadosDidáticos da Fase 4 (Ao Concluir com Sucesso)
              if (_showResultPanel && _lastValidationResult != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _buildDidacticResultPanel(),
                ),
            ],
          ),
        ),

        // Rodapé de Ações do Ciclo de Montagem
        _buildFooterActionPanel(),
      ],
    );
  }

  String _getStepInstructionText() {
    return switch (_stepIndex) {
      1 =>
        'FASE 4: Monte o circuito livremente! Adicione Bateria 9V, Interruptor, Resistor 680 Ω e LED vermelho, e conecte os fios.',
      2 =>
        'Passo de Previsão: Antes de energizar, qual é a sua previsão sobre o comportamento do circuito?',
      3 =>
        'Parabéns! O circuito está iluminando o primeiro ponto da maquete! Veja o painel didático abaixo.',
      _ => 'Monte seu circuito na bancada livre.',
    };
  }

  Widget _buildLibraryToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF0F172A),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Biblioteca:',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            _buildItemChip('Bateria 9V', Icons.battery_charging_full_rounded, Colors.amber,
                () => _addComponent(Phase4LibraryItem.battery9V)),
            _buildItemChip('Interruptor', Icons.toggle_on_rounded, Colors.green,
                () => _addComponent(Phase4LibraryItem.switchSPST)),
            _buildItemChip('LED Vermelho', Icons.lightbulb_outline_rounded, Colors.redAccent,
                () => _addComponent(Phase4LibraryItem.ledRed)),
            _buildItemChip('Resistor 68 Ω', Icons.bolt_rounded, Colors.redAccent,
                () => _addComponent(Phase4LibraryItem.resistor68)),
            _buildItemChip('Resistor 680 Ω', Icons.verified_user_rounded, Colors.lightGreenAccent,
                () => _addComponent(Phase4LibraryItem.resistor680)),
            _buildItemChip('Resistor 6,8 kΩ', Icons.shield_rounded, Colors.blueAccent,
                () => _addComponent(Phase4LibraryItem.resistor6800)),
            const VerticalDivider(color: Colors.white24),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              tooltip: 'Limpar Bancada',
              onPressed: _clearBench,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, color: color, size: 18),
        label: Text(label),
        labelStyle: TextStyle(
          fontFamily: GoogleFonts.outfit().fontFamily,
          fontSize: 12,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF1E293B),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildDraggableComponent(PlacedComponent comp) {
    final isSelectedForWiring = _selectedTerminalForWiring?.componentId == comp.id;

    return Positioned(
      left: comp.position.dx,
      top: comp.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            comp.position += details.delta;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelectedForWiring ? const Color(0xFF00FF9D) : const Color(0xFF334155),
              width: isSelectedForWiring ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nome e Ações do Componente
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getComponentTitle(comp),
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (comp.kind == CircuitComponentKind.switchComponent)
                    IconButton(
                      icon: Icon(
                        comp.isSwitchClosed ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                        color: comp.isSwitchClosed ? Colors.green : Colors.redAccent,
                      ),
                      onPressed: () => _toggleSwitch(comp),
                    ),
                  if (comp.kind == CircuitComponentKind.led)
                    IconButton(
                      icon: const Icon(Icons.swap_horiz_rounded, color: Colors.orangeAccent),
                      tooltip: 'Inverter polaridade do LED',
                      onPressed: () => _toggleLedPolarity(comp),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Terminais para Fio
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTerminalButton(comp, 'terminalA', 'T1 / (+)'),
                  const SizedBox(width: 20),
                  _buildTerminalButton(comp, 'terminalB', 'T2 / (-)'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalButton(PlacedComponent comp, String termKey, String label) {
    final termName = comp.kind == CircuitComponentKind.battery
        ? (termKey == 'terminalA' ? 'pos' : 'neg')
        : (comp.kind == CircuitComponentKind.led
            ? (termKey == 'terminalA' ? 'anode' : 'cathode')
            : (termKey == 'terminalA' ? 't1' : 't2'));

    final terminal = CircuitTerminal(comp.id, termName);
    final isSelected = _selectedTerminalForWiring == terminal;

    return InkWell(
      onTap: () => _onTerminalTap(terminal),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00FF9D) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF00FF9D)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : const Color(0xFF00FF9D),
          ),
        ),
      ),
    );
  }

  String _getComponentTitle(PlacedComponent comp) {
    return switch (comp.item) {
      Phase4LibraryItem.battery9V => 'Bateria 9V',
      Phase4LibraryItem.switchSPST => 'Interruptor',
      Phase4LibraryItem.ledRed => comp.isLedReversed ? 'LED (Invertido)' : 'LED Vermelho',
      Phase4LibraryItem.resistor68 => 'Resistor 68 Ω',
      Phase4LibraryItem.resistor680 => 'Resistor 680 Ω',
      Phase4LibraryItem.resistor6800 => 'Resistor 6,8 kΩ',
      _ => 'Componente',
    };
  }

  Widget _buildFooterActionPanel() {
    if (_stepIndex == 1) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF0F172A),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _placed.length >= 3 ? _startPredictionStep : null,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              'TESTAR E PREVER RESULTADO',
              style: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00FF9D),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    } else if (_stepIndex == 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF0F172A),
        child: Column(
          children: [
            Text(
              'O que acontecerá ao energizar o circuito?',
              style: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('LED acenderá com segurança'),
                  selected: _studentPrediction == StudentPrediction.safeAndLit,
                  onSelected: (_) =>
                      setState(() => _studentPrediction = StudentPrediction.safeAndLit),
                ),
                ChoiceChip(
                  label: const Text('Circuito aberto (LED apagado)'),
                  selected: _studentPrediction == StudentPrediction.openCircuit,
                  onSelected: (_) =>
                      setState(() => _studentPrediction = StudentPrediction.openCircuit),
                ),
                ChoiceChip(
                  label: const Text('Corrente excessiva (>100 mA)'),
                  selected: _studentPrediction == StudentPrediction.excessiveCurrent,
                  onSelected: (_) =>
                      setState(() => _studentPrediction = StudentPrediction.excessiveCurrent),
                ),
                ChoiceChip(
                  label: const Text('Curto-circuito'),
                  selected: _studentPrediction == StudentPrediction.shortCircuit,
                  onSelected: (_) =>
                      setState(() => _studentPrediction = StudentPrediction.shortCircuit),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _studentPrediction != null ? _confirmEnergizeAndEvaluate : null,
                icon: const Icon(Icons.bolt_rounded),
                label: Text(
                  'ENERGIZAR CIRCUITO',
                  style: TextStyle(
                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF9D),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF0F172A),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: widget.onPhaseComplete,
            icon: const Icon(Icons.emoji_events_rounded),
            label: Text(
              'CONCLUIR PRIMEIRO ESTANDE E ILUMINAR MAQUETE',
              style: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00FF9D),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildDidacticResultPanel() {
    final res = _lastValidationResult!;

    return GlassContainer(
      borderRadius: 16,
      accentColor: const Color(0xFF00FF9D),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: Color(0xFF00FF9D)),
              const SizedBox(width: 8),
              Text(
                'PAINEL DE RESULTADOS DIDÁTICOS',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FF9D),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResultMetric('Tensão da Bateria', '9 V'),
              _buildResultMetric('Tensão Direta LED', '2 V'),
              _buildResultMetric('Resistor Selecionado', '680 Ω'),
              _buildResultMetric('Corrente calculada', '${res.currentmA.toStringAsFixed(1)} mA'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fórmula: I = (9 V − 2 V) ÷ 680 Ω ≈ 10,3 mA (Circuito seguro e funcional)',
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 12,
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
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

/// Painter para desenhar linhas de fios simples entre componentes
class CustomPainterWidget extends StatelessWidget {
  final List<CircuitConnection> connections;
  final List<PlacedComponent> placedComponents;

  const CustomPainterWidget({
    super.key,
    required this.connections,
    required this.placedComponents,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: ConnectionsPainter(connections, placedComponents),
    );
  }
}

class ConnectionsPainter extends CustomPainter {
  final List<CircuitConnection> connections;
  final List<PlacedComponent> placedComponents;

  ConnectionsPainter(this.connections, this.placedComponents);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF9D)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final compMap = {for (final c in placedComponents) c.id: c};

    for (final conn in connections) {
      final compA = compMap[conn.from.componentId];
      final compB = compMap[conn.to.componentId];

      if (compA != null && compB != null) {
        final posA = compA.position + const Offset(50, 40);
        final posB = compB.position + const Offset(50, 40);
        canvas.drawLine(posA, posB, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
