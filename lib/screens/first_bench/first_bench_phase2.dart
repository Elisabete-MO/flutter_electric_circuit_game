import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/circuit_validator.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';

enum InspectionScenario {
  correct,
  reversedLed,
  missingResistor,
  incorrectResistor,
  openCircuit,
}

class InspectionScenarioData {
  final InspectionScenario scenario;
  final String title;
  final String description;
  final CircuitGraph graph;
  final InspectionScenario expectedDiagnosis;
  final String successExplanation;

  const InspectionScenarioData({
    required this.scenario,
    required this.title,
    required this.description,
    required this.graph,
    required this.expectedDiagnosis,
    required this.successExplanation,
  });
}

class InspectionPointInfo {
  final String id;
  final String title;
  final String question;
  final List<String> options;
  final IconData icon;
  final String explanation;

  const InspectionPointInfo({
    required this.id,
    required this.title,
    required this.question,
    required this.options,
    required this.icon,
    required this.explanation,
  });
}

/// Tela da Fase 2 do Primeiro Estande: Inspecione o circuito pré-montado.
class FirstBenchPhase2 extends StatefulWidget {
  final VoidCallback onPhaseComplete;
  final List<InspectionScenarioData>? injectedScenarios;
  final InspectionScenario? initialScenario;

  const FirstBenchPhase2({
    super.key,
    required this.onPhaseComplete,
    this.injectedScenarios,
    this.initialScenario,
  });

  @override
  State<FirstBenchPhase2> createState() => _FirstBenchPhase2State();
}

class _FirstBenchPhase2State extends State<FirstBenchPhase2> with SingleTickerProviderStateMixin {
  late List<InspectionScenarioData> _scenarios;
  int _currentScenarioIndex = 0;

  // Estado da inspeção dos 5 pontos
  int _activePointIndex = 0;
  final Set<String> _inspectedChecklist = {};
  final Map<String, int> _pointAnswers = {};

  // Estado do Diagnóstico e Teste
  bool _isDiagnosisMode = false;
  InspectionScenario? _selectedDiagnosis;
  bool _isTestReady = false;
  bool _isSwitchClosed = false;
  bool _isLedOn = false;

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _scenarios = widget.injectedScenarios ?? _getDefaultScenarios();

    if (widget.initialScenario != null) {
      final foundIdx = _scenarios.indexWhere((s) => s.scenario == widget.initialScenario);
      if (foundIdx != -1) {
        _currentScenarioIndex = foundIdx;
      }
    }

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  static List<InspectionScenarioData> _getDefaultScenarios() {
    const battery = CircuitComponentInstance(id: 'bat', kind: CircuitComponentKind.battery);
    const swClosed = CircuitComponentInstance(id: 'sw', kind: CircuitComponentKind.switchComponent, isSwitchClosed: true);
    const res680 = CircuitComponentInstance(id: 'res', kind: CircuitComponentKind.resistor, resistanceOhms: 680);
    const res68 = CircuitComponentInstance(id: 'res', kind: CircuitComponentKind.resistor, resistanceOhms: 68);
    const led = CircuitComponentInstance(id: 'led', kind: CircuitComponentKind.led);

    return [
      InspectionScenarioData(
        scenario: InspectionScenario.correct,
        title: 'Fase 2 — Inspecione o circuito',
        description: 'Antes de ligar, confira se a montagem é segura e funcional.',
        graph: CircuitGraph(
          components: [battery, swClosed, res680, led],
          connections: [
            CircuitConnection(battery.terminalA, swClosed.terminalA),
            CircuitConnection(swClosed.terminalB, res680.terminalA),
            CircuitConnection(res680.terminalB, led.terminalA),
            CircuitConnection(led.terminalB, battery.terminalB),
          ],
        ),
        expectedDiagnosis: InspectionScenario.correct,
        successExplanation: 'Excelente! O circuito está seguro, a polaridade do LED está correta e o resistor de 680 Ω protege os componentes. O LED acendeu!',
      ),
      InspectionScenarioData(
        scenario: InspectionScenario.reversedLed,
        title: 'Fase 2 — Inspecione o circuito',
        description: 'Antes de ligar, confira se a montagem é segura e funcional.',
        graph: CircuitGraph(
          components: [battery, swClosed, res680, led],
          connections: [
            CircuitConnection(battery.terminalA, swClosed.terminalA),
            CircuitConnection(swClosed.terminalB, res680.terminalA),
            CircuitConnection(res680.terminalB, led.terminalB),
            CircuitConnection(led.terminalA, battery.terminalB),
          ],
        ),
        expectedDiagnosis: InspectionScenario.reversedLed,
        successExplanation: 'Exato! O LED foi montado com a polaridade invertida (cátodo voltado ao lado positivo). A corrente foi bloqueada e o LED não acendeu.',
      ),
      InspectionScenarioData(
        scenario: InspectionScenario.missingResistor,
        title: 'Fase 2 — Inspecione o circuito',
        description: 'Antes de ligar, confira se a montagem é segura e funcional.',
        graph: CircuitGraph(
          components: [battery, swClosed, led],
          connections: [
            CircuitConnection(battery.terminalA, swClosed.terminalA),
            CircuitConnection(swClosed.terminalB, led.terminalA),
            CircuitConnection(led.terminalB, battery.terminalB),
          ],
        ),
        expectedDiagnosis: InspectionScenario.missingResistor,
        successExplanation: 'Correto! O circuito não possui resistor de proteção. Sem ele, a corrente de 9 V danificaria o LED.',
      ),
      InspectionScenarioData(
        scenario: InspectionScenario.incorrectResistor,
        title: 'Fase 2 — Inspecione o circuito',
        description: 'Antes de ligar, confira se a montagem é segura e funcional.',
        graph: CircuitGraph(
          components: [battery, swClosed, res68, led],
          connections: [
            CircuitConnection(battery.terminalA, swClosed.terminalA),
            CircuitConnection(swClosed.terminalB, res68.terminalA),
            CircuitConnection(res68.terminalB, led.terminalA),
            CircuitConnection(led.terminalB, battery.terminalB),
          ],
        ),
        expectedDiagnosis: InspectionScenario.incorrectResistor,
        successExplanation: 'Perfeito! O resistor instalado é de apenas 68 Ω, valor muito baixo que causaria sobrecorrente no LED.',
      ),
      InspectionScenarioData(
        scenario: InspectionScenario.openCircuit,
        title: 'Fase 2 — Inspecione o circuito',
        description: 'Antes de ligar, confira se a montagem é segura e funcional.',
        graph: CircuitGraph(
          components: [battery, swClosed, res680, led],
          connections: [
            CircuitConnection(battery.terminalA, swClosed.terminalA),
            CircuitConnection(res680.terminalB, led.terminalA),
            CircuitConnection(led.terminalB, battery.terminalB),
          ],
        ),
        expectedDiagnosis: InspectionScenario.openCircuit,
        successExplanation: 'Muito bem! Existe uma desconexão no circuito. Sem um percurso fechado completo, a corrente não circula.',
      ),
    ];
  }

  InspectionScenarioData get _current => _scenarios[_currentScenarioIndex];

  List<InspectionPointInfo> get _points => [
        const InspectionPointInfo(
          id: 'battery',
          title: 'Polos da Bateria',
          question: 'Os polos positivo e negativo foram utilizados corretamente sem curto-circuito?',
          options: [
            'Sim, a conexão entre os polos está correta.',
            'Não, há ligação direta entre os polos (+ e -).',
          ],
          icon: Icons.battery_charging_full_rounded,
          explanation: 'A bateria de 9 V fornece tensão em corrente contínua. Os fios devem conectar o polo positivo ao circuito e retornar ao negativo sem curto-circuito.',
        ),
        InspectionPointInfo(
          id: 'resistor',
          title: 'Valor do Resistor',
          question: 'O resistor presente no circuito é adequado para proteger o LED?',
          options: _current.scenario == InspectionScenario.missingResistor
              ? [
                  'Sim, o circuito funciona sem resistor.',
                  'Não, o resistor está ausente no percurso.',
                ]
              : _current.scenario == InspectionScenario.incorrectResistor
                  ? [
                      'Sim, o resistor de 68 Ω é adequado.',
                      'Não, o resistor de 68 Ω é muito baixo.',
                    ]
                  : [
                      'Sim, o resistor de 680 Ω é adequado.',
                      'Não, o resistor é inadequado.',
                    ],
          icon: Icons.compress_rounded,
          explanation: 'O resistor de 680 Ω limita a corrente em aproximadamente 10,3 mA para a bateria de 9 V, impedindo a queima do LED.',
        ),
        InspectionPointInfo(
          id: 'led',
          title: 'Polaridade do LED',
          question: 'O LED está ligado no sentido correto (Ânodo ao +, Cátodo ao -)?',
          options: _current.scenario == InspectionScenario.reversedLed
              ? [
                  'Sim, o LED está ligado corretamente.',
                  'Não, o LED está invertido.',
                ]
              : [
                  'Sim, o Ânodo está no lado positivo.',
                  'Não, o LED está com a polaridade invertida.',
                ],
          icon: Icons.lightbulb_rounded,
          explanation: 'O LED é um componente polarizado: a corrente só flui do Ânodo (perna longa, +) para o Cátodo (lado plano, -).',
        ),
        const InspectionPointInfo(
          id: 'switch',
          title: 'Estado do Interruptor',
          question: 'Qual é o estado atual do interruptor antes de energizar?',
          options: [
            'Aberto (circuito desligado, sem corrente).',
            'Fechado (circuito energizado).',
          ],
          icon: Icons.toggle_off_rounded,
          explanation: 'Antes da inspeção ser concluída, o interruptor SPST permanece aberto para garantir que a montagem seja avaliada em segurança.',
        ),
        InspectionPointInfo(
          id: 'wires',
          title: 'Continuidade dos Fios',
          question: 'Existe um percurso elétrico contínuo entre os dois polos da bateria?',
          options: _current.scenario == InspectionScenario.openCircuit
              ? [
                  'Sim, existe continuidade completa.',
                  'Não, existe uma desconexão no circuito.',
                ]
              : [
                  'Sim, todos os fios estão conectados.',
                  'Não, existe um percurso interrompido.',
                ],
          icon: Icons.alt_route_rounded,
          explanation: 'Para haver corrente elétrica, é indispensável que exista um percurso fechado e sem interrupções entre o polo positivo e o negativo.',
        ),
      ];

  bool get _isAllPointsInspected => _inspectedChecklist.length >= 5;

  void _selectPointAnswer(int optionIdx) {
    final point = _points[_activePointIndex];
    setState(() {
      _pointAnswers[point.id] = optionIdx;
      _inspectedChecklist.add(point.id);

      // Avança automaticamente para o próximo ponto não inspecionado
      if (_inspectedChecklist.length < 5) {
        for (int i = 0; i < 5; i++) {
          if (!_inspectedChecklist.contains(_points[i].id)) {
            _activePointIndex = i;
            break;
          }
        }
      }
    });
  }

  void _startDiagnosis() {
    setState(() {
      _isDiagnosisMode = true;
      _selectedDiagnosis = null;
      _isTestReady = false;
    });
  }

  void _confirmDiagnosis() {
    if (_selectedDiagnosis == null) return;
    setState(() {
      _isTestReady = true;
    });
  }

  void _runCircuitTest() {
    final isScenarioCorrect = _current.scenario == InspectionScenario.correct;
    final isUserDiagnosisCorrect = _selectedDiagnosis == _current.expectedDiagnosis;

    setState(() {
      _isSwitchClosed = true;
      _isLedOn = isScenarioCorrect;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProfVoltsFeedbackDialog(
          isCorrect: isUserDiagnosisCorrect,
          message: isUserDiagnosisCorrect
              ? _current.successExplanation
              : _getFailureExplanation(),
          onAction: () {
            Navigator.of(context).pop();
            if (isUserDiagnosisCorrect) {
              if (_currentScenarioIndex < _scenarios.length - 1) {
                setState(() {
                  _currentScenarioIndex++;
                  _resetInspectionState();
                });
              } else {
                widget.onPhaseComplete();
              }
            } else {
              setState(() {
                _isSwitchClosed = false;
                _isLedOn = false;
                _isTestReady = false;
              });
            }
          },
        ),
      );
    });
  }

  String _getFailureExplanation() {
    switch (_current.scenario) {
      case InspectionScenario.correct:
        return 'O circuito estava perfeitamente montado e seguro! O resistor de 680 Ω protegeu o LED e a polaridade estava correta.';
      case InspectionScenario.reversedLed:
        return 'Na verdade, o LED estava montado com a polaridade invertida (cátodo no positivo). A corrente foi bloqueada e o LED não acendeu.';
      case InspectionScenario.missingResistor:
        return 'O circuito não tinha resistor! Ligar a bateria de 9 V diretamente no LED causaria corrente excessiva e danificaria o componente.';
      case InspectionScenario.incorrectResistor:
        return 'O resistor instalado era de apenas 68 Ω. Essa resistência é muito baixa para 9 V e causaria corrente excessiva no LED.';
      case InspectionScenario.openCircuit:
        return 'Existia um fio desconectado no circuito. Como o caminho estava aberto, a corrente não pôde circular.';
    }
  }

  void _resetInspectionState() {
    _activePointIndex = 0;
    _inspectedChecklist.clear();
    _pointAnswers.clear();
    _isDiagnosisMode = false;
    _selectedDiagnosis = null;
    _isTestReady = false;
    _isSwitchClosed = false;
    _isLedOn = false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        if (isDesktop) {
          return _buildDesktopLayout(constraints);
        } else {
          return _buildMobileLayout(constraints);
        }
      },
    );
  }

  // ==========================================
  // LAYOUT DESKTOP (Stack 16:9 + Painel 27%)
  // ==========================================
  Widget _buildDesktopLayout(BoxConstraints constraints) {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 1600,
          height: 900,
          child: Row(
            children: [
              // Área Principal da Bancada (73% da largura)
              SizedBox(
                width: 1180,
                height: 900,
                child: Stack(
                  children: [
                    // 1. Cenário background_fase_01_bancada.png
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/backgrounds/background_fase_01_bancada.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/backgrounds/background_fase_01_bancada.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // 2. Cabeçalho Neutro no topo da bancada
                    Positioned(
                      top: 28,
                      left: 36,
                      width: 720,
                      child: _buildHeaderSection(),
                    ),

                    // 3. Fios desenhados com CustomPainter em camada inferior
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CircuitWirePainter(
                          scenario: _current.scenario,
                          isEnergized: _isSwitchClosed,
                          isLedOn: _isLedOn,
                          glowAnimation: _glowController,
                        ),
                      ),
                    ),

                    // 4. Componentes Físicos 2.5D
                    _buildPhysicalComponents(),

                    // 5. Cinco marcadores pequenos de inspeção sobre o circuito
                    ...List.generate(5, (index) {
                      return _buildInspectionMarkerPositioned(index);
                    }),
                  ],
                ),
              ),

              // Painel Lateral Direito (27% da largura)
              SizedBox(
                width: 420,
                height: 900,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 24, 28, 24),
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildSidePanel(),
                      ),
                      const SizedBox(height: 14),
                      _buildBottomActionButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LAYOUT MOBILE (Bancada no topo + Painel abaixo)
  // ==========================================
  Widget _buildMobileLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 12),
          // Vista da Bancada Mobile
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/backgrounds/background_fase_01_bancada.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CircuitWirePainter(
                        scenario: _current.scenario,
                        isEnergized: _isSwitchClosed,
                        isLedOn: _isLedOn,
                        glowAnimation: _glowController,
                        isMobileScale: true,
                      ),
                    ),
                  ),
                  _buildPhysicalComponents(isMobile: true),
                  ...List.generate(5, (index) {
                    return _buildInspectionMarkerPositioned(index, isMobile: true);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Painel Lateral adaptado para Mobile
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                _buildSidePanel(),
                const SizedBox(height: 14),
                _buildBottomActionButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CABEÇALHO NEUTRO
  // ==========================================
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.black.withValues(alpha: 0.65),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Color(0xFF10B981),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Fase 2 — Inspecione o circuito',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Antes de ligar, confira se a montagem é segura e funcional.',
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // COMPONENTES FÍSICOS SOBRE A BANCADA
  // ==========================================
  Widget _buildPhysicalComponents({bool isMobile = false}) {
    // Posições base no Stack
    final batPos = isMobile
        ? const Rect.fromLTWH(30, 160, 80, 100)
        : const Rect.fromLTWH(210, 430, 140, 170);

    final resPos = isMobile
        ? const Rect.fromLTWH(130, 60, 90, 45)
        : const Rect.fromLTWH(550, 350, 170, 75);

    final ledPos = isMobile
        ? const Rect.fromLTWH(250, 120, 55, 95)
        : const Rect.fromLTWH(900, 360, 90, 150);

    final swPos = isMobile
        ? const Rect.fromLTWH(140, 240, 90, 65)
        : const Rect.fromLTWH(540, 620, 150, 110);

    return Stack(
      children: [
        // 1. BATERIA 9V
        Positioned.fromRect(
          rect: batPos,
          child: _buildComponentImage(
            'assets/components/battery.png',
            shadowBlur: 10,
          ),
        ),

        // 2. RESISTOR (ou jumper/badge de valor)
        if (_current.scenario != InspectionScenario.missingResistor)
          Positioned.fromRect(
            rect: resPos,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildComponentImage('assets/components/resistor.png'),
                if (_current.scenario == InspectionScenario.incorrectResistor)
                  Positioned(
                    top: -14,
                    left: 0,
                    right: 0,
                    child: Center(
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
                            fontSize: isMobile ? 10 : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // 3. LED VERMELHO
        Positioned.fromRect(
          rect: ledPos,
          child: Transform.scale(
            scaleX: _current.scenario == InspectionScenario.reversedLed ? -1.0 : 1.0,
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

        // 4. INTERRUPTOR SPST
        Positioned.fromRect(
          rect: swPos,
          child: Image.asset(
            _isSwitchClosed ? 'assets/components/switch_closed.png' : 'assets/components/switch_open.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildComponentImage(String path, {double shadowBlur = 8}) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: shadowBlur,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(
        path,
        fit: BoxFit.contain,
      ),
    );
  }

  // ==========================================
  // CINCO MARCADORES DE INSPEÇÃO
  // ==========================================
  Widget _buildInspectionMarkerPositioned(int index, {bool isMobile = false}) {
    final point = _points[index];
    final isSelected = _activePointIndex == index && !_isDiagnosisMode;
    final isInspected = _inspectedChecklist.contains(point.id);

    // Coordenadas relativas dos 5 marcadores
    final coordsDesktop = [
      const Offset(180, 420), // 1. Polos da bateria
      const Offset(625, 305), // 2. Resistor
      const Offset(985, 415), // 3. LED
      const Offset(615, 730), // 4. Interruptor
      const Offset(410, 670), // 5. Continuidade
    ];

    final coordsMobile = [
      const Offset(20, 150),
      const Offset(165, 35),
      const Offset(290, 110),
      const Offset(175, 290),
      const Offset(90, 270),
    ];

    final pos = isMobile ? coordsMobile[index] : coordsDesktop[index];

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onTap: () {
          if (!_isDiagnosisMode) {
            setState(() {
              _activePointIndex = index;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isMobile ? 38 : 46,
          height: isMobile ? 38 : 46,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF10B981)
                : (isInspected ? const Color(0xFF04382B) : const Color(0xFF0F172A)),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : (isInspected ? const Color(0xFF10B981) : Colors.white54),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF10B981).withValues(alpha: 0.7)
                    : Colors.black45,
                blurRadius: isSelected ? 12 : 6,
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: isMobile ? 14 : 16,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
              if (isInspected && !isSelected)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PAINEL LATERAL
  // ==========================================
  Widget _buildSidePanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7EC), // Fundo creme
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF0B3C2D), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: _isDiagnosisMode ? _buildDiagnosisPanelContent() : _buildInspectionPanelContent(),
    );
  }

  // Conteúdo do Painel na Etapa de Inspeção dos 5 Pontos
  Widget _buildInspectionPanelContent() {
    final point = _points[_activePointIndex];
    final selectedOption = _pointAnswers[point.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicador de Ponto X de 5
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0B3C2D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Ponto ${_activePointIndex + 1} de 5',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              '${_inspectedChecklist.length} de 5 inspecionados',
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontSize: 13,
                color: const Color(0xFF3D5245),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Título do Ponto
        Row(
          children: [
            Icon(point.icon, color: const Color(0xFF0B3C2D), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                point.title,
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B3C2D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Pequena Ilustração Educativa Didática
        _buildEducationalIllustration(point.id),
        const SizedBox(height: 14),

        // Pergunta do Ponto
        Text(
          point.question,
          style: TextStyle(
            fontFamily: GoogleFonts.outfit().fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A2E26),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),

        // Alternativas
        ...List.generate(point.options.length, (optIdx) {
          final isChosen = selectedOption == optIdx;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => _selectPointAnswer(optIdx),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isChosen ? const Color(0xFF0B3C2D) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isChosen ? const Color(0xFF0B3C2D) : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isChosen ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isChosen ? Colors.white : const Color(0xFF64748B),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point.options[optIdx],
                        style: TextStyle(
                          fontFamily: GoogleFonts.outfit().fontFamily,
                          fontSize: 13.5,
                          fontWeight: isChosen ? FontWeight.bold : FontWeight.normal,
                          color: isChosen ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),

        // Feedback pedagógico se o item tiver sido respondido
        if (selectedOption != null)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFA5D6A7)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    point.explanation,
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 12.5,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const Spacer(),

        // Barra de progresso dos 5 pontos
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (idx) {
                final isDone = _inspectedChecklist.contains(_points[idx].id);
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFF0B3C2D) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  // Conteúdo do Painel na Etapa de Diagnóstico Final
  Widget _buildDiagnosisPanelContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0B3C2D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Diagnóstico Final',
            style: TextStyle(
              fontFamily: GoogleFonts.rajdhani().fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 14),

        Text(
          'Este circuito está seguro e pronto para ser ligado?',
          style: TextStyle(
            fontFamily: GoogleFonts.rajdhani().fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0B3C2D),
          ),
        ),
        const SizedBox(height: 16),

        // Opção 1: Sim, pronto
        _buildDiagnosisRadioCard(
          title: 'Sim, está pronto para ser ligado.',
          isSelected: _selectedDiagnosis == InspectionScenario.correct,
          onTap: () {
            setState(() {
              _selectedDiagnosis = InspectionScenario.correct;
            });
          },
        ),
        const SizedBox(height: 8),

        // Opção 2: Não, encontrei um problema
        _buildDiagnosisRadioCard(
          title: 'Não, encontrei um problema.',
          isSelected: _selectedDiagnosis != null && _selectedDiagnosis != InspectionScenario.correct,
          onTap: () {
            setState(() {
              if (_selectedDiagnosis == InspectionScenario.correct) {
                _selectedDiagnosis = null;
              }
            });
          },
        ),

        // Se escolheu "Não", mostra a lista de diagnósticos específicos
        if (_selectedDiagnosis != InspectionScenario.correct && _selectedDiagnosis != null ||
            _pointAnswers.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'Qual problema você identificou?',
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3D5245),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildProblemDetailOption('LED invertido', InspectionScenario.reversedLed),
          _buildProblemDetailOption('Resistor ausente', InspectionScenario.missingResistor),
          _buildProblemDetailOption('Resistor inadequado', InspectionScenario.incorrectResistor),
          _buildProblemDetailOption('Circuito aberto', InspectionScenario.openCircuit),
        ],

        const Spacer(),
      ],
    );
  }

  Widget _buildDiagnosisRadioCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0B3C2D) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF0B3C2D) : const Color(0xFFCBD5E1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemDetailOption(String label, InspectionScenario scenario) {
    final isSelected = _selectedDiagnosis == scenario;
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDiagnosis = scenario;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF0B3C2D) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: isSelected ? const Color(0xFF0B3C2D) : const Color(0xFF94A3B8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Visualização Didática Educativa
  Widget _buildEducationalIllustration(String pointId) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: switch (pointId) {
          'battery' => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.battery_charging_full_rounded, color: Colors.amber, size: 40),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('+ Polo Positivo (Vermelho)', style: TextStyle(fontFamily: GoogleFonts.rajdhani().fontFamily, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                    Text('- Polo Negativo (Preto)', style: TextStyle(fontFamily: GoogleFonts.rajdhani().fontFamily, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ],
            ),
          'resistor' => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/components/resistor.png', height: 40),
                const SizedBox(width: 12),
                Text(
                  _current.scenario == InspectionScenario.incorrectResistor ? '68 Ω (Muito baixo)' : '680 Ω (Valor Didático)',
                  style: TextStyle(
                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _current.scenario == InspectionScenario.incorrectResistor ? Colors.red : const Color(0xFF0B3C2D),
                  ),
                ),
              ],
            ),
          'led' => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/components/led_off.png', height: 50),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('+ Ânodo (perna longa)', style: TextStyle(fontFamily: GoogleFonts.rajdhani().fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0B3C2D))),
                    Text('- Cátodo (lado reto)', style: TextStyle(fontFamily: GoogleFonts.rajdhani().fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          'switch' => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/components/switch_open.png', height: 45),
                const SizedBox(width: 12),
                Text('OFF — Aberto (Sem corrente)', style: TextStyle(fontFamily: GoogleFonts.rajdhani().fontFamily, fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0B3C2D))),
              ],
            ),
          'wires' => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.alt_route_rounded, color: Color(0xFF0B3C2D), size: 36),
                const SizedBox(width: 12),
                Text('Percurso Completo em Série', style: TextStyle(fontFamily: GoogleFonts.rajdhani().fontFamily, fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0B3C2D))),
              ],
            ),
          _ => const Icon(Icons.search_rounded, size: 36, color: Color(0xFF0B3C2D)),
        },
      ),
    );
  }

  // Botão de Ação Inferior (Concluir Inspeção / Testar Circuito)
  Widget _buildBottomActionButton() {
    if (_isTestReady) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _runCircuitTest,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(
            'TESTAR CIRCUITO',
            style: TextStyle(
              fontFamily: GoogleFonts.rajdhani().fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    if (_isDiagnosisMode) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _selectedDiagnosis != null ? _confirmDiagnosis : null,
          icon: const Icon(Icons.check_circle_rounded),
          label: Text(
            'CONFIRMAR DIAGNÓSTICO',
            style: TextStyle(
              fontFamily: GoogleFonts.rajdhani().fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 1.0,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0B3C2D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isAllPointsInspected ? _startDiagnosis : null,
        icon: Icon(_isAllPointsInspected ? Icons.check_circle_outline_rounded : Icons.lock_rounded),
        label: Text(
          'CONCLUIR INSPEÇÃO',
          style: TextStyle(
            fontFamily: GoogleFonts.rajdhani().fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 1.0,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0B3C2D),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFCBD5E1),
          disabledForegroundColor: const Color(0xFF64748B),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PAINTER DOS FIOS DO CIRCUITO 2.5D
// ==========================================
class CircuitWirePainter extends CustomPainter {
  final InspectionScenario scenario;
  final bool isEnergized;
  final bool isLedOn;
  final Animation<double> glowAnimation;
  final bool isMobileScale;

  CircuitWirePainter({
    required this.scenario,
    required this.isEnergized,
    required this.isLedOn,
    required this.glowAnimation,
    this.isMobileScale = false,
  }) : super(repaint: glowAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    // Definir pontos dos terminais conforme viewport
    final batPos = isMobileScale
        ? const Offset(70, 210)
        : const Offset(280, 500);

    final resLeft = isMobileScale
        ? const Offset(135, 82)
        : const Offset(555, 387);

    final resRight = isMobileScale
        ? const Offset(215, 82)
        : const Offset(715, 387);

    final ledAnode = isMobileScale
        ? const Offset(265, 170)
        : const Offset(920, 440);

    final ledCathode = isMobileScale
        ? const Offset(290, 170)
        : const Offset(960, 440);

    final swRight = isMobileScale
        ? const Offset(225, 272)
        : const Offset(685, 675);

    final swLeft = isMobileScale
        ? const Offset(145, 272)
        : const Offset(545, 675);

    final batNeg = isMobileScale
        ? const Offset(100, 210)
        : const Offset(330, 500);

    final redColor = const Color(0xFFDC2626);
    final blackColor = const Color(0xFF1E293B);

    // Fio 1: Bateria Positivo -> Resistor (ou LED no cenário missingResistor)
    final path1 = Path();
    path1.moveTo(batPos.dx, batPos.dy);
    if (scenario == InspectionScenario.missingResistor) {
      path1.cubicTo(
        batPos.dx, batPos.dy - 120,
        ledAnode.dx - 100, ledAnode.dy - 60,
        ledAnode.dx, ledAnode.dy,
      );
    } else {
      path1.cubicTo(
        batPos.dx, batPos.dy - 80,
        resLeft.dx - 80, resLeft.dy,
        resLeft.dx, resLeft.dy,
      );
    }
    _drawCable(canvas, path1, redColor);

    // Fio 2: Resistor -> LED (Se resistor estiver presente)
    if (scenario != InspectionScenario.missingResistor) {
      final path2 = Path();
      path2.moveTo(resRight.dx, resRight.dy);
      path2.cubicTo(
        resRight.dx + 80, resRight.dy,
        ledAnode.dx - 40, ledAnode.dy - 40,
        ledAnode.dx, ledAnode.dy,
      );
      _drawCable(canvas, path2, redColor);
    }

    // Fio 3: LED Cátodo -> Interruptor Direita
    final path3 = Path();
    path3.moveTo(ledCathode.dx, ledCathode.dy);
    path3.cubicTo(
      ledCathode.dx + 20, ledCathode.dy + 100,
      swRight.dx + 60, swRight.dy,
      swRight.dx, swRight.dy,
    );
    _drawCable(canvas, path3, blackColor);

    // Fio 4: Interruptor Esquerda -> Bateria Negativo
    final path4 = Path();
    path4.moveTo(swLeft.dx, swLeft.dy);
    if (scenario == InspectionScenario.openCircuit) {
      // Percurso interrompido (corte no meio)
      final midPoint = Offset((swLeft.dx + batNeg.dx) / 2, (swLeft.dy + batNeg.dy) / 2 + 20);
      path4.quadraticBezierTo(swLeft.dx - 40, swLeft.dy, midPoint.dx + 30, midPoint.dy);
      _drawCable(canvas, path4, blackColor);

      final path4b = Path();
      path4b.moveTo(batNeg.dx, batNeg.dy);
      path4b.quadraticBezierTo(batNeg.dx, batNeg.dy + 60, midPoint.dx - 30, midPoint.dy + 10);
      _drawCable(canvas, path4b, blackColor);
    } else {
      path4.cubicTo(
        swLeft.dx - 80, swLeft.dy,
        batNeg.dx, batNeg.dy + 80,
        batNeg.dx, batNeg.dy,
      );
      _drawCable(canvas, path4, blackColor);
    }
  }

  void _drawCable(Canvas canvas, Path path, Color color) {
    // Sombra do Fio na Bancada
    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..strokeWidth = isMobileScale ? 4.0 : 7.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Corpo Principal do Fio
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = isMobileScale ? 4.0 : 6.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Brilho de Reflexo Superior
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = isMobileScale ? 1.0 : 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Efeito de Brilho de Corrente quando Energizado e Correto
    if (isEnergized && isLedOn) {
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF00FF9D).withValues(alpha: 0.4 + (glowAnimation.value * 0.4))
          ..strokeWidth = isMobileScale ? 6.0 : 9.0
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircuitWirePainter oldDelegate) {
    return oldDelegate.scenario != scenario ||
        oldDelegate.isEnergized != isEnergized ||
        oldDelegate.isLedOn != isLedOn;
  }
}
