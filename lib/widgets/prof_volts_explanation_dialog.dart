import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'prof_volts_full_body.dart';
import 'glass_container.dart';

/// Dialog de explicação pós-sucesso.
/// Pede que o jogador justifique o resultado observado com opções pré-definidas.
class ProfVoltsExplanationDialog extends StatefulWidget {
  const ProfVoltsExplanationDialog({
    super.key,
    required this.question,
    required this.options,
    required this.onExplain,
  });

  final String question;
  final List<String> options;
  final ValueChanged<String> onExplain;

  @override
  State<ProfVoltsExplanationDialog> createState() =>
      _ProfVoltsExplanationDialogState();
}

class _ProfVoltsExplanationDialogState
    extends State<ProfVoltsExplanationDialog> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF10B981);

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
                  emotion: ProfVoltsEmotion.happy,
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
                    'EXPLIQUE O RESULTADO',
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
                ...widget.options.map((opt) {
                  final isSelected = _selected == opt;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _selected = opt),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accentColor.withValues(alpha: 0.15)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? accentColor : Colors.white24,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected
                                  ? accentColor
                                  : Colors.white38,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                opt,
                                style: GoogleFonts.outfit(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _selected == null
                        ? null
                        : () => widget.onExplain(_selected!),
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
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('CONFIRMAR EXPLICAÇÃO'),
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
