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

/// Missão 03 — Fusível Didático: Escolha de capacidade e proteção por fusível
class CircuitoSeguroM3 extends StatefulWidget {
  final VoidCallback onMissionComplete;

  const CircuitoSeguroM3({
    super.key,
    required this.onMissionComplete,
  });

  @override
  State<CircuitoSeguroM3> createState() => _CircuitoSeguroM3State();
}

class _CircuitoSeguroM3State extends State<CircuitoSeguroM3>
    with SingleTickerProviderStateMixin {
  late final AnimationController _electronAnimController;
  final CircuitUndoRedoController _undoRedoController =
      CircuitUndoRedoController();

  bool _usePhysicalStyle = true;
  bool _isFuseInserted = true;
  bool _isFuseBlown = true; // Inicia com o fusível queimado
  int _selectedRatingIndex = 0; // 0 = 100mA (Correto), 1 = 1A (Sobredimensionado)

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

  bool get _isProtectedAndWorking =>
      _isFuseInserted && !_isFuseBlown && _selectedRatingIndex == 0;

  void _replaceFuse(int ratingIndex) {
    final prevRating = _selectedRatingIndex;
    final prevInserted = _isFuseInserted;
    final prevBlown = _isFuseBlown;

    _undoRedoController.execute(
      SelectOptionAction(
        description: 'Instalar Fusível ${ratingIndex == 0 ? "100mA" : "1A"}',
        onApply: () => setState(() {
          _selectedRatingIndex = ratingIndex;
          _isFuseInserted = true;
          _isFuseBlown = false;
        }),
        onUndo: () => setState(() {
          _selectedRatingIndex = prevRating;
          _isFuseInserted = prevInserted;
          _isFuseBlown = prevBlown;
        }),
      ),
    );
  }

  void _validate() {
    final isSuccess = _isProtectedAndWorking;
    String message;
    if (_isFuseBlown) {
      message = 'O fusível atual está com o filamento queimado. Substitua por um novo fusível íntegro!';
    } else if (_selectedRatingIndex != 0) {
      message = 'Atenção: Um fusível de 1A é muito alto para proteger este LED (15mA). Instale o fusível de 100mA adequado!';
    } else {
      message = 'Excelente! O fusível de 100mA protege perfeitamente o LED contra sobrecorrente sem abrir desnecessariamente!';
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
    final statusState = _isFuseBlown
        ? CircuitoSeguroState.fuseBlown
        : (_isProtectedAndWorking ? CircuitoSeguroState.safe : CircuitoSeguroState.inactive);

    final voltage = _isProtectedAndWorking ? 9.0 : 0.0;
    final current = _isProtectedAndWorking ? 13.0 : 0.0;

    return Row(
      children: [
        // 1. Bancada Principal
        Expanded(
          flex: 7,
          child: WorkbenchTableFrame(
            usePhysicalStyle: _usePhysicalStyle,
            onStyleChanged: (val) => setState(() => _usePhysicalStyle = val),
            leftHeaderWidget: CircuitoSeguroStatusCard(state: statusState),
            rightHeaderWidget: CircuitoSeguroTelemetryCard(
              voltage: voltage,
              currentMa: current,
              isSafe: _isProtectedAndWorking,
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
                    missionIndex: 2,
                    animValue: _electronAnimController.value,
                    usePhysicalStyle: _usePhysicalStyle,
                    isArmingSwitchClosed: true,
                    isShortCircuitActive: false,
                    isWireBroken: false,
                    isWireRepaired: true,
                    isFuseInserted: _isFuseInserted,
                    isFuseBlown: _isFuseBlown,
                    isFuseCorrectRating: _selectedRatingIndex == 0,
                    isLedInserted: true,
                    isResistorInserted: true,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 2. Painel Lateral
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
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
        ),
      ],
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
            'Missão 3 · Fusível Didático',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Inspecione o filamento do tubo de vidro e instale o fusível de 100mA de proteção adequada para proteger a carga.',
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
            'Checklist de Investigação:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildStepRow(1, 'Inspecionar filamento de vidro fundido', _isFuseInserted),
          _buildStepRow(2, 'Substituir por fusível novo e íntegro', !_isFuseBlown),
          _buildStepRow(3, 'Selecionar capacidade adequada (100mA)', _selectedRatingIndex == 0 && !_isFuseBlown),
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
        Text(
          'Gaveta de Fusíveis de Vidro:',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: (!_isFuseBlown && _selectedRatingIndex == 0)
                ? const Color(0xFF10B981)
                : const Color(0xFF0F172A),
            side: const BorderSide(color: Color(0xFF10B981)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _replaceFuse(0),
          icon: const Icon(Icons.bolt_rounded, color: Color(0xFF10B981)),
          label: Text(
            'Fusível Rápido 100mA (Recomendado)',
            style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: (!_isFuseBlown && _selectedRatingIndex == 1)
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF475569),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _replaceFuse(1),
          icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
          label: Text(
            'Fusível Industrial 1A (Sobredimensionado)',
            style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ),
      ],
    );
  }
}
