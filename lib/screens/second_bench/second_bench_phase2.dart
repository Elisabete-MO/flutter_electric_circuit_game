import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/first_step_component.dart';
import '../../models/phase2_inspection_data.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/realistic_wire_painter.dart';
import '../common_stand/stand_flow_tokens.dart';
import '../../widgets/workbench_components.dart';
import '../../widgets/workbench_sidebar_cards.dart';
import '../../widgets/workbench_table_frame.dart';

/// Fase 2 do Segundo Estande (Acende Aí): Inspecione o circuito.
class SecondBenchPhase2 extends StatefulWidget {
  final VoidCallback? onPhaseComplete;
  final InspectionScenario initialScenario;

  const SecondBenchPhase2({
    super.key,
    this.onPhaseComplete,
    this.initialScenario = InspectionScenario.correct,
  });

  @override
  State<SecondBenchPhase2> createState() => _SecondBenchPhase2State();
}

class _SecondBenchPhase2State extends State<SecondBenchPhase2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flowController;
  late InspectionScenario _currentScenario;
  late List<InspectionPointData> _points;

  final Set<int> _inspectedPointIds = {};
  int? _selectedPointId;

  // Respostas dadas em cada ponto
  final Map<int, int> _selectedAnswers = {};

  // Modo Diagnóstico Final
  bool _isDiagnosisMode = false;
  int? _selectedDiagnosisIndex;

  // Estado de teste após diagnóstico
  bool _isSwitchClosed = false;
  bool _isLedOn = false;

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _currentScenario = widget.initialScenario;
    _updatePointsForCurrentScenario();
  }

  @override
  void dispose() {
    _flowController.dispose();
    super.dispose();
  }

  void _updatePointsForCurrentScenario() {
    _points = InspectionPointData.getPointsForScenario(_currentScenario);
    _selectedPointId = _points.first.id;
    _inspectedPointIds.clear();
    _selectedAnswers.clear();
    _inspectedPointIds.add(_points.first.id);
    _isDiagnosisMode = false;
    _selectedDiagnosisIndex = null;
    _isSwitchClosed = false;
    _isLedOn = false;
  }

  void _changeScenario(InspectionScenario newScenario) {
    setState(() {
      _currentScenario = newScenario;
      _flowController.stop();
      _updatePointsForCurrentScenario();
    });
  }

  void _selectPoint(int pointId) {
    setState(() {
      _selectedPointId = pointId;
      _inspectedPointIds.add(pointId);
    });
  }

  bool get _isAllPointsInspected => _inspectedPointIds.length >= _points.length;

  void _onAnswerSelected(int pointId, int optionIndex) {
    setState(() {
      _selectedAnswers[pointId] = optionIndex;
    });
  }

  void _startDiagnosisMode() {
    setState(() {
      _isDiagnosisMode = true;
    });
  }

  void _confirmDiagnosis() {
    if (_selectedDiagnosisIndex == null) return;

    // Diagnóstico esperado de acordo com o cenário visual
    final expectedIndex = switch (_currentScenario) {
      InspectionScenario.correct => 0,
      InspectionScenario.reversedLed => 1,
      InspectionScenario.missingResistor => 2,
      InspectionScenario.incorrectResistor => 3,
      InspectionScenario.openCircuit => 4,
    };

    final isCorrect = _selectedDiagnosisIndex == expectedIndex;

    // Simulação do circuito ao energizar
    setState(() {
      _isSwitchClosed = true;
      _isLedOn = (_currentScenario == InspectionScenario.correct && isCorrect);
      if (_isLedOn) {
        _flowController.repeat();
      } else {
        _flowController.stop();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final message = isCorrect
          ? switch (_currentScenario) {
              InspectionScenario.correct =>
                'Diagnóstico Perfeito! O circuito físico está perfeitamente montado e seguro. O resistor de 680 Ω protege o LED e a polaridade está correta. O LED acendeu!',
              InspectionScenario.reversedLed =>
                'Excelente diagnóstico! Você identificou corretamente que o LED está montado com polaridade invertida (cátodo no polo positivo).',
              InspectionScenario.missingResistor =>
                'Diagnóstico Exato! O circuito não possui resistor de proteção. Sem ele, a bateria de 9 V danificaria o LED.',
              InspectionScenario.incorrectResistor =>
                'Perfeito! Você notou que o resistor instalado é de apenas 68 Ω, valor muito baixo que causaria sobrecorrente no LED.',
              InspectionScenario.openCircuit =>
                'Muito bem! Você detectou a desconexão no circuito. Sem um percurso fechado, a corrente não circula.',
            }
          : 'Diagnóstico Incorreto. Observe atentamente a montagem física na bancada e os pontos inspecionados antes de emitir o diagnóstico.';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProfVoltsFeedbackDialog(
          isCorrect: isCorrect,
          message: message,
          onAction: () {
            Navigator.of(context).pop();
            if (isCorrect) {
              widget.onPhaseComplete?.call();
            } else {
              setState(() {
                _isSwitchClosed = false;
                _isLedOn = false;
                _flowController.stop();
              });
            }
          },
        ),
      );
    });
  }

  void _showHelpModal() {
    showDialog(
      context: context,
      builder: (context) {
        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (event) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.of(context).pop();
            }
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StandFlowTokens.primaryGreen, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 16),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF04382B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fact_check_rounded,
                          color: StandFlowTokens.primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Como funciona a inspeção?',
                          style: TextStyle(
                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildHelpBullet('1. Exabine a montagem física na bancada de madeira.'),
                  _buildHelpBullet('2. Toque nos 5 marcadores numerados de 1 a 5.'),
                  _buildHelpBullet('3. Responda à pergunta de cada ponto no painel lateral.'),
                  _buildHelpBullet('4. Clique em "Concluir inspeção" para declarar o diagnóstico.'),
                  _buildHelpBullet('5. Teste o circuito para confirmar sua análise.'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: StandFlowTokens.primaryGreen,
                        side: const BorderSide(color: StandFlowTokens.primaryGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('ENTENDI'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: StandFlowTokens.primaryGreen,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
          ),
        ],
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
            usePhysicalStyle: true,
            onStyleChanged: (_) {},
            showModeSelector: false,
            leftHeaderWidget: _buildInspectionStatusBadge(),
            rightHeaderWidget: _buildInspectionProgressBadge(),
            child: _buildBenchWorkspace(),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Objetivo + Conteúdo de Inspeção/Diagnóstico + Ação)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Iluminação',
            showTeamHeader: false,
            buttonColor: _isDiagnosisMode
                ? const Color(0xFF00FF9D)
                : const Color(0xFF10B981),
            buttonLabel: _isDiagnosisMode
                ? 'TESTAR RESULTADO'
                : (_isAllPointsInspected
                    ? 'CONCLUIR INSPEÇÃO'
                    : 'INSPECIONE OS 5 PONTOS (${_inspectedPointIds.length}/5)'),
            toolboxItems: [
              const WorkbenchMissionObjectiveCard(
                missionNumber: 2,
                title: 'Inspecione o circuito',
                description: 'Examine os cinco pontos de teste do circuito físico montado antes de energizar.',
                voltsTip: 'Toque nos marcadores numerados de 1 a 5 na bancada e conclua a inspeção antes de testar.',
                accentColor: Color(0xFF0284C7),
              ),
              const SizedBox(height: 12),
              _buildSidePanelContent(),
            ],
            onEnergizePressed: () {
              if (_isDiagnosisMode) {
                if (_selectedDiagnosisIndex != null) {
                  _confirmDiagnosis();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecione um diagnóstico na lista antes de testar.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } else {
                if (_isAllPointsInspected) {
                  _startDiagnosisMode();
                } else {
                  _showHelpModal();
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInspectionStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isDiagnosisMode
                ? Icons.assignment_turned_in_rounded
                : (_isAllPointsInspected ? Icons.check_circle_rounded : Icons.fact_check_rounded),
            color: _isDiagnosisMode
                ? const Color(0xFF059669)
                : (_isAllPointsInspected ? const Color(0xFF10B981) : const Color(0xFF0284C7)),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _isDiagnosisMode
                ? 'MODO DIAGNÓSTICO'
                : (_isAllPointsInspected ? 'INSPEÇÃO PRONTA' : 'MODO INSPEÇÃO'),
            style: GoogleFonts.rajdhani(
              color: _isDiagnosisMode
                  ? const Color(0xFF059669)
                  : (_isAllPointsInspected ? const Color(0xFF10B981) : const Color(0xFF0284C7)),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionProgressBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed_rounded, color: Color(0xFF00FF9D), size: 16),
          const SizedBox(width: 6),
          Text(
            '${_inspectedPointIds.length} de ${_points.length} inspecionados',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // AMBIENTE DA BANCADA (Circuito Físico em Série)
  // ==========================================
  Widget _buildBenchWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Posições dos 4 Componentes Físicos no Stack da Bancada
        // Bateria (Esquerda), Resistor (Topo), LED (Direita), Interruptor (Base)
        final batCenter = Offset(w * 0.20, h * 0.52);
        final resCenter = Offset(w * 0.50, h * 0.26);
        final ledCenter = Offset(w * 0.80, h * 0.52);
        final swCenter = Offset(w * 0.50, h * 0.74);

        // Terminais exatos de conexão dos componentes para os fios
        final batPosTerm = Offset(batCenter.dx + 22, batCenter.dy - 65); // Polo Positivo (+)
        final batNegTerm = Offset(batCenter.dx - 22, batCenter.dy - 65); // Polo Negativo (-)

        final resLeftTerm = Offset(resCenter.dx - 65, resCenter.dy);
        final resRightTerm = Offset(resCenter.dx + 65, resCenter.dy);

        final ledAnodeTerm = Offset(ledCenter.dx - 18, ledCenter.dy + 42); // Terminal Ânodo (+)
        final ledCathodeTerm = Offset(ledCenter.dx + 18, ledCenter.dy + 42); // Terminal Cátodo (-)

        final swLeftTerm = Offset(swCenter.dx - 60, swCenter.dy);
        final swRightTerm = Offset(swCenter.dx + 60, swCenter.dy);

        // Posições dos 5 Marcadores de Inspeção (próximos aos objetos, sem cobri-los)
        final markerOffsets = [
          Offset(batCenter.dx - 50, batCenter.dy - 50), // Marker 1: Polos da Bateria
          Offset(resCenter.dx, resCenter.dy - 48),      // Marker 2: Valor do Resistor
          Offset(ledCenter.dx + 52, ledCenter.dy - 10), // Marker 3: Polaridade do LED
          Offset(swCenter.dx, swCenter.dy + 52),       // Marker 4: Estado do Interruptor
          Offset(w * 0.32, h * 0.72),                   // Marker 5: Continuidade dos Fios (no retorno)
        ];

        final List<WirePath> wires = [];
        final isConducting = _isLedOn;

        // 1. Fio Vermelho (Bateria + -> Resistor Esquerda)
        if (_currentScenario != InspectionScenario.missingResistor) {
          wires.add(WirePath(
            points: [
              batPosTerm,
              Offset(batPosTerm.dx + 40, batPosTerm.dy - 50),
              Offset(resLeftTerm.dx - 40, resLeftTerm.dy),
              resLeftTerm,
            ],
            color: const Color(0xFFEF4444),
            isActive: isConducting,
            thickness: 5.0,
          ));

          // Fio Vermelho (Resistor Direita -> LED Ânodo)
          wires.add(WirePath(
            points: [
              resRightTerm,
              Offset(resRightTerm.dx + 40, resRightTerm.dy),
              Offset(ledAnodeTerm.dx, resRightTerm.dy),
              ledAnodeTerm,
            ],
            color: const Color(0xFFEF4444),
            isActive: isConducting,
            thickness: 5.0,
          ));
        } else {
          // Se resistor ausente, fio direto da Bateria + para o LED
          wires.add(WirePath(
            points: [
              batPosTerm,
              Offset(batPosTerm.dx + 40, resCenter.dy - 30),
              Offset(ledAnodeTerm.dx, resCenter.dy - 30),
              ledAnodeTerm,
            ],
            color: const Color(0xFFEF4444),
            isActive: isConducting,
            thickness: 5.0,
          ));
        }

        // 2. Fio Azul (LED Cátodo -> Interruptor Direita)
        wires.add(WirePath(
          points: [
            ledCathodeTerm,
            Offset(ledCathodeTerm.dx, swRightTerm.dy),
            swRightTerm,
          ],
          color: const Color(0xFF2563EB),
          isActive: isConducting,
          thickness: 5.0,
        ));

        // 3. Fio Azul (Interruptor Esquerda -> Bateria -)
        if (_currentScenario == InspectionScenario.openCircuit) {
          // Interrupção visível no percurso (Circuito Aberto)
          wires.add(WirePath(
            points: [
              swLeftTerm,
              Offset(swLeftTerm.dx - 60, swLeftTerm.dy),
            ],
            color: const Color(0xFF2563EB),
            isActive: false,
            thickness: 5.0,
          ));
          wires.add(WirePath(
            points: [
              Offset(batNegTerm.dx - 40, swLeftTerm.dy - 20),
              Offset(batNegTerm.dx - 40, batNegTerm.dy),
              batNegTerm,
            ],
            color: const Color(0xFF2563EB),
            isActive: false,
            thickness: 5.0,
          ));
        } else {
          wires.add(WirePath(
            points: [
              swLeftTerm,
              Offset(batNegTerm.dx - 40, swLeftTerm.dy),
              Offset(batNegTerm.dx - 40, batNegTerm.dy),
              batNegTerm,
            ],
            color: const Color(0xFF2563EB),
            isActive: isConducting,
            thickness: 5.0,
          ));
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Seletor discreto de cenários (para testes didáticos)
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StandFlowTokens.primaryGreen.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Cenário: ',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<InspectionScenario>(
                        value: _currentScenario,
                        dropdownColor: const Color(0xFF0F172A),
                        style: TextStyle(
                          fontFamily: GoogleFonts.rajdhani().fontFamily,
                          fontSize: 12,
                          color: StandFlowTokens.accentGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        isDense: true,
                        items: const [
                          DropdownMenuItem(
                            value: InspectionScenario.correct,
                            child: Text('Correto (680 Ω, LED OK)'),
                          ),
                          DropdownMenuItem(
                            value: InspectionScenario.reversedLed,
                            child: Text('LED Invertido'),
                          ),
                          DropdownMenuItem(
                            value: InspectionScenario.missingResistor,
                            child: Text('Resistor Ausente'),
                          ),
                          DropdownMenuItem(
                            value: InspectionScenario.incorrectResistor,
                            child: Text('Resistor Incorreto (68 Ω)'),
                          ),
                          DropdownMenuItem(
                            value: InspectionScenario.openCircuit,
                            child: Text('Circuito Aberto'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) _changeScenario(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 1. Fios condutores físicos (RealisticWireWidget com elétrons animados)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _flowController,
                builder: (context, child) {
                  return RealisticWireWidget(
                    wires: wires,
                    animationValue: _flowController.value,
                    showElectrons: _isLedOn,
                  );
                },
              ),
            ),

            // 2. Componente 1: BATERIA 9 V (Lado Esquerdo)
            _buildPositionedComponent(
              center: batCenter,
              width: 120,
              height: 140,
              child: CustomPaint(
                painter: ComponentPhysicalPainter(
                  type: ComponentType.battery,
                  isActive: true,
                  isDarkMode: false,
                  value: 9.0,
                ),
              ),
            ),

            // 3. Componente 2: RESISTOR DE 680 Ω (Topo)
            if (_currentScenario != InspectionScenario.missingResistor)
              _buildPositionedComponent(
                center: resCenter,
                width: 140,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(140, 70),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.resistor,
                        isActive: true,
                        isDarkMode: false,
                        value: _currentScenario == InspectionScenario.incorrectResistor ? 68.0 : 680.0,
                      ),
                    ),
                    if (_currentScenario == InspectionScenario.incorrectResistor)
                      Positioned(
                        top: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '68 Ω',
                            style: TextStyle(
                              fontFamily: GoogleFonts.rajdhani().fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      Positioned(
                        top: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF04382B),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: StandFlowTokens.primaryGreen),
                          ),
                          child: Text(
                            '680 Ω',
                            style: TextStyle(
                              fontFamily: GoogleFonts.rajdhani().fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: StandFlowTokens.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // 4. Componente 3: LED VERMELHO (Direita)
            _buildPositionedComponent(
              center: ledCenter,
              width: 90,
              height: 130,
              child: Transform.scale(
                scaleX: _currentScenario == InspectionScenario.reversedLed ? -1.0 : 1.0,
                child: CustomPaint(
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.led,
                    isActive: _isLedOn,
                    isDarkMode: false,
                    brightnessRatio: _isLedOn ? 1.0 : 0.0,
                  ),
                ),
              ),
            ),

            // 5. Componente 4: INTERRUPTOR SPST (Base)
            _buildPositionedComponent(
              center: swCenter,
              width: 130,
              height: 90,
              child: CustomPaint(
                painter: ComponentPhysicalPainter(
                  type: ComponentType.switchComponent,
                  isActive: _isSwitchClosed,
                  isDarkMode: false,
                ),
              ),
            ),

            // 6. Cinco Marcadores de Inspeção Numerados 1 a 5
            ...List.generate(_points.length, (index) {
              final pt = _points[index];
              final offset = markerOffsets[index];
              final isSelected = _selectedPointId == pt.id && !_isDiagnosisMode;
              final isInspected = _inspectedPointIds.contains(pt.id);

              return Positioned(
                left: offset.dx - 22,
                top: offset.dy - 22,
                child: GestureDetector(
                  onTap: () {
                    if (!_isDiagnosisMode) {
                      _selectPoint(pt.id);
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 42 : 36,
                      height: isSelected ? 42 : 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? StandFlowTokens.accentGreen
                            : (isInspected
                                ? const Color(0xFF04382B)
                                : const Color(0xFF0F172A)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : (isInspected
                                  ? StandFlowTokens.primaryGreen
                                  : Colors.white60),
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? StandFlowTokens.accentGreen.withValues(alpha: 0.7)
                                : Colors.black45,
                            blurRadius: isSelected ? 12 : 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isInspected && !isSelected
                                ? Icons.check_rounded
                                : Icons.search_rounded,
                            size: 14,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                          Text(
                            '${pt.id}',
                            style: TextStyle(
                              fontFamily: GoogleFonts.rajdhani().fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildPositionedComponent({
    required Offset center,
    required double width,
    required double height,
    required Widget child,
  }) {
    return Positioned(
      left: center.dx - (width / 2),
      top: center.dy - (height / 2),
      width: width,
      height: height,
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  // ==========================================
  // PAINEL LATERAL (Modo Inspeção & Modo Diagnóstico)
  // ==========================================
  Widget _buildSidePanelContent() {
    if (_isDiagnosisMode) {
      return _buildDiagnosisSidePanelContent();
    }

    final pt = _points.firstWhere(
      (p) => p.id == _selectedPointId,
      orElse: () => _points.first,
    );

    final selectedAnswerIndex = _selectedAnswers[pt.id];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fact_check_rounded, color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ponto ${pt.id} — ${pt.title}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      pt.description,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPointVisualDiagram(pt.id),
          const SizedBox(height: 12),
          Text(
            pt.question,
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: StandFlowTokens.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(pt.options.length, (optIndex) {
            final isSelected = selectedAnswerIndex == optIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: () => _onAnswerSelected(pt.id, optIndex),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD1EBE1)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? StandFlowTokens.primaryGreen
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isSelected
                            ? StandFlowTokens.primaryGreen
                            : Colors.black45,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pt.options[optIndex],
                          style: TextStyle(
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            fontSize: 13,
                            color: StandFlowTokens.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (selectedAnswerIndex != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F3EC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: StandFlowTokens.primaryGreen),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: StandFlowTokens.darkGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pt.explanation,
                      style: TextStyle(
                        fontFamily: GoogleFonts.outfit().fontFamily,
                        fontSize: 12.5,
                        color: StandFlowTokens.textDark,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPointVisualDiagram(int pointId) {
    if (pointId == 3) {
      // Ilustração pedagógica da Polaridade do LED (Ânodo / Cátodo)
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2DCC8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Image.asset('assets/components/led_off.png', height: 48, fit: BoxFit.contain),
                const SizedBox(height: 4),
                const Text(
                  '+  Ânodo (perna longa)\n−  Cátodo (lado reto)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (pointId == 1) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2DCC8)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Row(
                children: [
                  Icon(Icons.add_circle_rounded, color: Colors.redAccent, size: 18),
                  SizedBox(width: 4),
                  Text('Polo Positivo (9V)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(width: 12),
              Row(
                children: [
                  Icon(Icons.remove_circle_rounded, color: Colors.black87, size: 18),
                  SizedBox(width: 4),
                  Text('Polo Negativo (GND)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDiagnosisSidePanelContent() {
    final diagnoses = [
      'Circuito correto e pronto para energizar',
      'LED invertido (cátodo no polo positivo)',
      'Resistor ausente (risco de queimar o LED)',
      'Resistor com valor incorreto (68 Ω)',
      'Circuito aberto (fio desconectado)',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_rounded, color: Color(0xFFD97706), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnóstico do Circuito',
                      style: GoogleFonts.rajdhani(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Com base nas suas medições e inspeções, selecione o diagnóstico do circuito.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(diagnoses.length, (index) {
            final isSelected = _selectedDiagnosisIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: () => setState(() => _selectedDiagnosisIndex = index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD1EBE1)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? StandFlowTokens.primaryGreen
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: isSelected
                            ? StandFlowTokens.primaryGreen
                            : Colors.black38,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          diagnoses[index],
                          style: TextStyle(
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: StandFlowTokens.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
