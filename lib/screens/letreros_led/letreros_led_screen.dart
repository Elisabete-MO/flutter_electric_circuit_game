import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/stand_mission.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/schematic_blueprint_socket.dart';
import '../../widgets/schematic_symbol_painters.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/workbench_components.dart';

/// Tela Interativa do Estande 05 / Estande "Letreiros de LED" (Equipe Sinalização).
class LetrerosLedScreen extends StatefulWidget {
  const LetrerosLedScreen({super.key});

  @override
  State<LetrerosLedScreen> createState() => _LetrerosLedScreenState();
}

class _LetrerosLedScreenState extends State<LetrerosLedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseAnimController;
  final List<StandMission> _missions = StandMission.letrerosLedMissions;
  int _currentMissionIndex = 0;

  // Estados da Missão 1 (Polaridade do LED)
  bool _m1LedDirectPolarity = true; // true = Anodo (+), Cathodo (-)
  bool _m1LedInserted = false;

  // Estados da Missão 2 (Diagnóstico de LED Invertido)
  bool _m2LedInvertedFixed = false;

  // Estados da Missão 3 (Resistor Limitador de Corrente)
  String? _m3SelectedResistor; // '0', '220', '680', '10000'

  // Estados da Missão 4 (Painel de Sinalização Dupla)
  bool _m4Branch1ResistorPlaced = false;
  bool _m4Branch2ResistorPlaced = false;

  // Estados da Missão 5 (Revisão do Letreiro Defeituoso)
  bool _m5GreenLedPolarityFixed = false;
  bool _m5RedResistorFixed = false;

  @override
  void initState() {
    super.initState();
    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnimController.dispose();
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
          _m1LedDirectPolarity = true;
          _m1LedInserted = false;
          break;
        case 1:
          _m2LedInvertedFixed = false;
          break;
        case 2:
          _m3SelectedResistor = null;
          break;
        case 3:
          _m4Branch1ResistorPlaced = false;
          _m4Branch2ResistorPlaced = false;
          break;
        case 4:
          _m5GreenLedPolarityFixed = false;
          _m5RedResistorFixed = false;
          break;
      }
    });
  }

  void _validateCurrentMission() {
    bool isSuccess = false;
    String feedbackMessage = _currentMission.failureFeedback;

    switch (_currentMissionIndex) {
      case 0: // M1: Polaridade do LED
        if (_m1LedInserted && _m1LedDirectPolarity) {
          isSuccess = true;
        } else if (!_m1LedInserted) {
          feedbackMessage = 'Insira o LED no soquete do circuito!';
        } else {
          feedbackMessage = 'Verifique a polaridade do LED: a corrente só passa no sentido ânodo (+) → cátodo (-).';
        }
        break;

      case 1: // M2: Diagnóstico de LED Invertido
        if (_m2LedInvertedFixed) {
          isSuccess = true;
        } else {
          feedbackMessage = 'O LED no sentido inverso bloqueia a corrente. Inverta os terminais para conduzir!';
        }
        break;

      case 2: // M3: Resistor Limitador de Corrente
        if (_m3SelectedResistor == '680') {
          isSuccess = true;
        } else if (_m3SelectedResistor == null) {
          feedbackMessage = 'Selecione um resistor para colocar em série com o LED!';
        } else if (_m3SelectedResistor == '0') {
          feedbackMessage = 'Perigo de sobrecorrente! Sem resistor de limitação, o LED queimará!';
        } else if (_m3SelectedResistor == '220') {
          feedbackMessage = 'Resistor de 220Ω permite corrente muito elevada para a fonte de 9V.';
        } else {
          feedbackMessage = 'Resistor de 10kΩ possui resistência excessiva, deixando o LED praticamente apagado.';
        }
        break;

      case 3: // M4: Painel de Sinalização Dupla
        if (_m4Branch1ResistorPlaced && _m4Branch2ResistorPlaced) {
          isSuccess = true;
        } else {
          feedbackMessage = 'Cada LED precisa de seu próprio resistor protetor de 680Ω em seu ramo!';
        }
        break;

      case 4: // M5: Revisão do Letreiro Defeituoso
        if (_m5GreenLedPolarityFixed && _m5RedResistorFixed) {
          isSuccess = true;
        } else if (!_m5GreenLedPolarityFixed) {
          feedbackMessage = 'Corrija a polaridade invertida do LED Verde na placa Entrada.';
        } else {
          feedbackMessage = 'Substitua o resistor de 0Ω (jumper curto) por um resistor protetor de 680Ω no LED Vermelho.';
        }
        break;
    }

    final fullMessage = isSuccess
        ? 'Missão "${_currentMission.title}" concluída com êxito! ${_currentMission.victoryCriteria}.\n\nProf. Volts: "${_currentMission.voltsMediation}"'
        : '$feedbackMessage\n\nProf. Volts: "${_currentMission.voltsMediation}"';

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
              'Parabéns! A Equipe Sinalização garantiu o correto funcionamento e proteção de todos os letreiros da Feira de Ciências!',
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
                  const Icon(Icons.verified_rounded, color: Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Selo "Semicondutores & Proteção" conquistado!',
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
              'ESTANDE 05 — LETREIROS DE LED',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Equipe Sinalização — Semicondutores e Proteção',
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
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildLedWorkbench(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Painel Lateral (40%)
                Expanded(
                  flex: 2,
                  child: WorkbenchSidePanel(
                    teamTitle: 'Componentes — Sinalização',
                    toolboxItems: [
                      _buildSidePanelContent(),
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

  Widget _buildLedWorkbench() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: _buildMissionSignDisplay(),
    );
  }

  Widget _buildMissionSignDisplay() {
    switch (_currentMissionIndex) {
      case 0:
        return _buildM1SignDisplay();
      case 1:
        return _buildM2SignDisplay();
      case 2:
        return _buildM3SignDisplay();
      case 3:
        return _buildM4SignDisplay();
      case 4:
        return _buildM5SignDisplay();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Visualizador da Missão 1: Polaridade do LED (Placa ATENÇÃO)
  Widget _buildM1SignDisplay() {
    final isLit = _m1LedInserted && _m1LedDirectPolarity;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLedSignBoard(
          title: 'ATENÇÃO',
          color: Colors.redAccent,
          isLit: isLit,
        ),

        // Socket Esquemático do LED Semicondutor
        SchematicBlueprintSocket<String>(
          expectedData: 'led_red',
          isFilled: _m1LedInserted,
          symbolWidget: SchematicLedWidget(
            size: 55,
            color: Colors.redAccent,
            isOn: isLit,
          ),
          placeholderWidget: const SchematicLedWidget(
            size: 45,
            color: Colors.white38,
            isOn: false,
          ),
          label: 'SOQUETE LED SEMICONDUTOR',
          onAccept: (_) {
            setState(() {
              _m1LedInserted = true;
            });
          },
          onTap: () {
            setState(() {
              _m1LedInserted = !_m1LedInserted;
            });
          },
        ),

        // Controle Clean de Polaridade (Ânodo / Cátodo)
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            side: const BorderSide(color: Color(0xFF00E5FF)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.flip_camera_android_rounded, color: Color(0xFF00E5FF)),
          label: Text(
            _m1LedDirectPolarity
                ? 'Polaridade: Direta [Ânodo (+) → Cátodo (-)]'
                : 'Polaridade: Inversa [Cátodo (-) → Ânodo (+)]',
            style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          onPressed: () {
            setState(() {
              _m1LedDirectPolarity = !_m1LedDirectPolarity;
            });
          },
        ),
      ],
    );
  }

  /// Visualizador da Missão 2: Diagnóstico de LED Invertido (Placa SAÍDA)
  Widget _buildM2SignDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLedSignBoard(
          title: 'SAÍDA',
          color: const Color(0xFF10B981),
          isLit: _m2LedInvertedFixed,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _m2LedInvertedFixed ? const Color(0xFF10B981) : Colors.amberAccent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _m2LedInvertedFixed ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                color: _m2LedInvertedFixed ? const Color(0xFF10B981) : Colors.amberAccent,
                size: 28,
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _m2LedInvertedFixed ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFF10B981)),
                ),
                icon: const Icon(Icons.rotate_right_rounded, color: Colors.white),
                label: Text(
                  _m2LedInvertedFixed ? 'Terminais Invertidos (Conduzindo!)' : 'Inverter Terminais do LED (180°)',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () {
                  setState(() {
                    _m2LedInvertedFixed = !_m2LedInvertedFixed;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Visualizador da Missão 3: Resistor Limitador de Corrente
  Widget _buildM3SignDisplay() {
    final isIdeal = _m3SelectedResistor == '680';
    final isBurnt = _m3SelectedResistor == '0';
    final isTooWeak = _m3SelectedResistor == '10000';
    final isOverheated = _m3SelectedResistor == '220';

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLedSignBoard(
          title: isBurnt ? 'QUEIMADO!' : 'ENTRADA',
          color: isBurnt ? Colors.grey : const Color(0xFF10B981),
          isLit: isIdeal || isOverheated,
          isBurnt: isBurnt,
          isDim: isTooWeak,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isIdeal ? const Color(0xFF10B981) : Colors.white24,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Resistor em Série Selecionado: ${_m3SelectedResistor ?? 'Nenhum'} ${_m3SelectedResistor != null ? 'Ω' : ''}',
                style: GoogleFonts.rajdhani(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildResistorChip('0 Ω (Jumper)', '0'),
                  _buildResistorChip('220 Ω', '220'),
                  _buildResistorChip('680 Ω (Ideal)', '680'),
                  _buildResistorChip('10 kΩ', '10000'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResistorChip(String label, String value) {
    final isSelected = _m3SelectedResistor == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          _m3SelectedResistor = val ? value : null;
        });
      },
      selectedColor: const Color(0xFF10B981),
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: GoogleFonts.rajdhani(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Visualizador da Missão 4: Painel de Sinalização Dupla
  Widget _buildM4SignDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLedSignBoard(
              title: 'ENTRADA',
              color: const Color(0xFF10B981),
              isLit: _m4Branch1ResistorPlaced,
            ),
            _buildLedSignBoard(
              title: 'SAÍDA',
              color: Colors.redAccent,
              isLit: _m4Branch2ResistorPlaced,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _m4Branch1ResistorPlaced ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFF10B981)),
              ),
              icon: Icon(_m4Branch1ResistorPlaced ? Icons.check : Icons.security_rounded),
              label: Text(
                _m4Branch1ResistorPlaced ? 'Resistor 680Ω (Ramo Entrada)' : 'Proteger Ramo 1 (Resistor 680Ω)',
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  _m4Branch1ResistorPlaced = !_m4Branch1ResistorPlaced;
                });
              },
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _m4Branch2ResistorPlaced ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFF10B981)),
              ),
              icon: Icon(_m4Branch2ResistorPlaced ? Icons.check : Icons.security_rounded),
              label: Text(
                _m4Branch2ResistorPlaced ? 'Resistor 680Ω (Ramo Saída)' : 'Proteger Ramo 2 (Resistor 680Ω)',
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  _m4Branch2ResistorPlaced = !_m4Branch2ResistorPlaced;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Visualizador da Missão 5: Revisão do Letreiro Defeituoso
  Widget _buildM5SignDisplay() {
    final allFixed = _m5GreenLedPolarityFixed && _m5RedResistorFixed;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLedSignBoard(
              title: 'ENTRADA',
              color: const Color(0xFF10B981),
              isLit: _m5GreenLedPolarityFixed,
            ),
            _buildLedSignBoard(
              title: 'SAÍDA',
              color: Colors.redAccent,
              isLit: _m5RedResistorFixed,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: allFixed ? const Color(0xFF10B981) : Colors.amberAccent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _m5GreenLedPolarityFixed ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFF10B981)),
                ),
                icon: Icon(_m5GreenLedPolarityFixed ? Icons.check : Icons.flip_camera_android_rounded),
                label: Text(
                  _m5GreenLedPolarityFixed ? 'Polaridade LED Verde Ok' : 'Corrigir Polaridade (LED Verde)',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  setState(() {
                    _m5GreenLedPolarityFixed = !_m5GreenLedPolarityFixed;
                  });
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _m5RedResistorFixed ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFF10B981)),
                ),
                icon: Icon(_m5RedResistorFixed ? Icons.check : Icons.build_rounded),
                label: Text(
                  _m5RedResistorFixed ? 'Resistor 680Ω Ok' : 'Substituir 0Ω por 680Ω (LED Vermelho)',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  setState(() {
                    _m5RedResistorFixed = !_m5RedResistorFixed;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildSidePanelContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            WorkbenchSymbolToolboxTile<String>(
              data: 'led_red',
              label: 'LED',
              tooltip: 'LED Vermelho (Semicondutor)',
              symbolWidget: SchematicLedWidget(size: 34, color: Colors.redAccent, isOn: true),
              color: Colors.redAccent,
            ),
            WorkbenchSymbolToolboxTile<String>(
              data: 'resistor_680',
              label: 'Resistor',
              tooltip: 'Resistor Prot. 680Ω',
              symbolWidget: SchematicResistorWidget(size: 34, color: Color(0xFFD97706)),
              color: Color(0xFFD97706),
            ),
            WorkbenchSymbolToolboxTile<String>(
              data: 'bateria_9v',
              label: 'Fonte 9V',
              tooltip: 'Fonte DC 9V',
              symbolWidget: SchematicBatteryWidget(size: 34, color: Color(0xFF0284C7)),
              color: Color(0xFF0284C7),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Simbologia e Regras:',
          style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• Ânodo (+): Terminal maior do LED (polo positivo).',
                style: GoogleFonts.rajdhani(color: const Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '• Cátodo (-): Terminal menor (polo negativo).',
                style: GoogleFonts.rajdhani(color: const Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '• Resistor: Limita a corrente para evitar a queima do diodo.',
                style: GoogleFonts.rajdhani(color: const Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
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





  /// Componente gráfico de placa de letreiro luminoso de LED estilo Neon/Glassmorphism
  Widget _buildLedSignBoard({
    required String title,
    required Color color,
    required bool isLit,
    bool isBurnt = false,
    bool isDim = false,
  }) {
    final activeColor = isBurnt
        ? Colors.grey
        : isLit
            ? color
            : Colors.white10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeColor,
          width: 3,
        ),
        boxShadow: isLit && !isBurnt
            ? [
                BoxShadow(
                  color: color.withValues(alpha: isDim ? 0.2 : 0.6),
                  blurRadius: isDim ? 12 : 30,
                  spreadRadius: isDim ? 2 : 6,
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBurnt
                ? Icons.flash_off_rounded
                : isLit
                    ? Icons.lightbulb_rounded
                    : Icons.lightbulb_outline_rounded,
            color: activeColor,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.rajdhani(
              color: activeColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}
