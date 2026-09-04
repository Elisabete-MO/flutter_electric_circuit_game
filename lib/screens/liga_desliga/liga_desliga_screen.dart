import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes.dart';
import '../../models/circuit_action.dart';
import '../../models/first_step_component.dart';
import '../../models/stand_mission.dart';
import '../../state/circuit_undo_redo_controller.dart';
import '../../state/progress_controller.dart';
import '../../widgets/circuit_symbol_painter.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/component_vector_painters.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/physical_blueprint_socket.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/prof_volts_full_body.dart';
import '../../widgets/realistic_wire_painter.dart';
import '../../widgets/schematic_blueprint_socket.dart';
import '../../widgets/schematic_symbol_painters.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/workbench_components.dart';
import '../../widgets/workbench_table_frame.dart';

/// Tela Interativa e Estilizada das 5 Missões do Estande 03 — "Liga e Desliga" (Equipe Controle)
class LigaDesligaScreen extends ConsumerStatefulWidget {
  const LigaDesligaScreen({super.key});

  @override
  ConsumerState<LigaDesligaScreen> createState() => _LigaDesligaScreenState();
}

class _LigaDesligaScreenState extends ConsumerState<LigaDesligaScreen>
    with TickerProviderStateMixin {
  int _currentMissionIndex = 0;
  final List<StandMission> _missions = StandMission.estande3Missions;
  final CircuitUndoRedoController _undoRedoController = CircuitUndoRedoController();

  // --- Modo de Visualizacao Visual: Esquemático (Blueprint) vs Físico 3D ---
  bool _usePhysicalStyle = true;

  // --- Estado Missão 1: Interruptor da Luminária ---
  bool _m1SwitchInserted = false;
  bool _m1SwitchClosed = false;
  bool _m1BatteryInserted = false;
  bool _m1BulbInserted = false;
  double _m1BatteryRotation = 270.0;
  double _m1SwitchRotation = 0.0;
  double _m1BulbRotation = 0.0;

  // --- Estado Missão 2: Aberto ou Fechado? ---
  bool _m2SwitchAClosed = false;
  bool _m2SwitchBClosed = true;
  String? _m2AnswerStateA; // 'aberto' / 'fechado'
  String? _m2AnswerStateB; // 'aberto' / 'fechado'

  // --- Estado Missão 3: Dois Controles ---
  bool _m3Switch1Closed = false;
  bool _m3Switch2Closed = false;
  bool _m3TestedSwitch1 = false;
  bool _m3TestedSwitch2 = false;
  bool _m3BatteryInserted = true;
  bool _m3LampAInserted = true;
  bool _m3LampBInserted = true;
  bool _m3Switch1Inserted = true;
  bool _m3Switch2Inserted = true;
  double _m3BatteryRotation = 270.0;
  double _m3LampARotation = 0.0;
  double _m3LampBRotation = 0.0;
  double _m3Switch1Rotation = 0.0;
  double _m3Switch2Rotation = 0.0;
  String? _m3MapSwitch1; // 'lampA' / 'lampB'
  String? _m3MapSwitch2; // 'lampA' / 'lampB'

  // --- Estado Missão 4: Conferência ---
  bool _m4SwitchInMainBranch = false;
  bool _m4SwitchClosed = true;
  bool _m4BatteryInserted = true;
  bool _m4SwitchSeriesInserted = false;
  bool _m4LampInserted = true;
  double _m4BatteryRotation = 270.0;
  double _m4SwitchSeriesRotation = 0.0;
  double _m4LampRotation = 0.0;

  // --- Estado Missão 5: Controle por Push-Button ---
  bool _m5PushButtonInserted = false;
  bool _m5PushButtonPressed = false;
  bool _m5TestedHoldAndRelease = false;
  bool _m5BatteryInserted = true;
  bool _m5LampInserted = true;
  double _m5BatteryRotation = 270.0;
  double _m5PushButtonRotation = 0.0;
  double _m5LampRotation = 0.0;

  // Animação de Fluxo de Corrente e Pulsos Neon
  late AnimationController _currentFlowController;

  @override
  void initState() {
    super.initState();
    _m1BatteryInserted = true;
    _m1BulbInserted = true;
    _currentFlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _currentFlowController.dispose();
    super.dispose();
  }

  // --- Helper methods for undo/redo ---
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
      description: 'Girar $name',
      onApply: () => setState(() => setRotation(newRotation)),
      onUndo: () => setState(() => setRotation(prevRotation)),
    ));
  }

  // Helper method for toggling boolean states with undo/redo support.
  // ignore: unused_element
  void _toggleBool({
    required String name,
    required bool Function() getValue,
    required void Function(bool) setValue,
  }) {
    final prevValue = getValue();
    _undoRedoController.execute(ToggleBoolAction(
      description: 'Alternar $name',
      onApply: () => setState(() => setValue(!prevValue)),
      onUndo: () => setState(() => setValue(prevValue)),
    ));
  }

  void _nextMission() {
    if (_currentMissionIndex < _missions.length - 1) {
      setState(() {
        _currentMissionIndex++;
      });
    } else {
      _finishAllMissions();
    }
  }

  void _finishAllMissions() {
    // Registra progresso no Riverpod
    ref
        .read(progressControllerProvider.notifier)
        .markAsCompleted('liga_desliga', stars: 3);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassContainer(
            borderRadius: 24,
            accentColor: const Color(0xFF10B981),
            opacity: 0.94,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ProfVoltsFullBody(
                  emotion: ProfVoltsEmotion.happy,
                  size: 140,
                ),
                const SizedBox(height: 14),
                Text(
                  'ESTANDE 03 CONCLUÍDO!',
                  style: GoogleFonts.rajdhani(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Equipe Controle — Liga e Desliga',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF042920),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildScoreRow('Funcionamento:', '3/3 ★★★'),
                      const SizedBox(height: 8),
                      _buildScoreRow('Segurança:', '3/3 ★★★'),
                      const SizedBox(height: 8),
                      _buildScoreRow('Comunicação:', '3/3 ★★★'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '“Excelente trabalho! O mini painel de controle está seguro e pronto para a comunidade aprender sobre circuitos abertos e fechados.”',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed(Routes.home);
                    },
                    icon: const Icon(Icons.map_rounded),
                    label: Text(
                      'Retornar à Feira de Ciências',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: const Color(0xFF021712),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF10B981),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
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
            _nextMission();
          }
        },
      ),
    );
  }

  // --- Lógica de Validação ---
  void _validateMission1() {
    if (!_m1SwitchInserted) {
      _showFeedback(false, _missions[0].failureFeedback);
      return;
    }
    _showFeedback(
      true,
      'Perfeito! O interruptor foi inserido no caminho da corrente. Quando fechado, a lâmpada acende; quando aberto, o circuito se interrompe!',
    );
  }

  void _validateMission2() {
    if (_m2AnswerStateA == 'aberto' && _m2AnswerStateB == 'fechado') {
      _showFeedback(
        true,
        'Excelente previsão! Circuito aberto interrompe a passagem de corrente e apaga a luz. Circuito fechado completa o percurso!',
      );
    } else {
      _showFeedback(false, _missions[1].failureFeedback);
    }
  }

  void _validateMission3() {
    if (!_m3TestedSwitch1 || !_m3TestedSwitch2) {
      _showFeedback(false, _missions[2].failureFeedback);
      return;
    }
    if (_m3MapSwitch1 == 'lampA' && _m3MapSwitch2 == 'lampB') {
      _showFeedback(
        true,
        'Muito bem! Você testou cada controle individualmente e mapeou corretamente Chave 1 -> Luminária A e Chave 2 -> Luminária B.',
      );
    } else {
      _showFeedback(
        false,
        'Mapeamento incorreto. Teste alternar uma chave por vez e observe qual luz responde.',
      );
    }
  }

  void _validateMission4() {
    if (!_m4SwitchInMainBranch) {
      _showFeedback(false, _missions[3].failureFeedback);
      return;
    }
    _showFeedback(
      true,
      'Excelente correção! Movendo o interruptor do ramo inútil para o ramo principal em série, a chave agora interrompe a corrente da lâmpada.',
    );
  }

  void _validateMission5() {
    if (!_m5PushButtonInserted) {
      _showFeedback(
        false,
        'Instale o interruptor do tipo push-button no circuito!',
      );
      return;
    }
    if (_m5TestedHoldAndRelease) {
      _showFeedback(
        true,
        'Excelente! O push-button só mantém a luz acesa enquanto o visitante o mantém pressionado.',
      );
    } else {
      _showFeedback(
        false,
        'Mantenha o push-button pressionado para acender a luminária e solte em seguida antes de validar.',
      );
    }
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
              'ESTANDE 03 — LIGA E DESLIGA',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Equipe Controle — Mini Painel de Iluminação',
              style: GoogleFonts.outfit(
                color: const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0284C7),
          ),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(Routes.home),
        ),
      ),
      body: TechGridBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Área Principal da Bancada
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      WorkbenchHeaderStepper(
                        totalMissions: _missions.length,
                        currentMissionIndex: _currentMissionIndex,
                        missionTitle: _missions[_currentMissionIndex].title,
                        missionObjective:
                            _missions[_currentMissionIndex].objective,
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
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildCurrentMissionUI(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Painel Lateral (Gaveta de Componentes & Validação)
                Expanded(
                  flex: 3,
                  child: WorkbenchSidePanel(
                    teamTitle: 'Painel da Equipe Controle',
                    toolboxItems: [
                      _buildMissionBriefingCard(),
                      _buildSideToolboxDrawer(),
                    ],
                    onEnergizePressed: _validateCurrentMission,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  void _validateCurrentMission() {
    switch (_currentMissionIndex) {
      case 0:
        _validateMission1();
        break;
      case 1:
        _validateMission2();
        break;
      case 2:
        _validateMission3();
        break;
      case 3:
        _validateMission4();
        break;
      case 4:
        _validateMission5();
        break;
    }
  }

  Widget _buildCurrentMissionUI() {
    switch (_currentMissionIndex) {
      case 0:
        return _buildMission1UI(_missions[0]);
      case 1:
        return _buildMission2UI(_missions[1]);
      case 2:
        return _buildMission3UI(_missions[2]);
      case 3:
        return _buildMission4UI(_missions[3]);
      case 4:
        return _buildMission5UI(_missions[4]);
      default:
        return Container();
    }
  }

  bool get _isCurrentCircuitClosed {
    switch (_currentMissionIndex) {
      case 0:
        return _m1SwitchInserted && _m1SwitchClosed && _m1BatteryInserted && _m1BulbInserted;
      case 1:
        return false;
      case 2:
        return _m3BatteryInserted &&
            ((_m3Switch1Inserted && _m3Switch1Closed && _m3LampAInserted) ||
                (_m3Switch2Inserted && _m3Switch2Closed && _m3LampBInserted));
      case 3:
        return _m4BatteryInserted &&
            _m4SwitchSeriesInserted &&
            _m4LampInserted &&
            (!_m4SwitchInMainBranch || _m4SwitchClosed);
      case 4:
        return _m5BatteryInserted && _m5PushButtonInserted && _m5PushButtonPressed && _m5LampInserted;
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
    return _isCurrentCircuitClosed ? 90.0 : 0.0;
  }

  Widget _buildStatusCard(bool isClosed) {
    final statusColor = isClosed
        ? const Color(0xFF10B981)
        : const Color(0xFF64748B);
    final statusText = isClosed
        ? 'CIRCUITO FECHADO (ON)'
        : 'CIRCUITO ABERTO (OFF)';

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
              fontSize: 12,
            ),
          ),
          Text(
            '${voltage.toStringAsFixed(1)}V ',
            style: GoogleFonts.outfit(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            '| CORRENTE: ',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            '${currentMa.toStringAsFixed(1)} mA',
            style: GoogleFonts.outfit(
              color: isClosed ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
          // Botão Undo
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
          // Contador
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
          // Botão Redo
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
                    'Prof. Volts: "${mission.voltsMediation}"',
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
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: Text(
            'Componentes Básicos:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
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
              tooltip: 'Fonte de Alimentação 9V',
              symbolWidget: _usePhysicalStyle
                  ? const BatteryVectorWidget(size: 34)
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
            // SPST: Interruptor alavanca
            WorkbenchSymbolToolboxTile<String>(
              data: 'switch',
              label: 'SPST',
              tooltip: 'Interruptor SPST (Alavanca)',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.switchComponent,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.switchComponent,
                        color: const Color(0xFF0284C7),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF0284C7),
            ),
            // Chave 1: Sem etiqueta, cor diferente
            WorkbenchSymbolToolboxTile<String>(
              data: 'switch1',
              label: 'Chave 1',
              tooltip: 'Interruptor 1 (Sem Etiqueta)',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.switchComponent,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.switchComponent,
                        color: const Color(0xFF0284C7),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF0284C7),
            ),
            // Chave 2: Sem etiqueta, cor diferente
            WorkbenchSymbolToolboxTile<String>(
              data: 'switch2',
              label: 'Chave 2',
              tooltip: 'Interruptor 2 (Sem Etiqueta)',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.switchComponent,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.switchComponent,
                        color: const Color(0xFF10B981),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF10B981),
            ),
            // Push-Button: Botão de pressão
            WorkbenchSymbolToolboxTile<String>(
              data: 'push_button',
              label: 'Botão',
              tooltip: 'Botão de Pressão (Momentâneo)',
              symbolWidget: _usePhysicalStyle
                  ? const PushButtonVectorWidget(size: 34)
                  : const SchematicSwitchWidget(
                      size: 34,
                      isPushButton: true,
                      color: Color(0xFFEF4444),
                    ),
              color: const Color(0xFFEF4444),
            ),
            // Lâmpada
            WorkbenchSymbolToolboxTile<String>(
              data: 'bulb',
              label: 'Lâmpada',
              tooltip: 'Lâmpada Incandescente E10',
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
            // Motor CC
            WorkbenchSymbolToolboxTile<String>(
              data: 'motor_cc',
              label: 'Motor CC',
              tooltip: 'Motor de Corrente Contínua',
              symbolWidget: _usePhysicalStyle
                  ? CustomPaint(
                      size: const Size(34, 34),
                      painter: ComponentPhysicalPainter(
                        type: ComponentType.motor,
                        isDarkMode: false,
                      ),
                    )
                  : CustomPaint(
                      size: const Size(34, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.motor,
                        color: const Color(0xFF0284C7),
                        strokeWidth: 2.0,
                      ),
                    ),
              color: const Color(0xFF0284C7),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // MISSÃO 1: Interruptor da Luminária
  // ==========================================
  Widget _buildMission1UI(StandMission mission) {
    return _usePhysicalStyle
        ? _buildPhysicalCanvasM1()
        : _buildSchematicCanvasM1();
  }

  // ==========================================
  // MISSÃO 2: Aberto ou Fechado?
  // ==========================================
  Widget _buildMission2UI(StandMission mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _usePhysicalStyle ? _buildPhysicalCanvasM2() : _buildSchematicCanvasM2(),
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
                      Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Questão 1: Estado A (Chave Aberta)
                _buildPredictionCard(
                  title: 'Cenário A: Interruptor no estado ABERTO (OFF)',
                  subtitle:
                      'Existe um espaço vazio entre os contatos elétricos da chave.',
                  currentValue: _m2AnswerStateA,
                  onSelect: (val) => setState(() => _m2AnswerStateA = val),
                ),

                const SizedBox(height: 8),

                // Questão 2: Estado B (Chave Fechada)
                _buildPredictionCard(
                  title: 'Cenário B: Interruptor no estado FECHADO (ON)',
                  subtitle: 'Os contatos condutores da chave estão encostados.',
                  currentValue: _m2AnswerStateB,
                  onSelect: (val) => setState(() => _m2AnswerStateB = val),
                ),
              ],
            ),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
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
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                  selected: currentValue == 'fechado',
                  selectedColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFF021E18),
                  onSelected: (selected) {
                    if (selected) onSelect('fechado');
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
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                  selected: currentValue == 'aberto',
                  selectedColor: Colors.amber,
                  backgroundColor: const Color(0xFF021E18),
                  onSelected: (selected) {
                    if (selected) onSelect('aberto');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MISSÃO 3: Dois Controles
  // ==========================================
  Widget _buildMission3UI(StandMission mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Teste acionar um interruptor por vez para descobrir qual luz responde a cada controle:',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              shadows: const [
                Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Bancada da Missão 3 (Clean Blueprint ou Físico 3D)
        _usePhysicalStyle
            ? _buildPhysicalCanvasM3()
            : _buildSchematicCanvasM3(),

        const SizedBox(height: 8),

        // Mapeamento de Resposta do Aluno
        Row(
          children: [
            Expanded(
              child: _buildMappingSelector(
                title: 'Chave 1 controla:',
                currentSelection: _m3MapSwitch1,
                onSelect: (val) => setState(() => _m3MapSwitch1 = val),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMappingSelector(
                title: 'Chave 2 controla:',
                currentSelection: _m3MapSwitch2,
                onSelect: (val) => setState(() => _m3MapSwitch2 = val),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMappingSelector({
    required String title,
    required String? currentSelection,
    required ValueChanged<String> onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: currentSelection != null
              ? const Color(0xFF0284C7)
              : const Color(0xFFCBD5E1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: currentSelection,
            dropdownColor: Colors.white,
            style: GoogleFonts.outfit(
              color: const Color(0xFF0F172A),
              fontSize: 12.5,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'lampA', child: Text('Luminária A')),
              DropdownMenuItem(value: 'lampB', child: Text('Luminária B')),
            ],
            onChanged: (val) {
              if (val != null) onSelect(val);
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MISSÃO 4: Conferência (Correção de Ramo Inútil)
  // ==========================================
  Widget _buildMission4UI(StandMission mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bancada Didática Interativa de Correção do Ramo (Clean Blueprint ou Físico 3D)
        _usePhysicalStyle
            ? _buildPhysicalCanvasM4()
            : _buildSchematicCanvasM4(),
      ],
    );
  }

  // ==========================================
  // MISSÃO 5: Controle por Push-Button
  // ==========================================
  Widget _buildMission5UI(StandMission mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bancada da Missão 5 (Clean Blueprint ou Físico 3D)
        _usePhysicalStyle
            ? _buildPhysicalCanvasM5()
            : _buildSchematicCanvasM5(),

        const SizedBox(height: 16),

        // Botão para Segurar / Pressionar
        if (_m5PushButtonInserted)
          Center(
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _m5PushButtonPressed = true;
                  _m5TestedHoldAndRelease = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  _m5PushButtonPressed = false;
                });
              },
              onTapCancel: () {
                setState(() {
                  _m5PushButtonPressed = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _m5PushButtonPressed
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_m5PushButtonPressed
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF0F172A))
                              .withValues(alpha: 0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _m5PushButtonPressed
                          ? Icons.lightbulb_rounded
                          : Icons.touch_app_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _m5PushButtonPressed
                          ? 'LUMINÁRIA ACESA! (PRESSIONADO)'
                          : 'SEGURE O BOTÃO PARA ACENDER',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================
  // CANVASES FÍSICOS 3D
  // ==========================================

  Widget _buildPhysicalCanvasM1() {
    final bool isClosed = _m1BatteryInserted && _m1SwitchInserted && _m1SwitchClosed && _m1BulbInserted;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 210.0;

        final double centerY = height * 0.50;
        final batteryPos = Offset(width * 0.18, centerY);
        final switchPos = Offset(width * 0.50, centerY);
        final lampPos = Offset(width * 0.82, centerY);

        // Fios dinâmicos - só aparecem quando componentes inseridos
        final wires = <WirePath>[];

        if (_m1BatteryInserted && _m1SwitchInserted) {
          final batTermA = ComponentPlacement(position: batteryPos, rotation: _m1BatteryRotation, type: ComponentType.battery).getTerminalPosition(0);
          final switchTermA = ComponentPlacement(position: switchPos, rotation: _m1SwitchRotation, type: ComponentType.switchComponent).getTerminalPosition(0);
          final leftX = batteryPos.dx - 55.0;
          final bottomY = centerY + 65.0;

          // VCC: Bateria(+) -> Switch(A)
          final intermediate = (_m1BatteryRotation % 360 == 270.0)
              ? [
                  Offset(leftX, batTermA.dy),
                  Offset(leftX, bottomY),
                  Offset(switchTermA.dx, bottomY),
                ]
              : null;

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: batteryPos, rotation: _m1BatteryRotation, type: ComponentType.battery),
            terminalIndexA: 0,
            compB: ComponentPlacement(position: switchPos, rotation: _m1SwitchRotation, type: ComponentType.switchComponent),
            terminalIndexB: 0,
            color: const Color(0xFFEF4444),
            isActive: isClosed,
            thickness: 4.5,
          ).toWirePath(intermediatePoints: intermediate));
        }

        if (_m1SwitchInserted && _m1BulbInserted) {
          // Switch(B) -> Bulb(A)
          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: switchPos, rotation: _m1SwitchRotation, type: ComponentType.switchComponent),
            terminalIndexA: 1,
            compB: ComponentPlacement(position: lampPos, rotation: _m1BulbRotation, type: ComponentType.bulb),
            terminalIndexB: 0,
            color: const Color(0xFFF97316),
            isActive: isClosed,
            thickness: 4.5,
          ).toWirePath());
        }

        if (_m1BulbInserted && _m1BatteryInserted) {
          final bulbTermB = ComponentPlacement(position: lampPos, rotation: _m1BulbRotation, type: ComponentType.bulb).getTerminalPosition(1);
          final batTermB = ComponentPlacement(position: batteryPos, rotation: _m1BatteryRotation, type: ComponentType.battery).getTerminalPosition(1);
          final leftX = batteryPos.dx - 55.0;
          final topY = centerY - 65.0;
          final bottomY = centerY + 65.0;

          // Bulb(B) -> Bateria(-) (retorno superior quando bateria está em 270°)
          final intermediate = (_m1BatteryRotation % 360 == 270.0)
              ? [
                  Offset(bulbTermB.dx, topY),
                  Offset(leftX, topY),
                  Offset(leftX, batTermB.dy),
                ]
              : [
                  Offset(bulbTermB.dx, bottomY),
                  Offset(batTermB.dx, bottomY),
                ];

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: lampPos, rotation: _m1BulbRotation, type: ComponentType.bulb),
            terminalIndexA: 1,
            compB: ComponentPlacement(position: batteryPos, rotation: _m1BatteryRotation, type: ComponentType.battery),
            terminalIndexB: 1,
            color: const Color(0xFF2563EB),
            isActive: isClosed,
            thickness: 4.5,
          ).toWirePath(intermediatePoints: intermediate));
        }

        return Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              // Fios realistas com elétrons animados
              Positioned.fill(
                child: RealisticWireWidget(
                  wires: wires,
                  animationValue: _currentFlowController.value,
                  showElectrons: isClosed,
                ),
              ),

              // Socket da Bateria (Esquerda)
              Positioned(
                left: batteryPos.dx - 47.5,
                top: batteryPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _m1BatteryInserted,
                  showLabel: false,
                  rotation: _m1BatteryRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Bateria M1',
                    getInserted: () => _m1BatteryInserted,
                    setInserted: (v) => _m1BatteryInserted = v,
                    getRotation: () => _m1BatteryRotation,
                    setRotation: (v) => _m1BatteryRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Bateria M1',
                    getRotation: () => _m1BatteryRotation,
                    setRotation: (v) => _m1BatteryRotation = v,
                  ),
                  onTap: () => _insertComponent(
                    name: 'Bateria M1',
                    getInserted: () => _m1BatteryInserted,
                    setInserted: (v) => _m1BatteryInserted = v,
                    getRotation: () => _m1BatteryRotation,
                    setRotation: (v) => _m1BatteryRotation = v,
                  ),
                  symbolWidget: CustomPaint(
                    size: const Size(80, 80),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.battery,
                      isActive: true,
                      isDarkMode: false,
                      value: 4.5,
                    ),
                  ),
                ),
              ),

              // Socket do Interruptor (Centro)
              Positioned(
                left: switchPos.dx - 47.5,
                top: switchPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _m1SwitchInserted,
                  showLabel: false,
                  rotation: _m1SwitchRotation,
                  onAccept: (_) {
                    final prevSwitchInserted = _m1SwitchInserted;
                    final prevSwitchClosed = _m1SwitchClosed;
                    final prevSwitchRotation = _m1SwitchRotation;
                    _undoRedoController.execute(CompoundAction(
                      description: 'Inserir Interruptor M1',
                      actions: [
                        InsertComponentAction(
                          description: 'Inserir Interruptor',
                          onApply: () => setState(() {
                            _m1SwitchInserted = true;
                            _m1SwitchRotation = 0;
                          }),
                          onUndo: () => setState(() {
                            _m1SwitchInserted = prevSwitchInserted;
                            _m1SwitchRotation = prevSwitchRotation;
                          }),
                        ),
                        ToggleBoolAction(
                          description: 'Fechar Interruptor',
                          onApply: () => setState(() => _m1SwitchClosed = true),
                          onUndo: () => setState(() => _m1SwitchClosed = prevSwitchClosed),
                        ),
                      ],
                    ));
                  },
                  onRotate: () => _rotateComponent(
                    name: 'Interruptor M1',
                    getRotation: () => _m1SwitchRotation,
                    setRotation: (v) => _m1SwitchRotation = v,
                  ),
                  onTap: () {
                    if (_m1SwitchInserted) {
                      final prev = _m1SwitchClosed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Interruptor M1',
                        onApply: () => setState(() => _m1SwitchClosed = !prev),
                        onUndo: () => setState(() => _m1SwitchClosed = prev),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(90, 80),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m1SwitchClosed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Socket da Lâmpada (Direita)
              Positioned(
                left: lampPos.dx - 47.5,
                top: lampPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _m1BulbInserted,
                  showLabel: false,
                  rotation: _m1BulbRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Lâmpada M1',
                    getInserted: () => _m1BulbInserted,
                    setInserted: (v) => _m1BulbInserted = v,
                    getRotation: () => _m1BulbRotation,
                    setRotation: (v) => _m1BulbRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Lâmpada M1',
                    getRotation: () => _m1BulbRotation,
                    setRotation: (v) => _m1BulbRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(80, 80),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.bulb,
                      isActive: isClosed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhysicalCanvasM2() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 145.0;

        final posABat = Offset(width * 0.12, 45.0);
        final posASw = Offset(width * 0.27, 45.0);
        final posABulb = Offset(width * 0.42, 45.0);

        final posBBat = Offset(width * 0.58, 45.0);
        final posBSw = Offset(width * 0.73, 45.0);
        final posBBulb = Offset(width * 0.88, 45.0);

        final wires = <WirePath>[];

        // Fios Cenário A
        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posABat, rotation: 0, type: ComponentType.battery),
          terminalIndexA: 1,
          compB: ComponentPlacement(position: posASw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexB: 0,
          color: const Color(0xFFEF4444),
          isActive: _m2SwitchAClosed,
          thickness: 4.0,
        ).toWirePath());

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posASw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexA: 1,
          compB: ComponentPlacement(position: posABulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexB: 0,
          color: const Color(0xFFF97316),
          isActive: _m2SwitchAClosed,
          thickness: 4.0,
        ).toWirePath());

        final termABulb = ComponentPlacement(position: posABulb, rotation: 0, type: ComponentType.bulb).getTerminalPosition(1);
        final termABat = ComponentPlacement(position: posABat, rotation: 0, type: ComponentType.battery).getTerminalPosition(1);
        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posABulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexA: 1,
          compB: ComponentPlacement(position: posABat, rotation: 0, type: ComponentType.battery),
          terminalIndexB: 1,
          color: const Color(0xFF2563EB),
          isActive: _m2SwitchAClosed,
          thickness: 4.0,
        ).toWirePath(intermediatePoints: [
          Offset(termABulb.dx, 100.0),
          Offset(termABat.dx, 100.0),
        ]));

        // Fios Cenário B
        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posBBat, rotation: 0, type: ComponentType.battery),
          terminalIndexA: 0,
          compB: ComponentPlacement(position: posBSw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexB: 0,
          color: const Color(0xFFEF4444),
          isActive: _m2SwitchBClosed,
          thickness: 4.0,
        ).toWirePath());

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posBSw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexA: 1,
          compB: ComponentPlacement(position: posBBulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexB: 0,
          color: const Color(0xFFF97316),
          isActive: _m2SwitchBClosed,
          thickness: 4.0,
        ).toWirePath());

        final termBBulb = ComponentPlacement(position: posBBulb, rotation: 0, type: ComponentType.bulb).getTerminalPosition(1);
        final termBBat = ComponentPlacement(position: posBBat, rotation: 0, type: ComponentType.battery).getTerminalPosition(1);
        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posBBulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexA: 1,
          compB: ComponentPlacement(position: posBBat, rotation: 0, type: ComponentType.battery),
          terminalIndexB: 1,
          color: const Color(0xFF2563EB),
          isActive: _m2SwitchBClosed,
          thickness: 4.0,
        ).toWirePath(intermediatePoints: [
          Offset(termBBulb.dx, 100.0),
          Offset(termBBat.dx, 100.0),
        ]));

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: RealisticWireWidget(
                  wires: wires,
                  animationValue: _currentFlowController.value,
                  showElectrons: _m2SwitchAClosed || _m2SwitchBClosed,
                ),
              ),

              // Rótulos dos Cenários
              Positioned(
                left: width * 0.05,
                top: 2,
                child: Text(
                  'CENÁRIO A (ABERTO)',
                  style: GoogleFonts.rajdhani(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Positioned(
                left: width * 0.52,
                top: 2,
                child: Text(
                  'CENÁRIO B (FECHADO)',
                  style: GoogleFonts.rajdhani(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),

              // Sockets Cenário A
              Positioned(
                left: posABat.dx - 30, top: posABat.dy - 20,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'battery', isFilled: true, showLabel: false, width: 60, height: 40,
                  onAccept: (_) {}, onRotate: () {}, onTap: () {},
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: ComponentPhysicalPainter(type: ComponentType.battery, isActive: true, isDarkMode: false, value: 4.5)),
                ),
              ),
              Positioned(
                left: posASw.dx - 30, top: posASw.dy - 20,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch', isFilled: true, showLabel: false, width: 60, height: 40,
                  onAccept: (_) {}, onRotate: () {},
                  onTap: () => setState(() => _m2SwitchAClosed = !_m2SwitchAClosed),
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: ComponentPhysicalPainter(type: ComponentType.switchComponent, isActive: _m2SwitchAClosed, isDarkMode: false)),
                ),
              ),
              Positioned(
                left: posABulb.dx - 30, top: posABulb.dy - 20,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'bulb', isFilled: true, showLabel: false, width: 60, height: 40,
                  onAccept: (_) {}, onRotate: () {}, onTap: () {},
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: ComponentPhysicalPainter(type: ComponentType.bulb, isActive: _m2SwitchAClosed, isDarkMode: false)),
                ),
              ),

              // Sockets Cenário B
              Positioned(
                left: posBBat.dx - 30, top: posBBat.dy - 20,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'battery', isFilled: true, showLabel: false, width: 60, height: 40,
                  onAccept: (_) {}, onRotate: () {}, onTap: () {},
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: ComponentPhysicalPainter(type: ComponentType.battery, isActive: true, isDarkMode: false, value: 4.5)),
                ),
              ),
              Positioned(
                left: posBSw.dx - 30, top: posBSw.dy - 20,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch', isFilled: true, showLabel: false, width: 60, height: 40,
                  onAccept: (_) {}, onRotate: () {},
                  onTap: () => setState(() => _m2SwitchBClosed = !_m2SwitchBClosed),
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: ComponentPhysicalPainter(type: ComponentType.switchComponent, isActive: _m2SwitchBClosed, isDarkMode: false)),
                ),
              ),
              Positioned(
                left: posBBulb.dx - 30, top: posBBulb.dy - 20,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'bulb', isFilled: true, showLabel: false, width: 60, height: 40,
                  onAccept: (_) {}, onRotate: () {}, onTap: () {},
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: ComponentPhysicalPainter(type: ComponentType.bulb, isActive: _m2SwitchBClosed, isDarkMode: false)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhysicalCanvasM3() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 180.0;
        final double centerY = 90.0;

        final batteryPos = Offset(width * 0.18, centerY);
        final switch1Pos = Offset(width * 0.50, 40.0);
        final switch2Pos = Offset(width * 0.50, 140.0);
        final lamp1Pos = Offset(width * 0.82, 40.0);
        final lamp2Pos = Offset(width * 0.82, 140.0);

        // Fios dinâmicos
        final wires = <WirePath>[];

        if (_m3BatteryInserted && _m3Switch1Inserted) {
          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: batteryPos, rotation: _m3BatteryRotation, type: ComponentType.battery),
            terminalIndexA: 0,
            compB: ComponentPlacement(position: switch1Pos, rotation: _m3Switch1Rotation, type: ComponentType.switchComponent),
            terminalIndexB: 0,
            color: const Color(0xFFEF4444),
            isActive: _m3Switch1Closed,
            thickness: 4.0,
          ).toWirePath());
        }

        if (_m3BatteryInserted && _m3Switch2Inserted) {
          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: batteryPos, rotation: _m3BatteryRotation, type: ComponentType.battery),
            terminalIndexA: 0,
            compB: ComponentPlacement(position: switch2Pos, rotation: _m3Switch2Rotation, type: ComponentType.switchComponent),
            terminalIndexB: 0,
            color: const Color(0xFFEAB308),
            isActive: _m3Switch2Closed,
            thickness: 4.0,
          ).toWirePath());
        }

        if (_m3Switch1Inserted && _m3LampAInserted) {
          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: switch1Pos, rotation: _m3Switch1Rotation, type: ComponentType.switchComponent),
            terminalIndexA: 1,
            compB: ComponentPlacement(position: lamp1Pos, rotation: _m3LampARotation, type: ComponentType.bulb),
            terminalIndexB: 0,
            color: const Color(0xFFF97316),
            isActive: _m3Switch1Closed,
            thickness: 4.0,
          ).toWirePath());
        }

        if (_m3Switch2Inserted && _m3LampBInserted) {
          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: switch2Pos, rotation: _m3Switch2Rotation, type: ComponentType.switchComponent),
            terminalIndexA: 1,
            compB: ComponentPlacement(position: lamp2Pos, rotation: _m3LampBRotation, type: ComponentType.bulb),
            terminalIndexB: 0,
            color: const Color(0xFF10B981),
            isActive: _m3Switch2Closed,
            thickness: 4.0,
          ).toWirePath());
        }

        if (_m3LampAInserted && _m3LampBInserted && _m3BatteryInserted) {
          final bulb2Term = ComponentPlacement(position: lamp2Pos, rotation: _m3LampBRotation, type: ComponentType.bulb).getTerminalPosition(1);
          final batTerm = ComponentPlacement(position: batteryPos, rotation: _m3BatteryRotation, type: ComponentType.battery).getTerminalPosition(1);
          final bottomY = 165.0;

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: lamp1Pos, rotation: _m3LampARotation, type: ComponentType.bulb),
            terminalIndexA: 1,
            compB: ComponentPlacement(position: batteryPos, rotation: _m3BatteryRotation, type: ComponentType.battery),
            terminalIndexB: 1,
            color: const Color(0xFF2563EB),
            isActive: _m3Switch1Closed || _m3Switch2Closed,
            thickness: 4.0,
          ).toWirePath(intermediatePoints: [
            Offset(bulb2Term.dx, bottomY),
            Offset(batTerm.dx, bottomY),
          ]));
        }

        return Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: RealisticWireWidget(
                  wires: wires,
                  animationValue: _currentFlowController.value,
                  showElectrons: _m3Switch1Closed || _m3Switch2Closed,
                ),
              ),

              // Socket Bateria
              Positioned(
                left: batteryPos.dx - 47.5,
                top: batteryPos.dy - 40.0,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _m3BatteryInserted,
                  showLabel: false,
                  rotation: _m3BatteryRotation,
                  width: 95,
                  height: 80,
                  onAccept: (_) => _insertComponent(
                    name: 'Bateria M3',
                    getInserted: () => _m3BatteryInserted,
                    setInserted: (v) => _m3BatteryInserted = v,
                    getRotation: () => _m3BatteryRotation,
                    setRotation: (v) => _m3BatteryRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Bateria M3',
                    getRotation: () => _m3BatteryRotation,
                    setRotation: (v) => _m3BatteryRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(80, 80),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.battery,
                      isActive: true,
                      isDarkMode: false,
                      value: 4.5,
                    ),
                  ),
                ),
              ),

              // Socket Chave 1 (Ramo 1 - Topo)
              Positioned(
                left: switch1Pos.dx - 40.0,
                top: switch1Pos.dy - 25.0,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch1',
                  isFilled: _m3Switch1Inserted,
                  showLabel: false,
                  rotation: _m3Switch1Rotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) {
                    final prevInserted = _m3Switch1Inserted;
                    final prevClosed = _m3Switch1Closed;
                    final prevRotation = _m3Switch1Rotation;
                    _undoRedoController.execute(CompoundAction(
                      description: 'Inserir Chave 1 M3',
                      actions: [
                        InsertComponentAction(
                          description: 'Inserir Chave 1',
                          onApply: () => setState(() { _m3Switch1Inserted = true; _m3Switch1Rotation = 0; }),
                          onUndo: () => setState(() { _m3Switch1Inserted = prevInserted; _m3Switch1Rotation = prevRotation; }),
                        ),
                        ToggleBoolAction(
                          description: 'Fechar Chave 1',
                          onApply: () => setState(() => _m3Switch1Closed = true),
                          onUndo: () => setState(() => _m3Switch1Closed = prevClosed),
                        ),
                      ],
                    ));
                  },
                  onRotate: () => _rotateComponent(
                    name: 'Chave 1 M3',
                    getRotation: () => _m3Switch1Rotation,
                    setRotation: (v) => _m3Switch1Rotation = v,
                  ),
                  onTap: () {
                    if (_m3Switch1Inserted) {
                      final prev = _m3Switch1Closed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Chave 1 M3',
                        onApply: () => setState(() { _m3Switch1Closed = !prev; _m3TestedSwitch1 = true; }),
                        onUndo: () => setState(() { _m3Switch1Closed = prev; _m3TestedSwitch1 = false; }),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(70, 45),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m3Switch1Closed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Socket Chave 2 (Ramo 2 - Baixo)
              Positioned(
                left: switch2Pos.dx - 40.0,
                top: switch2Pos.dy - 25.0,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch2',
                  isFilled: _m3Switch2Inserted,
                  showLabel: false,
                  rotation: _m3Switch2Rotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) {
                    final prevInserted = _m3Switch2Inserted;
                    final prevClosed = _m3Switch2Closed;
                    final prevRotation = _m3Switch2Rotation;
                    _undoRedoController.execute(CompoundAction(
                      description: 'Inserir Chave 2 M3',
                      actions: [
                        InsertComponentAction(
                          description: 'Inserir Chave 2',
                          onApply: () => setState(() { _m3Switch2Inserted = true; _m3Switch2Rotation = 0; }),
                          onUndo: () => setState(() { _m3Switch2Inserted = prevInserted; _m3Switch2Rotation = prevRotation; }),
                        ),
                        ToggleBoolAction(
                          description: 'Fechar Chave 2',
                          onApply: () => setState(() => _m3Switch2Closed = true),
                          onUndo: () => setState(() => _m3Switch2Closed = prevClosed),
                        ),
                      ],
                    ));
                  },
                  onRotate: () => _rotateComponent(
                    name: 'Chave 2 M3',
                    getRotation: () => _m3Switch2Rotation,
                    setRotation: (v) => _m3Switch2Rotation = v,
                  ),
                  onTap: () {
                    if (_m3Switch2Inserted) {
                      final prev = _m3Switch2Closed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Chave 2 M3',
                        onApply: () => setState(() { _m3Switch2Closed = !prev; _m3TestedSwitch2 = true; }),
                        onUndo: () => setState(() { _m3Switch2Closed = prev; _m3TestedSwitch2 = false; }),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(70, 45),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m3Switch2Closed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Socket Lâmpada A (Ramo 1 - Topo)
              Positioned(
                left: lamp1Pos.dx - 40.0,
                top: lamp1Pos.dy - 25.0,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _m3LampAInserted,
                  showLabel: false,
                  rotation: _m3LampARotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) => _insertComponent(
                    name: 'Lâmpada A M3',
                    getInserted: () => _m3LampAInserted,
                    setInserted: (v) => _m3LampAInserted = v,
                    getRotation: () => _m3LampARotation,
                    setRotation: (v) => _m3LampARotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Lâmpada A M3',
                    getRotation: () => _m3LampARotation,
                    setRotation: (v) => _m3LampARotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(70, 45),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.bulb,
                      isActive: _m3Switch1Closed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Socket Lâmpada B (Ramo 2 - Baixo)
              Positioned(
                left: lamp2Pos.dx - 40.0,
                top: lamp2Pos.dy - 25.0,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _m3LampBInserted,
                  showLabel: false,
                  rotation: _m3LampBRotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) => _insertComponent(
                    name: 'Lâmpada B M3',
                    getInserted: () => _m3LampBInserted,
                    setInserted: (v) => _m3LampBInserted = v,
                    getRotation: () => _m3LampBRotation,
                    setRotation: (v) => _m3LampBRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Lâmpada B M3',
                    getRotation: () => _m3LampBRotation,
                    setRotation: (v) => _m3LampBRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(70, 45),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.bulb,
                      isActive: _m3Switch2Closed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhysicalCanvasM4() {
    final bool isLampLit = _m4BatteryInserted &&
        _m4LampInserted &&
        _m4SwitchSeriesInserted &&
        (!_m4SwitchInMainBranch || _m4SwitchClosed);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 210.0;

        final double centerY = height * 0.50;
        final batteryPos = Offset(width * 0.18, centerY);
        final switchInutilityPos = Offset(width * 0.50, centerY - 55.0);
        final switchSeriesPos = Offset(width * 0.50, centerY);
        final lampPos = Offset(width * 0.82, centerY);

        // Fios dinâmicos
        final wires = <WirePath>[];

        if (_m4BatteryInserted && _m4LampInserted) {
          if (_m4SwitchInMainBranch) {
            // Switch no Ramo Principal (Centro)
            if (_m4SwitchSeriesInserted) {
              wires.add(DynamicWirePath.fromComponents(
                compA: ComponentPlacement(position: batteryPos, rotation: _m4BatteryRotation, type: ComponentType.battery),
                terminalIndexA: 0,
                compB: ComponentPlacement(position: switchSeriesPos, rotation: _m4SwitchSeriesRotation, type: ComponentType.switchComponent),
                terminalIndexB: 0,
                color: const Color(0xFFEF4444),
                isActive: isLampLit,
                thickness: 4.0,
              ).toWirePath());

              wires.add(DynamicWirePath.fromComponents(
                compA: ComponentPlacement(position: switchSeriesPos, rotation: _m4SwitchSeriesRotation, type: ComponentType.switchComponent),
                terminalIndexA: 1,
                compB: ComponentPlacement(position: lampPos, rotation: _m4LampRotation, type: ComponentType.bulb),
                terminalIndexB: 0,
                color: const Color(0xFF10B981),
                isActive: isLampLit,
                thickness: 4.0,
              ).toWirePath());
            }
          } else {
            // Switch no Ramo Inútil (Topo)
            wires.add(DynamicWirePath.fromComponents(
              compA: ComponentPlacement(position: batteryPos, rotation: _m4BatteryRotation, type: ComponentType.battery),
              terminalIndexA: 0,
              compB: ComponentPlacement(position: lampPos, rotation: _m4LampRotation, type: ComponentType.bulb),
              terminalIndexB: 0,
              color: const Color(0xFFEF4444),
              isActive: isLampLit,
              thickness: 4.0,
            ).toWirePath());

            if (_m4SwitchSeriesInserted) {
              wires.add(DynamicWirePath.fromComponents(
                compA: ComponentPlacement(position: batteryPos, rotation: _m4BatteryRotation, type: ComponentType.battery),
                terminalIndexA: 0,
                compB: ComponentPlacement(position: switchInutilityPos, rotation: _m4SwitchSeriesRotation, type: ComponentType.switchComponent),
                terminalIndexB: 0,
                color: const Color(0xFFEAB308),
                isActive: _m4SwitchClosed,
                thickness: 3.5,
              ).toWirePath());

              wires.add(DynamicWirePath.fromComponents(
                compA: ComponentPlacement(position: switchInutilityPos, rotation: _m4SwitchSeriesRotation, type: ComponentType.switchComponent),
                terminalIndexA: 1,
                compB: ComponentPlacement(position: lampPos, rotation: _m4LampRotation, type: ComponentType.bulb),
                terminalIndexB: 0,
                color: const Color(0xFFEAB308),
                isActive: _m4SwitchClosed,
                thickness: 3.5,
              ).toWirePath());
            }
          }

          final lampTerm = ComponentPlacement(position: lampPos, rotation: _m4LampRotation, type: ComponentType.bulb).getTerminalPosition(1);
          final batTerm = ComponentPlacement(position: batteryPos, rotation: _m4BatteryRotation, type: ComponentType.battery).getTerminalPosition(1);
          final bottomY = centerY + 65.0;

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: lampPos, rotation: _m4LampRotation, type: ComponentType.bulb),
            terminalIndexA: 1,
            compB: ComponentPlacement(position: batteryPos, rotation: _m4BatteryRotation, type: ComponentType.battery),
            terminalIndexB: 1,
            color: const Color(0xFF2563EB),
            isActive: isLampLit,
            thickness: 4.0,
          ).toWirePath(intermediatePoints: [
            Offset(lampTerm.dx, bottomY),
            Offset(batTerm.dx, bottomY),
          ]));
        }

        return Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: RealisticWireWidget(
                  wires: wires,
                  animationValue: _currentFlowController.value,
                  showElectrons: isLampLit,
                ),
              ),

              // Socket Bateria
              Positioned(
                left: batteryPos.dx - 47.5,
                top: batteryPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _m4BatteryInserted,
                  showLabel: false,
                  rotation: _m4BatteryRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Bateria M4',
                    getInserted: () => _m4BatteryInserted,
                    setInserted: (v) => _m4BatteryInserted = v,
                    getRotation: () => _m4BatteryRotation,
                    setRotation: (v) => _m4BatteryRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Bateria M4',
                    getRotation: () => _m4BatteryRotation,
                    setRotation: (v) => _m4BatteryRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(80, 80),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.battery,
                      isActive: true,
                      isDarkMode: false,
                      value: 4.5,
                    ),
                  ),
                ),
              ),

              // Posicionamento A: Ramo Inútil (Topo)
              Positioned(
                left: switchInutilityPos.dx - 47.5,
                top: switchInutilityPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _m4SwitchSeriesInserted && !_m4SwitchInMainBranch,
                  showLabel: false,
                  rotation: _m4SwitchSeriesRotation,
                  accentColor: !_m4SwitchInMainBranch
                      ? const Color(0xFFD97706)
                      : const Color(0xFF94A3B8),
                  onAccept: (_) {
                    final prevInserted = _m4SwitchSeriesInserted;
                    final prevInMain = _m4SwitchInMainBranch;
                    final prevClosed = _m4SwitchClosed;
                    _undoRedoController.execute(CompoundAction(
                      description: 'Inserir no Ramo Inútil M4',
                      actions: [
                        InsertComponentAction(
                          description: 'Inserir Interruptor',
                          onApply: () => setState(() {
                            _m4SwitchSeriesInserted = true;
                            _m4SwitchInMainBranch = false;
                            _m4SwitchClosed = true;
                          }),
                          onUndo: () => setState(() {
                            _m4SwitchSeriesInserted = prevInserted;
                            _m4SwitchInMainBranch = prevInMain;
                            _m4SwitchClosed = prevClosed;
                          }),
                        ),
                      ],
                    ));
                  },
                  onRotate: () => _rotateComponent(
                    name: 'Interruptor M4',
                    getRotation: () => _m4SwitchSeriesRotation,
                    setRotation: (v) => _m4SwitchSeriesRotation = v,
                  ),
                  onTap: () {
                    if (_m4SwitchSeriesInserted && !_m4SwitchInMainBranch) {
                      final prev = _m4SwitchClosed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Interruptor M4',
                        onApply: () => setState(() => _m4SwitchClosed = !prev),
                        onUndo: () => setState(() => _m4SwitchClosed = prev),
                      ));
                    } else {
                      final prevInMain = _m4SwitchInMainBranch;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Mover para Ramo Inútil M4',
                        onApply: () => setState(() {
                          _m4SwitchSeriesInserted = true;
                          _m4SwitchInMainBranch = false;
                        }),
                        onUndo: () => setState(() => _m4SwitchInMainBranch = prevInMain),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(80, 70),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m4SwitchClosed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Posicionamento B: Ramo Principal em Série (Centro)
              Positioned(
                left: switchSeriesPos.dx - 47.5,
                top: switchSeriesPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _m4SwitchSeriesInserted && _m4SwitchInMainBranch,
                  showLabel: false,
                  rotation: _m4SwitchSeriesRotation,
                  accentColor: _m4SwitchInMainBranch
                      ? const Color(0xFF059669)
                      : const Color(0xFF94A3B8),
                  onAccept: (_) {
                    final prevInserted = _m4SwitchSeriesInserted;
                    final prevInMain = _m4SwitchInMainBranch;
                    final prevClosed = _m4SwitchClosed;
                    _undoRedoController.execute(CompoundAction(
                      description: 'Inserir no Ramo Principal M4',
                      actions: [
                        InsertComponentAction(
                          description: 'Inserir Interruptor',
                          onApply: () => setState(() {
                            _m4SwitchSeriesInserted = true;
                            _m4SwitchInMainBranch = true;
                            _m4SwitchClosed = true;
                          }),
                          onUndo: () => setState(() {
                            _m4SwitchSeriesInserted = prevInserted;
                            _m4SwitchInMainBranch = prevInMain;
                            _m4SwitchClosed = prevClosed;
                          }),
                        ),
                      ],
                    ));
                  },
                  onRotate: () => _rotateComponent(
                    name: 'Interruptor M4',
                    getRotation: () => _m4SwitchSeriesRotation,
                    setRotation: (v) => _m4SwitchSeriesRotation = v,
                  ),
                  onTap: () {
                    if (_m4SwitchSeriesInserted && _m4SwitchInMainBranch) {
                      final prev = _m4SwitchClosed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Interruptor M4',
                        onApply: () => setState(() => _m4SwitchClosed = !prev),
                        onUndo: () => setState(() => _m4SwitchClosed = prev),
                      ));
                    } else {
                      final prevInMain = _m4SwitchInMainBranch;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Mover para Ramo Principal M4',
                        onApply: () => setState(() {
                          _m4SwitchSeriesInserted = true;
                          _m4SwitchInMainBranch = true;
                        }),
                        onUndo: () => setState(() => _m4SwitchInMainBranch = prevInMain),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(80, 70),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m4SwitchClosed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Socket Lâmpada
              Positioned(
                left: lampPos.dx - 47.5,
                top: lampPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _m4LampInserted,
                  showLabel: false,
                  rotation: _m4LampRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Lâmpada M4',
                    getInserted: () => _m4LampInserted,
                    setInserted: (v) => _m4LampInserted = v,
                    getRotation: () => _m4LampRotation,
                    setRotation: (v) => _m4LampRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Lâmpada M4',
                    getRotation: () => _m4LampRotation,
                    setRotation: (v) => _m4LampRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(80, 80),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.bulb,
                      isActive: isLampLit,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhysicalCanvasM5() {
    final bool isLit = _m5BatteryInserted && _m5PushButtonInserted && _m5PushButtonPressed && _m5LampInserted;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 210.0;
        final double centerY = height * 0.50;

        final batteryPos = Offset(width * 0.18, centerY);
        final pushButtonPos = Offset(width * 0.50, centerY);
        final lampPos = Offset(width * 0.82, centerY);

        // Fios dinâmicos
        final wires = <WirePath>[];

        if (_m5BatteryInserted && _m5PushButtonInserted) {
          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: batteryPos, rotation: _m5BatteryRotation, type: ComponentType.battery),
            terminalIndexA: 0,
            compB: ComponentPlacement(position: pushButtonPos, rotation: _m5PushButtonRotation, type: ComponentType.switchComponent),
            terminalIndexB: 0,
            color: const Color(0xFFEF4444),
            isActive: isLit,
            thickness: 4.5,
          ).toWirePath());
        }

        if (_m5PushButtonInserted && _m5LampInserted) {
          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: pushButtonPos, rotation: _m5PushButtonRotation, type: ComponentType.switchComponent),
            terminalIndexA: 1,
            compB: ComponentPlacement(position: lampPos, rotation: _m5LampRotation, type: ComponentType.bulb),
            terminalIndexB: 0,
            color: const Color(0xFFF97316),
            isActive: isLit,
            thickness: 4.5,
          ).toWirePath());
        }

        if (_m5LampInserted && _m5BatteryInserted) {
          final lampTerm = ComponentPlacement(position: lampPos, rotation: _m5LampRotation, type: ComponentType.bulb).getTerminalPosition(1);
          final batTerm = ComponentPlacement(position: batteryPos, rotation: _m5BatteryRotation, type: ComponentType.battery).getTerminalPosition(1);
          final bottomY = centerY + 65.0;

          wires.add(DynamicWirePath.fromComponents(
            compA: ComponentPlacement(position: lampPos, rotation: _m5LampRotation, type: ComponentType.bulb),
            terminalIndexA: 1,
            compB: ComponentPlacement(position: batteryPos, rotation: _m5BatteryRotation, type: ComponentType.battery),
            terminalIndexB: 1,
            color: const Color(0xFF2563EB),
            isActive: isLit,
            thickness: 4.5,
          ).toWirePath(intermediatePoints: [
            Offset(lampTerm.dx, bottomY),
            Offset(batTerm.dx, bottomY),
          ]));
        }

        return Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: RealisticWireWidget(
                  wires: wires,
                  animationValue: _currentFlowController.value,
                  showElectrons: isLit,
                ),
              ),

              // Socket Bateria
              Positioned(
                left: batteryPos.dx - 47.5,
                top: batteryPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _m5BatteryInserted,
                  showLabel: false,
                  rotation: _m5BatteryRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Bateria M5',
                    getInserted: () => _m5BatteryInserted,
                    setInserted: (v) => _m5BatteryInserted = v,
                    getRotation: () => _m5BatteryRotation,
                    setRotation: (v) => _m5BatteryRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Bateria M5',
                    getRotation: () => _m5BatteryRotation,
                    setRotation: (v) => _m5BatteryRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(80, 80),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.battery,
                      isActive: true,
                      isDarkMode: false,
                      value: 4.5,
                    ),
                  ),
                ),
              ),

              // Socket Push-Button
              Positioned(
                left: pushButtonPos.dx - 47.5,
                top: pushButtonPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'push_button',
                  isFilled: _m5PushButtonInserted,
                  showLabel: false,
                  rotation: _m5PushButtonRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Botão M5',
                    getInserted: () => _m5PushButtonInserted,
                    setInserted: (v) => _m5PushButtonInserted = v,
                    getRotation: () => _m5PushButtonRotation,
                    setRotation: (v) => _m5PushButtonRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Botão M5',
                    getRotation: () => _m5PushButtonRotation,
                    setRotation: (v) => _m5PushButtonRotation = v,
                  ),
                  onTap: () {
                    if (_m5PushButtonInserted) {
                      final prev = _m5PushButtonPressed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Pressionar Botão M5',
                        onApply: () => setState(() { _m5PushButtonPressed = !prev; _m5TestedHoldAndRelease = true; }),
                        onUndo: () => setState(() { _m5PushButtonPressed = prev; }),
                      ));
                    }
                  },
                  symbolWidget: PushButtonVectorWidget(
                    size: 65,
                    isPressed: _m5PushButtonPressed,
                  ),
                ),
              ),

              // Socket Lâmpada
              Positioned(
                left: lampPos.dx - 47.5,
                top: lampPos.dy - 47.5,
                child: PhysicalBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _m5LampInserted,
                  showLabel: false,
                  rotation: _m5LampRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Lâmpada M5',
                    getInserted: () => _m5LampInserted,
                    setInserted: (v) => _m5LampInserted = v,
                    getRotation: () => _m5LampRotation,
                    setRotation: (v) => _m5LampRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Lâmpada M5',
                    getRotation: () => _m5LampRotation,
                    setRotation: (v) => _m5LampRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(80, 80),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.bulb,
                      isActive: isLit,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchematicCanvasM1() {
    final bool isBulbLit = _m1BatteryInserted && _m1SwitchInserted && _m1SwitchClosed && _m1BulbInserted;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 210.0;
        final double batteryX = width * 0.18;
        final double lampX = width * 0.82;
        final double switchCenterX = width * 0.50;
        final double centerY = height * 0.50;

        return Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              // 1. Fios de Trançado Esquemático com Elétrons Animados (Conexão Perfeita)
              CustomPaint(
                size: Size(width, height),
                painter: SchematicCircuitWirePainter(
                  isClosed: isBulbLit,
                  animationValue: _currentFlowController.value,
                  switchInserted: _m1SwitchInserted,
                  wireColor: const Color(0xFF1E293B),
                ),
              ),

              // 2. Socket da Bateria (Esquerda)
              Positioned(
                left: batteryX - 47.5,
                top: centerY - 47.5,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _m1BatteryInserted,
                  showLabel: false,
                  rotation: _m1BatteryRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Bateria M1',
                    getInserted: () => _m1BatteryInserted,
                    setInserted: (v) => _m1BatteryInserted = v,
                    getRotation: () => _m1BatteryRotation,
                    setRotation: (v) => _m1BatteryRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Bateria M1',
                    getRotation: () => _m1BatteryRotation,
                    setRotation: (v) => _m1BatteryRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.battery,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(48, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.battery,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),

              // 3. Socket da Lâmpada (Direita)
              Positioned(
                left: lampX - 47.5,
                top: centerY - 47.5,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _m1BulbInserted,
                  showLabel: false,
                  rotation: _m1BulbRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Lâmpada M1',
                    getInserted: () => _m1BulbInserted,
                    setInserted: (v) => _m1BulbInserted = v,
                    getRotation: () => _m1BulbRotation,
                    setRotation: (v) => _m1BulbRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Lâmpada M1',
                    getRotation: () => _m1BulbRotation,
                    setRotation: (v) => _m1BulbRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: isBulbLit,
                      color: const Color(0xFF0F172A),
                      activeColor: const Color(0xFFD97706),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(48, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.bulb,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),

              // 4. Socket do Interruptor (Centralizado)
              Positioned(
                left: switchCenterX - 47.5,
                top: centerY - 47.5,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _m1SwitchInserted,
                  showLabel: false,
                  rotation: _m1SwitchRotation,
                  onAccept: (_) => _insertComponent(
                    name: 'Interruptor M1',
                    getInserted: () => _m1SwitchInserted,
                    setInserted: (v) => _m1SwitchInserted = v,
                    getRotation: () => _m1SwitchRotation,
                    setRotation: (v) => _m1SwitchRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Interruptor M1',
                    getRotation: () => _m1SwitchRotation,
                    setRotation: (v) => _m1SwitchRotation = v,
                  ),
                  onTap: () {
                    if (_m1SwitchInserted) {
                      final prev = _m1SwitchClosed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Interruptor M1',
                        onApply: () => setState(() => _m1SwitchClosed = !prev),
                        onUndo: () => setState(() => _m1SwitchClosed = prev),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m1SwitchClosed,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(48, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.switchComponent,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchematicCanvasM2() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 145.0;

        final posABat = Offset(width * 0.12, 45.0);
        final posASw = Offset(width * 0.27, 45.0);
        final posABulb = Offset(width * 0.42, 45.0);

        final posBBat = Offset(width * 0.58, 45.0);
        final posBSw = Offset(width * 0.73, 45.0);
        final posBBulb = Offset(width * 0.88, 45.0);

        final wires = <WirePath>[];

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posABat, rotation: 0, type: ComponentType.battery),
          terminalIndexA: 1,
          compB: ComponentPlacement(position: posASw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: _m2SwitchAClosed,
          thickness: 3.5,
        ).toWirePath());

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posASw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexA: 1,
          compB: ComponentPlacement(position: posABulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: _m2SwitchAClosed,
          thickness: 3.5,
        ).toWirePath());

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posABulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexA: 1,
          compB: ComponentPlacement(position: posABat, rotation: 0, type: ComponentType.battery),
          terminalIndexB: 0,
          color: const Color(0xFF0284C7),
          isActive: _m2SwitchAClosed,
          thickness: 3.5,
        ).toWirePath(intermediatePoints: [Offset(width * 0.27, 100.0)]));

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posBBat, rotation: 0, type: ComponentType.battery),
          terminalIndexA: 1,
          compB: ComponentPlacement(position: posBSw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexB: 0,
          color: const Color(0xFF10B981),
          isActive: _m2SwitchBClosed,
          thickness: 3.5,
        ).toWirePath());

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posBSw, rotation: 0, type: ComponentType.switchComponent),
          terminalIndexA: 1,
          compB: ComponentPlacement(position: posBBulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexB: 0,
          color: const Color(0xFF10B981),
          isActive: _m2SwitchBClosed,
          thickness: 3.5,
        ).toWirePath());

        wires.add(DynamicWirePath.fromComponents(
          compA: ComponentPlacement(position: posBBulb, rotation: 0, type: ComponentType.bulb),
          terminalIndexA: 1,
          compB: ComponentPlacement(position: posBBat, rotation: 0, type: ComponentType.battery),
          terminalIndexB: 0,
          color: const Color(0xFF10B981),
          isActive: _m2SwitchBClosed,
          thickness: 3.5,
        ).toWirePath(intermediatePoints: [Offset(width * 0.73, 100.0)]));

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: RealisticWireWidget(
                  wires: wires,
                  animationValue: _currentFlowController.value,
                  showElectrons: _m2SwitchAClosed || _m2SwitchBClosed,
                ),
              ),

              Positioned(
                left: width * 0.05, top: 2,
                child: Text('CENÁRIO A (ABERTO)', style: GoogleFonts.rajdhani(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Positioned(
                left: width * 0.52, top: 2,
                child: Text('CENÁRIO B (FECHADO)', style: GoogleFonts.rajdhani(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
              ),

              // Socket Bat A
              Positioned(
                left: posABat.dx - 30, top: posABat.dy - 20,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'battery', isFilled: true, width: 60, height: 40, showLabel: false, label: '', placeholderWidget: const SizedBox(),
                  onAccept: (_) {}, onRotate: () {}, onTap: () {},
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: CircuitSymbolPainter(type: ComponentType.battery, color: const Color(0xFF0284C7), strokeWidth: 2.0)),
                ),
              ),
              // Socket Sw A
              Positioned(
                left: posASw.dx - 30, top: posASw.dy - 20,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch', isFilled: true, width: 60, height: 40, showLabel: false, label: '', placeholderWidget: const SizedBox(),
                  onAccept: (_) {}, onRotate: () {},
                  onTap: () => setState(() => _m2SwitchAClosed = !_m2SwitchAClosed),
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: CircuitSymbolPainter(type: ComponentType.switchComponent, isActive: _m2SwitchAClosed, color: const Color(0xFF0284C7), strokeWidth: 2.0)),
                ),
              ),
              // Socket Bulb A
              Positioned(
                left: posABulb.dx - 30, top: posABulb.dy - 20,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'bulb', isFilled: true, width: 60, height: 40, showLabel: false, label: '', placeholderWidget: const SizedBox(),
                  onAccept: (_) {}, onRotate: () {}, onTap: () {},
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: CircuitSymbolPainter(type: ComponentType.bulb, isActive: _m2SwitchAClosed, color: const Color(0xFF0284C7), strokeWidth: 2.0)),
                ),
              ),

              // Socket Bat B
              Positioned(
                left: posBBat.dx - 30, top: posBBat.dy - 20,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'battery', isFilled: true, width: 60, height: 40, showLabel: false, label: '', placeholderWidget: const SizedBox(),
                  onAccept: (_) {}, onRotate: () {}, onTap: () {},
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: CircuitSymbolPainter(type: ComponentType.battery, color: const Color(0xFF10B981), strokeWidth: 2.0)),
                ),
              ),
              // Socket Sw B
              Positioned(
                left: posBSw.dx - 30, top: posBSw.dy - 20,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch', isFilled: true, width: 60, height: 40, showLabel: false, label: '', placeholderWidget: const SizedBox(),
                  onAccept: (_) {}, onRotate: () {},
                  onTap: () => setState(() => _m2SwitchBClosed = !_m2SwitchBClosed),
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: CircuitSymbolPainter(type: ComponentType.switchComponent, isActive: _m2SwitchBClosed, color: const Color(0xFF10B981), strokeWidth: 2.0)),
                ),
              ),
              // Socket Bulb B
              Positioned(
                left: posBBulb.dx - 30, top: posBBulb.dy - 20,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'bulb', isFilled: true, width: 60, height: 40, showLabel: false, label: '', placeholderWidget: const SizedBox(),
                  onAccept: (_) {}, onRotate: () {}, onTap: () {},
                  symbolWidget: CustomPaint(size: const Size(50, 35), painter: CircuitSymbolPainter(type: ComponentType.bulb, isActive: _m2SwitchBClosed, color: const Color(0xFF10B981), strokeWidth: 2.0)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchematicCanvasM3() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 180.0;
        final double batteryX = width * 0.18;
        final double lampX = width * 0.82;
        final double switchCenterX = width * 0.50;
        final double centerY = 90.0;

        return Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: SchematicCircuitWirePainterM3(
                  branch1Closed: _m3Switch1Closed,
                  branch2Closed: _m3Switch2Closed,
                  animationValue: _currentFlowController.value,
                ),
              ),

              // Socket da Bateria (Centro Esquerda)
              Positioned(
                left: batteryX - 47.5,
                top: centerY - 40.0,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _m3BatteryInserted,
                  showLabel: false,
                  rotation: _m3BatteryRotation,
                  width: 95,
                  height: 80,
                  onAccept: (_) => _insertComponent(
                    name: 'Bateria M3',
                    getInserted: () => _m3BatteryInserted,
                    setInserted: (v) => _m3BatteryInserted = v,
                    getRotation: () => _m3BatteryRotation,
                    setRotation: (v) => _m3BatteryRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Bateria M3',
                    getRotation: () => _m3BatteryRotation,
                    setRotation: (v) => _m3BatteryRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.battery,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(48, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.battery,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),

              // Socket Chave 1 (Ramo 1 - Topo)
              Positioned(
                left: switchCenterX - 40.0,
                top: 40.0 - 25.0,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch1',
                  isFilled: _m3Switch1Inserted,
                  showLabel: false,
                  rotation: _m3Switch1Rotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) => _insertComponent(
                    name: 'Chave 1 M3',
                    getInserted: () => _m3Switch1Inserted,
                    setInserted: (v) => _m3Switch1Inserted = v,
                    getRotation: () => _m3Switch1Rotation,
                    setRotation: (v) => _m3Switch1Rotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Chave 1 M3',
                    getRotation: () => _m3Switch1Rotation,
                    setRotation: (v) => _m3Switch1Rotation = v,
                  ),
                  onTap: () {
                    if (_m3Switch1Inserted) {
                      final prev = _m3Switch1Closed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Chave 1 M3',
                        onApply: () => setState(() { _m3Switch1Closed = !prev; _m3TestedSwitch1 = true; }),
                        onUndo: () => setState(() { _m3Switch1Closed = prev; _m3TestedSwitch1 = false; }),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m3Switch1Closed,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(48, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.switchComponent,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),

              // Socket Chave 2 (Ramo 2 - Baixo)
              Positioned(
                left: switchCenterX - 40.0,
                top: 140.0 - 25.0,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch2',
                  isFilled: _m3Switch2Inserted,
                  showLabel: false,
                  rotation: _m3Switch2Rotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) => _insertComponent(
                    name: 'Chave 2 M3',
                    getInserted: () => _m3Switch2Inserted,
                    setInserted: (v) => _m3Switch2Inserted = v,
                    getRotation: () => _m3Switch2Rotation,
                    setRotation: (v) => _m3Switch2Rotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Chave 2 M3',
                    getRotation: () => _m3Switch2Rotation,
                    setRotation: (v) => _m3Switch2Rotation = v,
                  ),
                  onTap: () {
                    if (_m3Switch2Inserted) {
                      final prev = _m3Switch2Closed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Chave 2 M3',
                        onApply: () => setState(() { _m3Switch2Closed = !prev; _m3TestedSwitch2 = true; }),
                        onUndo: () => setState(() { _m3Switch2Closed = prev; _m3TestedSwitch2 = false; }),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m3Switch2Closed,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(48, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.switchComponent,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),

              // Socket Lâmpada A (Ramo 1 - Topo)
              Positioned(
                left: lampX - 40.0,
                top: 40.0 - 25.0,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _m3LampAInserted,
                  showLabel: false,
                  rotation: _m3LampARotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) => _insertComponent(
                    name: 'Lâmpada A M3',
                    getInserted: () => _m3LampAInserted,
                    setInserted: (v) => _m3LampAInserted = v,
                    getRotation: () => _m3LampARotation,
                    setRotation: (v) => _m3LampARotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Lâmpada A M3',
                    getRotation: () => _m3LampARotation,
                    setRotation: (v) => _m3LampARotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: _m3Switch1Closed,
                      color: const Color(0xFF0F172A),
                      activeColor: const Color(0xFFD97706),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(48, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.bulb,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),

              // Socket Lâmpada B (Ramo 2 - Baixo)
              Positioned(
                left: lampX - 40.0,
                top: 140.0 - 25.0,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _m3LampBInserted,
                  showLabel: false,
                  rotation: _m3LampBRotation,
                  width: 80,
                  height: 50,
                  onAccept: (_) => _insertComponent(
                    name: 'Lâmpada B M3',
                    getInserted: () => _m3LampBInserted,
                    setInserted: (v) => _m3LampBInserted = v,
                    getRotation: () => _m3LampBRotation,
                    setRotation: (v) => _m3LampBRotation = v,
                  ),
                  onRotate: () => _rotateComponent(
                    name: 'Lâmpada B M3',
                    getRotation: () => _m3LampBRotation,
                    setRotation: (v) => _m3LampBRotation = v,
                  ),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: _m3Switch2Closed,
                      color: const Color(0xFF0F172A),
                      activeColor: const Color(0xFFD97706),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(48, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.bulb,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchematicCanvasM5() {
    final isLit = _m5PushButtonInserted && _m5PushButtonPressed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 270.0;
        final double batteryX = width * 0.18;
        final double lampX = width * 0.82;
        final double switchCenterX = width * 0.50;
        final double centerY = height * 0.50;

        return Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: SchematicCircuitWirePainter(
                  isClosed: isLit,
                  animationValue: _currentFlowController.value,
                  switchInserted: _m5PushButtonInserted,
                  wireColor: const Color(0xFF1E293B),
                ),
              ),

              // Bateria em Card (Esquerda)
              Positioned(
                left: batteryX - 47.5,
                top: centerY - 47.5,
                child: SchematicComponentCard(
                  label: '',
                  showLabel: false,
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.battery,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
              ),

              // Lâmpada em Card (Direita)
              Positioned(
                left: lampX - 47.5,
                top: centerY - 47.5,
                child: SchematicComponentCard(
                  label: '',
                  showLabel: false,
                  isActive: isLit,
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: isLit,
                      color: const Color(0xFF0F172A),
                      activeColor: const Color(0xFFD97706),
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
              ),

              // Soquete do Push-Button (Centro) - Sem icone fantasma ao estar vazio
              Positioned(
                left: switchCenterX - 47.5,
                top: centerY - 47.5,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'push_button',
                  isFilled: _m5PushButtonInserted,
                  showLabel: false,
                  onAccept: (_) => _insertComponent(
                    name: 'Botão M5',
                    getInserted: () => _m5PushButtonInserted,
                    setInserted: (v) => _m5PushButtonInserted = v,
                    getRotation: () => _m5PushButtonRotation,
                    setRotation: (v) => _m5PushButtonRotation = v,
                  ),
                  onTap: () {
                    if (_m5PushButtonInserted) {
                      final prev = _m5PushButtonPressed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Pressionar Botão M5',
                        onApply: () => setState(() { _m5PushButtonPressed = !prev; _m5TestedHoldAndRelease = true; }),
                        onUndo: () => setState(() { _m5PushButtonPressed = prev; }),
                      ));
                    }
                  },
                  symbolWidget: SchematicSwitchWidget(
                    size: 50,
                    isPushButton: true,
                    isClosed: _m5PushButtonPressed,
                    color: const Color(0xFF0F172A),
                  ),
                  placeholderWidget: const Opacity(
                    opacity: 0.4,
                    child: SchematicSwitchWidget(
                      size: 45,
                      isPushButton: true,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  label: '',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchematicCanvasM4() {
    final bool isLampLit = _m4SwitchInMainBranch ? _m4SwitchClosed : true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 270.0;
        final double batteryX = width * 0.18;
        final double lampX = width * 0.82;
        final double switchCenterX = width * 0.50;
        final double centerY = height * 0.50;

        return Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: SchematicCircuitWirePainterM4(
                  isClosed: isLampLit,
                  switchInMainBranch: _m4SwitchInMainBranch,
                  animationValue: _currentFlowController.value,
                ),
              ),

              // Bateria Card (Esquerda - Posição Centralizada)
              Positioned(
                left: batteryX - 47.5,
                top: centerY - 47.5,
                child: SchematicComponentCard(
                  label: '',
                  showLabel: false,
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.battery,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
              ),

              // Lâmpada Card (Direita - Posição Centralizada)
              Positioned(
                left: lampX - 47.5,
                top: centerY - 47.5,
                child: SchematicComponentCard(
                  label: '',
                  showLabel: false,
                  isActive: isLampLit,
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.bulb,
                      isActive: isLampLit,
                      color: const Color(0xFF0F172A),
                      activeColor: const Color(0xFFD97706),
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
              ),

              // Posicionamento A: Ramo Inútil (Topo)
              Positioned(
                left: switchCenterX - 47.5,
                top: (centerY - 55.0) - 47.5,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: !_m4SwitchInMainBranch,
                  showLabel: false,
                  accentColor: !_m4SwitchInMainBranch
                      ? const Color(0xFFD97706)
                      : const Color(0xFF94A3B8),
                  onAccept: (_) {
                    final prevInMain = _m4SwitchInMainBranch;
                    final prevClosed = _m4SwitchClosed;
                    _undoRedoController.execute(CompoundAction(
                      description: 'Inserir no Ramo Inútil M4',
                      actions: [
                        ToggleBoolAction(
                          description: 'Mover para Ramo Inútil',
                          onApply: () => setState(() => _m4SwitchInMainBranch = false),
                          onUndo: () => setState(() => _m4SwitchInMainBranch = prevInMain),
                        ),
                        ToggleBoolAction(
                          description: 'Fechar Interruptor',
                          onApply: () => setState(() => _m4SwitchClosed = true),
                          onUndo: () => setState(() => _m4SwitchClosed = prevClosed),
                        ),
                      ],
                    ));
                  },
                  onTap: () {
                    if (!_m4SwitchInMainBranch) {
                      final prev = _m4SwitchClosed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Interruptor M4',
                        onApply: () => setState(() => _m4SwitchClosed = !prev),
                        onUndo: () => setState(() => _m4SwitchClosed = prev),
                      ));
                    } else {
                      final prevInMain = _m4SwitchInMainBranch;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Mover para Ramo Inútil M4',
                        onApply: () => setState(() => _m4SwitchInMainBranch = false),
                        onUndo: () => setState(() => _m4SwitchInMainBranch = prevInMain),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m4SwitchClosed,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(48, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.switchComponent,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),

              // Posicionamento B: Ramo Principal em Série (Centro)
              Positioned(
                left: switchCenterX - 47.5,
                top: centerY - 47.5,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _m4SwitchInMainBranch,
                  showLabel: false,
                  accentColor: _m4SwitchInMainBranch
                      ? const Color(0xFF059669)
                      : const Color(0xFF94A3B8),
                  onAccept: (_) {
                    final prevInMain = _m4SwitchInMainBranch;
                    final prevClosed = _m4SwitchClosed;
                    _undoRedoController.execute(CompoundAction(
                      description: 'Inserir no Ramo Principal M4',
                      actions: [
                        ToggleBoolAction(
                          description: 'Mover para Ramo Principal',
                          onApply: () => setState(() => _m4SwitchInMainBranch = true),
                          onUndo: () => setState(() => _m4SwitchInMainBranch = prevInMain),
                        ),
                        ToggleBoolAction(
                          description: 'Fechar Interruptor',
                          onApply: () => setState(() => _m4SwitchClosed = true),
                          onUndo: () => setState(() => _m4SwitchClosed = prevClosed),
                        ),
                      ],
                    ));
                  },
                  onTap: () {
                    if (_m4SwitchInMainBranch) {
                      final prev = _m4SwitchClosed;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Toggle Interruptor M4',
                        onApply: () => setState(() => _m4SwitchClosed = !prev),
                        onUndo: () => setState(() => _m4SwitchClosed = prev),
                      ));
                    } else {
                      final prevInMain = _m4SwitchInMainBranch;
                      _undoRedoController.execute(ToggleBoolAction(
                        description: 'Mover para Ramo Principal M4',
                        onApply: () => setState(() => _m4SwitchInMainBranch = true),
                        onUndo: () => setState(() => _m4SwitchInMainBranch = prevInMain),
                      ));
                    }
                  },
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m4SwitchClosed,
                      color: const Color(0xFF0F172A),
                      strokeWidth: 2.2,
                    ),
                  ),
                  placeholderWidget: Opacity(
                    opacity: 0.4,
                    child: CustomPaint(
                      size: const Size(48, 34),
                      painter: CircuitSymbolPainter(
                        type: ComponentType.switchComponent,
                        color: const Color(0xFF94A3B8),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  label: '',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom Painter com Tracados Neon e Fluxo de Elétrons Animados
class CircuitWirePainter extends CustomPainter {
  final bool isClosed;
  final double animationValue;
  final bool switchInserted;

  CircuitWirePainter({
    required this.isClosed,
    required this.animationValue,
    required this.switchInserted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final neonColor = isClosed
        ? const Color(0xFF10B981)
        : const Color(0xFF475569);

    final wirePaint = Paint()
      ..color = neonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = neonColor.withValues(alpha: isClosed ? 0.5 : 0.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    path.moveTo(75, 115);
    path.lineTo(75, 45);
    path.lineTo(340, 45);
    path.lineTo(340, 115);
    path.lineTo(260, 115);

    path.moveTo(75, 115);
    path.lineTo(75, 195);
    path.lineTo(340, 195);
    path.lineTo(340, 115);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, wirePaint);

    // Desenha os nós de conexão (glowing pins)
    final pinPaint = Paint()
      ..color = isClosed ? const Color(0xFF34D399) : Colors.grey;
    canvas.drawCircle(const Offset(75, 115), 5, pinPaint);
    canvas.drawCircle(const Offset(340, 115), 5, pinPaint);

    // Se o circuito estiver fechado, desenha elétrons animados fluindo pelos fios
    if (isClosed) {
      final electronPaint = Paint()
        ..color = const Color(0xFF00F0FF)
        ..style = PaintingStyle.fill;

      const totalDots = 10;
      final metrics = path.computeMetrics();
      for (final metric in metrics) {
        final length = metric.length;
        for (int i = 0; i < totalDots; i++) {
          final distance = ((animationValue + (i / totalDots)) % 1.0) * length;
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 3.5, electronPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
