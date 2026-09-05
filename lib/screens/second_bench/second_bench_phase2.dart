import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/phase2_inspection_data.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import 'second_bench_tokens.dart';
import 'widgets/second_bench_action_bar.dart';
import 'widgets/second_bench_phase_scaffold.dart';
import 'widgets/second_bench_side_panel.dart';

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

class _SecondBenchPhase2State extends State<SecondBenchPhase2> {
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
    _currentScenario = widget.initialScenario;
    _updatePointsForCurrentScenario();
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
                border: Border.all(color: SecondBenchLayoutTokens.primaryGreen, width: 1.5),
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
                          color: SecondBenchLayoutTokens.primaryGreen,
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
                        foregroundColor: SecondBenchLayoutTokens.primaryGreen,
                        side: const BorderSide(color: SecondBenchLayoutTokens.primaryGreen),
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
              color: SecondBenchLayoutTokens.primaryGreen,
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
    return SecondBenchPhaseScaffold(
      phase: 2,
      title: 'Inspecione o circuito',
      instruction: 'Examine os cinco pontos de teste do circuito físico montado antes de energizar.',
      introIcon: Icons.fact_check_rounded,
      onHelpTap: _showHelpModal,
      backgroundAsset: 'assets/backgrounds/background_fase_02_bancada.png',
      workspace: _buildBenchWorkspace(),
      sidePanel: _buildSidePanel(),
      actionBar: SecondBenchActionBar(
        statusText: _isDiagnosisMode
            ? 'Declare o diagnóstico do circuito após a inspeção.'
            : (_isAllPointsInspected
                ? 'Todos os 5 pontos inspecionados! Clique para emitir o diagnóstico.'
                : 'Inspecione os 5 pontos de teste na bancada.'),
        progressText: '${_inspectedPointIds.length} de ${_points.length} inspecionados',
        actions: [
          if (!_isDiagnosisMode)
            FilledButton.icon(
              onPressed: _isAllPointsInspected ? _startDiagnosisMode : null,
              icon: const Icon(Icons.assignment_turned_in_rounded),
              label: Text(
                'CONCLUIR INSPEÇÃO',
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
            )
          else
            FilledButton.icon(
              onPressed: _selectedDiagnosisIndex != null ? _confirmDiagnosis : null,
              icon: const Icon(Icons.bolt_rounded),
              label: Text(
                'TESTAR RESULTADO',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: SecondBenchLayoutTokens.accentGreen,
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
                  border: Border.all(color: SecondBenchLayoutTokens.primaryGreen.withValues(alpha: 0.4)),
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
                          color: SecondBenchLayoutTokens.accentGreen,
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

            // 1. Fios condutores físicos curvos (CustomPainter na camada inferior)
            Positioned.fill(
              child: CustomPaint(
                painter: _PhysicalWirePainter(
                  batPos: batPosTerm,
                  batNeg: batNegTerm,
                  resLeft: resLeftTerm,
                  resRight: resRightTerm,
                  ledAnode: ledAnodeTerm,
                  ledCathode: ledCathodeTerm,
                  swLeft: swLeftTerm,
                  swRight: swRightTerm,
                  scenario: _currentScenario,
                ),
              ),
            ),

            // 2. Componente 1: BATERIA 9 V (Lado Esquerdo)
            _buildPositionedComponent(
              center: batCenter,
              width: 120,
              height: 140,
              child: Image.asset('assets/components/battery.png', fit: BoxFit.contain),
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
                    Image.asset('assets/components/resistor.png', fit: BoxFit.contain),
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
                            border: Border.all(color: SecondBenchLayoutTokens.primaryGreen),
                          ),
                          child: Text(
                            '680 Ω',
                            style: TextStyle(
                              fontFamily: GoogleFonts.rajdhani().fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: SecondBenchLayoutTokens.primaryGreen,
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Image.asset(
                    _isLedOn ? 'assets/components/led_on.png' : 'assets/components/led_off.png',
                    key: ValueKey(_isLedOn),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // 5. Componente 4: INTERRUPTOR SPST (Base)
            _buildPositionedComponent(
              center: swCenter,
              width: 130,
              height: 90,
              child: Image.asset(
                _isSwitchClosed ? 'assets/components/switch_closed.png' : 'assets/components/switch_open.png',
                fit: BoxFit.contain,
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
                            ? SecondBenchLayoutTokens.accentGreen
                            : (isInspected
                                ? const Color(0xFF04382B)
                                : const Color(0xFF0F172A)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : (isInspected
                                  ? SecondBenchLayoutTokens.primaryGreen
                                  : Colors.white60),
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? SecondBenchLayoutTokens.accentGreen.withValues(alpha: 0.7)
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
  Widget _buildSidePanel() {
    if (_isDiagnosisMode) {
      return _buildDiagnosisSidePanel();
    }

    final pt = _points.firstWhere(
      (p) => p.id == _selectedPointId,
      orElse: () => _points.first,
    );

    final selectedAnswerIndex = _selectedAnswers[pt.id];

    return SecondBenchSidePanel(
      title: 'Ponto ${pt.id} — ${pt.title}',
      subtitle: pt.description,
      icon: Icons.fact_check_rounded,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ilustração/Esquema didático auxiliar do ponto selecionado
            _buildPointVisualDiagram(pt.id),
            const SizedBox(height: 12),

            Text(
              pt.question,
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: SecondBenchLayoutTokens.textDark,
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
                          : const Color(0xFFFFFDF7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? SecondBenchLayoutTokens.primaryGreen
                            : const Color(0xFFD6CFC0),
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
                              ? SecondBenchLayoutTokens.primaryGreen
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
                              color: SecondBenchLayoutTokens.textDark,
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
                  border: Border.all(color: SecondBenchLayoutTokens.primaryGreen),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: SecondBenchLayoutTokens.darkGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pt.explanation,
                        style: TextStyle(
                          fontFamily: GoogleFonts.outfit().fontFamily,
                          fontSize: 12.5,
                          color: SecondBenchLayoutTokens.textDark,
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

  Widget _buildDiagnosisSidePanel() {
    final diagnoses = [
      'Circuito correto e pronto para energizar',
      'LED invertido (cátodo no polo positivo)',
      'Resistor ausente (risco de queimar o LED)',
      'Resistor com valor incorreto (68 Ω)',
      'Circuito aberto (fio desconectado)',
    ];

    return SecondBenchSidePanel(
      title: 'Diagnóstico do Circuito',
      subtitle: 'Com base nas suas medições e inspeções, selecione o diagnóstico do circuito.',
      icon: Icons.assignment_rounded,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(diagnoses.length, (index) {
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
                        : const Color(0xFFFFFDF7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? SecondBenchLayoutTokens.primaryGreen
                          : const Color(0xFFD6CFC0),
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
                            ? SecondBenchLayoutTokens.primaryGreen
                            : Colors.black38,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          diagnoses[index],
                          style: TextStyle(
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: SecondBenchLayoutTokens.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Painter dos fios condutores elétricos físicos (Red = Positivo, Black = Negativo)
class _PhysicalWirePainter extends CustomPainter {
  final Offset batPos;
  final Offset batNeg;
  final Offset resLeft;
  final Offset resRight;
  final Offset ledAnode;
  final Offset ledCathode;
  final Offset swLeft;
  final Offset swRight;
  final InspectionScenario scenario;

  _PhysicalWirePainter({
    required this.batPos,
    required this.batNeg,
    required this.resLeft,
    required this.resRight,
    required this.ledAnode,
    required this.ledCathode,
    required this.swLeft,
    required this.swRight,
    required this.scenario,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final redWirePaint = Paint()
      ..color = const Color(0xFFDC2626) // Vermelho físico vibrante
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final blackWirePaint = Paint()
      ..color = const Color(0xFF1E293B) // Preto/Grafite escuro físico
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sleevePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    // 1. Fio Vermelho (Bateria + -> Resistor Esquerda)
    if (scenario != InspectionScenario.missingResistor) {
      final p1 = Path();
      p1.moveTo(batPos.dx, batPos.dy);
      p1.cubicTo(
        batPos.dx + 40, batPos.dy - 80,
        resLeft.dx - 60, resLeft.dy,
        resLeft.dx, resLeft.dy,
      );
      canvas.drawPath(p1, redWirePaint);
      _drawTerminalSleeve(canvas, batPos, sleevePaint);
      _drawTerminalSleeve(canvas, resLeft, sleevePaint);

      // Fio Vermelho (Resistor Direita -> LED Ânodo)
      final p2 = Path();
      p2.moveTo(resRight.dx, resRight.dy);
      p2.cubicTo(
        resRight.dx + 60, resRight.dy,
        ledAnode.dx - 40, ledAnode.dy - 30,
        ledAnode.dx, ledAnode.dy,
      );
      canvas.drawPath(p2, redWirePaint);
      _drawTerminalSleeve(canvas, resRight, sleevePaint);
      _drawTerminalSleeve(canvas, ledAnode, sleevePaint);
    } else {
      // Se resistor ausente, fio direto da Bateria + para o LED
      final pDirect = Path();
      pDirect.moveTo(batPos.dx, batPos.dy);
      pDirect.cubicTo(
        batPos.dx + 120, batPos.dy - 120,
        ledAnode.dx - 60, ledAnode.dy - 40,
        ledAnode.dx, ledAnode.dy,
      );
      canvas.drawPath(pDirect, redWirePaint);
      _drawTerminalSleeve(canvas, batPos, sleevePaint);
      _drawTerminalSleeve(canvas, ledAnode, sleevePaint);
    }

    // 2. Fio Preto (LED Cátodo -> Interruptor Direita)
    final p3 = Path();
    p3.moveTo(ledCathode.dx, ledCathode.dy);
    p3.cubicTo(
      ledCathode.dx + 20, ledCathode.dy + 50,
      swRight.dx + 50, swRight.dy,
      swRight.dx, swRight.dy,
    );
    canvas.drawPath(p3, blackWirePaint);
    _drawTerminalSleeve(canvas, ledCathode, sleevePaint);
    _drawTerminalSleeve(canvas, swRight, sleevePaint);

    // 3. Fio Preto (Interruptor Esquerda -> Bateria -)
    if (scenario == InspectionScenario.openCircuit) {
      // Interrupção visível no percurso (Circuito Aberto)
      final p4a = Path();
      p4a.moveTo(swLeft.dx, swLeft.dy);
      p4a.cubicTo(
        swLeft.dx - 40, swLeft.dy,
        swLeft.dx - 80, swLeft.dy - 10,
        swLeft.dx - 90, swLeft.dy - 20,
      );
      canvas.drawPath(p4a, blackWirePaint);

      final p4b = Path();
      p4b.moveTo(batNeg.dx, batNeg.dy);
      p4b.cubicTo(
        batNeg.dx - 40, batNeg.dy + 80,
        batNeg.dx + 20, swLeft.dy + 40,
        batNeg.dx + 40, swLeft.dy + 10,
      );
      canvas.drawPath(p4b, blackWirePaint);
      _drawTerminalSleeve(canvas, swLeft, sleevePaint);
      _drawTerminalSleeve(canvas, batNeg, sleevePaint);
    } else {
      final p4 = Path();
      p4.moveTo(swLeft.dx, swLeft.dy);
      p4.cubicTo(
        swLeft.dx - 80, swLeft.dy,
        batNeg.dx - 60, batNeg.dy + 80,
        batNeg.dx, batNeg.dy,
      );
      canvas.drawPath(p4, blackWirePaint);
      _drawTerminalSleeve(canvas, swLeft, sleevePaint);
      _drawTerminalSleeve(canvas, batNeg, sleevePaint);
    }
  }

  void _drawTerminalSleeve(Canvas canvas, Offset pos, Paint paint) {
    canvas.drawCircle(pos, 6.0, paint);
  }

  @override
  bool shouldRepaint(covariant _PhysicalWirePainter oldDelegate) {
    return oldDelegate.scenario != scenario;
  }
}
