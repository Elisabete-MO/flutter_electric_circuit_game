import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/circuit_action.dart';
import '../../../state/circuit_undo_redo_controller.dart';
import '../../../widgets/prof_volts_feedback_dialog.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/circuito_seguro_painter.dart';
import '../widgets/circuito_seguro_widgets.dart';

/// Missão 05 — Vistoria Geral da Equipe: Checklist pré-feira com 3 falhas simultâneas
class CircuitoSeguroM5 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const CircuitoSeguroM5({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<CircuitoSeguroM5> createState() => _CircuitoSeguroM5State();
}

class _CircuitoSeguroM5State extends State<CircuitoSeguroM5>
    with SingleTickerProviderStateMixin {
  late final AnimationController _electronAnimController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _shortCircuitPresent = true;
  bool _fuseBlown = true;
  bool _wireBroken = true;
  bool _wireRepaired = false;
  bool _switchArmed = true;

  @override
  void initState() {
    super.initState();
    _electronAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _electronAnimController.dispose();
    super.dispose();
  }

  bool get _isAuditedAndSafe =>
      !_shortCircuitPresent && !_fuseBlown && _wireRepaired && _switchArmed;

  void _toggleShort() {
    final prev = _shortCircuitPresent;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Eliminar Curto-Circuito' : 'Inserir Curto',
        onApply: () => setState(() => _shortCircuitPresent = !prev),
        onUndo: () => setState(() => _shortCircuitPresent = prev),
      ),
    );
  }

  void _replaceFuse() {
    final prev = _fuseBlown;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Substituir Fusível Fundido' : 'Fundir Fusível',
        onApply: () => setState(() => _fuseBlown = !prev),
        onUndo: () => setState(() => _fuseBlown = prev),
      ),
    );
  }

  void _repairWire() {
    final prev = _wireRepaired;
    _undoRedoController.execute(
      ToggleBoolAction(
        description: prev ? 'Desconectar Cabo' : 'Reparar Cabo Rompido',
        onApply: () => setState(() => _wireRepaired = !prev),
        onUndo: () => setState(() => _wireRepaired = prev),
      ),
    );
  }

  void _validate() {
    final isSuccess = _isAuditedAndSafe;
    String message;
    if (_shortCircuitPresent) {
      message = 'Atenção: Ainda há um fio de curto causando sobrecarga perigosa na bateria!';
    } else if (_wireBroken && !_wireRepaired) {
      message = 'Circuito Aberto: O cabo rompido precisa ser reparado para dar continuidade!';
    } else if (_fuseBlown) {
      message = 'Fusível Queimado: Substitua o fusível danificado por um novo íntegro!';
    } else {
      message = 'Parabéns Equipe Segurança! Todas as 3 falhas foram sanadas com rigor técnico. A bancada do Estande 08 está certificada e pronta para os visitantes da feira!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isSuccess,
        message: message,
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
    CircuitoSeguroState statusState;
    if (_shortCircuitPresent) {
      statusState = CircuitoSeguroState.shortCircuit;
    } else if (_fuseBlown) {
      statusState = CircuitoSeguroState.fuseBlown;
    } else if (!_wireRepaired) {
      statusState = CircuitoSeguroState.openCircuit;
    } else {
      statusState = CircuitoSeguroState.safe;
    }

    final voltage = _isAuditedAndSafe ? 9.0 : (_shortCircuitPresent ? 1.2 : 0.0);
    final current = _isAuditedAndSafe ? 13.0 : (_shortCircuitPresent ? 450.0 : 0.0);

    return WorkbenchResponsiveLayout(
      workbench: WorkbenchTableFrame(
        usePhysicalStyle: _usePhysicalStyle,
        onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
        leftHeaderWidget: CircuitoSeguroStatusCard(state: statusState),
        rightHeaderWidget: CircuitoSeguroTelemetryCard(
          voltage: voltage,
          currentMa: current,
          isSafe: _isAuditedAndSafe,
        ),
        bottomWidget: CircuitoSeguroUndoRedoButtons(
          controller: _undoRedoController,
          onUndo: () => setState(() => _undoRedoController.undo()),
          onRedo: () => setState(() => _undoRedoController.redo()),
        ),
        child: AnimatedBuilder(
          animation: _electronAnimController,
          builder: (context, child) {
            return CustomPaint(
              painter: CircuitoSeguroPainter(
                missionIndex: 4,
                animValue: _electronAnimController.value,
                usePhysicalStyle: _usePhysicalStyle,
                isArmingSwitchClosed: _switchArmed,
                isShortCircuitActive: _shortCircuitPresent,
                isWireBroken: _wireBroken,
                isWireRepaired: _wireRepaired,
                isFuseInserted: true,
                isFuseBlown: _fuseBlown,
                isFuseCorrectRating: true,
                isLedInserted: true,
                isResistorInserted: true,
                isBuzzerActive: _isAuditedAndSafe,
              ),
            );
          },
        ),
      ),
      sidePanel: WorkbenchSidePanel(
        teamTitle: 'Equipe Segurança',
        showTeamHeader: false,
        buttonColor: const Color(0xFF10B981),
        toolboxItems: [
          _buildObjectiveCard(),
          const SizedBox(height: 12),
          _buildInvestigationStepper(),
          const SizedBox(height: 12),
          _buildToolboxControls(),
        ],
        onEnergizePressed: _validate,
      ),
    );
  }

  Widget _buildObjectiveCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Missão 5 · Vistoria Geral da Equipe',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Audite a montagem pré-feira, resolva as 3 não-conformidades de segurança e certifique a bancada.',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF94A3B8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigationStepper() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checklist de Vistoria da Feira:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, '1. Eliminar desvio de curto-circuito', !_shortCircuitPresent),
          _buildStepRow(2, '2. Substituir fusível fundido por íntegro', !_fuseBlown),
          _buildStepRow(3, '3. Reparar cabo partido e energizar', _isAuditedAndSafe),
        ],
      ),
    );
  }

  Widget _buildStepRow(int step, String label, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isDone ? const Color(0xFF10B981) : const Color(0xFF64748B),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                color: isDone ? Colors.white : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolboxControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _shortCircuitPresent
                ? const Color(0xFFEF4444)
                : const Color(0xFF1E293B),
            side: BorderSide(
              color: _shortCircuitPresent ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _toggleShort,
          icon: Icon(
            _shortCircuitPresent ? Icons.warning_amber_rounded : Icons.check_rounded,
            color: _shortCircuitPresent ? Colors.white : const Color(0xFF10B981),
          ),
          label: Text(
            _shortCircuitPresent ? '1. Remover Curto-Circuito' : '1. Curto Sanado (OK)',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _fuseBlown
                ? const Color(0xFFD97706)
                : const Color(0xFF1E293B),
            side: BorderSide(
              color: _fuseBlown ? const Color(0xFFD97706) : const Color(0xFF10B981),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _replaceFuse,
          icon: Icon(
            _fuseBlown ? Icons.bolt_rounded : Icons.check_rounded,
            color: _fuseBlown ? Colors.white : const Color(0xFF10B981),
          ),
          label: Text(
            _fuseBlown ? '2. Trocar Fusível Fundido' : '2. Fusível Íntegro 100mA (OK)',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: !_wireRepaired
                ? const Color(0xFF0284C7)
                : const Color(0xFF1E293B),
            side: BorderSide(
              color: !_wireRepaired ? const Color(0xFF0284C7) : const Color(0xFF10B981),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _repairWire,
          icon: Icon(
            !_wireRepaired ? Icons.build_rounded : Icons.check_rounded,
            color: !_wireRepaired ? Colors.white : const Color(0xFF10B981),
          ),
          label: Text(
            !_wireRepaired ? '3. Reparar Cabo Rompido' : '3. Cabo Contínuo (OK)',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
