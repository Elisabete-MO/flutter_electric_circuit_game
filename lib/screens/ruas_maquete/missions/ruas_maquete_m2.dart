import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../models/first_step_component.dart';
import '../../../models/stand_mission.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/physical_blueprint_socket.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/schematic_blueprint_socket.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/ruas_maquete_painter.dart';
import '../widgets/ruas_maquete_widgets.dart';

/// Missão 2 do Estande 04 — Comparação de Brilho (1 vs 2 Lâmpadas em Série).
class RuasMaqueteM2 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const RuasMaqueteM2({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<RuasMaqueteM2> createState() => _RuasMaqueteM2State();
}

class _RuasMaqueteM2State extends State<RuasMaqueteM2>
    with SingleTickerProviderStateMixin {
  final StandMission _mission = StandMission.ruasMaqueteMissions[1];
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  late AnimationController _electronAnimController;
  bool _usePhysicalStyle = true;

  bool _m2IsSeriesTwoBulbs = false;
  String? _m2SelectedExplanation;
  double _m2SecondaryBulbRotation = 0.0;

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

  void _validate() {
    bool isSuccess = false;
    String feedbackMessage = _mission.failureFeedback;

    if (_m2SelectedExplanation == 'corrente_reduzida') {
      isSuccess = true;
    } else if (_m2SelectedExplanation == null) {
      feedbackMessage =
          'Selecione a explicação física sobre o motivo do brilho atenuado em série.';
    } else {
      feedbackMessage =
          'Pense bem: no circuito em série, adicionar mais resistências reduz a corrente total.';
    }

    final fullMessage = isSuccess
        ? 'Missão "${_mission.title}" concluída com êxito! ${_mission.victoryCriteria}.\n\nProf. Volts: "${_mission.voltsMediation}"'
        : '$feedbackMessage\n\nProf. Volts: "${_mission.voltsMediation}"';

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
              _m2IsSeriesTwoBulbs ? 45.0 : 90.0,
              true,
            ),
            bottomWidget: _buildUndoRedoButtons(),
            child: LayoutBuilder(
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
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _electronAnimController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: RuasMaquetePainter(
                              missionIndex: 1,
                              animValue: _electronAnimController.value,
                              m1Connected: true,
                              m2Series: _m2IsSeriesTwoBulbs,
                              m3Junction: false,
                              m3Return: false,
                              m4Parallel: false,
                              m5House1Broken: false,
                              usePhysicalStyle: _usePhysicalStyle,
                              lampY: lampY,
                              socketY: socketY,
                              lamp1X: lamp1X,
                              lamp2X: lamp2X,
                              socketX: socketX,
                              socketRotation: 0.0,
                            ),
                          );
                        },
                      ),
                    ),
                    ..._buildOverlayElements(
                      lamp1X: lamp1X,
                      lamp2X: lamp2X,
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
        // Painel Lateral (Briefing & Investigação)
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
    required double lamp1X,
    required double lamp2X,
    required double socketX,
    required double lampY,
    required double socketY,
  }) {
    return [
      Positioned(
        left: lamp1X - 40,
        top: lampY - 30,
        child: buildRuasMaqueteLampSymbol(
          isLit: true,
          brightnessRatio: _m2IsSeriesTwoBulbs ? 0.5 : 1.0,
          usePhysicalStyle: _usePhysicalStyle,
        ),
      ),
      Positioned(
        left: lamp1X - 75,
        top: lampY + 34,
        width: 150,
        child: Center(
          child: buildRuasMaqueteLabelBadge(
            'Poste Principal (${_m2IsSeriesTwoBulbs ? "50%" : "100%"})',
          ),
        ),
      ),
      Positioned(
        left: lamp2X - 40,
        top: lampY - 32,
        child: buildRuasMaqueteSocketTile(
          width: 80,
          height: 60,
          expectedData: 'bulb',
          isFilled: _m2IsSeriesTwoBulbs,
          symbolType: ComponentType.bulb,
          label: 'Poste Secundário',
          brightnessRatio: 0.5,
          usePhysicalStyle: _usePhysicalStyle,
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
          left: lamp2X - 75,
          top: lampY + 38,
          width: 150,
          child: Center(
            child: buildRuasMaqueteLabelBadge('Poste 2 em Série (50%)'),
          ),
        ),
      Positioned(
        left: socketX - 40,
        top: socketY - 32,
        child: _buildBatteryWidget(),
      ),
    ];
  }

  Widget _buildBatteryWidget() {
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
              isActive: true,
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
            isActive: true,
          )
        : SchematicComponentCard(
            symbolWidget: symbolWidget,
            label: 'Bateria 4.5V',
            isActive: true,
          );
  }

  Widget _buildSideTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pergunta de Investigação Física:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFFD97706),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Por que o brilho dos dois postes diminuiu ao ligá-los no mesmo caminho em série?',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildExplanationOption(
          id: 'corrente_reduzida',
          text:
              'Porque a corrente elétrica encontrou duas resistências na mesma rota, reduzindo a corrente disponível para cada lâmpada.',
        ),
        _buildExplanationOption(
          id: 'bateria_esgotada',
          text:
              'Porque a bateria perdeu toda a sua energia instantaneamente ao acender o segundo poste.',
        ),
        _buildExplanationOption(
          id: 'mais_energia',
          text:
              'Porque ligar postes em série gera mais energia do que a fonte original fornece.',
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
            color: isSelected
                ? const Color(0xFF0284C7)
                : const Color(0xFFCBD5E1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFF0284C7)
                  : const Color(0xFF94A3B8),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.rajdhani(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF475569),
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
                  'Missão 2: ${_mission.title}',
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
