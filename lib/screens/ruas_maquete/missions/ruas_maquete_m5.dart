import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../services/circuit_solver/mission_circuit_builder.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/ruas_maquete_painter.dart';
import '../widgets/ruas_maquete_widgets.dart';

/// Missão 5 do Estande 04 — Teste de Manutenção e Independência dos Ramos em Paralelo.
class RuasMaqueteM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const RuasMaqueteM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<RuasMaqueteM5> createState() => _RuasMaqueteM5State();
}

class _RuasMaqueteM5State extends State<RuasMaqueteM5>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.ruasMaqueteMissions[4];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;
  bool _isSimulating = false;

  bool _m5House1Broken = false;
  bool _m5MaintenanceConfirmed = false;
  double _m5House1Rotation = 0.0;
  double _m5MaintenanceRotation = 0.0;

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

  Future<void> _validate() async {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    try {
      bool isSuccess = false;
      String feedbackMessage = _mission.failureFeedback;

      if (_m5House1Broken && _m5MaintenanceConfirmed) {
        final result = await MissionCircuitBuilder()
            .addBattery(id: 'bat1', voltage: 4.5)
            .addBulb(id: 'bulbB', resistance: 5.0)
            .connect('bat1', 'B', 'bulbB', 'A')
            .connect('bulbB', 'B', 'bat1', 'A')
            .simulate();
        if (result.hasClosedLoop && result.errorMessage == null) {
          feedbackMessage =
              'Manutenção validada! A Lâmpada B permanece acesa mesmo com a Lâmpada A desconectada. '
              'Em paralelo, os ramos são independentes.';
          isSuccess = true;
        } else {
          feedbackMessage =
              result.errorMessage ?? 'Erro na simulação do circuito.';
        }
      } else if (!_m5House1Broken) {
        feedbackMessage =
            'Simule o defeito na Lâmpada A para testar a independência do circuito!';
      } else {
        feedbackMessage =
            'Confirme o resultado da manutenção ao observar que a Lâmpada B permanece acesa.';
      }

      final fullMessage = isSuccess
          ? 'Missão "${_mission.title}" concluída com êxito! ${_mission.victoryCriteria}.\n\nProf. Volts: "${_mission.voltsMediation}"'
          : '$feedbackMessage\n\nProf. Volts: "${_mission.voltsMediation}"';

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
                widget.onMissionComplete();
              }
            },
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Área Principal da Bancada
        Expanded(
          flex: 7,
          child: WorkbenchTableFrame(
            usePhysicalStyle: _usePhysicalStyle,
            onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
            leftHeaderWidget: buildRuasMaqueteStatusCard(true),
            rightHeaderWidget: buildRuasMaqueteTelemetryCard(
              4.5,
              _m5House1Broken ? 135.0 : 180.0,
              true,
            ),
            bottomWidget: _buildUndoRedoButtons(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final lampY = h * 0.28;
                final socketY = h * 0.80;
                final socketX = w * 0.50;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _electronAnimController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: RuasMaquetePainter(
                              missionIndex: 4,
                              animValue: _electronAnimController.value,
                              m1Connected: false,
                              m2Series: false,
                              m3Junction: false,
                              m3Return: false,
                              m4Parallel: true,
                              m5House1Broken: _m5House1Broken,
                              usePhysicalStyle: _usePhysicalStyle,
                              lampY: lampY,
                              socketY: socketY,
                              lamp1X: w * 0.34,
                              lamp2X: w * 0.66,
                              socketX: socketX,
                              socketRotation: _m5House1Rotation,
                            ),
                          );
                        },
                      ),
                    ),
                    ..._buildOverlayElements(
                      socketX: socketX,
                      lampY: lampY,
                      socketY: socketY,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Painel Lateral (Briefing & Conclusão)
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Painel da Equipe Bairro',
            toolboxItems: [
              _buildMissionBriefingCard(),
              _buildSideTools(),
            ],
            onEnergizePressed: _validate,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildOverlayElements({
    required double socketX,
    required double lampY,
    required double socketY,
  }) {
    return [
      LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final x1 = w * 0.18;
          final x2 = w * 0.38;
          final x3 = w * 0.62;
          final x4 = w * 0.82;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Poste 1 (Permanecendo Aceso)
              Positioned(
                left: x1 - 40,
                top: lampY - 30,
                child: buildRuasMaqueteLampSymbol(
                  isLit: true,
                  brightnessRatio: 1.0,
                  usePhysicalStyle: _usePhysicalStyle,
                ),
              ),
              Positioned(
                left: x1 - 65,
                top: lampY + 34,
                width: 130,
                child: Center(child: buildRuasMaqueteLabelBadge('Poste 1')),
              ),

              // Soquete / Casa 01 (Em Manutenção / Simulada)
              Positioned(
                left: x2 - 40,
                top: lampY - 32,
                child: buildRuasMaqueteSocketTile(
                  width: 80,
                  height: 60,
                  expectedData: 'bulb',
                  isFilled: !_m5House1Broken,
                  symbolType: ComponentType.bulb,
                  label: 'Casa 01',
                  usePhysicalStyle: _usePhysicalStyle,
                  rotation: _m5House1Rotation,
                  onRotate: () => _rotateComponent(
                    name: 'Casa 01',
                    getRotation: () => _m5House1Rotation,
                    setRotation: (v) => _m5House1Rotation = v,
                  ),
                  onAccept: () => _insertComponent(
                    name: 'Casa 01',
                    getInserted: () => !_m5House1Broken,
                    setInserted: (v) => _m5House1Broken = !v,
                    getRotation: () => _m5House1Rotation,
                    setRotation: (v) => _m5House1Rotation = v,
                  ),
                  onTap: () => _insertComponent(
                    name: 'Casa 01',
                    getInserted: () => !_m5House1Broken,
                    setInserted: (v) => _m5House1Broken = !v,
                    getRotation: () => _m5House1Rotation,
                    setRotation: (v) => _m5House1Rotation = v,
                  ),
                ),
              ),
              Positioned(
                left: x2 - 65,
                top: lampY + 38,
                width: 130,
                child: Center(
                  child: buildRuasMaqueteLabelBadge(
                    'Casa 01',
                    isBroken: _m5House1Broken,
                  ),
                ),
              ),

              // Casa 02 (Permanecendo Acesa)
              Positioned(
                left: x3 - 40,
                top: lampY - 30,
                child: buildRuasMaqueteHouseSymbol(
                  name: 'Casa 02 (Praça)',
                  isLit: true,
                  brightness: 1.0,
                  usePhysicalStyle: _usePhysicalStyle,
                ),
              ),
              Positioned(
                left: x3 - 65,
                top: lampY + 34,
                width: 130,
                child: Center(child: buildRuasMaqueteLabelBadge('Casa 02')),
              ),

              // Poste 2 (Permanecendo Aceso)
              Positioned(
                left: x4 - 40,
                top: lampY - 30,
                child: buildRuasMaqueteLampSymbol(
                  isLit: true,
                  brightnessRatio: 1.0,
                  usePhysicalStyle: _usePhysicalStyle,
                ),
              ),
              Positioned(
                left: x4 - 65,
                top: lampY + 34,
                width: 130,
                child: Center(child: buildRuasMaqueteLabelBadge('Poste 2')),
              ),

              // Soquete do Conector de Manutenção
              Positioned(
                left: socketX - 40,
                top: socketY - 32,
                child: buildRuasMaqueteSocketTile(
                  width: 80,
                  height: 60,
                  expectedData: 'fio_serie',
                  isFilled: _m5MaintenanceConfirmed,
                  symbolType: ComponentType.connectingWire,
                  label: 'Manutenção',
                  usePhysicalStyle: _usePhysicalStyle,
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
            ],
          );
        },
      ),
    ];
  }

  Widget _buildSideTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conclusão da Equipe Bairro:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFD97706),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Em paralelo, quando a Lâmpada A se queima ou é removida, a Lâmpada B continua recebendo corrente em seu ramo independente. É por isso que as casas da cidade usam ligação em paralelo!',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF475569),
            fontSize: 14,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildUndoRedoButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            tooltip: 'Desfazer ação',
            color: _undoRedoController.canUndo
                ? const Color(0xFF0F172A)
                : const Color(0xFFCBD5E1),
            onPressed: _undoRedoController.canUndo
                ? () => _undoRedoController.undo()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 20),
            tooltip: 'Refazer ação',
            color: _undoRedoController.canRedo
                ? const Color(0xFF0F172A)
                : const Color(0xFFCBD5E1),
            onPressed: _undoRedoController.canRedo
                ? () => _undoRedoController.redo()
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionBriefingCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt_rounded,
                  color: Color(0xFF0284C7), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Missão 5: ${_mission.title}',
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
            _mission.objective,
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
                    'Prof. Volts: "${_mission.voltsMediation}"',
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
}
