import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/prof_volts_full_body.dart';

class SandboxMascotPanelWidget extends StatelessWidget {
  final ProfVoltsEmotion emotion;
  final String message;
  final bool isDark;
  final VoidCallback onClose;

  const SandboxMascotPanelWidget({
    super.key,
    required this.emotion,
    required this.message,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GlassContainer(
        key: ValueKey(emotion),
        borderRadius: 16,
        opacity: isDark ? 0.35 : 0.6,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ProfVoltsFullBody(
              emotion: emotion,
              size: 64,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  fontFamily: GoogleFonts.outfit().fontFamily,
                ),
              ),
            ),
            IconButton(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.close_rounded, size: 18),
              tooltip: 'Fechar',
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
