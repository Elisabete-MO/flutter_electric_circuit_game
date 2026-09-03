import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes.dart';
import '../../models/stand_mission.dart';
import '../../state/progress_controller.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/prof_volts_full_body.dart';
import '../../widgets/schematic_blueprint_socket.dart';
import '../../widgets/schematic_symbol_painters.dart';
import '../../widgets/component_vector_painters.dart';
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

  // --- Estado Missão 1: Interruptor da Luminária ---
  bool _m1SwitchInserted = false;
  bool _m1SwitchClosed = false;

  // --- Estado Missão 2: Aberto ou Fechado? ---
  String? _m2AnswerStateA; // 'aberto' / 'fechado'
  String? _m2AnswerStateB; // 'aberto' / 'fechado'

  // --- Estado Missão 3: Dois Controles ---
  bool _m3Switch1Closed = false;
  bool _m3Switch2Closed = false;
  bool _m3TestedSwitch1 = false;
  bool _m3TestedSwitch2 = false;
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
    ref.read(progressControllerProvider.notifier).markAsCompleted('liga_desliga', stars: 3);

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
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
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
      _showFeedback(false, 'Mapeamento incorreto. Teste alternar uma chave por vez e observe qual luz responde.');
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
      _showFeedback(false, 'Instale o interruptor do tipo push-button no circuito!');
      return;
    }
    if (_m5TestedHoldAndRelease) {
      _showFeedback(
        true,
        'Excelente! O push-button só mantém a luz acesa enquanto o visitante o mantém pressionado.',
      );
    } else {
      _showFeedback(false, 'Mantenha o push-button pressionado para acender a luminária e solte em seguida antes de validar.');
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
              style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0284C7)),
          onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.home),
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
        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
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
                const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFD97706), size: 18),
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
    final statusColor = isClosed ? const Color(0xFF10B981) : const Color(0xFF64748B);
    final statusText = isClosed ? 'CIRCUITO FECHADO (ON)' : 'CIRCUITO ABERTO (OFF)';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
          ),
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
                style: GoogleFonts.rajdhani(color: const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '${voltage.toStringAsFixed(1)}V  |  ',
                style: GoogleFonts.outfit(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'CORRENTE: ',
                style: GoogleFonts.rajdhani(color: const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '${currentMa.toStringAsFixed(1)} mA',
                style: GoogleFonts.outfit(
                  color: isClosed ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
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
    return const Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        WorkbenchSymbolToolboxTile<String>(
          data: 'switch',
          label: 'Interruptor',
          tooltip: 'Interruptor (SPST)',
          symbolWidget: PushButtonVectorWidget(size: 34),
          color: Color(0xFFD97706),
        ),
        WorkbenchSymbolToolboxTile<String>(
          data: 'battery',
          label: 'Bateria',
          tooltip: 'Bateria 4.5V',
          symbolWidget: BatteryVectorWidget(size: 34),
          color: Color(0xFF0284C7),
        ),
        WorkbenchSymbolToolboxTile<String>(
          data: 'lamp',
          label: 'Lâmpada',
          tooltip: 'Lâmpada (Carga)',
          symbolWidget: BulbVectorWidget(size: 34, isOn: true),
          color: Color(0xFFD97706),
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
        Expanded(child: _buildSchematicCanvasM1()),
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
          style: GoogleFonts.outfit(color: const Color(0xFF334155), fontSize: 14.5, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        // Questão 1: Estado A (Chave Aberta)
        _buildPredictionCard(
          title: 'Cenário A: Interruptor no estado ABERTO (OFF)',
          subtitle: 'Existe um espaço vazio entre os contatos elétricos da chave.',
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
          color: currentValue != null ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
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
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 13),
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
                        color: currentValue == 'fechado' ? Colors.black : Colors.white,
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
                        color: currentValue == 'aberto' ? Colors.black : Colors.white,
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
          style: GoogleFonts.outfit(color: const Color(0xFF334155), fontSize: 14.5, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        // Bancada com 2 Interruptores e 2 Lâmpadas
        Container(
          height: 230,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Bateria Comum
              _buildRealisticBattery(),

              // Painel de 2 Chaves
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSwitchControlCard(
                    label: 'CHAVE 1',
                    isClosed: _m3Switch1Closed,
                    onToggle: () {
                      setState(() {
                        _m3Switch1Closed = !_m3Switch1Closed;
                        _m3TestedSwitch1 = true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchControlCard(
                    label: 'CHAVE 2',
                    isClosed: _m3Switch2Closed,
                    onToggle: () {
                      setState(() {
                        _m3Switch2Closed = !_m3Switch2Closed;
                        _m3TestedSwitch2 = true;
                      });
                    },
                  ),
                ],
              ),

              // Painel de 2 Lâmpadas (A e B)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRealisticBulb(
                    isLit: _m3Switch1Closed,
                    label: 'Luminária A',
                  ),
                  const SizedBox(height: 16),
                  _buildRealisticBulb(
                    isLit: _m3Switch2Closed,
                    label: 'Luminária B',
                  ),
                ],
              ),
            ],
          ),
        ),

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
        border: Border.all(color: currentSelection != null ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: currentSelection,
            dropdownColor: Colors.white,
            style: GoogleFonts.outfit(color: const Color(0xFF0F172A), fontSize: 13),
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
    final bool isLampLit = _m4SwitchInMainBranch ? _m4SwitchClosed : true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Problema Detectado: O interruptor foi montado em um ramo paralelo (ramo inútil). A lâmpada permanece acesa mesmo quando tentamos desligar!',
                  style: GoogleFonts.outfit(color: const Color(0xFF92400E), fontSize: 13.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bancada Didática Interativa de Correção do Ramo
        Container(
          height: 250,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. Fonte (Bateria 4.5V na Esquerda)
              Positioned(
                left: 20,
                top: 75,
                child: _buildRealisticBattery(),
              ),

              // 2. Opção A: Ramo Inútil (Paralelo - Topo)
              Positioned(
                left: 210,
                top: 15,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _m4SwitchInMainBranch = false;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: !_m4SwitchInMainBranch
                          ? const Color(0xFFFEF3C7)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !_m4SwitchInMainBranch ? const Color(0xFFD97706) : const Color(0xFFCBD5E1),
                        width: !_m4SwitchInMainBranch ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          !_m4SwitchInMainBranch
                              ? Icons.warning_amber_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: !_m4SwitchInMainBranch ? const Color(0xFFD97706) : const Color(0xFF64748B),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          !_m4SwitchInMainBranch
                              ? 'Ramo Inútil (Chave Ineficaz)'
                              : 'Mover Chave para Ramo Inútil',
                          style: GoogleFonts.rajdhani(
                            color: !_m4SwitchInMainBranch ? const Color(0xFF92400E) : const Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Opção B: Ramo Principal (Em Série com a Lâmpada - Centro)
              Positioned(
                left: 210,
                top: 80,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _m4SwitchInMainBranch = true;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _m4SwitchInMainBranch
                          ? const Color(0xFFEFF6FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _m4SwitchInMainBranch ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
                        width: _m4SwitchInMainBranch ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _m4SwitchInMainBranch
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: _m4SwitchInMainBranch ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _m4SwitchInMainBranch
                              ? 'Ramo Principal em Série (Correto!)'
                              : 'Mover Chave para Ramo Principal (Série)',
                          style: GoogleFonts.rajdhani(
                            color: _m4SwitchInMainBranch ? const Color(0xFF0F172A) : const Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Teste de Acionamento da Chave quando posicionada
              Positioned(
                left: 210,
                top: 145,
                child: Row(
                  children: [
                    Text(
                      'Estado da Chave:',
                      style: GoogleFonts.outfit(color: const Color(0xFF475569), fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('OFF (Aberta)', style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.bold)),
                      selected: !_m4SwitchClosed,
                      selectedColor: const Color(0xFFFDE68A),
                      onSelected: (_) => setState(() => _m4SwitchClosed = false),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: Text('ON (Fechada)', style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.bold)),
                      selected: _m4SwitchClosed,
                      selectedColor: const Color(0xFFBAE6FD),
                      onSelected: (_) => setState(() => _m4SwitchClosed = true),
                    ),
                  ],
                ),
              ),

              // 5. Luminária na Direita
              Positioned(
                right: 25,
                top: 65,
                child: _buildRealisticBulb(isLit: isLampLit),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MISSÃO 5: Controle por Push-Button
  // ==========================================
  Widget _buildMission5UI(StandMission mission) {
    final isLit = _m5PushButtonInserted && _m5PushButtonPressed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instrução do Prof. Volts para a missão 5
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0284C7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF0284C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Luz Temporária por Pressão (Push-Button)',
                        style: GoogleFonts.rajdhani(color: const Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      'Instale o botão de pressão (push-button) e segure para manter a luminária acesa temporariamente.',
                      style: GoogleFonts.outfit(color: const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Bancada da Missão 5
        Container(
          height: 220,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 60,
                child: _buildRealisticBattery(),
              ),

              // Soquete / Botão de encaixe do Push-Button
              Positioned(
                left: 200,
                top: 60,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'push_button',
                  isFilled: _m5PushButtonInserted,
                  symbolWidget: PushButtonVectorWidget(
                    size: 56,
                    isPressed: _m5PushButtonPressed,
                  ),
                  placeholderWidget: const PushButtonVectorWidget(
                    size: 48,
                  ),
                  label: 'PUSH-BUTTON',
                  onAccept: (_) {
                    setState(() {
                      _m5PushButtonInserted = true;
                    });
                  },
                  onTap: () {},
                ),
              ),

              Positioned(
                right: 25,
                top: 50,
                child: _buildRealisticBulb(isLit: isLit),
              ),
            ],
          ),
        ),

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
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: _m5PushButtonPressed ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_m5PushButtonPressed ? const Color(0xFF0284C7) : const Color(0xFF0F172A)).withValues(alpha: 0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _m5PushButtonPressed ? Icons.lightbulb_rounded : Icons.touch_app_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _m5PushButtonPressed ? 'LUMINÁRIA ACESA! (PRESSIONADO)' : 'SEGURE O PUSH-BUTTON PARA ACENDER',
                      style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- Widgets Auxiliares de Componentes Realistas ---

  Widget _buildRealisticBattery() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF042920),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.battery_charging_full_rounded, color: Color(0xFF10B981), size: 38),
          const SizedBox(height: 4),
          Text(
            'BATERIA 4.5V',
            style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildRealisticBulb({required bool isLit, String? label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isLit ? const Color(0xFF451A03) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLit ? Colors.amberAccent : Colors.white24,
          width: 1.5,
        ),
        boxShadow: [
          if (isLit)
            BoxShadow(
              color: Colors.amberAccent.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_rounded,
            size: 42,
            color: isLit ? Colors.amberAccent : Colors.white30,
          ),
          const SizedBox(height: 4),
          Text(
            label ?? (isLit ? 'LUMINÁRIA ACESA' : 'LUMINÁRIA DESLIGADA'),
            style: GoogleFonts.rajdhani(
              color: isLit ? Colors.amberAccent : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchControlCard({required bool isClosed, required VoidCallback onToggle, String? label}) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isClosed ? const Color(0xFF064E3B) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isClosed ? const Color(0xFF10B981) : Colors.amber.withValues(alpha: 0.6),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isClosed ? const Color(0xFF10B981).withValues(alpha: 0.4) : Colors.black45,
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isClosed
                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                    : Colors.white10,
              ),
              child: Icon(
                isClosed ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                color: isClosed ? const Color(0xFF34D399) : Colors.amber,
                size: 26,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label ?? 'INTERRUPTOR (SPST)',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  isClosed ? 'FECHADO (ON)' : 'ABERTO (OFF)',
                  style: GoogleFonts.rajdhani(
                    color: isClosed ? const Color(0xFF34D399) : Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildSchematicCanvasM1() {
    final bool isBulbLit = _m1SwitchInserted && _m1SwitchClosed;

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

              // 2. Símbolo da Fonte (Bateria na Esquerda)
              Positioned(
                left: batteryX - 30,
                top: 75,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BatteryVectorWidget(size: 60),
                    SizedBox(height: 4),
                    Text(
                      'FONTE 4.5V',
                      style: TextStyle(color: Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // 3. Símbolo da Lâmpada (Na Direita, Perfeitamente Conectada aos Fios)
              Positioned(
                left: lampX - 30,
                top: 75,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BulbVectorWidget(
                      size: 60,
                      isOn: isBulbLit,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LÂMPADA',
                      style: TextStyle(
                        color: isBulbLit ? const Color(0xFFD97706) : const Color(0xFF0F172A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Socket DragTarget do Interruptor (Centralizado no Topo)
              Positioned(
                left: switchCenterX - 47.5,
                top: 10,
                child: SchematicBlueprintSocket<String>(
                  expectedData: 'switch',
                  isFilled: _m1SwitchInserted,
                  onAccept: (_) => setState(() => _m1SwitchInserted = true),
                  onTap: () => setState(() {
                    if (_m1SwitchInserted) {
                      _m1SwitchClosed = !_m1SwitchClosed;
                    }
                  }),
                  symbolWidget: PushButtonVectorWidget(
                    size: 56,
                    isPressed: _m1SwitchClosed,
                  ),
                  placeholderWidget: const PushButtonVectorWidget(
                    size: 48,
                  ),
                  label: _m1SwitchInserted
                      ? (_m1SwitchClosed ? 'INTERRUPTOR (FECHADO)' : 'INTERRUPTOR (ABERTO)')
                      : 'SOLTE A CHAVE ESQUEMÁTICA',
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
    final neonColor = isClosed ? const Color(0xFF10B981) : const Color(0xFF475569);

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
    final pinPaint = Paint()..color = isClosed ? const Color(0xFF34D399) : Colors.grey;
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


