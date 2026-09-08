import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/ui_scale.dart';
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
                  emotion: ProfVoltsEmotion.happy,
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
                    'EXPLIQUE O RESULTADO',
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
                ...widget.options.map((opt) {
                  final isSelected = _selected == opt;
                  return Padding(
                    padding: EdgeInsets.only(bottom: scale.spacing(8)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(scale.size(12)),
                      onTap: () => setState(() => _selected = opt),
                      child: Container(
                        width: double.infinity,
                        padding: scale.insetsSymmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accentColor.withValues(alpha: 0.15)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(scale.size(12)),
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
                              size: scale.icon(20),
                            ),
                            SizedBox(width: scale.spacing(12)),
                            Expanded(
                              child: Text(
                                opt,
                                style: GoogleFonts.outfit(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: scale.font(14),
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
                SizedBox(height: scale.spacing(16)),
                SizedBox(
                  width: double.infinity,
                  height: scale.size(48),
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
                        borderRadius: BorderRadius.circular(scale.size(14)),
                      ),
                      textStyle: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: scale.font(16),
                      ),
                    ),
                    icon: Icon(Icons.check_circle_outline, size: scale.icon(20)),
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
