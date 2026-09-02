import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes.dart';
import '../../models/stand_mission.dart';
import '../../state/progress_controller.dart';
import '../../widgets/eletrolab_header_brand.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/prof_volts_full_body.dart';
import '../../widgets/prof_volts_speech.dart';
import '../../widgets/tech_grid_background.dart';

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

  // --- Estado Missão 5: Demonstração Guiada ---
  int _m5VisitorStep = 0;
  bool _m5Switch1 = false;
  bool _m5Switch2 = false;

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
    if (_m5VisitorStep >= 3) {
      _showFeedback(
        true,
        'Demonstração impecável! Você cumpriu toda a sequência de pedidos dos visitantes do estande.',
      );
    } else {
      _showFeedback(false, _missions[4].failureFeedback);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mission = _missions[_currentMissionIndex];

    return Scaffold(
      body: TechGridBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Cabeçalho EletroLab + Indicador de Progresso (M1 a M5)
              _buildTopBar(),

              // 2. Balão de Fala Animado do Professor Volts com Mascot Avatar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: ProfVoltsSpeech(
                  text: '“${mission.voltsMediation}”',
                ),
              ),

              // 3. Conteúdo da Missão Atual
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: _buildMissionContent(mission),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF021E18).withValues(alpha: 0.85),
        border: const Border(bottom: BorderSide(color: Color(0xFF10B981), width: 1.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.home),
                tooltip: 'Voltar ao Mapa da Feira',
              ),
              const SizedBox(width: 8),
              const EletroLabHeaderBrand(compact: true),
            ],
          ),

          // Badges das Missões 1 a 5
          Row(
            children: List.generate(_missions.length, (idx) {
              final active = idx == _currentMissionIndex;
              final done = idx < _currentMissionIndex;
              return Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: done
                      ? const Color(0xFF10B981)
                      : (active ? const Color(0xFF059669) : const Color(0xFF042D23)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? Colors.white : (done ? const Color(0xFF34D399) : Colors.white24),
                    width: active ? 1.5 : 1.0,
                  ),
                  boxShadow: active
                      ? [
                          const BoxShadow(
                            color: Color(0xFF10B981),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (done) const Icon(Icons.check_rounded, color: Colors.white, size: 13),
                    if (done) const SizedBox(width: 3),
                    Text(
                      'M${idx + 1}',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionContent(StandMission mission) {
    switch (_currentMissionIndex) {
      case 0:
        return _buildMission1UI(mission);
      case 1:
        return _buildMission2UI(mission);
      case 2:
        return _buildMission3UI(mission);
      case 3:
        return _buildMission4UI(mission);
      case 4:
        return _buildMission5UI(mission);
      default:
        return Container();
    }
  }

  // ==========================================
  // MISSÃO 1: Interruptor da Luminária
  // ==========================================
  Widget _buildMission1UI(StandMission mission) {
    final bool isBulbLit = _m1SwitchInserted && _m1SwitchClosed;

    return GlassContainer(
      borderRadius: 24,
      accentColor: const Color(0xFF10B981),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionHeader(mission),
          const SizedBox(height: 16),

          // Bancada de Montagem
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF031D17), Color(0xFF021410)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Stack(
              children: [
                // 1. Fios Neons com Animação de Elétrons
                CustomPaint(
                  size: Size.infinite,
                  painter: CircuitWirePainter(
                    isClosed: isBulbLit,
                    animationValue: _currentFlowController.value,
                    switchInserted: _m1SwitchInserted,
                  ),
                ),

                // 2. Fonte (Bateria 4.5V)
                Positioned(
                  left: 40,
                  top: 75,
                  child: _buildRealisticBattery(),
                ),

                // 3. Slot do Interruptor (Topo Centro)
                Positioned(
                  left: 280,
                  top: 15,
                  child: _m1SwitchInserted
                      ? _buildSwitchControlCard(
                          isClosed: _m1SwitchClosed,
                          onToggle: () {
                            setState(() {
                              _m1SwitchClosed = !_m1SwitchClosed;
                            });
                          },
                        )
                      : _buildInsertSwitchSlot(
                          onTap: () {
                            setState(() {
                              _m1SwitchInserted = true;
                            });
                          },
                        ),
                ),

                // 4. Luminária (Direita com Glow Halo)
                Positioned(
                  right: 45,
                  top: 65,
                  child: _buildRealisticBulb(isLit: isBulbLit),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Botão Testar e Energizar
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _validateMission1,
              icon: const Icon(Icons.bolt_rounded),
              label: Text(
                'TESTAR E ENERGIZAR',
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: const Color(0xFF021712),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MISSÃO 2: Aberto ou Fechado?
  // ==========================================
  Widget _buildMission2UI(StandMission mission) {
    return GlassContainer(
      borderRadius: 24,
      accentColor: const Color(0xFF10B981),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionHeader(mission),
          const SizedBox(height: 14),

          Text(
            'Examine a posição da chave nos dois cenários e preveja se haverá passagem de corrente:',
            style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), fontSize: 14.5),
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

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _validateMission2,
              icon: const Icon(Icons.psychology_rounded),
              label: Text(
                'VERIFICAR PREVISÃO',
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: const Color(0xFF021712),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
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
        color: const Color(0xFF03261D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.rajdhani(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 16.5)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'Circuito Aberto (Apagada)',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: currentValue == 'aberto' ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  selected: currentValue == 'aberto',
                  selectedColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFF021A14),
                  onSelected: (_) => onSelect('aberto'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'Circuito Fechado (Acesa)',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: currentValue == 'fechado' ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  selected: currentValue == 'fechado',
                  selectedColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFF021A14),
                  onSelected: (_) => onSelect('fechado'),
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
    return GlassContainer(
      borderRadius: 24,
      accentColor: const Color(0xFF10B981),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionHeader(mission),
          const SizedBox(height: 14),

          Text(
            'Teste acionar um interruptor por vez para descobrir qual luz responde a cada controle:',
            style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), fontSize: 14.5),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Painel de Chaves
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03261D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Interruptores', style: GoogleFonts.rajdhani(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 16.5)),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: Text('Chave 1', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                        value: _m3Switch1Closed,
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: (val) {
                          setState(() {
                            _m3Switch1Closed = val;
                            _m3TestedSwitch1 = true;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: Text('Chave 2', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                        value: _m3Switch2Closed,
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: (val) {
                          setState(() {
                            _m3Switch2Closed = val;
                            _m3TestedSwitch2 = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Resposta das Luminárias
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03261D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    children: [
                      Text('Luminárias Independentes', style: GoogleFonts.rajdhani(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 16.5)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniBulbDisplay('Luminária A', _m3Switch1Closed),
                          _buildMiniBulbDisplay('Luminária B', _m3Switch2Closed),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mapeamento Selecionável
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF021D17),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButton<String>(
                  value: _m3MapSwitch1,
                  hint: Text('Mapear Chave 1...', style: GoogleFonts.outfit(color: Colors.white60)),
                  dropdownColor: const Color(0xFF03261D),
                  items: const [
                    DropdownMenuItem(value: 'lampA', child: Text('Chave 1 ➔ Luminária A', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'lampB', child: Text('Chave 1 ➔ Luminária B', style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (val) => setState(() => _m3MapSwitch1 = val),
                ),
                DropdownButton<String>(
                  value: _m3MapSwitch2,
                  hint: Text('Mapear Chave 2...', style: GoogleFonts.outfit(color: Colors.white60)),
                  dropdownColor: const Color(0xFF03261D),
                  items: const [
                    DropdownMenuItem(value: 'lampA', child: Text('Chave 2 ➔ Luminária A', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'lampB', child: Text('Chave 2 ➔ Luminária B', style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (val) => setState(() => _m3MapSwitch2 = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _validateMission3,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                'CONFIRMAR MAPEAMENTO',
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: const Color(0xFF021712),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MISSÃO 4: Conferência
  // ==========================================
  Widget _buildMission4UI(StandMission mission) {
    final bool lampIsLit = _m4SwitchInMainBranch ? _m4SwitchClosed : true;

    return GlassContainer(
      borderRadius: 24,
      accentColor: const Color(0xFF10B981),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionHeader(mission),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Problema: A chave está num desvio (ramo inútil) e a corrente continua passando para a lâmpada mesmo ao abrir o interruptor!',
                    style: GoogleFonts.outfit(color: Colors.amberAccent, fontSize: 13.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF031D17), Color(0xFF021410)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 30,
                  top: 70,
                  child: _buildRealisticBattery(),
                ),
                Positioned(
                  right: 40,
                  top: 65,
                  child: _buildRealisticBulb(isLit: lampIsLit),
                ),
                Positioned(
                  left: 230,
                  top: 25,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _m4SwitchInMainBranch = !_m4SwitchInMainBranch;
                      });
                    },
                    icon: Icon(
                      _m4SwitchInMainBranch ? Icons.check_circle_rounded : Icons.swap_horiz_rounded,
                      color: _m4SwitchInMainBranch ? const Color(0xFF10B981) : Colors.amber,
                    ),
                    label: Text(
                      _m4SwitchInMainBranch
                          ? 'Ramo Principal (Correto)'
                          : 'Ramo Inútil (Clique para Mover)',
                      style: GoogleFonts.rajdhani(
                        color: _m4SwitchInMainBranch ? const Color(0xFF10B981) : Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _m4SwitchInMainBranch ? const Color(0xFF10B981) : Colors.amber,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                if (_m4SwitchInMainBranch)
                  Positioned(
                    left: 240,
                    top: 85,
                    child: SwitchListTile(
                      title: Text('Testar Chave', style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
                      value: _m4SwitchClosed,
                      onChanged: (val) => setState(() => _m4SwitchClosed = val),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _validateMission4,
              icon: const Icon(Icons.build_rounded),
              label: Text(
                'CONFERIR MONTAGEM',
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: const Color(0xFF021712),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MISSÃO 5: Demonstração Guiada
  // ==========================================
  Widget _buildMission5UI(StandMission mission) {
    final visitorRequests = [
      '“1: Por favor, acione a iluminação da luminária principal (Chave 1 ON).”',
      '“2: Agora desative a luz principal e ligue a luz de apoio (Chave 1 OFF, Chave 2 ON).”',
      '“3: Excelente! Por fim, acione ambas as luminárias juntas (Chave 1 ON, Chave 2 ON).”',
    ];

    return GlassContainer(
      borderRadius: 24,
      accentColor: const Color(0xFF10B981),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionHeader(mission),
          const SizedBox(height: 14),

          // Terminal do Visitante Virtual
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF03261D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_pin_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solicitação do Visitante Virtual:', style: GoogleFonts.rajdhani(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        _m5VisitorStep < visitorRequests.length
                            ? visitorRequests[_m5VisitorStep]
                            : '✨ Todos os pedidos foram atendidos com sucesso!',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: Text('Chave 1', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                  value: _m5Switch1,
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (val) {
                    setState(() {
                      _m5Switch1 = val;
                      _checkMission5Sequence();
                    });
                  },
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: Text('Chave 2', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                  value: _m5Switch2,
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (val) {
                    setState(() {
                      _m5Switch2 = val;
                      _checkMission5Sequence();
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _validateMission5,
              icon: const Icon(Icons.verified_rounded),
              label: Text(
                'CONCLUIR DEMONSTRAÇÃO',
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: const Color(0xFF021712),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkMission5Sequence() {
    if (_m5VisitorStep == 0 && _m5Switch1 && !_m5Switch2) {
      setState(() => _m5VisitorStep = 1);
    } else if (_m5VisitorStep == 1 && !_m5Switch1 && _m5Switch2) {
      setState(() => _m5VisitorStep = 2);
    } else if (_m5VisitorStep == 2 && _m5Switch1 && _m5Switch2) {
      setState(() => _m5VisitorStep = 3);
    }
  }

  // --- Widgets Auxiliares de Componentes Realistas ---

  Widget _buildMissionHeader(StandMission mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mission.title.toUpperCase(),
          style: GoogleFonts.rajdhani(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF10B981),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          mission.objective,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

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

  Widget _buildRealisticBulb({required bool isLit}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isLit)
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.amberAccent.withValues(alpha: 0.6),
                  Colors.amber.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_rounded,
              size: 58,
              color: isLit ? Colors.amberAccent : Colors.white30,
            ),
            const SizedBox(height: 4),
            Text(
              isLit ? 'LUMINÁRIA ACESA' : 'DESLIGADA',
              style: GoogleFonts.rajdhani(
                color: isLit ? Colors.amberAccent : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchControlCard({required bool isClosed, required VoidCallback onToggle}) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isClosed ? const Color(0xFF10B981) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isClosed ? const Color(0xFF34D399) : Colors.white24,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isClosed ? const Color(0xFF10B981).withValues(alpha: 0.4) : Colors.black45,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isClosed ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              isClosed ? 'CHAVE FECHADA (ON)' : 'CHAVE ABERTA (OFF)',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsertSwitchSlot({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_outline_rounded, color: Colors.amber, size: 22),
            const SizedBox(width: 8),
            Text(
              'Inserir Interruptor Aqui',
              style: GoogleFonts.rajdhani(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBulbDisplay(String label, bool isLit) {
    return Column(
      children: [
        Icon(
          Icons.lightbulb_rounded,
          size: 46,
          color: isLit ? Colors.amberAccent : Colors.white24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: isLit ? Colors.amberAccent : Colors.white60,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
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
