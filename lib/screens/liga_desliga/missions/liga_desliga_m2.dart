import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/realistic_wire_painter.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/liga_desliga_widgets.dart';

/// Missão 2 do Estande 3 — Preveja a chave (Aberto ou Fechado).
class LigaDesligaM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LigaDesligaM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<LigaDesligaM2> createState() => _LigaDesligaM2State();
}

class _LigaDesligaM2State extends State<LigaDesligaM2> {
  final StandMission _mission = StandMission.estande3Missions[1];

  bool _usePhysicalStyle = true;
  final bool _switchAClosed = false;
  final bool _switchBClosed = true;
  String? _answerStateA;
  String? _answerStateB;

  void _validate() {
    if (_answerStateA == 'aberto' && _answerStateB == 'fechado') {
      _showFeedback(
        true,
        'Excelente previsão! Circuito aberto interrompe a passagem de corrente e apaga a luz. Circuito fechado completa o percurso!',
      );
    } else {
      _showFeedback(false, _mission.failureFeedback);
    }
  }

  void _showFeedback(bool isCorrect, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isCorrect,
        message: message,
        onAction: () {
          Navigator.of(context).pop();
          if (isCorrect) {
            widget.onMissionComplete();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Área Principal da Bancada
        Expanded(
          flex: 7,
          child: WorkbenchTableFrame(
            usePhysicalStyle: _usePhysicalStyle,
            onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
            leftHeaderWidget: buildLigaDesligaStatusCard(false),
            rightHeaderWidget: buildLigaDesligaTelemetryCard(4.5, 0.0, false),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _usePhysicalStyle
                    ? _buildPhysicalCanvas()
                    : _buildSchematicCanvas(),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Examine a posição da chave nos dois cenários e preveja se haverá passagem de corrente:',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            shadows: const [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Questão 1: Estado A (Chave Aberta)
                        _buildPredictionCard(
                          title: 'Cenário A: Interruptor no estado ABERTO (OFF)',
                          subtitle:
                              'Existe um espaço vazio entre os contatos elétricos da chave.',
                          currentValue: _answerStateA,
                          onSelect: (val) => setState(() => _answerStateA = val),
                        ),

                        const SizedBox(height: 8),

                        // Questão 2: Estado B (Chave Fechada)
                        _buildPredictionCard(
                          title: 'Cenário B: Interruptor no estado FECHADO (ON)',
                          subtitle:
                              'Os contatos condutores da chave estão encostados.',
                          currentValue: _answerStateB,
                          onSelect: (val) => setState(() => _answerStateB = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Briefing & Botão de Validação)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Controle',
            toolboxItems: [
              _buildMissionBriefingCard(),
            ],
            onEnergizePressed: _validate,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionCard({
    required String title,
    required String subtitle,
    required String? currentValue,
    required ValueChanged<String> onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: currentValue != null
              ? const Color(0xFF0284C7)
              : const Color(0xFFCBD5E1),
          width: currentValue != null ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'LÂMPADA ACESA (Circuito Fechado)',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: currentValue == 'fechado'
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  selected: currentValue == 'fechado',
                  selectedColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFFF1F5F9),
                  onSelected: (val) {
                    if (val) onSelect('fechado');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'LÂMPADA APAGADA (Circuito Aberto)',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: currentValue == 'aberto'
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  selected: currentValue == 'aberto',
                  selectedColor: const Color(0xFFEF4444),
                  backgroundColor: const Color(0xFFF1F5F9),
                  onSelected: (val) {
                    if (val) onSelect('aberto');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionBriefingCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt_rounded, color: Color(0xFF0284C7), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Missão 2: ${_mission.title}',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _mission.objective,
            style: GoogleFonts.outfit(
              color: const Color(0xFF334155),
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prof. Volts: "${_mission.voltsMediation}"',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF475569),
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 180.0;

        final posABat = Offset(width * 0.12, 60.0);
        final posASw = Offset(width * 0.27, 60.0);
        final posABulb = Offset(width * 0.42, 60.0);

        final posBBat = Offset(width * 0.58, 60.0);
        final posBSw = Offset(width * 0.73, 60.0);
        final posBBulb = Offset(width * 0.88, 60.0);

        final wires = <WirePath>[];

        // Fios Cenário A
        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posABat, rotation: 0, type: ComponentType.battery),
          terminalIndexA: 1,
          compB: ComponentPlacement(
              position: posASw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexB: 0,
          color: const Color(0xFFEF4444),
          isActive: _switchAClosed,
          thickness: 4.0,
        ).toWirePath());

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posASw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexA: 1,
          compB: ComponentPlacement(
              position: posABulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexB: 0,
          color: const Color(0xFFF97316),
          isActive: _switchAClosed,
          thickness: 4.0,
        ).toWirePath());

        final termABulb = ComponentPlacement(
                position: posABulb, rotation: 0, type: ComponentType.bulb)
            .getTerminalPosition(1);
        final termABat = ComponentPlacement(
                position: posABat, rotation: 0, type: ComponentType.battery)
            .getTerminalPosition(1);
        final rightA = posABulb.dx + 35.0;
        final leftA = posABat.dx - 35.0;
        const bottomYA = 135.0;

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posABulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexA: 1,
          compB: ComponentPlacement(
              position: posABat, rotation: 0, type: ComponentType.battery),
          terminalIndexB: 1,
          color: const Color(0xFF2563EB),
          isActive: _switchAClosed,
          thickness: 4.0,
        ).toWirePath(intermediatePoints: [
          Offset(rightA, termABulb.dy),
          Offset(rightA, bottomYA),
          Offset(leftA, bottomYA),
          Offset(leftA, termABat.dy),
        ]));

        // Fios Cenário B
        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posBBat, rotation: 0, type: ComponentType.battery),
          terminalIndexA: 0,
          compB: ComponentPlacement(
              position: posBSw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexB: 0,
          color: const Color(0xFFEF4444),
          isActive: _switchBClosed,
          thickness: 4.0,
        ).toWirePath());

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posBSw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexA: 1,
          compB: ComponentPlacement(
              position: posBBulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexB: 0,
          color: const Color(0xFFF97316),
          isActive: _switchBClosed,
          thickness: 4.0,
        ).toWirePath());

        final termBBulb = ComponentPlacement(
                position: posBBulb, rotation: 0, type: ComponentType.bulb)
            .getTerminalPosition(1);
        final termBBat = ComponentPlacement(
                position: posBBat, rotation: 0, type: ComponentType.battery)
            .getTerminalPosition(1);
        final rightB = posBBulb.dx + 35.0;
        final leftB = posBBat.dx - 35.0;
        const bottomYB = 135.0;

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posBBulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexA: 1,
          compB: ComponentPlacement(
              position: posBBat, rotation: 0, type: ComponentType.battery),
          terminalIndexB: 1,
          color: const Color(0xFF2563EB),
          isActive: _switchBClosed,
          thickness: 4.0,
        ).toWirePath(intermediatePoints: [
          Offset(rightB, termBBulb.dy),
          Offset(rightB, bottomYB),
          Offset(leftB, bottomYB),
          Offset(leftB, termBBat.dy),
        ]));

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: RealisticWireWidget(
                  wires: wires,
                  showElectrons: false,
                ),
              ),

              // Cenário A Componentes
              Positioned(
                left: posABat.dx - 35,
                top: posABat.dy - 35,
                child: CustomPaint(
                  size: const Size(70, 70),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.battery,
                    isActive: true,
                    isDarkMode: false,
                    value: 4.5,
                  ),
                ),
              ),
              Positioned(
                left: posASw.dx - 35,
                top: posASw.dy - 35,
                child: CustomPaint(
                  size: const Size(70, 70),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.switchComponent,
                    isActive: _switchAClosed,
                    isDarkMode: false,
                  ),
                ),
              ),
              Positioned(
                left: posABulb.dx - 35,
                top: posABulb.dy - 35,
                child: CustomPaint(
                  size: const Size(70, 70),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.bulb,
                    isActive: _switchAClosed,
                    isDarkMode: false,
                  ),
                ),
              ),

              // Cenário B Componentes
              Positioned(
                left: posBBat.dx - 35,
                top: posBBat.dy - 35,
                child: CustomPaint(
                  size: const Size(70, 70),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.battery,
                    isActive: true,
                    isDarkMode: false,
                    value: 4.5,
                  ),
                ),
              ),
              Positioned(
                left: posBSw.dx - 35,
                top: posBSw.dy - 35,
                child: CustomPaint(
                  size: const Size(70, 70),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.switchComponent,
                    isActive: _switchBClosed,
                    isDarkMode: false,
                  ),
                ),
              ),
              Positioned(
                left: posBBulb.dx - 35,
                top: posBBulb.dy - 35,
                child: CustomPaint(
                  size: const Size(70, 70),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.bulb,
                    isActive: _switchBClosed,
                    isDarkMode: false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchematicCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 180.0;

        final posABat = Offset(width * 0.12, 60.0);
        final posASw = Offset(width * 0.27, 60.0);
        final posABulb = Offset(width * 0.42, 60.0);

        final posBBat = Offset(width * 0.58, 60.0);
        final posBSw = Offset(width * 0.73, 60.0);
        final posBBulb = Offset(width * 0.88, 60.0);

        final wires = <WirePath>[];

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posABat, rotation: 0, type: ComponentType.battery),
          terminalIndexA: 1,
          compB: ComponentPlacement(
              position: posASw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: _switchAClosed,
          thickness: 3.5,
        ).toWirePath());

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posASw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexA: 1,
          compB: ComponentPlacement(
              position: posABulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: _switchAClosed,
          thickness: 3.5,
        ).toWirePath());

        final termABulb = ComponentPlacement(
                position: posABulb, rotation: 0, type: ComponentType.bulb)
            .getTerminalPosition(1);
        final termABat = ComponentPlacement(
                position: posABat, rotation: 0, type: ComponentType.battery)
            .getTerminalPosition(0);
        final rightA = posABulb.dx + 35.0;
        final leftA = posABat.dx - 35.0;
        const bottomYA = 135.0;

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posABulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexA: 1,
          compB: ComponentPlacement(
              position: posABat, rotation: 0, type: ComponentType.battery),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: _switchAClosed,
          thickness: 3.5,
        ).toWirePath(intermediatePoints: [
          Offset(rightA, termABulb.dy),
          Offset(rightA, bottomYA),
          Offset(leftA, bottomYA),
          Offset(leftA, termABat.dy),
        ]));

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posBBat, rotation: 0, type: ComponentType.battery),
          terminalIndexA: 1,
          compB: ComponentPlacement(
              position: posBSw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: _switchBClosed,
          thickness: 3.5,
        ).toWirePath());

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posBSw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexA: 1,
          compB: ComponentPlacement(
              position: posBBulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: _switchBClosed,
          thickness: 3.5,
        ).toWirePath());

        final termBBulb = ComponentPlacement(
                position: posBBulb, rotation: 0, type: ComponentType.bulb)
            .getTerminalPosition(1);
        final termBBat = ComponentPlacement(
                position: posBBat, rotation: 0, type: ComponentType.battery)
            .getTerminalPosition(0);
        final rightB = posBBulb.dx + 35.0;
        final leftB = posBBat.dx - 35.0;
        const bottomYB = 135.0;

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
              position: posBBulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexA: 1,
          compB: ComponentPlacement(
              position: posBBat, rotation: 0, type: ComponentType.battery),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: _switchBClosed,
          thickness: 3.5,
        ).toWirePath(intermediatePoints: [
          Offset(rightB, termBBulb.dy),
          Offset(rightB, bottomYB),
          Offset(leftB, bottomYB),
          Offset(leftB, termBBat.dy),
        ]));

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: RealisticWireWidget(
                  wires: wires,
                  showElectrons: false,
                ),
              ),

              // Cenário A
              Positioned(
                left: posABat.dx - 25,
                top: posABat.dy - 20,
                child: CustomPaint(
                  size: const Size(50, 40),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.battery,
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.0,
                  ),
                ),
              ),
              Positioned(
                left: posASw.dx - 25,
                top: posASw.dy - 20,
                child: CustomPaint(
                  size: const Size(50, 40),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.switchComponent,
                    isActive: _switchAClosed,
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.0,
                  ),
                ),
              ),
              Positioned(
                left: posABulb.dx - 25,
                top: posABulb.dy - 20,
                child: CustomPaint(
                  size: const Size(50, 40),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.bulb,
                    isActive: _switchAClosed,
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.0,
                  ),
                ),
              ),

              // Cenário B
              Positioned(
                left: posBBat.dx - 25,
                top: posBBat.dy - 20,
                child: CustomPaint(
                  size: const Size(50, 40),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.battery,
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.0,
                  ),
                ),
              ),
              Positioned(
                left: posBSw.dx - 25,
                top: posBSw.dy - 20,
                child: CustomPaint(
                  size: const Size(50, 40),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.switchComponent,
                    isActive: _switchBClosed,
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.0,
                  ),
                ),
              ),
              Positioned(
                left: posBBulb.dx - 25,
                top: posBBulb.dy - 20,
                child: CustomPaint(
                  size: const Size(50, 40),
                  painter: CircuitSymbolPainter(
                    type: ComponentType.bulb,
                    isActive: _switchBClosed,
                    color: const Color(0xFF0F172A),
                    strokeWidth: 2.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
