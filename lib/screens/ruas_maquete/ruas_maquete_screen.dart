import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/stand_mission.dart';
import '../../models/first_step_component.dart';
import '../../models/component_terminals.dart';
import '../../models/circuit_action.dart';
import '../../state/progress_controller.dart';
import '../../state/circuit_undo_redo_controller.dart';
import '../../services/circuit_solver/mission_circuit_builder.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/schematic_blueprint_socket.dart';
import '../../widgets/physical_blueprint_socket.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/circuit_symbol_painter.dart';
import '../../widgets/street_lamp_painter.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/workbench_components.dart';
import '../../widgets/workbench_table_frame.dart';
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
  double _m1WireRotation = 0.0;

  // Estados da Missão 2 (Comparação de Brilho)
  bool _m2IsSeriesTwoBulbs = false;
  String? _m2SelectedExplanation;
  double _m2SecondaryBulbRotation = 0.0;

  // Estados da Missão 3 (Bifurcação de Fios / Nó)
  bool _m3JunctionInserted = false;
  bool _m3ReturnConnected = false;
  double _m3JunctionRotation = 0.0;
  double _m3ReturnRotation = 0.0;

  // Estados da Missão 4 (Casas Independentes / Paralelo)
  bool _m4ParallelWireConnected = false;
  double _m4ParallelRotation = 0.0;

  // Estados da Missão 5 (Teste de Manutenção do Bairro)
  bool _m5House1Broken = false;
  bool _m5MaintenanceConfirmed = false;
  double _m5House1Rotation = 0.0;
  double _m5MaintenanceRotation = 0.0;

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
    final nextInserted = !prevInserted;
    _undoRedoController.execute(InsertComponentAction(
      description: nextInserted ? 'Inserir $name' : 'Remover $name',
      onApply: () => setState(() {
        setInserted(nextInserted);
        if (nextInserted) setRotation(0);
      }),
      onUndo: () => setState(() {
        setInserted(prevInserted);
        setRotation(prevRotation);
      }),
    ));
  }

  void _rotateComponent({
    required String name,
    required double Function() getRotation,
    required void Function(double) setRotation,
  }) {
    final prevRotation = getRotation();
    final newRotation = (prevRotation + 90) % 360;
    _undoRedoController.execute(RotateComponentAction(
      description: 'Girar $name (${newRotation.toInt()}°)',
      onApply: () => setState(() => setRotation(newRotation)),
      onUndo: () => setState(() => setRotation(prevRotation)),
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
          _m1WireRotation = 0.0;
          break;
        case 1:
          _m2IsSeriesTwoBulbs = false;
          _m2SelectedExplanation = null;
          _m2SecondaryBulbRotation = 0.0;
          break;
        case 2:
          _m3JunctionInserted = false;
          _m3ReturnConnected = false;
          _m3JunctionRotation = 0.0;
          _m3ReturnRotation = 0.0;
          break;
        case 3:
          _m4ParallelWireConnected = false;
          _m4ParallelRotation = 0.0;
          break;
        case 4:
          _m5House1Broken = false;
          _m5MaintenanceConfirmed = false;
          _m5House1Rotation = 0.0;
          _m5MaintenanceRotation = 0.0;
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
                // Coluna Principal da Bancada (70%)
                Expanded(
                  flex: 7,
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
                      const SizedBox(height: 12),
                      Expanded(
                        child: WorkbenchTableFrame(
                          usePhysicalStyle: _usePhysicalStyle,
                          onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
                          leftHeaderWidget: _buildStatusCard(_isCurrentCircuitClosed),
                          rightHeaderWidget: _buildTelemetryCard(
                            _currentCircuitVoltage,
                            _currentCircuitCurrentMa,
                            _isCurrentCircuitClosed,
                          ),
                          bottomWidget: _buildUndoRedoButtons(),
                          child: _buildMaqueteWorkbench(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Painel Lateral (30%)
                Expanded(
                  flex: 3,
                  child: WorkbenchSidePanel(
                    teamTitle: 'Gaveta de Símbolos — Maquete',
                    toolboxItems: [
                      _buildMissionBriefingCard(),
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

  bool get _isCurrentCircuitClosed {
    switch (_currentMissionIndex) {
      case 0:
        return _m1WireInserted || _m1WireConnected;
      case 1:
        return _m2IsSeriesTwoBulbs;
      case 2:
        return _m3JunctionInserted && _m3ReturnConnected;
      case 3:
        return _m4ParallelWireConnected;
      case 4:
        return !_m5House1Broken;
      default:
        return false;
    }
  }

  double get _currentCircuitVoltage {
    switch (_currentMissionIndex) {
      case 0:
      case 1:
        return 4.5;
      default:
        return 9.0;
    }
  }

  double get _currentCircuitCurrentMa {
    return _isCurrentCircuitClosed ? 80.0 : 0.0;
  }

  Widget _buildStatusCard(bool isClosed) {
    final statusColor = isClosed ? const Color(0xFF10B981) : const Color(0xFF64748B);
    final statusText = isClosed ? 'CIRCUITO FECHADO (ON)' : 'CIRCUITO ABERTO (OFF)';

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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                if (isClosed)
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1.5,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: GoogleFonts.rajdhani(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard(double voltage, double currentMa, bool isClosed) {
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
          Text(
            'TENSÃO: ',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            '${voltage.toStringAsFixed(1)}V',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF0284C7),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '| CORRENTE: ',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            '${currentMa.toStringAsFixed(0)}mA',
            style: GoogleFonts.rajdhani(
              color: isClosed ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
        final lamp1X = w * 0.34;
        final lamp2X = w * 0.66;
        final socketX = w * 0.50;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Painter customizado com linhas esquemáticas e elétrons alinhados aos componentes
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _electronAnimController,
                builder: (context, child) {
                  final double socketRotation = switch (_currentMissionIndex) {
                    0 => _m1WireRotation,
                    1 => 0.0,
                    2 => _m3ReturnRotation,
                    3 => _m4ParallelRotation,
                    4 => _m5House1Rotation,
                    _ => 0.0,
                  };

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
                      socketRotation: socketRotation,
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

  Widget _buildSocketTile({
    required double width,
    required double height,
    required String expectedData,
    required bool isFilled,
    required VoidCallback onAccept,
    required VoidCallback onTap,
    required VoidCallback onRotate,
    required double rotation,
    required ComponentType symbolType,
    required String label,
    double brightnessRatio = 1.0,
  }) {
    final symbolWidget = _usePhysicalStyle
        ? (symbolType == ComponentType.bulb
            ? CustomPaint(
                size: Size(width - 20, height - 20),
                painter: StreetLampPainter(
                  isActive: isFilled,
                  brightnessRatio: brightnessRatio,
                  isDarkMode: false,
                ),
              )
            : CustomPaint(
                size: Size(width - 20, height - 20),
                painter: ComponentPhysicalPainter(
                  type: symbolType,
                  isDarkMode: false,
                  wireKind: expectedData == 'junction_node'
                      ? 'junction'
                      : (expectedData == 'fio_paralelo' ? 'parallel' : 'series'),
                ),
              ))
        : CustomPaint(
            size: Size(width - 20, height - 20),
            painter: CircuitSymbolPainter(
              type: symbolType,
              isActive: isFilled,
              isJunction: expectedData == 'junction_node',
              isParallel: expectedData == 'fio_paralelo',
              color: const Color(0xFF0F172A),
              strokeWidth: 2.5,
            ),
          );

    final placeholderWidget = _usePhysicalStyle
        ? (symbolType == ComponentType.bulb
            ? CustomPaint(
                size: Size(width - 20, height - 20),
                painter: StreetLampPainter(
                  isActive: false,
                  brightnessRatio: 0.0,
                  isDarkMode: false,
                ),
              )
            : CustomPaint(
                size: Size(width - 25, height - 25),
                painter: ComponentPhysicalPainter(
                  type: symbolType,
                  isDarkMode: false,
                  wireKind: expectedData == 'junction_node'
                      ? 'junction'
                      : (expectedData == 'fio_paralelo' ? 'parallel' : 'series'),
                ),
              ))
        : CustomPaint(
            size: Size(width - 25, height - 25),
            painter: CircuitSymbolPainter(
              type: symbolType,
              isJunction: expectedData == 'junction_node',
              isParallel: expectedData == 'fio_paralelo',
              color: const Color(0xFF94A3B8),
              strokeWidth: 2.0,
            ),
          );

    if (_usePhysicalStyle) {
      return PhysicalBlueprintSocket<String>(
        width: width,
        height: height,
        expectedData: expectedData,
        isFilled: isFilled,
        onAccept: (_) => onAccept(),
        onTap: onTap,
        onRotate: onRotate,
        rotation: rotation,
        symbolWidget: symbolWidget,
        placeholderWidget: placeholderWidget,
        showLabel: label.isNotEmpty,
        label: label,
      );
    } else {
      return SchematicBlueprintSocket<String>(
        width: width,
        height: height,
        expectedData: expectedData,
        isFilled: isFilled,
        onAccept: (_) => onAccept(),
        onTap: onTap,
        onRotate: onRotate,
        rotation: rotation,
        symbolWidget: symbolWidget,
        placeholderWidget: placeholderWidget,
        showLabel: label.isNotEmpty,
        label: label,
      );
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

      // Socket da Bateria 4.5V / Fonte de Alimentação
      Positioned(
        left: sX - 40,
        top: sY - 32,
        child: _buildSocketTile(
          width: 80,
          height: 60,
          expectedData: 'battery',
          isFilled: isLit,
          symbolType: ComponentType.battery,
          label: 'Bateria 4.5V',
          rotation: _m1WireRotation,
          onRotate: () => _rotateComponent(
            name: 'Bateria 4.5V',
            getRotation: () => _m1WireRotation,
            setRotation: (v) => _m1WireRotation = v,
          ),
          onAccept: () => _insertComponent(
            name: 'Bateria 4.5V',
            getInserted: () => _m1WireInserted,
            setInserted: (v) {
              _m1WireInserted = v;
              _m1WireConnected = v;
            },
            getRotation: () => _m1WireRotation,
            setRotation: (v) => _m1WireRotation = v,
          ),
          onTap: () => _insertComponent(
            name: 'Bateria 4.5V',
            getInserted: () => _m1WireInserted,
            setInserted: (v) {
              _m1WireInserted = v;
              _m1WireConnected = v;
            },
            getRotation: () => _m1WireRotation,
            setRotation: (v) => _m1WireRotation = v,
          ),
        ),
      ),
    ];
  }

  /// Overlay da Missão 2: Comparação de Brilho 1 vs 2 Lâmpadas
  List<Widget> _buildM2OverlayElements(double l1X, double l2X, double sX, double lY, double sY) {
    return [
      // Poste Principal (Sempre Ligado na Rede)
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
        child: Center(child: _buildLabelBadge('Poste Principal (${_m2IsSeriesTwoBulbs ? "50%" : "100%"})')),
      ),

      // Soquete Interativo do Poste Secundário (Série)
      Positioned(
        left: l2X - 40,
        top: lY - 32,
        child: _buildSocketTile(
          width: 80,
          height: 60,
          expectedData: 'bulb',
          isFilled: _m2IsSeriesTwoBulbs,
          symbolType: ComponentType.bulb,
          label: 'Poste Secundário',
          brightnessRatio: 0.5,
          rotation: _m2SecondaryBulbRotation,
          onRotate: () => _rotateComponent(
            name: 'Poste Secundário',
            getRotation: () => _m2SecondaryBulbRotation,
            setRotation: (v) => _m2SecondaryBulbRotation = v,
          ),
          onAccept: () => _insertComponent(
            name: 'Poste Secundário',
            getInserted: () => _m2IsSeriesTwoBulbs,
            setInserted: (v) => _m2IsSeriesTwoBulbs = v,
            getRotation: () => _m2SecondaryBulbRotation,
            setRotation: (v) => _m2SecondaryBulbRotation = v,
          ),
          onTap: () => _insertComponent(
            name: 'Poste Secundário',
            getInserted: () => _m2IsSeriesTwoBulbs,
            setInserted: (v) => _m2IsSeriesTwoBulbs = v,
            getRotation: () => _m2SecondaryBulbRotation,
            setRotation: (v) => _m2SecondaryBulbRotation = v,
          ),
        ),
      ),
      if (_m2IsSeriesTwoBulbs)
        Positioned(
          left: l2X - 75,
          top: lY + 38,
          width: 150,
          child: Center(child: _buildLabelBadge('Poste 2 em Série (50%)')),
        ),

      // Bateria 4.5V (Alimentação da Rede) no centro inferior
      Positioned(
        left: sX - 40,
        top: sY - 32,
        child: _buildBatteryWidget(isLit: true),
      ),
    ];
  }

  /// Constrói o Card/Widget da Bateria 4.5V (Fonte de Alimentação) em 3D ou Esquemático
  Widget _buildBatteryWidget({bool isLit = true}) {
    final symbolWidget = _usePhysicalStyle
        ? CustomPaint(
            size: const Size(60, 40),
            painter: ComponentPhysicalPainter(
              type: ComponentType.battery,
              isDarkMode: false,
            ),
          )
        : CustomPaint(
            size: const Size(60, 40),
            painter: CircuitSymbolPainter(
              type: ComponentType.battery,
              isActive: isLit,
              color: const Color(0xFF0F172A),
              strokeWidth: 2.5,
            ),
          );

    return _usePhysicalStyle
        ? PhysicalComponentCard(
            width: 80,
            height: 60,
            symbolWidget: symbolWidget,
            label: 'Bateria 4.5V',
            isActive: isLit,
          )
        : SchematicComponentCard(
            symbolWidget: symbolWidget,
            label: 'Bateria 4.5V',
            isActive: isLit,
          );
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

      // Soquete 1: Nó de Junção (Bifurcação (+))
      Positioned(
        left: sX - 40,
        top: nodeY - 32,
        child: _buildSocketTile(
          width: 80,
          height: 60,
          expectedData: 'junction_node',
          isFilled: _m3JunctionInserted,
          symbolType: ComponentType.connectingWire,
          label: 'Nó (+)',
          rotation: _m3JunctionRotation,
          onRotate: () => _rotateComponent(
            name: 'Nó de Junção',
            getRotation: () => _m3JunctionRotation,
            setRotation: (v) => _m3JunctionRotation = v,
          ),
          onAccept: () => _insertComponent(
            name: 'Nó de Junção',
            getInserted: () => _m3JunctionInserted,
            setInserted: (v) => _m3JunctionInserted = v,
            getRotation: () => _m3JunctionRotation,
            setRotation: (v) => _m3JunctionRotation = v,
          ),
          onTap: () => _insertComponent(
            name: 'Nó de Junção',
            getInserted: () => _m3JunctionInserted,
            setInserted: (v) => _m3JunctionInserted = v,
            getRotation: () => _m3JunctionRotation,
            setRotation: (v) => _m3JunctionRotation = v,
          ),
        ),
      ),

      // Soquete 2: Retorno (- )
      Positioned(
        left: sX - 40,
        top: sY - 32,
        child: _buildSocketTile(
          width: 80,
          height: 60,
          expectedData: 'fio_serie',
          isFilled: _m3ReturnConnected,
          symbolType: ComponentType.connectingWire,
          label: 'Retorno (-)',
          rotation: _m3ReturnRotation,
          onRotate: () => _rotateComponent(
            name: 'Retorno Reconectado',
            getRotation: () => _m3ReturnRotation,
            setRotation: (v) => _m3ReturnRotation = v,
          ),
          onAccept: () => _insertComponent(
            name: 'Retorno Reconectado',
            getInserted: () => _m3ReturnConnected,
            setInserted: (v) => _m3ReturnConnected = v,
            getRotation: () => _m3ReturnRotation,
            setRotation: (v) => _m3ReturnRotation = v,
          ),
          onTap: () => _insertComponent(
            name: 'Retorno Reconectado',
            getInserted: () => _m3ReturnConnected,
            setInserted: (v) => _m3ReturnConnected = v,
            getRotation: () => _m3ReturnRotation,
            setRotation: (v) => _m3ReturnRotation = v,
          ),
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

      // Soquete da Fiação em Paralelo
      Positioned(
        left: sX - 40,
        top: sY - 32,
        child: _buildSocketTile(
          width: 80,
          height: 60,
          expectedData: 'fio_paralelo',
          isFilled: _m4ParallelWireConnected,
          symbolType: ComponentType.connectingWire,
          label: 'Fiação Paralela',
          rotation: _m4ParallelRotation,
          onRotate: () => _rotateComponent(
            name: 'Fiação em Paralelo',
            getRotation: () => _m4ParallelRotation,
            setRotation: (v) => _m4ParallelRotation = v,
          ),
          onAccept: () => _insertComponent(
            name: 'Fiação em Paralelo',
            getInserted: () => _m4ParallelWireConnected,
            setInserted: (v) => _m4ParallelWireConnected = v,
            getRotation: () => _m4ParallelRotation,
            setRotation: (v) => _m4ParallelRotation = v,
          ),
          onTap: () => _insertComponent(
            name: 'Fiação em Paralelo',
            getInserted: () => _m4ParallelWireConnected,
            setInserted: (v) => _m4ParallelWireConnected = v,
            getRotation: () => _m4ParallelRotation,
            setRotation: (v) => _m4ParallelRotation = v,
          ),
        ),
      ),
    ];
  }

  /// Overlay da Missão 5: Teste de Manutenção do Bairro
  List<Widget> _buildM5OverlayElements(double l1X, double l2X, double sX, double lY, double sY) {
    return [
      // Soquete da Lâmpada A (Casa 01)
      Positioned(
        left: l1X - 40,
        top: lY - 32,
        child: _buildSocketTile(
          width: 80,
          height: 60,
          expectedData: 'bulb',
          isFilled: !_m5House1Broken,
          symbolType: ComponentType.bulb,
          label: 'Lâmpada A',
          rotation: _m5House1Rotation,
          onRotate: () => _rotateComponent(
            name: 'Lâmpada A',
            getRotation: () => _m5House1Rotation,
            setRotation: (v) => _m5House1Rotation = v,
          ),
          onAccept: () => _insertComponent(
            name: 'Lâmpada A',
            getInserted: () => !_m5House1Broken,
            setInserted: (v) => _m5House1Broken = !v,
            getRotation: () => _m5House1Rotation,
            setRotation: (v) => _m5House1Rotation = v,
          ),
          onTap: () => _insertComponent(
            name: 'Lâmpada A',
            getInserted: () => !_m5House1Broken,
            setInserted: (v) => _m5House1Broken = !v,
            getRotation: () => _m5House1Rotation,
            setRotation: (v) => _m5House1Rotation = v,
          ),
        ),
      ),
      Positioned(
        left: l1X - 75,
        top: lY + 38,
        width: 150,
        child: Center(child: _buildLabelBadge('Lâmpada A (Simulada)', isBroken: _m5House1Broken)),
      ),

      // Lâmpada B (Casa 02 - Sempre Funcional)
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

      // Soquete do Conector de Manutenção
      Positioned(
        left: sX - 40,
        top: sY - 32,
        child: _buildSocketTile(
          width: 80,
          height: 60,
          expectedData: 'fio_serie',
          isFilled: _m5MaintenanceConfirmed,
          symbolType: ComponentType.connectingWire,
          label: 'Manutenção',
          rotation: _m5MaintenanceRotation,
          onRotate: () => _rotateComponent(
            name: 'Conector de Manutenção',
            getRotation: () => _m5MaintenanceRotation,
            setRotation: (v) => _m5MaintenanceRotation = v,
          ),
          onAccept: () => _insertComponent(
            name: 'Conector de Manutenção',
            getInserted: () => _m5MaintenanceConfirmed,
            setInserted: (v) => _m5MaintenanceConfirmed = v,
            getRotation: () => _m5MaintenanceRotation,
            setRotation: (v) => _m5MaintenanceRotation = v,
          ),
          onTap: () => _insertComponent(
            name: 'Conector de Manutenção',
            getInserted: () => _m5MaintenanceConfirmed,
            setInserted: (v) => _m5MaintenanceConfirmed = v,
            getRotation: () => _m5MaintenanceRotation,
            setRotation: (v) => _m5MaintenanceRotation = v,
          ),
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

  Widget _buildMissionBriefingCard() {
    final mission = _missions[_currentMissionIndex];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'MISSÃO 0${_currentMissionIndex + 1}',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mission.title,
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
            mission.objective,
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
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.psychology_rounded,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mission.voltsMediation,
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
              tooltip: 'Poste / Lâmpada',
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
            // Condutor Série
            WorkbenchSymbolToolboxTile<String>(
              data: 'fio_serie',
              label: 'Condutor',
              tooltip: 'Fio Condutor',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.connectingWire,
                        wireKind: 'series',
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.connectingWire,
                        isJunction: false,
                        isParallel: false,
                        color: const Color(0xFF0F172A),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF0284C7),
            ),
            // Nó de Junção
            WorkbenchSymbolToolboxTile<String>(
              data: 'junction_node',
              label: 'Nó Junção',
              tooltip: 'Nó / Bifurcação',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.connectingWire,
                        wireKind: 'junction',
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.connectingWire,
                        isJunction: true,
                        isParallel: false,
                        color: const Color(0xFF8B5CF6),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF8B5CF6),
            ),
            // Fiação Paralela
            WorkbenchSymbolToolboxTile<String>(
              data: 'fio_paralelo',
              label: 'Fio Paralelo',
              tooltip: 'Fio de Ramo Paralelo',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.connectingWire,
                        wireKind: 'parallel',
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.connectingWire,
                        isJunction: false,
                        isParallel: true,
                        color: const Color(0xFFEC4899),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFFEC4899),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSidePanelMissionContent(),
      ],
    );
  }

  Widget _buildUndoRedoButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
                size: 18,
              ),
              onPressed: _undoRedoController.canUndo
                  ? () => setState(() => _undoRedoController.undo())
                  : null,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '${_undoRedoController.undoCount}',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF475569),
                fontSize: 13,
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
                size: 18,
              ),
              onPressed: _undoRedoController.canRedo
                  ? () => setState(() => _undoRedoController.redo())
                  : null,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                  color: Colors.transparent,
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

  /// Badge de Rótulo posicionado abaixo do componente com texto branco sobre a mesa verde
  Widget _buildLabelBadge(String text, {bool isBroken = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isBroken ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.rajdhani(
          color: isBroken ? const Color(0xFFFCA5A5) : Colors.white,
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
  final double socketRotation;

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
    required this.socketRotation,
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

    void drawStyledPath(Path path, Paint paint, {Color? customColor, bool isPositive = true}) {
      if (usePhysicalStyle) {
        final isActive = paint == activeWirePaint;
        final baseColor = customColor ?? (isPositive ? const Color(0xFFDC2626) : const Color(0xFF2563EB));

        // 1. Sombra projetada do fio
        final shadowPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.22)
          ..strokeWidth = 6.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path.shift(const Offset(1.5, 2.5)), shadowPaint);

        // 2. Isolamento do fio (Vermelho positivo / Azul negativo / Ambar jumper)
        final wireInsulationPaint = Paint()
          ..color = isActive ? baseColor : baseColor.withValues(alpha: 0.5)
          ..strokeWidth = 4.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, wireInsulationPaint);

        // 3. Brilho especular no fio físico
        final specularPaint = Paint()
          ..color = Colors.white.withValues(alpha: isActive ? 0.40 : 0.20)
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path.shift(const Offset(0, -1.2)), specularPaint);
      } else {
        canvas.drawPath(path, paint);
      }
    }

    void drawTerminalDot(Offset pos) {
      if (usePhysicalStyle) {
        return;
      } else {
        canvas.drawCircle(pos, 3.5, nodePaint);
      }
    }

    Path makeFlexiblePath(List<Offset> points) {
      if (points.isEmpty) return Path();
      if (points.length == 1) return Path()..addOval(Rect.fromCircle(center: points.first, radius: 1));

      final path = Path()..moveTo(points.first.dx, points.first.dy);

      if (points.length == 2) {
        final p0 = points[0];
        final p1 = points[1];
        final dx = (p1.dx - p0.dx).abs();
        final dy = (p1.dy - p0.dy).abs();

        if (dx > 12.0 && dy > 3.0) {
          final midX = (p0.dx + p1.dx) / 2;
          path.cubicTo(
            midX, p0.dy,
            midX, p1.dy,
            p1.dx, p1.dy,
          );
          return path;
        }

        path.lineTo(p1.dx, p1.dy);
        return path;
      }

      const double maxRadius = 22.0;

      for (int i = 1; i < points.length - 1; i++) {
        final pPrev = points[i - 1];
        final pCurr = points[i];
        final pNext = points[i + 1];

        final v1 = pPrev - pCurr;
        final v2 = pNext - pCurr;
        final d1 = v1.distance;
        final d2 = v2.distance;

        if (d1 == 0 || d2 == 0) {
          path.lineTo(pCurr.dx, pCurr.dy);
          continue;
        }

        final radius = math.min(maxRadius, math.min(d1 / 2, d2 / 2));

        final startArc = pCurr + (v1 / d1) * radius;
        final endArc = pCurr + (v2 / d2) * radius;

        path.lineTo(startArc.dx, startArc.dy);
        path.quadraticBezierTo(pCurr.dx, pCurr.dy, endArc.dx, endArc.dy);
      }

      path.lineTo(points.last.dx, points.last.dy);
      return path;
    }

    // Terminais dinâmicos da bateria baseados no ângulo de rotação do soquete
    final batPosTerminal = getTerminalPosition(
      componentCenter: Offset(socketX, socketY),
      componentType: ComponentType.battery,
      terminalIndex: 0,
      rotationDegrees: socketRotation,
    );
    final batNegTerminal = getTerminalPosition(
      componentCenter: Offset(socketX, socketY),
      componentType: ComponentType.battery,
      terminalIndex: 1,
      rotationDegrees: socketRotation,
    );

    final topLoopY = socketY - 70.0;
    final outerLeftX = lamp1X - 70.0;
    final outerRightX = lamp2X + 70.0;

    // Determinar waypoints de saída de fiação baseados na rotação do soquete
    final List<Offset> posExitWaypoints;
    final List<Offset> negExitWaypoints;

    final normRotation = (socketRotation % 360 + 360) % 360;
    if (normRotation >= 45 && normRotation < 135) {
      // 90° (Terminais virados para a DIREITA)
      posExitWaypoints = [batPosTerminal, Offset(socketX + 70.0, batPosTerminal.dy), Offset(socketX + 70.0, topLoopY)];
      negExitWaypoints = [Offset(socketX + 70.0, topLoopY), Offset(socketX + 70.0, batNegTerminal.dy), batNegTerminal];
    } else if (normRotation >= 135 && normRotation < 225) {
      // 180° (Terminais virados para BAIXO)
      posExitWaypoints = [batPosTerminal, Offset(batPosTerminal.dx, socketY + 70.0), Offset(outerLeftX, socketY + 70.0)];
      negExitWaypoints = [Offset(outerRightX, socketY + 70.0), Offset(batNegTerminal.dx, socketY + 70.0), batNegTerminal];
    } else if (normRotation >= 225 && normRotation < 315) {
      // 270° (Terminais virados para a ESQUERDA)
      posExitWaypoints = [batPosTerminal, Offset(socketX - 70.0, batPosTerminal.dy), Offset(socketX - 70.0, topLoopY)];
      negExitWaypoints = [Offset(socketX - 70.0, topLoopY), Offset(socketX - 70.0, batNegTerminal.dy), batNegTerminal];
    } else {
      // 0° (Terminais virados para CIMA - Topo)
      posExitWaypoints = [batPosTerminal, Offset(batPosTerminal.dx, topLoopY)];
      negExitWaypoints = [Offset(batNegTerminal.dx, topLoopY), batNegTerminal];
    }

    // Desenhar caminhos de fios conforme a missão
    if (missionIndex == 0) {
      // M1 (2 Lâmpadas em Série com Soquete de Fio): Socket (+) -> Lamp1 -> Lamp2 -> Socket (-)
      final isConnected = m1Connected;
      final currentPaint = isConnected ? activeWirePaint : wirePaint;

      final path1 = makeFlexiblePath([
        ...posExitWaypoints,
        Offset(outerLeftX, topLoopY),
        Offset(outerLeftX, lampY),
        Offset(lamp1X - termOffset, lampY),
      ]);

      final path2 = makeFlexiblePath([
        Offset(lamp1X + termOffset, lampY),
        Offset(lamp2X - termOffset, lampY),
      ]);

      final path3 = makeFlexiblePath([
        Offset(lamp2X + termOffset, lampY),
        Offset(outerRightX, lampY),
        Offset(outerRightX, topLoopY),
        ...negExitWaypoints,
      ]);

      drawStyledPath(path1, currentPaint, isPositive: true);
      drawStyledPath(path2, currentPaint, customColor: const Color(0xFFD97706));
      drawStyledPath(path3, currentPaint, isPositive: false);

      drawTerminalDot(batPosTerminal);
      drawTerminalDot(Offset(lamp1X - termOffset, lampY));
      drawTerminalDot(Offset(lamp1X + termOffset, lampY));
      drawTerminalDot(Offset(lamp2X - termOffset, lampY));
      drawTerminalDot(Offset(lamp2X + termOffset, lampY));
      drawTerminalDot(batNegTerminal);

      if (isConnected) {
        _drawElectronsOnPath(canvas, path1, electronPaint);
        _drawElectronsOnPath(canvas, path2, electronPaint);
        _drawElectronsOnPath(canvas, path3, electronPaint);
      }
    } else if (missionIndex == 1) {
      // M2 (Comparação de Brilho 1 vs 2 Lâmpadas): Fio de retorno inferior contínuo, passando pelo Poste Secundário
      final path1 = makeFlexiblePath([
        ...posExitWaypoints,
        Offset(outerLeftX, topLoopY),
        Offset(outerLeftX, lampY),
        Offset(lamp1X - termOffset, lampY),
      ]);

      final path2 = makeFlexiblePath([
        Offset(lamp1X + termOffset, lampY),
        Offset(lamp2X - termOffset, lampY),
      ]);

      final path3 = makeFlexiblePath([
        Offset(lamp2X + termOffset, lampY),
        Offset(outerRightX, lampY),
        Offset(outerRightX, topLoopY),
        ...negExitWaypoints,
      ]);

      drawStyledPath(path1, activeWirePaint, isPositive: true);
      drawStyledPath(path2, activeWirePaint, customColor: const Color(0xFFD97706));
      drawStyledPath(path3, m2Series ? activeWirePaint : wirePaint, isPositive: false);

      drawTerminalDot(batPosTerminal);
      drawTerminalDot(Offset(lamp1X - termOffset, lampY));
      drawTerminalDot(Offset(lamp1X + termOffset, lampY));
      drawTerminalDot(Offset(lamp2X - termOffset, lampY));
      drawTerminalDot(Offset(lamp2X + termOffset, lampY));
      drawTerminalDot(batNegTerminal);

      _drawElectronsOnPath(canvas, path1, electronPaint);
      _drawElectronsOnPath(canvas, path2, electronPaint);
      if (m2Series) {
        _drawElectronsOnPath(canvas, path3, electronPaint);
      }
    } else if (missionIndex == 2) {
      // M3: Bifurcação de Fios (Nó de Junção -> Ramos A e B -> Retorno)
      final isBothActive = m3Junction && m3Return;
      final nodeY = lampY + 45.0;

      // 1. Tronco Positivo VCC (Saindo da Bateria e subindo alinhado no eixo central até o pino inferior do Nó de Junção)
      final pathTrunkVcc = makeFlexiblePath([
        batPosTerminal,
        Offset(batPosTerminal.dx, socketY - 45.0),
        Offset(socketX, socketY - 60.0),
        Offset(socketX, nodeY + 18.0),
      ]);

      // 2. Ramo Lâmpada A (Saindo do centro exato do Nó de Junção (socketX, nodeY) para a esquerda -> Rua A)
      final pathBranchA = makeFlexiblePath([
        Offset(socketX, nodeY),
        Offset(lamp1X + termOffset, nodeY),
        Offset(lamp1X + termOffset, lampY),
      ]);

      // 3. Ramo Lâmpada B (Saindo do centro exato do Nó de Junção (socketX, nodeY) para a direita -> Rua B)
      final pathBranchB = makeFlexiblePath([
        Offset(socketX, nodeY),
        Offset(lamp2X - termOffset, nodeY),
        Offset(lamp2X - termOffset, lampY),
      ]);

      // 4. Retorno Rua A (da Rua A para o Retorno (-))
      final pathReturnA = makeFlexiblePath([
        Offset(lamp1X - termOffset, lampY),
        Offset(outerLeftX, lampY),
        Offset(outerLeftX, topLoopY),
        ...negExitWaypoints,
      ]);

      // 5. Retorno Rua B (da Rua B para o Retorno (-))
      final pathReturnB = makeFlexiblePath([
        Offset(lamp2X + termOffset, lampY),
        Offset(outerRightX, lampY),
        Offset(outerRightX, topLoopY),
        ...negExitWaypoints,
      ]);

      drawStyledPath(pathTrunkVcc, m3Junction ? activeWirePaint : wirePaint, isPositive: true);
      drawStyledPath(pathBranchA, m3Junction ? activeWirePaint : wirePaint, isPositive: true);
      drawStyledPath(pathBranchB, m3Junction ? activeWirePaint : wirePaint, isPositive: true);
      drawStyledPath(pathReturnA, m3Return ? activeWirePaint : wirePaint, isPositive: false);
      drawStyledPath(pathReturnB, m3Return ? activeWirePaint : wirePaint, isPositive: false);

      drawTerminalDot(batPosTerminal);
      drawTerminalDot(Offset(socketX, nodeY + 18.0));
      drawTerminalDot(Offset(lamp1X + termOffset, lampY));
      drawTerminalDot(Offset(lamp1X - termOffset, lampY));
      drawTerminalDot(Offset(lamp2X - termOffset, lampY));
      drawTerminalDot(Offset(lamp2X + termOffset, lampY));
      drawTerminalDot(batNegTerminal);

      if (isBothActive) {
        _drawElectronsOnPath(canvas, pathTrunkVcc, electronPaint);
        _drawElectronsOnPath(canvas, pathBranchA, electronPaint);
        _drawElectronsOnPath(canvas, pathBranchB, electronPaint);
        _drawElectronsOnPath(canvas, pathReturnA, electronPaint);
        _drawElectronsOnPath(canvas, pathReturnB, electronPaint);
      }
    } else if (missionIndex == 3 || missionIndex == 4) {
      // M4 e M5: Circuito em Paralelo
      final isActive = m4Parallel || missionIndex == 4;
      final currentPaint = isActive ? activeWirePaint : wirePaint;
      const busOffset = 48.0;

      // Barramento Positivo Left (Saindo do terminal + no topo da bateria)
      final pathBusLeft = makeFlexiblePath([
        ...posExitWaypoints,
        Offset(outerLeftX, topLoopY),
        Offset(outerLeftX, lampY),
        Offset(lamp2X - busOffset, lampY),
      ]);

      final branch1Pos = makeFlexiblePath([
        Offset(lamp1X - busOffset, lampY),
        Offset(lamp1X - termOffset, lampY),
      ]);

      final branch2Pos = makeFlexiblePath([
        Offset(lamp2X - busOffset, lampY),
        Offset(lamp2X - termOffset, lampY),
      ]);

      // Barramento Negativo Right (Saindo do terminal - no topo da bateria)
      final pathBusRight = makeFlexiblePath([
        Offset(outerRightX, lampY),
        Offset(outerRightX, topLoopY),
        ...negExitWaypoints,
      ]);

      final branch1Neg = makeFlexiblePath([
        Offset(lamp1X + busOffset, lampY),
        Offset(lamp1X + termOffset, lampY),
      ]);

      final branch2Neg = makeFlexiblePath([
        Offset(lamp2X + busOffset, lampY),
        Offset(lamp2X + termOffset, lampY),
      ]);

      drawStyledPath(pathBusLeft, currentPaint, isPositive: true);
      drawStyledPath(branch1Pos, currentPaint, isPositive: true);
      drawStyledPath(branch2Pos, currentPaint, isPositive: true);
      drawStyledPath(pathBusRight, currentPaint, isPositive: false);
      drawStyledPath(branch1Neg, currentPaint, isPositive: false);
      drawStyledPath(branch2Neg, currentPaint, isPositive: false);

      drawTerminalDot(batPosTerminal);
      drawTerminalDot(Offset(lamp1X - termOffset, lampY));
      drawTerminalDot(Offset(lamp1X + termOffset, lampY));
      drawTerminalDot(Offset(lamp2X - termOffset, lampY));
      drawTerminalDot(Offset(lamp2X + termOffset, lampY));
      drawTerminalDot(batNegTerminal);

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
    if (usePhysicalStyle) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFEF08A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      for (final metric in metrics) {
        final length = metric.length;
        const count = 3;
        for (int i = 0; i < count; i++) {
          final distance = (length * ((animValue + i / count) % 1.0));
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 2.5, glowPaint);
            canvas.drawCircle(tangent.position, 1.2, Paint()..color = Colors.white);
          }
        }
      }
    } else {
      for (final metric in metrics) {
        final length = metric.length;
        const count = 4;
        for (int i = 0; i < count; i++) {
          final distance = (length * ((animValue + i / count) % 1.0));
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 3.5, paint);
          }
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
