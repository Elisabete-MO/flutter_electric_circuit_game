import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/stand_mission.dart';
import '../../models/first_step_component.dart';
import '../../models/circuit_action.dart';
import '../../state/progress_controller.dart';
import '../../state/circuit_undo_redo_controller.dart';
import '../../services/circuit_solver/mission_circuit_builder.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/schematic_blueprint_socket.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/circuit_symbol_painter.dart';
import '../../widgets/street_lamp_painter.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/workbench_components.dart';
import '../../widgets/success_confetti_overlay.dart';

/// Tela Interativa do Estande 04 / Estande "Ruas da Maquete" (Equipe Bairro).
class RuasMaqueteScreen extends ConsumerStatefulWidget {
  const RuasMaqueteScreen({super.key});

  @override
  ConsumerState<RuasMaqueteScreen> createState() => _RuasMaqueteScreenState();
}

class _RuasMaqueteScreenState extends ConsumerState<RuasMaqueteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _electronAnimController;
  final CircuitUndoRedoController _undoRedoController = CircuitUndoRedoController();
  final List<StandMission> _missions = StandMission.ruasMaqueteMissions;
  int _currentMissionIndex = 0;
  bool _usePhysicalStyle = true;

  // Estados da Missão 1 (Postes em Série)
  bool _m1WireConnected = false;
  bool _m1WireInserted = false;

  // Estados da Missão 2 (Comparação de Brilho)
  bool _m2IsSeriesTwoBulbs = true;
  String? _m2SelectedExplanation;

  // Estados da Missão 3 (Bifurcação de Fios / Nó)
  bool _m3JunctionInserted = false;
  bool _m3ReturnConnected = false;

  // Estados da Missão 4 (Casas Independentes / Paralelo)
  bool _m4ParallelWireConnected = false;

  // Estados da Missão 5 (Teste de Manutenção do Bairro)
  bool _m5House1Broken = false;
  bool _m5MaintenanceConfirmed = false;

  // Estado de simulação
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _electronAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _electronAnimController.dispose();
    super.dispose();
  }

  void _insertComponent({
    required String name,
    required bool Function() getInserted,
    required void Function(bool) setInserted,
    required double Function() getRotation,
    required void Function(double) setRotation,
  }) {
    final prevInserted = getInserted();
    final prevRotation = getRotation();
    _undoRedoController.execute(InsertComponentAction(
      description: 'Inserir $name',
      onApply: () => setState(() { setInserted(true); setRotation(0); }),
      onUndo: () => setState(() { setInserted(prevInserted); setRotation(prevRotation); }),
    ));
  }

  StandMission get _currentMission => _missions[_currentMissionIndex];

  void _nextMission() {
    if (_currentMissionIndex < _missions.length - 1) {
      setState(() {
        _currentMissionIndex++;
      });
    } else {
      _showStandCompletionDialog();
    }
  }

  void _resetCurrentMission() {
    _undoRedoController.clear();
    setState(() {
      switch (_currentMissionIndex) {
        case 0:
          _m1WireConnected = false;
          _m1WireInserted = false;
          break;
        case 1:
          _m2IsSeriesTwoBulbs = true;
          _m2SelectedExplanation = null;
          break;
        case 2:
          _m3JunctionInserted = false;
          _m3ReturnConnected = false;
          break;
        case 3:
          _m4ParallelWireConnected = false;
          break;
        case 4:
          _m5House1Broken = false;
          _m5MaintenanceConfirmed = false;
          break;
      }
    });
  }

  Future<void> _validateCurrentMission() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedbackMessage = _currentMission.failureFeedback;

      switch (_currentMissionIndex) {
        case 0: // M1: Postes em Série
          if (_m1WireInserted || _m1WireConnected) {
            final result = await MissionCircuitBuilder()
                .addBattery(id: 'bat1', voltage: 4.5)
                .addBulb(id: 'bulb1', resistance: 5.0)
                .addBulb(id: 'bulb2', resistance: 5.0)
                .connect('bat1', 'B', 'bulb1', 'A')
                .connect('bulb1', 'B', 'bulb2', 'A')
                .connect('bulb2', 'B', 'bat1', 'A')
                .simulate();
            if (result.hasClosedLoop && result.errorMessage == null) {
              final currentMa = result.current * 1000;
              feedbackMessage = 'Circuito em série validado! Corrente: ${currentMa.toStringAsFixed(1)}mA. '
                  'Ambas as lâmpadas recebem a mesma corrente.';
              isSuccess = true;
            } else {
              feedbackMessage = result.errorMessage ?? 'Circuito em série incompleto. Verifique as conexões.';
            }
          } else {
            feedbackMessage = 'Conecte o fio condutor em série para fechar o circuito dos postes!';
          }
          break;

        case 1: // M2: Comparação de Brilho
          if (_m2SelectedExplanation == 'corrente_reduzida') {
            isSuccess = true;
          } else if (_m2SelectedExplanation == null) {
            feedbackMessage = 'Selecione a explicação física sobre o motivo do brilho atenuado em série.';
          } else {
            feedbackMessage = 'Pense bem: no circuito em série, adicionar mais resistências reduz a corrente total.';
          }
          break;

        case 2: // M3: Bifurcação de Fios
          if (_m3JunctionInserted && _m3ReturnConnected) {
            final result = await MissionCircuitBuilder()
                .addBattery(id: 'bat1', voltage: 4.5)
                .addBulb(id: 'bulbA', resistance: 5.0)
                .addBulb(id: 'bulbB', resistance: 5.0)
                .connect('bat1', 'B', 'bulbA', 'A')
                .connect('bulbA', 'B', 'bat1', 'A')
                .connect('bat1', 'B', 'bulbB', 'A')
                .connect('bulbB', 'B', 'bat1', 'A')
                .simulate();
            if (result.hasClosedLoop && result.errorMessage == null) {
              feedbackMessage = 'Bifurcação validada! A corrente se divide em dois ramos independentes e reconverge ao polo negativo.';
              isSuccess = true;
            } else {
              feedbackMessage = result.errorMessage ?? 'A bifurcação precisa se reconectar ao polo negativo da fonte.';
            }
          } else if (!_m3JunctionInserted) {
            feedbackMessage = 'Insira o nó de bifurcação para dividir a corrente para as duas ruas.';
          } else {
            feedbackMessage = 'A bifurcação precisa se reconectar ao polo negativo da fonte.';
          }
          break;

        case 3: // M4: Paralelo
          if (_m4ParallelWireConnected) {
            final result = await MissionCircuitBuilder()
                .addBattery(id: 'bat1', voltage: 4.5)
                .addBulb(id: 'bulb1', resistance: 5.0)
                .addBulb(id: 'bulb2', resistance: 5.0)
                .connect('bat1', 'B', 'bulb1', 'A')
                .connect('bulb1', 'B', 'bat1', 'A')
                .connect('bat1', 'B', 'bulb2', 'A')
                .connect('bulb2', 'B', 'bat1', 'A')
                .simulate();
            if (result.hasClosedLoop && result.errorMessage == null) {
              final current1 = (result.componentCurrents['bulb1'] ?? 0) * 1000;
              final current2 = (result.componentCurrents['bulb2'] ?? 0) * 1000;
              feedbackMessage = 'Circuito em paralelo validado! '
                  'Lâmpada 1: ${current1.toStringAsFixed(1)}mA, Lâmpada 2: ${current2.toStringAsFixed(1)}mA. '
                  'Ambas recebem tensão total da bateria.';
              isSuccess = true;
            } else {
              feedbackMessage = result.errorMessage ?? 'Monte as ligações em paralelo para que cada casa tenha seu ramo individual.';
            }
          } else {
            feedbackMessage = 'Monte as ligações em paralelo para que cada casa tenha seu ramo individual.';
          }
          break;

        case 4: // M5: Manutenção
          if (_m5House1Broken && _m5MaintenanceConfirmed) {
            final result = await MissionCircuitBuilder()
                .addBattery(id: 'bat1', voltage: 4.5)
                .addBulb(id: 'bulbB', resistance: 5.0)
                .connect('bat1', 'B', 'bulbB', 'A')
                .connect('bulbB', 'B', 'bat1', 'A')
                .simulate();
            if (result.hasClosedLoop && result.errorMessage == null) {
              feedbackMessage = 'Manutenção validada! A Lâmpada B permanece acesa mesmo com a Lâmpada A desconectada. '
                  'Em paralelo, os ramos são independentes.';
              isSuccess = true;
            } else {
              feedbackMessage = result.errorMessage ?? 'Erro na simulação do circuito.';
            }
          } else if (!_m5House1Broken) {
            feedbackMessage = 'Simule o defeito na Lâmpada A para testar a independência do circuito!';
          } else {
            feedbackMessage = 'Confirme o resultado da manutenção ao observar que a Lâmpada B permanece acesa.';
          }
          break;
      }

      final fullMessage = isSuccess
          ? 'Missão "${_currentMission.title}" concluída com êxito! ${_currentMission.victoryCriteria}.\n\nProf. Volts: "${_currentMission.voltsMediation}"'
          : '$feedbackMessage\n\nProf. Volts: "${_currentMission.voltsMediation}"';

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ProfVoltsFeedbackDialog(
            isCorrect: isSuccess,
            message: fullMessage,
            onAction: () {
              Navigator.of(context).pop();
              if (isSuccess) {
                showSuccessConfetti(context);
                _nextMission();
              }
            },
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  void _showStandCompletionDialog() {
    ref.read(progressControllerProvider.notifier).markAsCompleted('ruas_maquete', stars: 3);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Estande Concluído!',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parabéns! A Equipe Bairro padronizou a iluminação das "Ruas da Maquete" com circuitos em série e paralelo!',
              style: GoogleFonts.rajdhani(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology_rounded, color: Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Selo "Distribuição Comunitária" conquistado!',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Voltar ao Mapa da Feira',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ESTANDE 04 — RUAS DA MAQUETE',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Equipe Bairro — Circuito em Série e Paralelo',
              style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0284C7)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: TechGridBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Coluna Principal da Bancada (60%)
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      WorkbenchHeaderStepper(
                        totalMissions: _missions.length,
                        currentMissionIndex: _currentMissionIndex,
                        missionTitle: _missions[_currentMissionIndex].title,
                        missionObjective: _missions[_currentMissionIndex].objective,
                        onPrevious: _currentMissionIndex > 0
                            ? () => setState(() => _currentMissionIndex--)
                            : null,
                        onNext: _currentMissionIndex < _missions.length - 1
                            ? () => setState(() => _currentMissionIndex++)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      _buildVisualModeSelector(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildMaqueteWorkbench(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Painel Lateral (40%)
                Expanded(
                  flex: 2,
                  child: WorkbenchSidePanel(
                    teamTitle: 'Gaveta de Símbolos — Maquete',
                    toolboxItems: [
                      _buildSideToolboxDrawer(),
                    ],
                    onEnergizePressed: _validateCurrentMission,
                    isLoading: _isSimulating,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opção 1: Esquemático
          GestureDetector(
            onTap: () => setState(() => _usePhysicalStyle = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: !_usePhysicalStyle
                    ? const Color(0xFF0284C7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: !_usePhysicalStyle
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.architecture_rounded,
                    size: 16,
                    color: !_usePhysicalStyle
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Esquemático',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: !_usePhysicalStyle
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Opção 2: Físico 3D
          GestureDetector(
            onTap: () => setState(() => _usePhysicalStyle = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _usePhysicalStyle
                    ? const Color(0xFF0284C7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _usePhysicalStyle
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.electrical_services_rounded,
                    size: 16,
                    color: _usePhysicalStyle
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Físico 3D',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _usePhysicalStyle
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Desenho interativo da bancada simulando as Ruas da Maquete com alinhamento preciso
  Widget _buildMaqueteWorkbench() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final lampY = h * 0.28;
        final socketY = h * 0.80;
        final lamp1X = w * 0.28;
        final lamp2X = w * 0.72;
        final socketX = w * 0.50;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Painter customizado com linhas esquemáticas e elétrons alinhados aos componentes
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _electronAnimController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _RuasMaquetePainter(
                      missionIndex: _currentMissionIndex,
                      animValue: _electronAnimController.value,
                      m1Connected: _m1WireInserted || _m1WireConnected,
                      m2Series: _m2IsSeriesTwoBulbs,
                      m3Junction: _m3JunctionInserted,
                      m3Return: _m3ReturnConnected,
                      m4Parallel: _m4ParallelWireConnected,
                      m5House1Broken: _m5House1Broken,
                      usePhysicalStyle: _usePhysicalStyle,
                      lampY: lampY,
                      socketY: socketY,
                      lamp1X: lamp1X,
                      lamp2X: lamp2X,
                      socketX: socketX,
                    ),
                  );
                },
              ),
            ),

            // Interatividade Visual Específica por Missão com Alinhamento Exato
            ..._buildMissionOverlayElements(
              lamp1X: lamp1X,
              lamp2X: lamp2X,
              socketX: socketX,
              lampY: lampY,
              socketY: socketY,
            ),
          ],
        );
      },
    );
  }

  /// Elementos visuais sobrepostos e interativos na bancada posicionados com precisão matemática
  List<Widget> _buildMissionOverlayElements({
    required double lamp1X,
    required double lamp2X,
    required double socketX,
    required double lampY,
    required double socketY,
  }) {
    switch (_currentMissionIndex) {
      case 0:
        return _buildM1OverlayElements(lamp1X, lamp2X, socketX, lampY, socketY);
      case 1:
        return _buildM2OverlayElements(lamp1X, lamp2X, socketX, lampY, socketY);
      case 2:
        return _buildM3OverlayElements(lamp1X, lamp2X, socketX, lampY, socketY);
      case 3:
        return _buildM4OverlayElements(lamp1X, lamp2X, socketX, lampY, socketY);
      case 4:
        return _buildM5OverlayElements(lamp1X, lamp2X, socketX, lampY, socketY);
      default:
        return [];
    }
  }

  /// Overlay da Missão 1: Conexão em Série de Postes
  List<Widget> _buildM1OverlayElements(double l1X, double l2X, double sX, double lY, double sY) {
    final isLit = _m1WireInserted || _m1WireConnected;
    return [
      // Componente Poste 1 (Alameda)
      Positioned(
        left: l1X - 40,
        top: lY - 30,
        child: _buildLampSymbol(
          isLit: isLit,
          brightnessRatio: isLit ? 0.5 : 0.0,
        ),
      ),
      Positioned(
        left: l1X - 75,
        top: lY + 34,
        width: 150,
        child: Center(child: _buildLabelBadge('Poste 1 (Alameda)')),
      ),

      // Componente Poste 2 (Avenida)
      Positioned(
        left: l2X - 40,
        top: lY - 30,
        child: _buildLampSymbol(
          isLit: isLit,
          brightnessRatio: isLit ? 0.5 : 0.0,
        ),
      ),
      Positioned(
        left: l2X - 75,
        top: lY + 34,
        width: 150,
        child: Center(child: _buildLabelBadge('Poste 2 (Avenida)')),
      ),

      // Socket do Fio em Série
      Positioned(
        left: sX - 40,
        top: sY - 32,
        child: SizedBox(
          width: 80,
          height: 65,
          child: SchematicBlueprintSocket<String>(
            width: 80,
            height: 65,
            expectedData: 'fio_serie',
            isFilled: isLit,
            showLabel: false,
            onAccept: (_) => _insertComponent(
              name: 'Fio em Série',
              getInserted: () => _m1WireInserted,
              setInserted: (v) {
                _m1WireInserted = v;
                _m1WireConnected = v;
              },
              getRotation: () => 0,
              setRotation: (_) {},
            ),
            onTap: () {
              _insertComponent(
                name: 'Fio em Série',
                getInserted: () => _m1WireInserted,
                setInserted: (v) {
                  _m1WireInserted = v;
                  _m1WireConnected = v;
                },
                getRotation: () => 0,
                setRotation: (_) {},
              );
            },
            symbolWidget: _usePhysicalStyle
                ? CustomPaint(
                    size: const Size(50, 50),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.connectingWire,
                      isDarkMode: false,
                    ),
                  )
                : CustomPaint(
                    size: const Size(50, 50),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.connectingWire,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.5,
                    ),
                  ),
            placeholderWidget: _usePhysicalStyle
                ? CustomPaint(
                    size: const Size(45, 45),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.connectingWire,
                      isDarkMode: false,
                    ),
                  )
                : CustomPaint(
                    size: const Size(45, 45),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.connectingWire,
                      color: const Color(0xFF94A3B8),
                      strokeWidth: 2.0,
                    ),
                  ),
            label: '',
          ),
        ),
      ),
    ];
  }

  /// Overlay da Missão 2: Comparação de Brilho 1 vs 2 Lâmpadas
  List<Widget> _buildM2OverlayElements(double l1X, double l2X, double sX, double lY, double sY) {
    return [
      // Poste Principal
      Positioned(
        left: l1X - 40,
        top: lY - 30,
        child: _buildLampSymbol(
          isLit: true,
          brightnessRatio: _m2IsSeriesTwoBulbs ? 0.5 : 1.0,
        ),
      ),
      Positioned(
        left: l1X - 75,
        top: lY + 34,
        width: 150,
        child: Center(child: _buildLabelBadge('Poste Principal')),
      ),

      // Poste Secundário (Série)
      if (_m2IsSeriesTwoBulbs) ...[
        Positioned(
          left: l2X - 40,
          top: lY - 30,
          child: _buildLampSymbol(
            isLit: true,
            brightnessRatio: 0.5,
          ),
        ),
        Positioned(
          left: l2X - 75,
          top: lY + 34,
          width: 150,
          child: Center(child: _buildLabelBadge('Poste Secundário (Série)')),
        ),
      ],

      // Painel de Teste de Modo
      Positioned(
        left: sX - 220,
        top: sY - 25,
        width: 440,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Modo de Teste: ',
                style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('1 Poste (100% Brilho)'),
                selected: !_m2IsSeriesTwoBulbs,
                onSelected: (val) => setState(() => _m2IsSeriesTwoBulbs = !val),
                selectedColor: const Color(0xFF10B981),
                backgroundColor: const Color(0xFF1E293B),
                labelStyle: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('2 Postes em Série (50% Brilho)'),
                selected: _m2IsSeriesTwoBulbs,
                onSelected: (val) => setState(() => _m2IsSeriesTwoBulbs = val),
                selectedColor: Colors.amberAccent,
                backgroundColor: const Color(0xFF1E293B),
                labelStyle: GoogleFonts.rajdhani(
                  color: _m2IsSeriesTwoBulbs ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  /// Overlay da Missão 3: Bifurcação de Fios (Nó)
  List<Widget> _buildM3OverlayElements(double l1X, double l2X, double sX, double lY, double sY) {
    final bothLit = _m3JunctionInserted && _m3ReturnConnected;
    final nodeY = lY + 45.0;

    return [
      // Rua A (Nó Norte)
      Positioned(
        left: l1X - 40,
        top: lY - 30,
        child: _buildLampSymbol(
          isLit: bothLit,
          brightnessRatio: bothLit ? 1.0 : 0.0,
        ),
      ),
      Positioned(
        left: l1X - 75,
        top: lY + 34,
        width: 150,
        child: Center(child: _buildLabelBadge('Rua A (Nó Norte)')),
      ),

      // Rua B (Nó Sul)
      Positioned(
        left: l2X - 40,
        top: lY - 30,
        child: _buildLampSymbol(
          isLit: bothLit,
          brightnessRatio: bothLit ? 1.0 : 0.0,
        ),
      ),
      Positioned(
        left: l2X - 75,
        top: lY + 34,
        width: 150,
        child: Center(child: _buildLabelBadge('Rua B (Nó Sul)')),
      ),

      // Indicador Visual do Nó de Junção
      Positioned(
        left: sX - 40,
        top: nodeY - 14,
        width: 80,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _m3JunctionInserted ? const Color(0xFF10B981) : const Color(0xFF64748B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Nó (+)',
              style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
      ),

      // Botões de Ação da Missão 3
      Positioned(
        left: sX - 220,
        top: sY - 25,
        width: 440,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _m3JunctionInserted ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFF10B981)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: Icon(_m3JunctionInserted ? Icons.check : Icons.call_split_rounded, size: 16),
              label: Text(
                _m3JunctionInserted ? 'Nó Inserido' : '1. Inserir Nó de Junção',
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () {
                _insertComponent(
                  name: 'Nó de Junção',
                  getInserted: () => _m3JunctionInserted,
                  setInserted: (v) => _m3JunctionInserted = v,
                  getRotation: () => 0,
                  setRotation: (_) {},
                );
              },
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _m3ReturnConnected ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFF10B981)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: Icon(_m3ReturnConnected ? Icons.check : Icons.subdirectory_arrow_left_rounded, size: 16),
              label: Text(
                _m3ReturnConnected ? 'Retorno Reconectado' : '2. Reconectar Retorno (-)',
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () {
                _insertComponent(
                  name: 'Retorno Reconectado',
                  getInserted: () => _m3ReturnConnected,
                  setInserted: (v) => _m3ReturnConnected = v,
                  getRotation: () => 0,
                  setRotation: (_) {},
                );
              },
            ),
          ],
        ),
      ),
    ];
  }

  /// Overlay da Missão 4: Casas Independentes (Paralelo)
  List<Widget> _buildM4OverlayElements(double l1X, double l2X, double sX, double lY, double sY) {
    return [
      // Casa 01
      Positioned(
        left: l1X - 40,
        top: lY - 30,
        child: _buildHouseSymbol(
          name: 'Casa 01 (Alameda)',
          isLit: _m4ParallelWireConnected,
          brightness: 1.0,
        ),
      ),
      Positioned(
        left: l1X - 75,
        top: lY + 34,
        width: 150,
        child: Center(child: _buildLabelBadge('Casa 01 (Alameda)')),
      ),

      // Casa 02
      Positioned(
        left: l2X - 40,
        top: lY - 30,
        child: _buildHouseSymbol(
          name: 'Casa 02 (Praça)',
          isLit: _m4ParallelWireConnected,
          brightness: 1.0,
        ),
      ),
      Positioned(
        left: l2X - 75,
        top: lY + 34,
        width: 150,
        child: Center(child: _buildLabelBadge('Casa 02 (Praça)')),
      ),

      // Botão Conectar Fiação em Paralelo
      Positioned(
        left: sX - 200,
        top: sY - 25,
        width: 400,
        child: InkWell(
          onTap: () {
            _insertComponent(
              name: 'Fiação em Paralelo',
              getInserted: () => _m4ParallelWireConnected,
              setInserted: (v) => _m4ParallelWireConnected = v,
              getRotation: () => 0,
              setRotation: (_) {},
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: _m4ParallelWireConnected
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _m4ParallelWireConnected ? const Color(0xFF10B981) : Colors.amberAccent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _m4ParallelWireConnected ? Icons.check_circle_rounded : Icons.alt_route_rounded,
                  color: _m4ParallelWireConnected ? const Color(0xFF10B981) : Colors.amberAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _m4ParallelWireConnected
                      ? 'Circuito em Paralelo Ativo (Brilho Máximo)'
                      : 'Clique para Conectar Fiação em Paralelo',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  /// Overlay da Missão 5: Teste de Manutenção do Bairro
  List<Widget> _buildM5OverlayElements(double l1X, double l2X, double sX, double lY, double sY) {
    return [
      // Lâmpada A
      Positioned(
        left: l1X - 40,
        top: lY - 30,
        child: _buildHouseSymbol(
          name: 'Lâmpada A (Simulada)',
          isLit: !_m5House1Broken,
          brightness: !_m5House1Broken ? 1.0 : 0.0,
          isBroken: _m5House1Broken,
        ),
      ),
      Positioned(
        left: l1X - 75,
        top: lY + 34,
        width: 150,
        child: Center(child: _buildLabelBadge('Lâmpada A (Simulada)', isBroken: _m5House1Broken)),
      ),

      // Lâmpada B
      Positioned(
        left: l2X - 40,
        top: lY - 30,
        child: _buildHouseSymbol(
          name: 'Lâmpada B (Testada)',
          isLit: true,
          brightness: 1.0,
        ),
      ),
      Positioned(
        left: l2X - 75,
        top: lY + 34,
        width: 150,
        child: Center(child: _buildLabelBadge('Lâmpada B (Testada)')),
      ),

      // Botões da Missão 5
      Positioned(
        left: sX - 230,
        top: sY - 25,
        width: 460,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _m5House1Broken ? Colors.redAccent.withValues(alpha: 0.8) : const Color(0xFF1E293B),
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              icon: const Icon(Icons.flash_off_rounded, color: Colors.white, size: 16),
              label: Text(
                _m5House1Broken ? 'Lâmpada A Desconectada' : 'Simular Defeito Lâmpada A',
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () {
                _insertComponent(
                  name: 'Simular Defeito Lâmpada A',
                  getInserted: () => _m5House1Broken,
                  setInserted: (v) => _m5House1Broken = v,
                  getRotation: () => 0,
                  setRotation: (_) {},
                );
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _m5MaintenanceConfirmed ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFF10B981)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              icon: Icon(_m5MaintenanceConfirmed ? Icons.verified_rounded : Icons.check_circle_outline_rounded, size: 16),
              label: Text(
                _m5MaintenanceConfirmed ? 'Lâmpada B Acesa' : 'Confirmar Manutenção',
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () {
                _insertComponent(
                  name: 'Confirmar Manutenção',
                  getInserted: () => _m5MaintenanceConfirmed,
                  setInserted: (v) => _m5MaintenanceConfirmed = v,
                  getRotation: () => 0,
                  setRotation: (_) {},
                );
              },
            ),
          ],
        ),
      ),
    ];
  }

  /// Componente dinâmico do painel lateral para perguntas/ferramentas
  Widget _buildSidePanelMissionContent() {
    Widget content;
    switch (_currentMissionIndex) {
      case 0:
        content = _buildM1SideTools();
        break;
      case 1:
        content = _buildM2SideTools();
        break;
      case 2:
        content = _buildM3SideTools();
        break;
      case 3:
        content = _buildM4SideTools();
        break;
      case 4:
        content = _buildM5SideTools();
        break;
      default:
        content = const SizedBox.shrink();
    }
    return Column(
      children: [
        content,
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
            onPressed: _resetCurrentMission,
            label: Text(
              'Reiniciar Montagem',
              style: GoogleFonts.rajdhani(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideToolboxDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'SÍMBOLOS DISPONÍVEIS (ARRASTE PARA O ESQUEMA):',
            style: GoogleFonts.rajdhani(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Bateria
            WorkbenchSymbolToolboxTile<String>(
              data: 'battery',
              label: 'Bateria',
              tooltip: 'Fonte de Alimentação 4.5V',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.battery,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.battery,
                        color: const Color(0xFFD97706),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFFD97706),
            ),
            // Lâmpada
            WorkbenchSymbolToolboxTile<String>(
              data: 'bulb',
              label: 'Lâmpada',
              tooltip: 'Poste de Iluminação',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.bulb,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.bulb,
                        color: const Color(0xFF10B981),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF10B981),
            ),
            // Condutor
            WorkbenchSymbolToolboxTile<String>(
              data: 'fio_serie',
              label: 'Condutor',
              tooltip: 'Condutor em Série',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.connectingWire,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.connectingWire,
                        color: const Color(0xFF0F172A),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF0284C7),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildUndoRedoButtons(),
        _buildSidePanelMissionContent(),
      ],
    );
  }

  Widget _buildUndoRedoButtons() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
            message: _undoRedoController.canUndo
                ? 'Desfazer: ${_undoRedoController.lastUndoDescription}'
                : 'Nada para desfazer',
            child: IconButton(
              icon: Icon(
                Icons.undo_rounded,
                color: _undoRedoController.canUndo
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFCBD5E1),
                size: 22,
              ),
              onPressed: _undoRedoController.canUndo
                  ? () => setState(() => _undoRedoController.undo())
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: _undoRedoController.canUndo
                    ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${_undoRedoController.undoCount}',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Tooltip(
            message: _undoRedoController.canRedo
                ? 'Refazer: ${_undoRedoController.lastRedoDescription}'
                : 'Nada para refazer',
            child: IconButton(
              icon: Icon(
                Icons.redo_rounded,
                color: _undoRedoController.canRedo
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFCBD5E1),
                size: 22,
              ),
              onPressed: _undoRedoController.canRedo
                  ? () => setState(() => _undoRedoController.redo())
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: _undoRedoController.canRedo
                    ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildM1SideTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dica do Professor Volts:',
          style: GoogleFonts.rajdhani(color: const Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          'Arraste ou toque no símbolo do Condutor em Série para conectar os dois postes da maquete em circuito em série.',
          style: GoogleFonts.rajdhani(color: const Color(0xFF475569), fontSize: 13, height: 1.3),
        ),
      ],
    );
  }

  Widget _buildM2SideTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pergunta de Investigação Física:',
          style: GoogleFonts.rajdhani(color: const Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Por que o brilho dos dois postes diminuiu ao ligá-los no mesmo caminho em série?',
          style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildExplanationOption(
          id: 'corrente_reduzida',
          text: 'Porque a corrente elétrica encontrou duas resistências na mesma rota, reduzindo a corrente disponível para cada lâmpada.',
        ),
        _buildExplanationOption(
          id: 'bateria_esgotada',
          text: 'Porque a bateria perdeu toda a sua energia instantaneamente ao acender o segundo poste.',
        ),
        _buildExplanationOption(
          id: 'mais_energia',
          text: 'Porque ligar postes em série gera mais energia do que a fonte original fornece.',
        ),
      ],
    );
  }

  Widget _buildExplanationOption({required String id, required String text}) {
    final isSelected = _m2SelectedExplanation == id;
    return InkWell(
      onTap: () {
        setState(() {
          _m2SelectedExplanation = id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.rajdhani(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildM3SideTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dica Pedagógica do Prof. Volts:',
          style: GoogleFonts.rajdhani(color: const Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          'Uma bifurcação (nó) divide a corrente em duas rotas separadas (Rua A e Rua B). Ambas precisam se reconectar ao polo negativo para fechar o circuito!',
          style: GoogleFonts.rajdhani(color: const Color(0xFF475569), fontSize: 14, height: 1.3),
        ),
      ],
    );
  }

  Widget _buildM4SideTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vantagem do Circuito em Paralelo:',
          style: GoogleFonts.rajdhani(color: const Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          'Cada casa do bairro recebe a tensão total da bateria (4.5V). Assim, todas as lâmpadas acendem com 100% de brilho máximo sem interferência!',
          style: GoogleFonts.rajdhani(color: const Color(0xFF475569), fontSize: 14, height: 1.3),
        ),
      ],
    );
  }

  Widget _buildM5SideTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conclusão da Equipe Bairro:',
          style: GoogleFonts.rajdhani(color: const Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          'Em paralelo, quando a Lâmpada A se queima ou é removida, a Lâmpada B continua recebendo corrente em seu ramo independente. É por isso que as casas da cidade usam ligação em paralelo!',
          style: GoogleFonts.rajdhani(color: const Color(0xFF475569), fontSize: 14, height: 1.3),
        ),
      ],
    );
  }

  /// Componente didático de lâmpada/poste centralizado
  Widget _buildLampSymbol({
    required bool isLit,
    required double brightnessRatio,
  }) {
    return SizedBox(
      width: 80,
      height: 60,
      child: Center(
        child: _usePhysicalStyle
            ? CustomPaint(
                size: const Size(60, 60),
                painter: StreetLampPainter(
                  isActive: isLit,
                  brightnessRatio: brightnessRatio,
                  isDarkMode: false,
                ),
              )
            : CustomPaint(
                size: const Size(55, 55),
                painter: CircuitSymbolPainter(
                  type: ComponentType.bulb,
                  isActive: isLit,
                  color: const Color(0xFF0F172A),
                  strokeWidth: 2.5,
                ),
              ),
      ),
    );
  }

  /// Componente didático visual de casa da maquete centralizado
  Widget _buildHouseSymbol({
    required String name,
    required bool isLit,
    required double brightness,
    bool isBroken = false,
  }) {
    return SizedBox(
      width: 80,
      height: 60,
      child: Center(
        child: _usePhysicalStyle
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLit ? const Color(0xFFFEF3C7) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBroken
                        ? const Color(0xFFDC2626)
                        : isLit
                            ? const Color(0xFFD97706)
                            : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                  boxShadow: isLit
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                            blurRadius: 10,
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  isBroken
                      ? Icons.gavel_rounded
                      : isLit
                          ? Icons.home_rounded
                          : Icons.home_outlined,
                  size: 32,
                  color: isBroken
                      ? const Color(0xFFDC2626)
                      : isLit
                          ? const Color(0xFFD97706)
                          : const Color(0xFF64748B),
                ),
              )
            : CustomPaint(
                size: const Size(55, 55),
                painter: CircuitSymbolPainter(
                  type: ComponentType.bulb,
                  isActive: isLit && !isBroken,
                  isBurned: isBroken,
                  color: const Color(0xFF0F172A),
                  strokeWidth: 2.5,
                ),
              ),
      ),
    );
  }

  /// Badge de Rótulo posicionado abaixo do componente
  Widget _buildLabelBadge(String text, {bool isBroken = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isBroken ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.rajdhani(
          color: isBroken ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Custom Painter com traçados esquemáticos e físicos ajustados aos terminais dos componentes
class _RuasMaquetePainter extends CustomPainter {
  final int missionIndex;
  final double animValue;
  final bool m1Connected;
  final bool m2Series;
  final bool m3Junction;
  final bool m3Return;
  final bool m4Parallel;
  final bool m5House1Broken;
  final bool usePhysicalStyle;
  final double lampY;
  final double socketY;
  final double lamp1X;
  final double lamp2X;
  final double socketX;

  _RuasMaquetePainter({
    required this.missionIndex,
    required this.animValue,
    required this.m1Connected,
    required this.m2Series,
    required this.m3Junction,
    required this.m3Return,
    required this.m4Parallel,
    required this.m5House1Broken,
    required this.usePhysicalStyle,
    required this.lampY,
    required this.socketY,
    required this.lamp1X,
    required this.lamp2X,
    required this.socketX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = usePhysicalStyle ? const Color(0xFF94A3B8) : const Color(0xFF64748B)
      ..strokeWidth = usePhysicalStyle ? 4.0 : 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final activeWirePaint = Paint()
      ..color = usePhysicalStyle ? const Color(0xFF0284C7) : const Color(0xFF0F172A)
      ..strokeWidth = usePhysicalStyle ? 5.0 : 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final electronPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.fill;

    final nodePaint = Paint()
      ..color = activeWirePaint.color
      ..style = PaintingStyle.fill;

    // Terminais dos componentes (esquerda / direita)
    const termOffset = 32.0;
    const socketTermOffset = 30.0;

    void drawTerminalDot(Offset pos) {
      canvas.drawCircle(pos, usePhysicalStyle ? 4.5 : 3.5, nodePaint);
    }

    // Desenhar caminhos de fios conforme a missão
    if (missionIndex == 0 || (missionIndex == 1 && m2Series)) {
      // M1 e M2 (2 Lâmpadas em Série): Socket (+) -> Lamp1 -> Lamp2 -> Socket (-)
      final isConnected = missionIndex == 0 ? m1Connected : true;
      final currentPaint = isConnected ? activeWirePaint : wirePaint;

      // Haste 1: Do Socket (+ esquerda) subindo até a esquerda da Lâmpada 1
      final path1 = Path()
        ..moveTo(socketX - socketTermOffset, socketY)
        ..lineTo(lamp1X - termOffset, socketY)
        ..lineTo(lamp1X - termOffset, lampY);

      // Haste 2 (Série): Da direita da Lâmpada 1 até a esquerda da Lâmpada 2
      final path2 = Path()
        ..moveTo(lamp1X + termOffset, lampY)
        ..lineTo(lamp2X - termOffset, lampY);

      // Haste 3: Da direita da Lâmpada 2 descendo até o Socket (- direita)
      final path3 = Path()
        ..moveTo(lamp2X + termOffset, lampY)
        ..lineTo(lamp2X + termOffset, socketY)
        ..lineTo(socketX + socketTermOffset, socketY);

      canvas.drawPath(path1, currentPaint);
      canvas.drawPath(path2, currentPaint);
      canvas.drawPath(path3, currentPaint);

      // Nós de conexão visual nos terminais
      drawTerminalDot(Offset(socketX - socketTermOffset, socketY));
      drawTerminalDot(Offset(lamp1X - termOffset, lampY));
      drawTerminalDot(Offset(lamp1X + termOffset, lampY));
      drawTerminalDot(Offset(lamp2X - termOffset, lampY));
      drawTerminalDot(Offset(lamp2X + termOffset, lampY));
      drawTerminalDot(Offset(socketX + socketTermOffset, socketY));

      if (isConnected) {
        _drawElectronsOnPath(canvas, path1, electronPaint);
        _drawElectronsOnPath(canvas, path2, electronPaint);
        _drawElectronsOnPath(canvas, path3, electronPaint);
      }
    } else if (missionIndex == 1 && !m2Series) {
      // M2 (1 Lâmpada Apenas): Socket (+) -> Lamp1 -> Socket (-)
      final path1 = Path()
        ..moveTo(socketX - socketTermOffset, socketY)
        ..lineTo(lamp1X - termOffset, socketY)
        ..lineTo(lamp1X - termOffset, lampY);

      final pathReturn = Path()
        ..moveTo(lamp1X + termOffset, lampY)
        ..lineTo(lamp1X + termOffset, socketY)
        ..lineTo(socketX + socketTermOffset, socketY);

      canvas.drawPath(path1, activeWirePaint);
      canvas.drawPath(pathReturn, activeWirePaint);

      drawTerminalDot(Offset(socketX - socketTermOffset, socketY));
      drawTerminalDot(Offset(lamp1X - termOffset, lampY));
      drawTerminalDot(Offset(lamp1X + termOffset, lampY));
      drawTerminalDot(Offset(socketX + socketTermOffset, socketY));

      _drawElectronsOnPath(canvas, path1, electronPaint);
      _drawElectronsOnPath(canvas, pathReturn, electronPaint);
    } else if (missionIndex == 2) {
      // M3: Bifurcação de Fios (Nó de Junção)
      final isBothActive = m3Junction && m3Return;
      final nodeY = lampY + 45.0;

      // Alimentação Principal (+)
      final pathFeed = Path()
        ..moveTo(socketX - socketTermOffset, socketY)
        ..lineTo(socketX - socketTermOffset, nodeY)
        ..lineTo(socketX, nodeY);

      // Ramo Lâmpada A
      final pathBranchA = Path()
        ..moveTo(socketX, nodeY)
        ..lineTo(lamp1X + termOffset, nodeY)
        ..lineTo(lamp1X + termOffset, lampY);

      // Ramo Lâmpada B
      final pathBranchB = Path()
        ..moveTo(socketX, nodeY)
        ..lineTo(lamp2X - termOffset, nodeY)
        ..lineTo(lamp2X - termOffset, lampY);

      // Retorno do Nó
      final pathReturn = Path()
        ..moveTo(lamp1X - termOffset, lampY)
        ..lineTo(lamp1X - termOffset, socketY)
        ..lineTo(socketX + socketTermOffset, socketY);

      final pathReturnB = Path()
        ..moveTo(lamp2X + termOffset, lampY)
        ..lineTo(lamp2X + termOffset, socketY)
        ..lineTo(socketX + socketTermOffset, socketY);

      canvas.drawPath(pathFeed, m3Junction ? activeWirePaint : wirePaint);
      canvas.drawPath(pathBranchA, m3Junction ? activeWirePaint : wirePaint);
      canvas.drawPath(pathBranchB, m3Junction ? activeWirePaint : wirePaint);
      canvas.drawPath(pathReturn, m3Return ? activeWirePaint : wirePaint);
      canvas.drawPath(pathReturnB, m3Return ? activeWirePaint : wirePaint);

      drawTerminalDot(Offset(socketX, nodeY));
      drawTerminalDot(Offset(socketX - socketTermOffset, socketY));
      drawTerminalDot(Offset(socketX + socketTermOffset, socketY));

      if (isBothActive) {
        _drawElectronsOnPath(canvas, pathFeed, electronPaint);
        _drawElectronsOnPath(canvas, pathBranchA, electronPaint);
        _drawElectronsOnPath(canvas, pathBranchB, electronPaint);
        _drawElectronsOnPath(canvas, pathReturn, electronPaint);
        _drawElectronsOnPath(canvas, pathReturnB, electronPaint);
      }
    } else if (missionIndex == 3 || missionIndex == 4) {
      // M4 e M5: Circuito em Paralelo
      final isActive = m4Parallel || missionIndex == 4;
      final currentPaint = isActive ? activeWirePaint : wirePaint;
      const busOffset = 48.0;

      // Barramento Positivo Left
      final pathBusLeft = Path()
        ..moveTo(socketX - socketTermOffset, socketY)
        ..lineTo(lamp1X - busOffset, socketY)
        ..lineTo(lamp1X - busOffset, lampY)
        ..lineTo(lamp2X - busOffset, lampY);

      final branch1Pos = Path()
        ..moveTo(lamp1X - busOffset, lampY)
        ..lineTo(lamp1X - termOffset, lampY);

      final branch2Pos = Path()
        ..moveTo(lamp2X - busOffset, lampY)
        ..lineTo(lamp2X - termOffset, lampY);

      // Barramento Negativo Right
      final pathBusRight = Path()
        ..moveTo(socketX + socketTermOffset, socketY)
        ..lineTo(lamp2X + busOffset, socketY)
        ..lineTo(lamp2X + busOffset, lampY)
        ..lineTo(lamp1X + busOffset, lampY);

      final branch1Neg = Path()
        ..moveTo(lamp1X + busOffset, lampY)
        ..lineTo(lamp1X + termOffset, lampY);

      final branch2Neg = Path()
        ..moveTo(lamp2X + busOffset, lampY)
        ..lineTo(lamp2X + termOffset, lampY);

      canvas.drawPath(pathBusLeft, currentPaint);
      canvas.drawPath(branch1Pos, currentPaint);
      canvas.drawPath(branch2Pos, currentPaint);
      canvas.drawPath(pathBusRight, currentPaint);
      canvas.drawPath(branch1Neg, currentPaint);
      canvas.drawPath(branch2Neg, currentPaint);

      drawTerminalDot(Offset(lamp1X - termOffset, lampY));
      drawTerminalDot(Offset(lamp1X + termOffset, lampY));
      drawTerminalDot(Offset(lamp2X - termOffset, lampY));
      drawTerminalDot(Offset(lamp2X + termOffset, lampY));
      drawTerminalDot(Offset(socketX - socketTermOffset, socketY));
      drawTerminalDot(Offset(socketX + socketTermOffset, socketY));

      if (isActive) {
        if (!m5House1Broken || missionIndex != 4) {
          _drawElectronsOnPath(canvas, branch1Pos, electronPaint);
          _drawElectronsOnPath(canvas, branch1Neg, electronPaint);
        }
        _drawElectronsOnPath(canvas, pathBusLeft, electronPaint);
        _drawElectronsOnPath(canvas, branch2Pos, electronPaint);
        _drawElectronsOnPath(canvas, pathBusRight, electronPaint);
        _drawElectronsOnPath(canvas, branch2Neg, electronPaint);
      }
    }
  }

  void _drawElectronsOnPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      final length = metric.length;
      const count = 6;
      for (int i = 0; i < count; i++) {
        final distance = (length * ((animValue + i / count) % 1.0));
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 4, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RuasMaquetePainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.missionIndex != missionIndex ||
        oldDelegate.m1Connected != m1Connected ||
        oldDelegate.m2Series != m2Series ||
        oldDelegate.m3Junction != m3Junction ||
        oldDelegate.m3Return != m3Return ||
        oldDelegate.m4Parallel != m4Parallel ||
        oldDelegate.m5House1Broken != m5House1Broken ||
        oldDelegate.usePhysicalStyle != usePhysicalStyle ||
        oldDelegate.lampY != lampY ||
        oldDelegate.socketY != socketY ||
        oldDelegate.lamp1X != lamp1X ||
        oldDelegate.lamp2X != lamp2X ||
        oldDelegate.socketX != socketX;
  }
}
