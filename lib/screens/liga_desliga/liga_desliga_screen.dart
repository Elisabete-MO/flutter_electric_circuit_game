import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes.dart';
import '../../models/first_step_component.dart';
import '../../models/stand_mission.dart';
import '../../state/progress_controller.dart';
import '../../widgets/circuit_symbol_painter.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/component_vector_painters.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/prof_volts_full_body.dart';
import '../../widgets/realistic_wire_painter.dart';
import '../../widgets/schematic_blueprint_socket.dart';
import '../../widgets/schematic_symbol_painters.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/workbench_components.dart';

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

  // --- Modo de Visualizacao Visual: Esquemático (Blueprint) vs Físico 3D ---
  bool _usePhysicalStyle = true;

  // --- Estado Missão 1: Interruptor da Luminária ---
  bool _m1SwitchInserted = false;
  bool _m1SwitchClosed = false;
  bool _m1BatteryInserted = false;
  bool _m1BulbInserted = false;
  double _m1BatteryRotation = 0.0;
  double _m1SwitchRotation = 0.0;
  double _m1BulbRotation = 0.0;

  // --- Estado Missão 2: Aberto ou Fechado? ---
  String? _m2AnswerStateA; // 'aberto' / 'fechado'
  String? _m2AnswerStateB; // 'aberto' / 'fechado'

  // --- Estado Missão 3: Dois Controles ---
  bool _m3Switch1Closed = false;
  bool _m3Switch2Closed = false;
  bool _m3TestedSwitch1 = false;
  bool _m3TestedSwitch2 = false;
  bool _m3BatteryInserted = false;
  bool _m3LampAInserted = false;
  bool _m3LampBInserted = false;
  bool _m3Switch1Inserted = false;
  bool _m3Switch2Inserted = false;
  double _m3BatteryRotation = 0.0;
  double _m3LampARotation = 0.0;
  double _m3LampBRotation = 0.0;
  double _m3Switch1Rotation = 0.0;
  double _m3Switch2Rotation = 0.0;
  String? _m3MapSwitch1; // 'lampA' / 'lampB'
  String? _m3MapSwitch2; // 'lampA' / 'lampB'

  // --- Estado Missão 4: Conferência ---
  bool _m4SwitchInMainBranch = false;
  bool _m4SwitchClosed = true;

  // --- Estado Missão 5: Controle por Push-Button ---
  bool _m5PushButtonInserted = false;
  bool _m5PushButtonPressed = false;
  bool _m5TestedHoldAndRelease = false;

  // Animação de Fluxo de Corrente e Pulsos Neon
  late AnimationController _currentFlowController;

  @override
  void initState() {
    super.initState();
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
                      const SizedBox(height: 8),
                      // Seletor de Estilo Visual (Esquemático vs Físico 3D)
                      _buildVisualModeSelector(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildCurrentMissionUI(),
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

  Widget _buildVisualModeSelector() {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opção 1: Esquemático (Blueprint)
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
          // Opção 2: Físico Realista
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

  Widget _buildTelemetryBar({
    required bool isClosed,
    required double voltage,
    required double currentMa,
  }) {
    final statusColor = isClosed
        ? const Color(0xFF10B981)
        : const Color(0xFF64748B);
    final statusText = isClosed
        ? 'CIRCUITO FECHADO (ON)'
        : 'CIRCUITO ABERTO (OFF)';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (isClosed)
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: GoogleFonts.rajdhani(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'TENSÃO: ',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                '${voltage.toStringAsFixed(1)}V  |  ',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                'CORRENTE: ',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                '${currentMa.toStringAsFixed(1)} mA',
                style: GoogleFonts.outfit(
                  color: isClosed
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideToolboxDrawer() {
    return Wrap(
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
                    color: const Color(0xFFD97706),
                    strokeWidth: 2.0,
                  ),
                ),
          color: const Color(0xFFD97706),
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
          label: 'Push-Button',
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
    );
  }

  // ==========================================
  // MISSÃO 1: Interruptor da Luminária
  // ==========================================
  Widget _buildMission1UI(StandMission mission) {
    final bool isBulbLit = _m1SwitchInserted && _m1SwitchClosed;
    return Column(
      children: [
        _buildTelemetryBar(
          isClosed: isBulbLit,
          voltage: 4.5,
          currentMa: isBulbLit ? 90.0 : 0.0,
        ),
        Expanded(
          child: _usePhysicalStyle
              ? _buildPhysicalCanvasM1()
              : _buildSchematicCanvasM1(),
        ),
      ],
    );
  }

  // ==========================================
  // MISSÃO 2: Aberto ou Fechado?
  // ==========================================
  Widget _buildMission2UI(StandMission mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Examine a posição da chave nos dois cenários e preveja se haverá passagem de corrente:',
          style: GoogleFonts.outfit(
            color: const Color(0xFF334155),
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Questão 1: Estado A (Chave Aberta)
        _buildPredictionCard(
          title: 'Cenário A: Interruptor no estado ABERTO (OFF)',
          subtitle:
              'Existe um espaço vazio entre os contatos elétricos da chave.',
          currentValue: _m2AnswerStateA,
          onSelect: (val) => setState(() => _m2AnswerStateA = val),
        ),

        const SizedBox(height: 12),

        // Questão 2: Estado B (Chave Fechada)
        _buildPredictionCard(
          title: 'Cenário B: Interruptor no estado FECHADO (ON)',
          subtitle: 'Os contatos condutores da chave estão encostados.',
          currentValue: _m2AnswerStateB,
          onSelect: (val) => setState(() => _m2AnswerStateB = val),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              color: const Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'LÂMPADA ACESA (Circuito Fechado)',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'LÂMPADA APAGADA (Circuito Aberto)',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
        Text(
          'Teste acionar um interruptor por vez para descobrir qual luz responde a cada controle:',
          style: GoogleFonts.outfit(
            color: const Color(0xFF334155),
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Bancada da Missão 3 (Clean Blueprint ou Físico 3D)
        _usePhysicalStyle
            ? _buildPhysicalCanvasM3()
            : _buildSchematicCanvasM3(),

        const SizedBox(height: 16),

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
            const SizedBox(width: 12),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: currentSelection,
            dropdownColor: Colors.white,
            style: GoogleFonts.outfit(
              color: const Color(0xFF0F172A),
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                          : 'SEGURE O PUSH-BUTTON PARA ACENDER',
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
    final bool isClosed = _m1SwitchInserted && _m1SwitchClosed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight > 0
            ? constraints.maxHeight
            : 270.0;

        final batteryPos = Offset(75, height / 2);
        final switchPos = Offset(width / 2, 60);
        final lampPos = Offset(width - 75, height / 2);

        final wires = [
          // VCC (Vermelho): Pino (+) da Bateria Snap -> Terminal Esquerdo da Chave
          WirePath(
            points: [
              Offset(batteryPos.dx + 14, batteryPos.dy - 40),
              Offset(switchPos.dx - 35, switchPos.dy),
            ],
            color: const Color(0xFFEF4444),
            isActive: isClosed,
            thickness: 4.5,
          ),
          // Saída (Laranja): Terminal Direito da Chave -> Pino Esquerdo da Lâmpada
          WirePath(
            points: [
              Offset(switchPos.dx + 35, switchPos.dy),
              Offset(lampPos.dx - 7, lampPos.dy + 24),
            ],
            color: const Color(0xFFF97316),
            isActive: isClosed,
            thickness: 4.5,
          ),
          // GND (Preto): Pino Direito da Lâmpada -> Retorno para Pino (-) da Bateria Snap
          WirePath(
            points: [
              Offset(lampPos.dx + 7, lampPos.dy + 24),
              Offset(width / 2, height - 20),
              Offset(batteryPos.dx - 14, batteryPos.dy - 40),
            ],
            color: const Color(0xFF1E293B),
            isActive: isClosed,
            thickness: 4.5,
          ),
        ];

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
              ),
            ],
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

              // Bateria 4.5V / 9V 3D Físico
              Positioned(
                left: batteryPos.dx - 40,
                top: batteryPos.dy - 40,
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.battery,
                    isActive: true,
                    isDarkMode: false,
                    value: 4.5,
                  ),
                ),
              ),

              // Soquete / Interruptor Físico
              Positioned(
                left: switchPos.dx - 45,
                top: switchPos.dy - 40,
                child: _m1SwitchInserted
                    ? GestureDetector(
                        onTap: () =>
                            setState(() => _m1SwitchClosed = !_m1SwitchClosed),
                        child: CustomPaint(
                          size: const Size(90, 80),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.switchComponent,
                            isActive: _m1SwitchClosed,
                            isDarkMode: false,
                          ),
                        ),
                      )
                    : DragTarget<String>(
                        onWillAcceptWithDetails: (details) =>
                            details.data == 'switch',
                        onAcceptWithDetails: (details) {
                          setState(() {
                            _m1SwitchInserted = true;
                            _m1SwitchClosed = true;
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            width: 90,
                            height: 75,
                            decoration: BoxDecoration(
                              color: candidateData.isNotEmpty
                                  ? const Color(
                                      0xFF38BDF8,
                                    ).withValues(alpha: 0.2)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: candidateData.isNotEmpty
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFF94A3B8),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_rounded,
                                color: Color(0xFF64748B),
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Lâmpada 3D Físico
              Positioned(
                left: lampPos.dx - 40,
                top: lampPos.dy - 40,
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.bulb,
                    isActive: isClosed,
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

  Widget _buildPhysicalCanvasM3() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 270.0;

        final batteryPos = Offset(65, height / 2);
        final switch1Pos = Offset(width * 0.42, 50);
        final switch2Pos = Offset(width * 0.42, 180);
        final lamp1Pos = Offset(width - 65, 50);
        final lamp2Pos = Offset(width - 65, 180);

        final wires = [
          // VCC 1 (Vermelho): Pino (+) da Bateria Snap -> Chave 1
          WirePath(
            points: [
              Offset(batteryPos.dx + 14, batteryPos.dy - 40),
              Offset(switch1Pos.dx - 35, switch1Pos.dy),
            ],
            color: const Color(0xFFEF4444),
            isActive: _m3Switch1Closed,
            thickness: 4.0,
          ),
          // VCC 2 (Amarelo): Pino (+) da Bateria Snap -> Chave 2
          WirePath(
            points: [
              Offset(batteryPos.dx + 14, batteryPos.dy - 40),
              Offset(switch2Pos.dx - 35, switch2Pos.dy),
            ],
            color: const Color(0xFFEAB308),
            isActive: _m3Switch2Closed,
            thickness: 4.0,
          ),
          // Chave 1 -> Pino Esquerdo da Lâmpada A (Laranja)
          WirePath(
            points: [
              Offset(switch1Pos.dx + 35, switch1Pos.dy),
              Offset(lamp1Pos.dx - 7, lamp1Pos.dy + 24),
            ],
            color: const Color(0xFFF97316),
            isActive: _m3Switch1Closed,
            thickness: 4.0,
          ),
          // Chave 2 -> Pino Esquerdo da Lâmpada B (Verde)
          WirePath(
            points: [
              Offset(switch2Pos.dx + 35, switch2Pos.dy),
              Offset(lamp2Pos.dx - 7, lamp2Pos.dy + 24),
            ],
            color: const Color(0xFF10B981),
            isActive: _m3Switch2Closed,
            thickness: 4.0,
          ),
          // Retorno GND (Preto): Pinos Direitos das Lâmpadas -> Retorno para Pino (-) da Bateria Snap
          WirePath(
            points: [
              Offset(lamp1Pos.dx + 7, lamp1Pos.dy + 24),
              Offset(lamp2Pos.dx + 7, lamp2Pos.dy + 24),
              Offset(batteryPos.dx - 14, batteryPos.dy - 40),
            ],
            color: const Color(0xFF1E293B),
            isActive: _m3Switch1Closed || _m3Switch2Closed,
            thickness: 4.0,
          ),
        ];

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
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

              // Bateria
              Positioned(
                left: batteryPos.dx - 40,
                top: batteryPos.dy - 40,
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.battery,
                    isActive: true,
                    isDarkMode: false,
                    value: 4.5,
                  ),
                ),
              ),

              // Chave 1
              Positioned(
                left: switch1Pos.dx - 40,
                top: switch1Pos.dy - 35,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _m3Switch1Closed = !_m3Switch1Closed;
                      _m3TestedSwitch1 = true;
                    });
                  },
                  child: CustomPaint(
                    size: const Size(80, 70),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m3Switch1Closed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Chave 2
              Positioned(
                left: switch2Pos.dx - 40,
                top: switch2Pos.dy - 35,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _m3Switch2Closed = !_m3Switch2Closed;
                      _m3TestedSwitch2 = true;
                    });
                  },
                  child: CustomPaint(
                    size: const Size(80, 70),
                    painter: ComponentPhysicalPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m3Switch2Closed,
                      isDarkMode: false,
                    ),
                  ),
                ),
              ),

              // Lâmpada A
              Positioned(
                left: lamp1Pos.dx - 40,
                top: lamp1Pos.dy - 35,
                child: CustomPaint(
                  size: const Size(80, 70),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.bulb,
                    isActive: _m3Switch1Closed,
                    isDarkMode: false,
                  ),
                ),
              ),

              // Lâmpada B
              Positioned(
                left: lamp2Pos.dx - 40,
                top: lamp2Pos.dy - 35,
                child: CustomPaint(
                  size: const Size(80, 70),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.bulb,
                    isActive: _m3Switch2Closed,
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

  Widget _buildPhysicalCanvasM4() {
    final bool isLampLit = _m4SwitchInMainBranch ? _m4SwitchClosed : true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 270.0;

        final batteryPos = Offset(65, height / 2);
        final switchUpperPos = Offset(width * 0.5, 40);
        final switchSeriesPos = Offset(width * 0.5, height / 2);
        final lampPos = Offset(width - 65, height / 2);

        final wires = [
          // VCC Principal (Vermelho): Pino (+) da Bateria Snap -> Chave Série Principal
          WirePath(
            points: [
              Offset(batteryPos.dx + 14, batteryPos.dy - 40),
              Offset(switchSeriesPos.dx - 35, switchSeriesPos.dy),
            ],
            color: const Color(0xFFEF4444),
            isActive: isLampLit,
            thickness: 4.0,
          ),
          // Ramo Inútil (Laranja): Pino (+) Bateria Snap -> Chave Topo -> Pino Esquerdo Lâmpada
          WirePath(
            points: [
              Offset(batteryPos.dx + 14, batteryPos.dy - 40),
              Offset(switchUpperPos.dx - 35, switchUpperPos.dy),
              Offset(switchUpperPos.dx + 35, switchUpperPos.dy),
              Offset(lampPos.dx - 7, lampPos.dy + 24),
            ],
            color: const Color(0xFFF97316),
            isActive: !_m4SwitchInMainBranch,
            thickness: 3.5,
          ),
          // Série Principal -> Pino Esquerdo da Lâmpada
          WirePath(
            points: [
              Offset(switchSeriesPos.dx + 35, switchSeriesPos.dy),
              Offset(lampPos.dx - 7, lampPos.dy + 24),
            ],
            color: const Color(0xFF10B981),
            isActive: isLampLit,
            thickness: 4.0,
          ),
          // GND Retorno (Preto): Pino Direito da Lâmpada -> Retorno para Pino (-) da Bateria Snap
          WirePath(
            points: [
              Offset(lampPos.dx + 7, lampPos.dy + 24),
              Offset(width / 2, height - 20),
              Offset(batteryPos.dx - 14, batteryPos.dy - 40),
            ],
            color: const Color(0xFF1E293B),
            isActive: isLampLit,
            thickness: 4.0,
          ),
        ];

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
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

              // Bateria
              Positioned(
                left: batteryPos.dx - 40,
                top: batteryPos.dy - 40,
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.battery,
                    isActive: true,
                    isDarkMode: false,
                    value: 4.5,
                  ),
                ),
              ),

              // Posicionamento A: Ramo Inútil (Topo)
              Positioned(
                left: switchUpperPos.dx - 40,
                top: switchUpperPos.dy - 35,
                child: !_m4SwitchInMainBranch
                    ? GestureDetector(
                        onTap: () =>
                            setState(() => _m4SwitchClosed = !_m4SwitchClosed),
                        child: CustomPaint(
                          size: const Size(80, 70),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.switchComponent,
                            isActive: _m4SwitchClosed,
                            isDarkMode: false,
                          ),
                        ),
                      )
                    : DragTarget<String>(
                        onAcceptWithDetails: (_) =>
                            setState(() => _m4SwitchInMainBranch = false),
                        builder: (context, candidateData, rejectedData) =>
                            Container(
                              width: 80,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF94A3B8),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                      ),
              ),

              // Posicionamento B: Ramo Principal em Série (Centro)
              Positioned(
                left: switchSeriesPos.dx - 40,
                top: switchSeriesPos.dy - 35,
                child: _m4SwitchInMainBranch
                    ? GestureDetector(
                        onTap: () =>
                            setState(() => _m4SwitchClosed = !_m4SwitchClosed),
                        child: CustomPaint(
                          size: const Size(80, 70),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.switchComponent,
                            isActive: _m4SwitchClosed,
                            isDarkMode: false,
                          ),
                        ),
                      )
                    : DragTarget<String>(
                        onAcceptWithDetails: (_) =>
                            setState(() => _m4SwitchInMainBranch = true),
                        builder: (context, candidateData, rejectedData) =>
                            Container(
                              width: 80,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF059669),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Color(0xFF059669),
                              ),
                            ),
                      ),
              ),

              // Lâmpada
              Positioned(
                left: lampPos.dx - 40,
                top: lampPos.dy - 40,
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.bulb,
                    isActive: isLampLit,
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

  Widget _buildPhysicalCanvasM5() {
    final bool isLit = _m5PushButtonInserted && _m5PushButtonPressed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 270.0;

        final batteryPos = Offset(65, height / 2);
        final switchPos = Offset(width / 2, height / 2);
        final lampPos = Offset(width - 65, height / 2);

        final wires = [
          WirePath(
            points: [
              Offset(batteryPos.dx + 14, batteryPos.dy - 40),
              Offset(switchPos.dx - 35, switchPos.dy),
            ],
            color: const Color(0xFFEF4444),
            isActive: isLit,
            thickness: 4.5,
          ),
          WirePath(
            points: [
              Offset(switchPos.dx + 35, switchPos.dy),
              Offset(lampPos.dx - 7, lampPos.dy + 24),
            ],
            color: const Color(0xFFF97316),
            isActive: isLit,
            thickness: 4.5,
          ),
          WirePath(
            points: [
              Offset(lampPos.dx + 7, lampPos.dy + 24),
              Offset(width / 2, height - 20),
              Offset(batteryPos.dx - 14, batteryPos.dy - 40),
            ],
            color: const Color(0xFF1E293B),
            isActive: isLit,
            thickness: 4.5,
          ),
        ];

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
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

              // Bateria
              Positioned(
                left: batteryPos.dx - 40,
                top: batteryPos.dy - 40,
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.battery,
                    isActive: true,
                    isDarkMode: false,
                    value: 4.5,
                  ),
                ),
              ),

              // Push-Button Físico Interativo (Pressione e Segure)
              Positioned(
                left: switchPos.dx - 45,
                top: switchPos.dy - 40,
                child: _m5PushButtonInserted
                    ? GestureDetector(
                        onTapDown: (_) => setState(() {
                          _m5PushButtonPressed = true;
                          _m5TestedHoldAndRelease = true;
                        }),
                        onTapUp: (_) =>
                            setState(() => _m5PushButtonPressed = false),
                        onTapCancel: () =>
                            setState(() => _m5PushButtonPressed = false),
                        child: CustomPaint(
                          size: const Size(90, 80),
                          painter: ComponentPhysicalPainter(
                            type: ComponentType.switchComponent,
                            isActive: _m5PushButtonPressed,
                            isDarkMode: false,
                          ),
                        ),
                      )
                    : DragTarget<String>(
                        onAcceptWithDetails: (_) =>
                            setState(() => _m5PushButtonInserted = true),
                        builder: (context, candidateData, rejectedData) =>
                            Container(
                              width: 90,
                              height: 80,
                              decoration: BoxDecoration(
                                color: candidateData.isNotEmpty
                                    ? const Color(
                                        0xFF38BDF8,
                                      ).withValues(alpha: 0.2)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: candidateData.isNotEmpty
                                      ? const Color(0xFF0284C7)
                                      : const Color(0xFF94A3B8),
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add_rounded,
                                  color: Color(0xFF64748B),
                                  size: 32,
                                ),
                              ),
                            ),
                      ),
              ),

              // Lâmpada
              Positioned(
                left: lampPos.dx - 40,
                top: lampPos.dy - 40,
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: ComponentPhysicalPainter(
                    type: ComponentType.bulb,
                    isActive: isLit,
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

  Widget _buildSchematicCanvasM1() {
    final bool isBulbLit = _m1BatteryInserted && _m1SwitchInserted && _m1SwitchClosed && _m1BulbInserted;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double batteryX = 60.0;
        final double lampX = width - 60.0;
        final double switchCenterX = width / 2;

        return SizedBox(
          height: 270,
          child: Stack(
            children: [
              // 1. Fios de Trançado Esquemático com Elétrons Animados (Conexão Perfeita)
              CustomPaint(
                size: Size(width, 270),
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
                top: 70,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _m1BatteryInserted,
                  showLabel: false,
                  rotation: _m1BatteryRotation,
                  onAccept: (_) => setState(() => _m1BatteryInserted = true),
                  onRotate: () => setState(() => _m1BatteryRotation = (_m1BatteryRotation + 90) % 360),
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
                top: 70,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _m1BulbInserted,
                  showLabel: false,
                  rotation: _m1BulbRotation,
                  onAccept: (_) => setState(() => _m1BulbInserted = true),
                  onRotate: () => setState(() => _m1BulbRotation = (_m1BulbRotation + 90) % 360),
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

              // 4. Socket do Interruptor (Centralizado no Topo)
              Positioned(
                left: switchCenterX - 47.5,
                top: 10,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _m1SwitchInserted,
                  showLabel: false,
                  rotation: _m1SwitchRotation,
                  onAccept: (_) => setState(() => _m1SwitchInserted = true),
                  onRotate: () => setState(() => _m1SwitchRotation = (_m1SwitchRotation + 90) % 360),
                  onTap: () => setState(() {
                    if (_m1SwitchInserted) {
                      _m1SwitchClosed = !_m1SwitchClosed;
                    }
                  }),
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

  Widget _buildSchematicCanvasM3() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double batteryX = 60.0;
        final double lampX = width - 60.0;
        final double switchCenterX = width / 2;

        return SizedBox(
          height: 270,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, 270),
                painter: SchematicCircuitWirePainterM3(
                  branch1Closed: _m3Switch1Closed,
                  branch2Closed: _m3Switch2Closed,
                  animationValue: _currentFlowController.value,
                ),
              ),

              // Socket da Bateria (Centro Esquerda)
              Positioned(
                left: batteryX - 47.5,
                top: 60,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'battery',
                  isFilled: _m3BatteryInserted,
                  showLabel: false,
                  rotation: _m3BatteryRotation,
                  onAccept: (_) => setState(() => _m3BatteryInserted = true),
                  onRotate: () => setState(() => _m3BatteryRotation = (_m3BatteryRotation + 90) % 360),
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
                left: switchCenterX - 47.5,
                top: 10,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch1',
                  isFilled: _m3Switch1Inserted,
                  showLabel: false,
                  rotation: _m3Switch1Rotation,
                  onAccept: (_) => setState(() => _m3Switch1Inserted = true),
                  onRotate: () => setState(() => _m3Switch1Rotation = (_m3Switch1Rotation + 90) % 360),
                  onTap: () => setState(() {
                    if (_m3Switch1Inserted) {
                      _m3Switch1Closed = !_m3Switch1Closed;
                      _m3TestedSwitch1 = true;
                    }
                  }),
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
                left: switchCenterX - 47.5,
                top: 128,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch2',
                  isFilled: _m3Switch2Inserted,
                  showLabel: false,
                  rotation: _m3Switch2Rotation,
                  onAccept: (_) => setState(() => _m3Switch2Inserted = true),
                  onRotate: () => setState(() => _m3Switch2Rotation = (_m3Switch2Rotation + 90) % 360),
                  onTap: () => setState(() {
                    if (_m3Switch2Inserted) {
                      _m3Switch2Closed = !_m3Switch2Closed;
                      _m3TestedSwitch2 = true;
                    }
                  }),
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
                left: lampX - 47.5,
                top: 10,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _m3LampAInserted,
                  showLabel: false,
                  rotation: _m3LampARotation,
                  onAccept: (_) => setState(() => _m3LampAInserted = true),
                  onRotate: () => setState(() => _m3LampARotation = (_m3LampARotation + 90) % 360),
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
                left: lampX - 47.5,
                top: 128,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'bulb',
                  isFilled: _m3LampBInserted,
                  showLabel: false,
                  rotation: _m3LampBRotation,
                  onAccept: (_) => setState(() => _m3LampBInserted = true),
                  onRotate: () => setState(() => _m3LampBRotation = (_m3LampBRotation + 90) % 360),
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
        final double batteryX = 60.0;
        final double lampX = width - 60.0;
        final double switchCenterX = width / 2;

        return SizedBox(
          height: 270,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, 270),
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
                top: 70,
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
                top: 70,
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

              // Soquete do Push-Button (Topo Centro) - Sem icone fantasma ao estar vazio
              Positioned(
                left: switchCenterX - 47.5,
                top: 10,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'push_button',
                  isFilled: _m5PushButtonInserted,
                  showLabel: false,
                  onAccept: (_) => setState(() => _m5PushButtonInserted = true),
                  onTap: () {},
                  symbolWidget: CustomPaint(
                    size: const Size(54, 38),
                    painter: CircuitSymbolPainter(
                      type: ComponentType.switchComponent,
                      isActive: _m5PushButtonPressed,
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

  Widget _buildSchematicCanvasM4() {
    final bool isLampLit = _m4SwitchInMainBranch ? _m4SwitchClosed : true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double batteryX = 60.0;
        final double lampX = width - 60.0;
        final double switchCenterX = width / 2;

        return SizedBox(
          height: 270,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, 270),
                painter: SchematicCircuitWirePainterM4(
                  isClosed: isLampLit,
                  switchInMainBranch: _m4SwitchInMainBranch,
                  animationValue: _currentFlowController.value,
                ),
              ),

              // Bateria Card (Esquerda - Posição Centralizada)
              Positioned(
                left: batteryX - 47.5,
                top: 70,
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
                top: 70,
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
                top: 10,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: !_m4SwitchInMainBranch,
                  showLabel: false,
                  accentColor: !_m4SwitchInMainBranch
                      ? const Color(0xFFD97706)
                      : const Color(0xFF94A3B8),
                  onAccept: (_) =>
                      setState(() => _m4SwitchInMainBranch = false),
                  onTap: () => setState(() {
                    if (!_m4SwitchInMainBranch) {
                      _m4SwitchClosed = !_m4SwitchClosed;
                    } else {
                      _m4SwitchInMainBranch = false;
                    }
                  }),
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
                top: 70,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _m4SwitchInMainBranch,
                  showLabel: false,
                  accentColor: _m4SwitchInMainBranch
                      ? const Color(0xFF059669)
                      : const Color(0xFF94A3B8),
                  onAccept: (_) => setState(() => _m4SwitchInMainBranch = true),
                  onTap: () => setState(() {
                    if (_m4SwitchInMainBranch) {
                      _m4SwitchClosed = !_m4SwitchClosed;
                    } else {
                      _m4SwitchInMainBranch = true;
                    }
                  }),
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
