import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/stand_mission.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/schematic_blueprint_socket.dart';
import '../../widgets/schematic_symbol_painters.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/workbench_components.dart';

/// Estande 06 — "Movimento em Miniatura" (Equipe Mecânica)
class MovimentoMiniaturaScreen extends StatefulWidget {
  const MovimentoMiniaturaScreen({super.key});

  @override
  State<MovimentoMiniaturaScreen> createState() => _MovimentoMiniaturaScreenState();
}

class _MovimentoMiniaturaScreenState extends State<MovimentoMiniaturaScreen>
    with SingleTickerProviderStateMixin {
  late final List<StandMission> _missions;
  int _currentMissionIndex = 0;

  // Controller para rotação da hélice do motor CC
  late final AnimationController _fanController;

  // Estátos das Missões:
  // M1: Primeiro Giro do Motor
  bool _m1MotorInserted = false;

  // M2: Inversão de Sentido de Rotação
  bool _m2ReversedPolarity = false; // false = Horário (+/-), true = Anti-horário (-/+)

  // M3: Botão de Partida do Motor (Push-button)
  bool _m3PushButtonInserted = false;
  bool _m3PushButtonPressed = false;

  // M4: Painel com LED Indicador em Paralelo
  bool _m4LedInserted = false;
  bool _m4ResistorInserted = false;

  // M5: Diagnóstico do Mini Carrinho
  bool _m5WireRepaired = false;
  bool _m5CarTested = false;

  StandMission get _currentMission => _missions[_currentMissionIndex];

  @override
  void initState() {
    super.initState();
    _missions = StandMission.movimentoMiniaturaMissions;
    _fanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _fanController.dispose();
    super.dispose();
  }

  void _nextMission() {
    if (_currentMissionIndex < _missions.length - 1) {
      setState(() {
        _currentMissionIndex++;
      });
    } else {
      _showStandCompletionDialog();
    }
  }

  void _previousMission() {
    if (_currentMissionIndex > 0) {
      setState(() {
        _currentMissionIndex--;
      });
    }
  }

  void _validateCurrentMission() {
    bool isSuccess = false;
    String feedbackMessage = _currentMission.failureFeedback;

    switch (_currentMissionIndex) {
      case 0: // M1: Primeiro Giro do Motor
        if (_m1MotorInserted) {
          isSuccess = true;
        } else {
          feedbackMessage = 'Confira se ambos os terminais do motor estão conectados à fonte didática!';
        }
        break;

      case 1: // M2: Inversão de Sentido de Rotação
        if (_m2ReversedPolarity) {
          isSuccess = true;
        } else {
          feedbackMessage = 'Inverta a polaridade da fonte (+/- ➔ -/+) para alterar o sentido do campo magnético.';
        }
        break;

      case 2: // M3: Botão de Partida do Motor (Push-button)
        if (_m3PushButtonInserted && _m3PushButtonPressed) {
          isSuccess = true;
        } else if (!_m3PushButtonInserted) {
          feedbackMessage = 'Instale o interruptor tipo push-button na linha de corrente!';
        } else {
          feedbackMessage = 'Pressione e segure o botão de partida para acionar o motor CC.';
        }
        break;

      case 3: // M4: Painel com LED Indicador
        if (_m4LedInserted && _m4ResistorInserted) {
          isSuccess = true;
        } else if (!_m4LedInserted) {
          feedbackMessage = 'Conecte o LED indicador no ramo em paralelo!';
        } else {
          feedbackMessage = 'O LED indicador também necessita de resistor de proteção no seu ramo!';
        }
        break;

      case 4: // M5: Diagnóstico do Mini Carrinho
        if (_m5WireRepaired && _m5CarTested) {
          isSuccess = true;
        } else if (!_m5WireRepaired) {
          feedbackMessage = 'Inspecione os terminais do motor para encontrar e reparar a fiação solta.';
        } else {
          feedbackMessage = 'Teste o acionamento do mini carrinho após o reparo!';
        }
        break;
    }

    final fullMessage = isSuccess
        ? 'Missão "${_currentMission.title}" concluída! ${_currentMission.victoryCriteria}.\n\nProf. Volts: "${_currentMission.voltsMediation}"'
        : '$feedbackMessage\n\nProf. Volts: "A corrente elétrica gera um campo magnético no motor CC, transformando energia elétrica em torque mecânico."';

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
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ],
        ),
        content: Text(
          'Parabéns! Você completou todas as missões do Estande "Movimento em Miniatura". A equipe da Mecânica agora domina a conversão de energia elétrica em torque rotacional!',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('VOLTAR AO MAPA', style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold)),
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
              'ESTANDE 06 — MOVIMENTO EM MINIATURA',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Equipe Mecânica — Conservação e Transmutação de Energia',
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
                // Área Principal do Laboratório / Bancada
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildStepperHeader(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildCurrentMissionUI(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Painel Lateral (Gaveta de Componentes & Instruções)
                Expanded(
                  flex: 2,
                  child: _buildSideControlPanel(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    return WorkbenchHeaderStepper(
      totalMissions: _missions.length,
      currentMissionIndex: _currentMissionIndex,
      missionTitle: _currentMission.title,
      missionObjective: _currentMission.objective,
      onPrevious: _currentMissionIndex > 0 ? _previousMission : null,
      onNext: _currentMissionIndex < _missions.length - 1 ? _nextMission : null,
    );
  }

  Widget _buildCurrentMissionUI() {
    switch (_currentMissionIndex) {
      case 0:
        return _buildM1UI();
      case 1:
        return _buildM2UI();
      case 2:
        return _buildM3UI();
      case 3:
        return _buildM4UI();
      case 4:
        return _buildM5UI();
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // MISSÃO 1: Primeiro Giro do Motor
  // ==========================================
  Widget _buildM1UI() {
    return Stack(
      children: [
        // Diagrama Blueprint Desenho do Circuito
        Positioned.fill(
          child: CustomPaint(
            painter: SchematicCircuitWirePainter(
              isClosed: _m1MotorInserted,
              animationValue: 0.5,
              wireColor: const Color(0xFF1E293B),
            ),
          ),
        ),

        // Fonte CC / Bateria Esquemática (Esquerda)
        const Positioned(
          left: 40,
          top: 100,
          child: Column(
            children: [
              SchematicBatteryWidget(size: 60, color: Color(0xFF0284C7)),
              SizedBox(height: 6),
              Text(
                'FONTE 6.0V CC',
                style: TextStyle(color: Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Motor CC com Hélice Animada (Centro Topo Visual)
        Positioned(
          left: 0,
          right: 0,
          top: 20,
          child: Center(
            child: _buildAnimatedMotorWidget(
              isRunning: _m1MotorInserted,
              isReversed: false,
            ),
          ),
        ),

        // Socket Esquemático para Arrastar o Motor CC (Direita / Linha)
        Positioned(
          right: 60,
          top: 95,
          child: SchematicBlueprintSocket<String>(
            expectedData: 'motor_cc',
            isFilled: _m1MotorInserted,
            symbolWidget: SchematicMotorWidget(
              size: 50,
              color: const Color(0xFF0284C7),
              isRunning: _m1MotorInserted,
            ),
            placeholderWidget: const SchematicMotorWidget(
              size: 45,
              color: Color(0xFF94A3B8),
              isRunning: false,
            ),
            label: 'MOTOR CC',
            onAccept: (_) {
              setState(() {
                _m1MotorInserted = true;
              });
            },
            onTap: () {
              setState(() {
                _m1MotorInserted = !_m1MotorInserted;
              });
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MISSÃO 2: Inversão de Sentido de Rotação
  // ==========================================
  Widget _buildM2UI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedMotorWidget(
            isRunning: true,
            isReversed: _m2ReversedPolarity,
          ),
          const SizedBox(height: 20),
          Text(
            _m2ReversedPolarity
                ? 'Sentido de Rotação: ANTI-HORÁRIO ↺ (Polaridade Invertida -/+)'
                : 'Sentido de Rotação: HORÁRIO ↻ (Polaridade Padrão +/-)',
            style: GoogleFonts.rajdhani(
              color: _m2ReversedPolarity ? const Color(0xFF0284C7) : const Color(0xFFD97706),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              side: BorderSide(
                color: _m2ReversedPolarity ? const Color(0xFF0284C7) : const Color(0xFFD97706),
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            icon: const Icon(Icons.sync_alt_rounded, color: Color(0xFF0284C7)),
            label: Text(
              _m2ReversedPolarity
                ? 'Polaridade Atual: Polo (-) → Polo (+)'
                : 'Inverter Polaridade da Fonte (+/- ➔ -/+)',
              style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 15),
            ),
            onPressed: () {
              setState(() {
                _m2ReversedPolarity = !_m2ReversedPolarity;
              });
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MISSÃO 3: Botão de Partida do Motor
  // ==========================================
  Widget _buildM3UI() {
    final isMotorSpinning = _m3PushButtonInserted && _m3PushButtonPressed;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedMotorWidget(
            isRunning: isMotorSpinning,
            isReversed: false,
          ),
          const SizedBox(height: 20),
          DragTarget<String>(
            onWillAcceptWithDetails: (details) => details.data == 'push_button',
            onAcceptWithDetails: (_) {
              setState(() {
                _m3PushButtonInserted = true;
              });
            },
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              return InkWell(
                onTap: () {
                  setState(() {
                    _m3PushButtonInserted = !_m3PushButtonInserted;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _m3PushButtonInserted
                          ? const Color(0xFF0284C7)
                          : isHovering
                              ? const Color(0xFF0284C7)
                              : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _m3PushButtonInserted ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                        color: _m3PushButtonInserted ? const Color(0xFF0284C7) : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _m3PushButtonInserted
                            ? 'Push-Button Instalado no Circuito'
                            : '➕ Encaixar Interruptor Push-Button',
                        style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (_m3PushButtonInserted)
            GestureDetector(
              onTapDown: (_) => setState(() => _m3PushButtonPressed = true),
              onTapUp: (_) => setState(() => _m3PushButtonPressed = false),
              onTapCancel: () => setState(() => _m3PushButtonPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: _m3PushButtonPressed ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_m3PushButtonPressed ? const Color(0xFF0284C7) : const Color(0xFF0F172A)).withValues(alpha: 0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_m3PushButtonPressed ? Icons.play_arrow_rounded : Icons.radio_button_checked_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      _m3PushButtonPressed ? 'MOTOR EM PARTIDA! (PRESSIONADO)' : 'SEGURE PARA ACIONAR O MOTOR',
                      style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // MISSÃO 4: Painel com LED Indicador
  // ==========================================
  Widget _buildM4UI() {
    final isSystemReady = _m4LedInserted && _m4ResistorInserted;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedMotorWidget(
                isRunning: isSystemReady,
                isReversed: false,
              ),
              const SizedBox(width: 40),
              // LED Indicador em Paralelo
              Column(
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    size: 48,
                    color: isSystemReady ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isSystemReady ? 'LED STATUS: ON 🟢' : 'LED STATUS: OFF 🔴',
                    style: GoogleFonts.rajdhani(
                      color: isSystemReady ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Slot 1: LED Indicador
              DragTarget<String>(
                onWillAcceptWithDetails: (details) => details.data == 'led_indicator',
                onAcceptWithDetails: (_) => setState(() => _m4LedInserted = true),
                builder: (context, candidateData, rejectedData) {
                  return InkWell(
                    onTap: () => setState(() => _m4LedInserted = !_m4LedInserted),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _m4LedInserted ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          Icon(_m4LedInserted ? Icons.check_circle_rounded : Icons.add_box_rounded, color: _m4LedInserted ? const Color(0xFF0284C7) : const Color(0xFFD97706)),
                          const SizedBox(width: 8),
                          Text(
                            _m4LedInserted ? 'LED Indicador OK' : '➕ LED no Ramo Paralelo',
                            style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              // Slot 2: Resistor 680Ω
              DragTarget<String>(
                onWillAcceptWithDetails: (details) => details.data == 'resistor_680',
                onAcceptWithDetails: (_) => setState(() => _m4ResistorInserted = true),
                builder: (context, candidateData, rejectedData) {
                  return InkWell(
                    onTap: () => setState(() => _m4ResistorInserted = !_m4ResistorInserted),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _m4ResistorInserted ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          Icon(_m4ResistorInserted ? Icons.check_circle_rounded : Icons.add_box_rounded, color: _m4ResistorInserted ? const Color(0xFF0284C7) : const Color(0xFFD97706)),
                          const SizedBox(width: 8),
                          Text(
                            _m4ResistorInserted ? 'Resistor 680Ω OK' : '➕ Resistor de Proteção',
                            style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MISSÃO 5: Diagnóstico do Mini Carrinho
  // ==========================================
  Widget _buildM5UI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visualização do Carrinho com Motor
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car_filled_rounded, size: 72, color: Color(0xFF0284C7)),
              const SizedBox(width: 20),
              _buildAnimatedMotorWidget(
                isRunning: _m5WireRepaired && _m5CarTested,
                isReversed: false,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _m5WireRepaired ? const Color(0xFF0284C7) : const Color(0xFFD97706)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _m5WireRepaired ? Icons.build_circle_rounded : Icons.warning_amber_rounded,
                  color: _m5WireRepaired ? const Color(0xFF0284C7) : const Color(0xFFD97706),
                ),
                const SizedBox(width: 10),
                Text(
                  _m5WireRepaired
                      ? 'Fiação Reparada: Mau contato corrigido no terminal!'
                      : 'Diagnóstico: Fio do terminal positivo solto (Mau Contato)',
                  style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  side: BorderSide(color: _m5WireRepaired ? const Color(0xFF0284C7) : const Color(0xFFD97706)),
                ),
                icon: const Icon(Icons.handyman_rounded, color: Color(0xFFD97706)),
                label: Text(
                  _m5WireRepaired ? 'Terminal Reparado (Soldado)' : 'Reparar Mau Contato no Terminal',
                  style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  setState(() {
                    _m5WireRepaired = !_m5WireRepaired;
                  });
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: Text(
                  'Testar Carrinho',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  setState(() {
                    _m5CarTested = true;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Widget Animado do Motor CC ---
  Widget _buildAnimatedMotorWidget({required bool isRunning, required bool isReversed}) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _fanController,
          builder: (context, child) {
            final angle = isRunning
                ? _fanController.value * 2 * math.pi * (isReversed ? -1 : 1)
                : 0.0;
            return Transform.rotate(
              angle: angle,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRunning ? const Color(0xFF10B981).withValues(alpha: 0.2) : const Color(0xFF1E293B),
                  border: Border.all(
                    color: isRunning ? const Color(0xFF10B981) : Colors.white24,
                    width: 3,
                  ),
                  boxShadow: isRunning
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.5),
                            blurRadius: 16,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.autorenew_rounded, size: 64, color: Colors.white),
                    const Icon(Icons.brightness_5_rounded, size: 24, color: Colors.amber),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          isRunning ? 'MOTOR CC EM OPERAÇÃO ⚡' : 'MOTOR CC DESLIGADO ⚪',
          style: GoogleFonts.rajdhani(
            color: isRunning ? const Color(0xFF0284C7) : const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSideControlPanel() {
    return WorkbenchSidePanel(
      teamTitle: 'Painel da Equipe Mecânica',
      toolboxItems: [
        _buildSideToolboxDrawer(),
      ],
      onEnergizePressed: _validateCurrentMission,
    );
  }

  Widget _buildSideToolboxDrawer() {
    return const Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        WorkbenchSymbolToolboxTile<String>(
          data: 'motor_cc',
          label: 'Motor CC',
          tooltip: 'Motor CC',
          symbolWidget: SchematicMotorWidget(size: 34, color: Color(0xFF0284C7), isRunning: true),
          color: Color(0xFF0284C7),
        ),
        WorkbenchSymbolToolboxTile<String>(
          data: 'push_button',
          label: 'Botão',
          tooltip: 'Push-Button',
          symbolWidget: SchematicSwitchWidget(size: 34, color: Color(0xFFD97706), isClosed: false),
          color: Color(0xFFD97706),
        ),
        WorkbenchSymbolToolboxTile<String>(
          data: 'led_indicator',
          label: 'LED',
          tooltip: 'LED Indicador',
          symbolWidget: SchematicLedWidget(size: 34, color: Colors.redAccent, isOn: true),
          color: Colors.redAccent,
        ),
        WorkbenchSymbolToolboxTile<String>(
          data: 'resistor_680',
          label: 'Resistor',
          tooltip: 'Resistor (680Ω)',
          symbolWidget: SchematicResistorWidget(size: 34, color: Color(0xFFD97706)),
          color: Color(0xFFD97706),
        ),
      ],
    );
  }
}
