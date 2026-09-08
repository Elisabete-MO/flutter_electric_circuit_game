import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/ui_scale.dart';
import 'prof_volts_full_body.dart';
import 'glass_container.dart';

/// Dialog de previsão obrigatória antes de energizar o circuito.
/// Exibe pergunta contextual + opções de ChoiceChip + botão registrar.
class ProfVoltsPredictionDialog extends StatefulWidget {
  const ProfVoltsPredictionDialog({
    super.key,
    required this.question,
    required this.options,
    required this.onPredict,
  });

  final String question;
  final List<String> options;
  final ValueChanged<String> onPredict;

  @override
  State<ProfVoltsPredictionDialog> createState() =>
      _ProfVoltsPredictionDialogState();
}

class _ProfVoltsPredictionDialogState extends State<ProfVoltsPredictionDialog> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFD97706);
    final scale = context.uiScale;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: scale.insetsSymmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: scale.dialogWidth(480)),
        child: GlassContainer(
          borderRadius: scale.size(24),
          accentColor: accentColor,
          opacity: 0.92,
          padding: scale.insetsAll(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfVoltsFullBody(
                  emotion: ProfVoltsEmotion.neutral,
                  size: scale.size(130),
                ),
                SizedBox(height: scale.spacing(14)),
                Container(
                  padding: scale.insetsSymmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(scale.size(8)),
                    border:
                        Border.all(color: accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'PREVISÃO OBRIGATÓRIA',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      fontSize: scale.font(14),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: scale.spacing(16)),
                Text(
                  widget.question,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: scale.font(15),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: scale.spacing(20)),
                Wrap(
                  spacing: scale.spacing(8),
                  runSpacing: scale.spacing(8),
                  alignment: WrapAlignment.center,
                  children: widget.options.map((opt) {
                    final isSelected = _selected == opt;
                    return ChoiceChip(
                      label: Text(
                        opt,
                        style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.bold,
                          fontSize: scale.font(13),
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: accentColor,
                      backgroundColor: const Color(0xFF1E293B),
                      side: BorderSide(
                        color: isSelected
                            ? accentColor
                            : Colors.white24,
                      ),
                      onSelected: (val) =>
                          setState(() => _selected = val ? opt : null),
                    );
                  }).toList(),
                ),
                SizedBox(height: scale.spacing(24)),
                SizedBox(
                  width: double.infinity,
                  height: scale.size(48),
                  child: FilledButton.icon(
                    onPressed: _selected == null
                        ? null
                        : () => widget.onPredict(_selected!),
                    style: FilledButton.styleFrom(
                      backgroundColor: _selected == null
                          ? const Color(0xFF475569)
                          : accentColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF475569),
                      disabledForegroundColor: Colors.white38,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(scale.size(14)),
                      ),
                      textStyle: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: scale.font(16),
                      ),
                    ),
                    icon: Icon(Icons.psychology_rounded, size: scale.icon(20)),
                    label: const Text('REGISTRAR PREVISÃO'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
