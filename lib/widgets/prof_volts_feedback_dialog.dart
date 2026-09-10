import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/ui_scale.dart';
import 'prof_volts_full_body.dart';
import 'glass_container.dart';

class ProfVoltsFeedbackDialog extends StatelessWidget {
  const ProfVoltsFeedbackDialog({
    super.key,
    required this.isCorrect,
    required this.message,
    required this.onAction,
  });

  final bool isCorrect;
  final String message;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scale = context.uiScale;

    final accentColor = isCorrect
        ? (isDark ? const Color(0xFF00FF9D) : const Color(0xFF00875A))
        : (isDark ? const Color(0xFFFF3B7F) : const Color(0xFFD81B60));
    final buttonTextColor = isDark ? Colors.black : Colors.white;
    final titleText = isCorrect ? 'SINAL ANALISADO: CORRETO!' : 'SINAL DE ALERTA: ANOMALIA!';
    final buttonText = isCorrect ? 'CONTINUAR' : 'TENTAR NOVAMENTE';
    final buttonIcon = isCorrect ? Icons.arrow_forward_rounded : Icons.replay_rounded;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: scale.insetsSymmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: scale.dialogWidth(520)),
        child: GlassContainer(
          borderRadius: scale.size(24),
          accentColor: accentColor,
          opacity: isDark ? 0.8 : 0.9,
          padding: scale.insetsAll(26),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Mascote Corpo Inteiro
                ProfVoltsFullBody(
                  emotion: isCorrect ? ProfVoltsEmotion.happy : ProfVoltsEmotion.sad,
                  size: scale.size(160),
                ),
                SizedBox(height: scale.spacing(16)),
                
                // 2. Título HUD Cyber
                Container(
                  padding: scale.insetsSymmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(scale.size(8)),
                    border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    titleText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 1.5,
                      fontSize: scale.font(17),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: scale.spacing(16)),

                // 3. Mensagem explicativa
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    fontSize: scale.font(16.5),
                    fontFamily: GoogleFonts.outfit().fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: scale.spacing(24)),

                // 4. Botão de Ação Cyberpunk
                SizedBox(
                  width: double.infinity,
                  height: scale.size(52),
                  child: FilledButton.icon(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: buttonTextColor,
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
                    icon: Icon(buttonIcon, size: scale.icon(20), color: buttonTextColor),
                    label: Text(buttonText),
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

/// Diálogo Amigável de Dica do Professor Volts
class ProfVoltsTipDialog extends StatelessWidget {
  const ProfVoltsTipDialog({
    super.key,
    required this.voltsTip,
    this.title = 'Dica do Professor Volts',
  });

  final String voltsTip;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scale = context.uiScale;
    const accentColor = Color(0xFFF59E0B);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: scale.insetsSymmetric(horizontal: 20, vertical: 28),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: scale.dialogWidth(480)),
        child: GlassContainer(
          borderRadius: scale.size(24),
          accentColor: accentColor,
          opacity: isDark ? 0.85 : 0.94,
          padding: scale.insetsAll(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfVoltsFullBody(
                  emotion: ProfVoltsEmotion.happy,
                  size: scale.size(110, min: 80, max: 140),
                ),
                SizedBox(height: scale.spacing(14)),
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.rajdhani(
                    fontSize: scale.font(20),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: scale.spacing(12)),
                Container(
                  padding: scale.insetsAll(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(scale.size(14)),
                    border: Border.all(
                      color: const Color(0xFFFDE68A),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    '“$voltsTip”',
                    style: GoogleFonts.outfit(
                      fontSize: scale.font(UiTypography.body),
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFF78350F),
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: scale.spacing(20)),
                SizedBox(
                  width: double.infinity,
                  height: scale.size(48),
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(scale.size(14)),
                      ),
                      textStyle: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: scale.font(16),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('ENTENDI, OBRIGADO!'),
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
