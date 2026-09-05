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

/// Missão 2 do Estande 3 — Preveja a chave (Dois Cartazes Lado a Lado).
class LigaDesligaM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const LigaDesligaM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<LigaDesligaM2> createState() => _LigaDesligaM2State();
}

class _LigaDesligaM2State extends State<LigaDesligaM2>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.estande3Missions[1];

  bool _usePhysicalStyle = true;
  final bool _switchAClosed = false;
  final bool _switchBClosed = true;

  bool _isRevealed = false;
  String? _answerStateA;
  String? _answerStateB;

  late final AnimationController _flowController;

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _flowController.dispose();
    super.dispose();
  }

  void _validate() {
    if (_answerStateA == null || _answerStateB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, registre sua previsão para ambos os cartazes antes de energizar!',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isRevealed = true;
    });
    _flowController.repeat();

    final isSuccess = _answerStateA == 'aberto' && _answerStateB == 'fechado';

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (isSuccess) {
        _showFeedback(
          true,
          'Excelente previsão! Circuito aberto interrompe a passagem de corrente e apaga a luz. Circuito fechado completa o percurso!',
        );
      } else {
        _showFeedback(false, _mission.failureFeedback);
      }
    });
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
          } else {
            setState(() {
              _isRevealed = false;
            });
            _flowController.stop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flowController,
      builder: (context, _) {
        return Row(
          children: [
            // Área Principal da Bancada (Dois Cartazes Lado a Lado)
            Expanded(
              flex: 7,
              child: WorkbenchTableFrame(
                usePhysicalStyle: _usePhysicalStyle,
                onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
                leftHeaderWidget: buildLigaDesligaStatusCard(
                  _isRevealed ? _switchBClosed : false,
                ),
                rightHeaderWidget: buildLigaDesligaTelemetryCard(
                  4.5,
                  _isRevealed ? 22.5 : 0.0,
                  _isRevealed,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cartaz A: Chave Aberta (OFF)
                    Expanded(
                      child: _buildPoster(
                        scenarioId: 'A',
                        badgeTitle: 'CARTAZ A',
                        badgeColor: const Color(0xFF0284C7),
                        circuitTitle: 'Montagem 1: Alavanca Aberta',
                        circuitSubtitle: 'Observe o contato mecânico da chave',
                        switchClosed: _switchAClosed,
                        currentAnswer: _answerStateA,
                        correctAnswer: 'aberto',
                        onSelect: (val) {
                          setState(() {
                            _answerStateA = val;
                            if (_isRevealed) {
                              _isRevealed = false;
                              _flowController.stop();
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Cartaz B: Chave Fechada (ON)
                    Expanded(
                      child: _buildPoster(
                        scenarioId: 'B',
                        badgeTitle: 'CARTAZ B',
                        badgeColor: const Color(0xFF059669),
                        circuitTitle: 'Montagem 2: Alavanca Fechada',
                        circuitSubtitle: 'Observe o contato mecânico da chave',
                        switchClosed: _switchBClosed,
                        currentAnswer: _answerStateB,
                        correctAnswer: 'fechado',
                        onSelect: (val) {
                          setState(() {
                            _answerStateB = val;
                            if (_isRevealed) {
                              _isRevealed = false;
                              _flowController.stop();
                            }
                          });
                        },
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
      },
    );
  }

  Widget _buildPoster({
    required String scenarioId,
    required String badgeTitle,
    required Color badgeColor,
    required String circuitTitle,
    required String circuitSubtitle,
    required bool switchClosed,
    required String? currentAnswer,
    required String correctAnswer,
    required ValueChanged<String> onSelect,
  }) {
    final bool isCorrect = currentAnswer == correctAnswer;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isRevealed
              ? (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
              : (currentAnswer != null ? badgeColor : const Color(0xFFCBD5E1)),
          width: _isRevealed || currentAnswer != null ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Cabeçalho do Cartaz
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeTitle,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        circuitTitle,
                        style: GoogleFonts.rajdhani(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        circuitSubtitle,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_isRevealed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCorrect
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 14,
                          color: isCorrect
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCorrect ? 'Correto' : 'Incorreto',
                          style: GoogleFonts.rajdhani(
                            color: isCorrect
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.help_outline_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Prever',
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 2. Área do Circuito (Mini Canvas)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1E19),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1E3A32),
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _usePhysicalStyle
                    ? _buildMiniPhysicalCircuit(switchClosed)
                    : _buildMiniSchematicCircuit(switchClosed),
              ),
            ),
          ),

          // 3. Área de Hipótese / Decisão
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ao energizar o circuito, a lâmpada irá:',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF334155),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Botão 1: Vai Acender (Circuito Fechado)
                    Expanded(
                      child: _buildChoiceButton(
                        label: 'VAI ACENDER',
                        icon: Icons.lightbulb_rounded,
                        activeColor: const Color(0xFF10B981),
                        isSelected: currentAnswer == 'fechado',
                        isRevealed: _isRevealed,
                        isCorrectChoice: correctAnswer == 'fechado',
                        onTap: () => onSelect('fechado'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botão 2: Ficará Apagada (Circuito Aberto)
                    Expanded(
                      child: _buildChoiceButton(
                        label: 'FICARÁ APAGADA',
                        icon: Icons.lightbulb_outline_rounded,
                        activeColor: const Color(0xFF64748B),
                        isSelected: currentAnswer == 'aberto',
                        isRevealed: _isRevealed,
                        isCorrectChoice: correctAnswer == 'aberto',
                        onTap: () => onSelect('aberto'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required IconData icon,
    required Color activeColor,
    required bool isSelected,
    required bool isRevealed,
    required bool isCorrectChoice,
    required VoidCallback onTap,
  }) {
    Color borderColor = const Color(0xFFCBD5E1);
    Color backgroundColor = const Color(0xFFF8FAFC);
    Color textColor = const Color(0xFF334155);

    if (isSelected) {
      borderColor = activeColor;
      backgroundColor = activeColor.withValues(alpha: 0.12);
      textColor = activeColor;
    }

    if (isRevealed) {
      if (isCorrectChoice) {
        borderColor = const Color(0xFF10B981);
        if (isSelected) {
          backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.18);
          textColor = const Color(0xFF047857);
        }
      } else if (isSelected && !isCorrectChoice) {
        borderColor = const Color(0xFFEF4444);
        backgroundColor = const Color(0xFFEF4444).withValues(alpha: 0.15);
        textColor = const Color(0xFFDC2626);
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.0 : 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.rajdhani(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPhysicalCircuit(bool switchClosed) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final double centerY = height * 0.44;
        final posBat = Offset(width * 0.18, centerY);
        final posSw = Offset(width * 0.50, centerY);
        final posBulb = Offset(width * 0.82, centerY);

        final bool isCircWorking = _isRevealed && switchClosed;

        final wires = <WirePath>[];

        // 1. Fio Vermelho (+): Bateria (+) -> Chave (Terminal 0)
        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
            position: posBat,
            rotation: 0,
            type: ComponentType.battery,
          ),
          terminalIndexA: 0,
          compB: ComponentPlacement(
            position: posSw,
            rotation: 0,
            type: ComponentType.switchComponent,
          ),
          terminalIndexB: 0,
          color: const Color(0xFFEF4444),
          isActive: isCircWorking,
          thickness: 4.0,
        ).toWirePath());

        // 2. Fio Laranja (Intermediário): Chave (Terminal 1) -> Lâmpada (Terminal 0)
        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
            position: posSw,
            rotation: 0,
            type: ComponentType.switchComponent,
          ),
          terminalIndexA: 1,
          compB: ComponentPlacement(
            position: posBulb,
            rotation: 0,
            type: ComponentType.bulb,
          ),
          terminalIndexB: 0,
          color: const Color(0xFFF97316),
          isActive: isCircWorking,
          thickness: 4.0,
        ).toWirePath());

        // 3. Fio Azul (-) Retorno: Lâmpada (Terminal 1) -> Bateria (-)
        final termBulb = ComponentPlacement(
          position: posBulb,
          rotation: 0,
          type: ComponentType.bulb,
        ).getTerminalPosition(1);
        final termBat = ComponentPlacement(
          position: posBat,
          rotation: 0,
          type: ComponentType.battery,
        ).getTerminalPosition(1);

        final rightX = posBulb.dx + 26.0;
        final leftX = posBat.dx - 26.0;
        final bottomY = height * 0.86;

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
            position: posBulb,
            rotation: 0,
            type: ComponentType.bulb,
          ),
          terminalIndexA: 1,
          compB: ComponentPlacement(
            position: posBat,
            rotation: 0,
            type: ComponentType.battery,
          ),
          terminalIndexB: 1,
          color: const Color(0xFF2563EB),
          isActive: isCircWorking,
          thickness: 4.0,
        ).toWirePath(intermediatePoints: [
          Offset(rightX, termBulb.dy),
          Offset(rightX, bottomY),
          Offset(leftX, bottomY),
          Offset(leftX, termBat.dy),
        ]));

        return Stack(
          children: [
            // Camada de Fios Realistas
            Positioned.fill(
              child: RealisticWireWidget(
                wires: wires,
                animationValue: _flowController.value,
                showElectrons: isCircWorking,
              ),
            ),

            // Bateria
            Positioned(
              left: posBat.dx - 32,
              top: posBat.dy - 32,
              child: CustomPaint(
                size: const Size(64, 64),
                painter: ComponentPhysicalPainter(
                  type: ComponentType.battery,
                  isActive: true,
                  isDarkMode: false,
                  value: 4.5,
                ),
              ),
            ),

            // Chave SPST
            Positioned(
              left: posSw.dx - 32,
              top: posSw.dy - 32,
              child: CustomPaint(
                size: const Size(64, 64),
                painter: ComponentPhysicalPainter(
                  type: ComponentType.switchComponent,
                  isActive: switchClosed,
                  isDarkMode: false,
                ),
              ),
            ),

            // Lâmpada
            Positioned(
              left: posBulb.dx - 32,
              top: posBulb.dy - 32,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: const Size(64, 64),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.bulb,
                      isActive: isCircWorking,
                      isDarkMode: false,
                    ),
                  ),
                  if (!_isRevealed)
                    Positioned(
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF00E5FF),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          '?',
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniSchematicCircuit(bool switchClosed) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final double centerY = height * 0.44;
        final posBat = Offset(width * 0.18, centerY);
        final posSw = Offset(width * 0.50, centerY);
        final posBulb = Offset(width * 0.82, centerY);

        final bool isCircWorking = _isRevealed && switchClosed;

        final wires = <WirePath>[];

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
            position: posBat,
            rotation: 0,
            type: ComponentType.battery,
          ),
          terminalIndexA: 1,
          compB: ComponentPlacement(
            position: posSw,
            rotation: 0,
            type: ComponentType.switchComponent,
          ),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: isCircWorking,
          thickness: 3.2,
        ).toWirePath());

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
            position: posSw,
            rotation: 0,
            type: ComponentType.switchComponent,
          ),
          terminalIndexA: 1,
          compB: ComponentPlacement(
            position: posBulb,
            rotation: 0,
            type: ComponentType.bulb,
          ),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: isCircWorking,
          thickness: 3.2,
        ).toWirePath());

        final termBulb = ComponentPlacement(
          position: posBulb,
          rotation: 0,
          type: ComponentType.bulb,
        ).getTerminalPosition(1);
        final termBat = ComponentPlacement(
          position: posBat,
          rotation: 0,
          type: ComponentType.battery,
        ).getTerminalPosition(0);

        final rightX = posBulb.dx + 26.0;
        final leftX = posBat.dx - 26.0;
        final bottomY = height * 0.86;

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(
            position: posBulb,
            rotation: 0,
            type: ComponentType.bulb,
          ),
          terminalIndexA: 1,
          compB: ComponentPlacement(
            position: posBat,
            rotation: 0,
            type: ComponentType.battery,
          ),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: isCircWorking,
          thickness: 3.2,
        ).toWirePath(intermediatePoints: [
          Offset(rightX, termBulb.dy),
          Offset(rightX, bottomY),
          Offset(leftX, bottomY),
          Offset(leftX, termBat.dy),
        ]));

        return Stack(
          children: [
            Positioned.fill(
              child: RealisticWireWidget(
                wires: wires,
                animationValue: _flowController.value,
                showElectrons: isCircWorking,
              ),
            ),

            // Símbolo Esquemático Bateria
            Positioned(
              left: posBat.dx - 24,
              top: posBat.dy - 18,
              child: CustomPaint(
                size: const Size(48, 36),
                painter: CircuitSymbolPainter(
                  type: ComponentType.battery,
                  color: const Color(0xFFE2E8F0),
                  strokeWidth: 2.0,
                ),
              ),
            ),

            // Símbolo Esquemático Chave
            Positioned(
              left: posSw.dx - 24,
              top: posSw.dy - 18,
              child: CustomPaint(
                size: const Size(48, 36),
                painter: CircuitSymbolPainter(
                  type: ComponentType.switchComponent,
                  isActive: switchClosed,
                  color: const Color(0xFFE2E8F0),
                  strokeWidth: 2.0,
                ),
              ),
            ),

            // Símbolo Esquemático Lâmpada
            Positioned(
              left: posBulb.dx - 24,
              top: posBulb.dy - 18,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: const Size(48, 36),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: isCircWorking,
                      color: const Color(0xFFE2E8F0),
                      activeColor: const Color(0xFFFBBF24),
                      strokeWidth: 2.0,
                    ),
                  ),
                  if (!_isRevealed)
                    Positioned(
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF00E5FF),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          '?',
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
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
}
