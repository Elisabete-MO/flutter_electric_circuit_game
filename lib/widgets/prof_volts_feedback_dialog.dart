import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: GlassContainer(
        borderRadius: 24,
        accentColor: accentColor,
        opacity: isDark ? 0.8 : 0.9,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // 1. Mascote Corpo Inteiro
            ProfVoltsFullBody(
              emotion: isCorrect ? ProfVoltsEmotion.happy : ProfVoltsEmotion.sad,
              size: 150,
            ),
            const SizedBox(height: 16),
            
            // 2. Título HUD Cyber
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                titleText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // 3. Mensagem explicativa
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                fontSize: 15,
                fontFamily: GoogleFonts.outfit().fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 4. Botão de Ação Cyberpunk
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: buttonTextColor,
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
                icon: Icon(buttonIcon, size: 20, color: buttonTextColor),
                label: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
