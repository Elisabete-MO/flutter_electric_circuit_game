import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../second_bench_tokens.dart';

/// Painel Lateral Compartilhado do Estande 2 (Acende Aí).
/// Possui largura e acabamento padronizados para todas as 4 fases.
class SecondBenchSidePanel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final Widget? footer;
  final double? width;
  final double minWidth;

  const SecondBenchSidePanel({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.child,
    this.footer,
    this.width = SecondBenchLayoutTokens.sidePanelWidth,
    this.minWidth = SecondBenchLayoutTokens.sidePanelMinWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: width ?? SecondBenchLayoutTokens.sidePanelWidth,
      ),
      decoration: BoxDecoration(
        color: SecondBenchLayoutTokens.panelBg,
        borderRadius: BorderRadius.circular(SecondBenchLayoutTokens.panelRadius),
        border: Border.all(
          color: SecondBenchLayoutTokens.panelBorder,
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SecondBenchLayoutTokens.panelRadius - 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Cabeçalho Fixo do Painel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: SecondBenchLayoutTokens.panelHeaderBg,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE2D7C3),
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: SecondBenchLayoutTokens.darkGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: SecondBenchLayoutTokens.accentGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: SecondBenchLayoutTokens.textDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontFamily: GoogleFonts.outfit().fontFamily,
                              fontSize: 12.5,
                              color: SecondBenchLayoutTokens.textDark.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Corpo do Painel com Rolagem
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: child,
              ),
            ),

            // 3. Rodapé Opcional do Painel
            if (footer != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF2EAD9),
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFE2D7C3),
                      width: 1.5,
                    ),
                  ),
                ),
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}
