import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/prof_volts_full_body.dart';

class SandboxMascotPanelWidget extends StatefulWidget {
  final ProfVoltsEmotion emotion;
  final String message;
  final bool isDark;
  final VoidCallback onClose;
  final VoidCallback? onQuickAction;
  final String? quickActionLabel;

  const SandboxMascotPanelWidget({
    super.key,
    required this.emotion,
    required this.message,
    required this.isDark,
    required this.onClose,
    this.onQuickAction,
    this.quickActionLabel,
  });

  @override
  State<SandboxMascotPanelWidget> createState() => _SandboxMascotPanelWidgetState();
}

class _SandboxMascotPanelWidgetState extends State<SandboxMascotPanelWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor;
    String badgeTitle;
    IconData badgeIcon;

    switch (widget.emotion) {
      case ProfVoltsEmotion.sad:
        themeColor = const Color(0xFFFF3B7F); // Cyber Neon Pink/Red
        badgeTitle = 'ALERTA DO PROF. VOLTS';
        badgeIcon = Icons.warning_amber_rounded;
        break;
      case ProfVoltsEmotion.happy:
        themeColor = const Color(0xFF00FF9D); // Cyber Emerald
        badgeTitle = 'CIRCUITO ATIVO!';
        badgeIcon = Icons.bolt_rounded;
        break;
      case ProfVoltsEmotion.neutral:
        themeColor = const Color(0xFF00F5D4); // Cyber Cyan
        badgeTitle = 'DICA DO LABORATÓRIO';
        badgeIcon = Icons.lightbulb_outline_rounded;
        break;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowAlpha = 0.25 + (_pulseController.value * 0.2);

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          child: Container(
            key: ValueKey('${widget.emotion}_${widget.message}'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withValues(alpha: glowAlpha),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: GlassContainer(
              borderRadius: 16,
              opacity: widget.isDark ? 0.45 : 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Avatar com Anel Neon Glow e Pulso
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: themeColor,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: ProfVoltsFullBody(
                        emotion: widget.emotion,
                        size: 54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Conteúdo de Texto e Badge HUD
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge de Cabeçalho HUD
                        Row(
                          children: [
                            Icon(badgeIcon, size: 14, color: themeColor),
                            const SizedBox(width: 5),
                            Text(
                              badgeTitle,
                              style: GoogleFonts.rajdhani(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Mensagem de Fala
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: widget.isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                            fontFamily: GoogleFonts.outfit().fontFamily,
                          ),
                        ),

                        // Botão de Ação Rápida (ex: Substituir Componentes)
                        if (widget.onQuickAction != null && widget.quickActionLabel != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: widget.onQuickAction,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: themeColor.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: themeColor, width: 1.2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.build_circle_rounded, size: 14, color: themeColor),
                                    const SizedBox(width: 5),
                                    Text(
                                      widget.quickActionLabel!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: widget.isDark ? Colors.white : Colors.black.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Botão de Fechar HUD
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: widget.isDark ? Colors.white60 : Colors.black54,
                    ),
                    tooltip: 'Fechar',
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
