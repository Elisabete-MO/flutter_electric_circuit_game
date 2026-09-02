import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/stand_mission.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/workbench_components.dart';

/// Tela Interativa do Estande 04 / Estande "Ruas da Maquete" (Equipe Bairro).
class RuasMaqueteScreen extends StatefulWidget {
  const RuasMaqueteScreen({super.key});

  @override
  State<RuasMaqueteScreen> createState() => _RuasMaqueteScreenState();
}

class _RuasMaqueteScreenState extends State<RuasMaqueteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _electronAnimController;
  final List<StandMission> _missions = StandMission.ruasMaqueteMissions;
  int _currentMissionIndex = 0;

  // Estados da Missão 1 (Postes em Série)
  bool _m1WireConnected = false;

  // Estados da Missão 2 (Comparação de Brilho)
  bool _m2IsSeriesTwoBulbs = true; // true = 2 postes em série (50%), false = 1 poste (100%)
  String? _m2SelectedExplanation;

  // Estados da Missão 3 (Bifurcação de Fios / Nó)
  bool _m3JunctionInserted = false;
  bool _m3ReturnConnected = false;

  // Estados da Missão 4 (Casas Independentes / Paralelo)
  bool _m4ParallelWireConnected = false;

  // Estados da Missão 5 (Teste de Manutenção do Bairro)
  bool _m5House1Broken = false;
  bool _m5MaintenanceConfirmed = false;

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
    setState(() {
      switch (_currentMissionIndex) {
        case 0:
          _m1WireConnected = false;
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

  void _validateCurrentMission() {
    bool isSuccess = false;
    String feedbackMessage = _currentMission.failureFeedback;

    switch (_currentMissionIndex) {
      case 0: // M1: Postes em Série
        if (_m1WireConnected) {
          isSuccess = true;
        } else {
          feedbackMessage = 'Conecte o fio condutor em série entre a bateria e as duas lâmpadas!';
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
          isSuccess = true;
        } else if (!_m3JunctionInserted) {
          feedbackMessage = 'Insira o nó de bifurcação para dividir a corrente para as duas ruas.';
        } else {
          feedbackMessage = 'A bifurcação precisa se reconectar ao polo negativo da fonte.';
        }
        break;

      case 3: // M4: Casas Independentes (Paralelo)
        if (_m4ParallelWireConnected) {
          isSuccess = true;
        } else {
          feedbackMessage = 'Monte as ligações em paralelo para que cada casa tenha seu ramo individual.';
        }
        break;

      case 4: // M5: Teste de Manutenção do Bairro
        if (_m5House1Broken && _m5MaintenanceConfirmed) {
          isSuccess = true;
        } else if (!_m5House1Broken) {
          feedbackMessage = 'Simule o defeito na Lâmpada A para testar a independência do circuito!';
        } else {
          feedbackMessage = 'Confirme o resultado da manutenção ao observar que a Lâmpada B permanece acesa.';
        }
        break;
    }

    final fullMessage = isSuccess
        ? 'Missão "${_currentMission.title}" concluída com êxito! ${_currentMission.victoryCriteria}.\n\nProf. Volts: "${_currentMission.voltsMediation}"'
        : '$feedbackMessage\n\nProf. Volts: "No circuito em série há apenas uma rota; no circuito em paralelo, cada ramo é independente."';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isSuccess,
        message: fullMessage,
        onAction: () {
          Navigator.of(context).pop();
          if (isSuccess) {
            _nextMission();
          }
        },
      ),
    );
  }

  void _showStandCompletionDialog() {
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
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
      backgroundColor: const Color(0xFF021712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF041C16),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ESTANDE 04 — RUAS DA MAQUETE',
              style: GoogleFonts.orbitron(
                color: const Color(0xFF10B981),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Equipe Bairro — Circuito em Série e Paralelo',
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF10B981)),
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
                    teamTitle: 'Painel da Equipe Bairro',
                    toolboxItems: [
                      _buildMissionControlPanel(),
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



  /// Desenho interativo da bancada simulando as Ruas da Maquete
  Widget _buildMaqueteWorkbench() {
    return GlassContainer(
      accentColor: const Color(0xFF10B981),
      borderWidth: 1.5,
      child: Stack(
        children: [
          // Fundo com visual de asfalto/rua da maquete
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF092A24),
                    const Color(0xFF041916),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Painter customizado com linhas neon e animação de elétrons
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _electronAnimController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RuasMaquetePainter(
                    missionIndex: _currentMissionIndex,
                    animValue: _electronAnimController.value,
                    m1Connected: _m1WireConnected,
                    m2Series: _m2IsSeriesTwoBulbs,
                    m3Junction: _m3JunctionInserted,
                    m3Return: _m3ReturnConnected,
                    m4Parallel: _m4ParallelWireConnected,
                    m5House1Broken: _m5House1Broken,
                  ),
                );
              },
            ),
          ),

          // Interatividade Visual Específica por Missão
          _buildMissionOverlayContent(),
        ],
      ),
    );
  }

  /// Elementos visuais sobrepostos e interativos na bancada
  Widget _buildMissionOverlayContent() {
    switch (_currentMissionIndex) {
      case 0: // M1: Postes em Série
        return _buildM1Overlay();
      case 1: // M2: Comparação de Brilho
        return _buildM2Overlay();
      case 2: // M3: Bifurcação de Fios
        return _buildM3Overlay();
      case 3: // M4: Casas Independentes (Paralelo)
        return _buildM4Overlay();
      case 4: // M5: Teste de Manutenção
        return _buildM5Overlay();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Overlay da Missão 1: Conexão em Série de Postes
  Widget _buildM1Overlay() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStreetLamp(
                  label: 'Poste 1 (Alameda)',
                  isLit: _m1WireConnected,
                  brightnessRatio: _m1WireConnected ? 0.5 : 0.0,
                ),
                _buildStreetLamp(
                  label: 'Poste 2 (Avenida)',
                  isLit: _m1WireConnected,
                  brightnessRatio: _m1WireConnected ? 0.5 : 0.0,
                ),
              ],
            ),

            // Drop Target ou Botão de Interação
            DragTarget<String>(
              onWillAcceptWithDetails: (details) => details.data == 'fio_serie',
              onAcceptWithDetails: (details) {
                setState(() {
                  _m1WireConnected = true;
                });
              },
              builder: (context, candidateData, rejectedData) {
                final isHovered = candidateData.isNotEmpty;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _m1WireConnected = !_m1WireConnected;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: _m1WireConnected
                          ? const Color(0xFF064E3B)
                          : isHovered
                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                              : const Color(0xFF0F172A).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _m1WireConnected
                            ? const Color(0xFF10B981)
                            : isHovered
                                ? const Color(0xFF10B981)
                                : Colors.amber,
                        width: isHovered ? 2.5 : 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_m1WireConnected || isHovered ? const Color(0xFF10B981) : Colors.amber).withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: (_m1WireConnected || isHovered ? const Color(0xFF10B981) : Colors.amber).withValues(alpha: 0.2),
                            border: Border.all(
                              color: _m1WireConnected || isHovered ? const Color(0xFF10B981) : Colors.amber,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            _m1WireConnected
                                ? Icons.check_circle_rounded
                                : isHovered
                                    ? Icons.move_to_inbox_rounded
                                    : Icons.add_box_rounded,
                            color: _m1WireConnected || isHovered ? const Color(0xFF10B981) : Colors.amber,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _m1WireConnected
                                  ? '⚡ Fio em Série Conectado (Rota Única)'
                                  : isHovered
                                      ? '🎯 Solte para Encaixar Fio!'
                                      : '➕ Encaixar Fio em Série',
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _m1WireConnected
                                  ? 'Clique para alternar conexão'
                                  : 'Arraste o componente da gaveta ou clique aqui',
                              style: GoogleFonts.rajdhani(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Overlay da Missão 2: Comparação de Brilho 1 vs 2 Lâmpadas
  Widget _buildM2Overlay() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStreetLamp(
                  label: 'Poste Principal',
                  isLit: true,
                  brightnessRatio: _m2IsSeriesTwoBulbs ? 0.5 : 1.0,
                ),
                if (_m2IsSeriesTwoBulbs)
                  _buildStreetLamp(
                    label: 'Poste Secundário (Série)',
                    isLit: true,
                    brightnessRatio: 0.5,
                  ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Modo de Teste: ',
                    style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('1 Poste (100% Brilho)'),
                    selected: !_m2IsSeriesTwoBulbs,
                    onSelected: (val) {
                      setState(() {
                        _m2IsSeriesTwoBulbs = !val;
                      });
                    },
                    selectedColor: const Color(0xFF10B981),
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('2 Postes em Série (50% Brilho)'),
                    selected: _m2IsSeriesTwoBulbs,
                    onSelected: (val) {
                      setState(() {
                        _m2IsSeriesTwoBulbs = val;
                      });
                    },
                    selectedColor: Colors.amberAccent,
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: GoogleFonts.rajdhani(
                      color: _m2IsSeriesTwoBulbs ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Overlay da Missão 3: Bifurcação de Fios (Nó)
  Widget _buildM3Overlay() {
    final bothLit = _m3JunctionInserted && _m3ReturnConnected;
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStreetLamp(
                  label: 'Rua A (Nó Norte)',
                  isLit: bothLit,
                  brightnessRatio: bothLit ? 1.0 : 0.0,
                ),
                _buildStreetLamp(
                  label: 'Rua B (Nó Sul)',
                  isLit: bothLit,
                  brightnessRatio: bothLit ? 1.0 : 0.0,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _m3JunctionInserted
                        ? const Color(0xFF10B981)
                        : const Color(0xFF1E293B),
                    side: const BorderSide(color: Color(0xFF10B981)),
                  ),
                  icon: Icon(_m3JunctionInserted ? Icons.check : Icons.call_split_rounded),
                  label: Text(
                    _m3JunctionInserted ? 'Nó de Junção Inserido' : '1. Inserir Nó de Junção',
                    style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    setState(() {
                      _m3JunctionInserted = !_m3JunctionInserted;
                    });
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _m3ReturnConnected
                        ? const Color(0xFF10B981)
                        : const Color(0xFF1E293B),
                    side: const BorderSide(color: Color(0xFF10B981)),
                  ),
                  icon: Icon(_m3ReturnConnected ? Icons.check : Icons.subdirectory_arrow_left_rounded),
                  label: Text(
                    _m3ReturnConnected ? 'Retorno Reconectado (-)' : '2. Reconectar Retorno (-)',
                    style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    setState(() {
                      _m3ReturnConnected = !_m3ReturnConnected;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Overlay da Missão 4: Casas Independentes (Paralelo)
  Widget _buildM4Overlay() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHouseDisplay(
                  name: 'Casa 01 (Alameda)',
                  isLit: _m4ParallelWireConnected,
                  brightness: 1.0,
                ),
                _buildHouseDisplay(
                  name: 'Casa 02 (Praça)',
                  isLit: _m4ParallelWireConnected,
                  brightness: 1.0,
                ),
              ],
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _m4ParallelWireConnected = !_m4ParallelWireConnected;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: _m4ParallelWireConnected
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _m4ParallelWireConnected ? const Color(0xFF10B981) : Colors.amberAccent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _m4ParallelWireConnected ? Icons.check_circle_rounded : Icons.alt_route_rounded,
                      color: _m4ParallelWireConnected ? const Color(0xFF10B981) : Colors.amberAccent,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _m4ParallelWireConnected
                          ? 'Circuito em Paralelo Ativo (Brilho Máximo em Ambos)'
                          : 'Clique para Conectar Fiação em Paralelo',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Overlay da Missão 5: Teste de Manutenção do Bairro
  Widget _buildM5Overlay() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHouseDisplay(
                  name: 'Lâmpada A (Simulada)',
                  isLit: !_m5House1Broken,
                  brightness: !_m5House1Broken ? 1.0 : 0.0,
                  isBroken: _m5House1Broken,
                ),
                _buildHouseDisplay(
                  name: 'Lâmpada B (Testada)',
                  isLit: true,
                  brightness: 1.0,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _m5House1Broken ? Colors.redAccent.withValues(alpha: 0.8) : const Color(0xFF1E293B),
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  icon: const Icon(Icons.flash_off_rounded, color: Colors.white),
                  label: Text(
                    _m5House1Broken ? 'Lâmpada A Desconectada' : 'Simular Defeito na Lâmpada A',
                    style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    setState(() {
                      _m5House1Broken = !_m5House1Broken;
                    });
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _m5MaintenanceConfirmed ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                    side: const BorderSide(color: Color(0xFF10B981)),
                  ),
                  icon: Icon(_m5MaintenanceConfirmed ? Icons.verified_rounded : Icons.check_circle_outline_rounded),
                  label: Text(
                    _m5MaintenanceConfirmed ? 'Lâmpada B Continua Acesa (Confirmado)' : 'Confirmar Manutenção',
                    style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    setState(() {
                      _m5MaintenanceConfirmed = !_m5MaintenanceConfirmed;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Painel da direita com ferramentas e formulários didáticos
  Widget _buildMissionControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF082B24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                'Painel de Controle',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),

          // Instruções da Missão Atual
          Text(
            _currentMission.objective,
            style: GoogleFonts.rajdhani(
              color: Colors.white70,
              fontSize: 15,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Conteúdo específico da Missão no Painel Lateral
          Expanded(
            child: SingleChildScrollView(
              child: _buildSidePanelMissionContent(),
            ),
          ),

          // Botões de Ação (Testar e Validar)
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: Text(
                'TESTAR E VALIDAR CIRCUITO',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onPressed: _validateCurrentMission,
            ),
          ),
        ],
      ),
    );
  }

  /// Conteúdo dinâmico do painel lateral para perguntas/ferramentas
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

  Widget _buildM1SideTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gaveta de Componentes:',
          style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        const WorkbenchToolboxItem<String>(
          data: 'fio_serie',
          title: 'Fio Condutor em Série',
          subtitle: 'Interliga postes em rota única',
          icon: Icons.alt_route_rounded,
          color: Color(0xFF10B981),
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
          style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Por que o brilho dos dois postes diminuiu ao ligá-los no mesmo caminho em série?',
          style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
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
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF10B981) : Colors.white60,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.rajdhani(
                  color: isSelected ? Colors.white : Colors.white70,
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
          style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          'Uma bifurcação (nó) divide a corrente em duas rotas separadas (Rua A e Rua B). Ambas precisam se reconectar ao polo negativo para fechar o circuito!',
          style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 14, height: 1.3),
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
          style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          'Cada casa do bairro recebe a tensão total da bateria (4.5V). Assim, todas as lâmpadas acendem com 100% de brilho máximo sem interference!',
          style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 14, height: 1.3),
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
          style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          'Em paralelo, quando a Lâmpada A se queima ou é removida, a Lâmpada B continua recebendo corrente em seu ramo independente. É por isso que as casas da cidade usam ligação em paralelo!',
          style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 14, height: 1.3),
        ),
      ],
    );
  }



  /// Componente didático visual de poste de iluminação pública
  Widget _buildStreetLamp({
    required String label,
    required bool isLit,
    required double brightnessRatio,
  }) {
    final glowColor = isLit
        ? Colors.amberAccent.withValues(alpha: brightnessRatio)
        : Colors.white10;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isLit)
              Container(
                width: 70 * brightnessRatio + 20,
                height: 70 * brightnessRatio + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: glowColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.6 * brightnessRatio),
                      blurRadius: 30 * brightnessRatio,
                      spreadRadius: 10 * brightnessRatio,
                    ),
                  ],
                ),
              ),
            Icon(
              Icons.lightbulb_rounded,
              size: 48,
              color: isLit
                  ? Color.lerp(Colors.white, Colors.amberAccent, brightnessRatio)
                  : Colors.white24,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: isLit ? Colors.white : Colors.white60,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Componente didático visual de casa da maquete
  Widget _buildHouseDisplay({
    required String name,
    required bool isLit,
    required double brightness,
    bool isBroken = false,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLit
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isBroken
                      ? Colors.redAccent
                      : isLit
                          ? const Color(0xFF10B981)
                          : Colors.white24,
                  width: 2,
                ),
                boxShadow: isLit
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          blurRadius: 16,
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
                size: 50,
                color: isBroken
                    ? Colors.redAccent
                    : isLit
                        ? Colors.amberAccent
                        : Colors.white30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: GoogleFonts.rajdhani(
            color: isBroken ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

/// Custom Painter com traçados neon e animação de elétrons para as Ruas da Maquete
class _RuasMaquetePainter extends CustomPainter {
  final int missionIndex;
  final double animValue;
  final bool m1Connected;
  final bool m2Series;
  final bool m3Junction;
  final bool m3Return;
  final bool m4Parallel;
  final bool m5House1Broken;

  _RuasMaquetePainter({
    required this.missionIndex,
    required this.animValue,
    required this.m1Connected,
    required this.m2Series,
    required this.m3Junction,
    required this.m3Return,
    required this.m4Parallel,
    required this.m5House1Broken,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = const Color(0xFF0D9488).withValues(alpha: 0.4)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final activeWirePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final electronPaint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.fill;

    // Desenhar caminhos de fios conforme a missão
    if (missionIndex == 0) { // M1: Série
      final path = Path()
        ..moveTo(size.width * 0.1, size.height * 0.8)
        ..lineTo(size.width * 0.3, size.height * 0.3)
        ..lineTo(size.width * 0.7, size.height * 0.3)
        ..lineTo(size.width * 0.9, size.height * 0.8);

      canvas.drawPath(path, m1Connected ? activeWirePaint : wirePaint);

      if (m1Connected) {
        _drawElectronsOnPath(canvas, path, electronPaint);
      }
    } else if (missionIndex == 3 || missionIndex == 4) { // M4 e M5: Paralelo
      final pathRamo1 = Path()
        ..moveTo(size.width * 0.1, size.height * 0.8)
        ..lineTo(size.width * 0.3, size.height * 0.3)
        ..lineTo(size.width * 0.9, size.height * 0.8);

      final pathRamo2 = Path()
        ..moveTo(size.width * 0.1, size.height * 0.8)
        ..lineTo(size.width * 0.7, size.height * 0.3)
        ..lineTo(size.width * 0.9, size.height * 0.8);

      final isActive = m4Parallel || missionIndex == 4;
      canvas.drawPath(pathRamo1, isActive ? activeWirePaint : wirePaint);
      canvas.drawPath(pathRamo2, isActive ? activeWirePaint : wirePaint);

      if (isActive) {
        if (!m5House1Broken || missionIndex != 4) {
          _drawElectronsOnPath(canvas, pathRamo1, electronPaint);
        }
        _drawElectronsOnPath(canvas, pathRamo2, electronPaint);
      }
    }
  }

  void _drawElectronsOnPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      final length = metric.length;
      final count = 6;
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
        oldDelegate.m5House1Broken != m5House1Broken;
  }
}
