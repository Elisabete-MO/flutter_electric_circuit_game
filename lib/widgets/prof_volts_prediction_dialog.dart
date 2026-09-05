import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'prof_volts_full_body.dart';
import 'glass_container.dart';

/// Dialog de previsão obrigatória antes de energizar o circuito.
/// Exibe pergunta contextual + opções deChoiceChip + botão registrar.
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

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: GlassContainer(
          borderRadius: 24,
          accentColor: accentColor,
          opacity: 0.92,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ProfVoltsFullBody(
                  emotion: ProfVoltsEmotion.neutral,
                  size: 130,
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'PREVISÃO OBRIGATÓRIA',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.question,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: widget.options.map((opt) {
                    final isSelected = _selected == opt;
                    return ChoiceChip(
                      label: Text(
                        opt,
                        style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
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
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 16,
                      ),
                    ),
                    icon: const Icon(Icons.psychology_rounded, size: 20),
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
