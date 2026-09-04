import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../second_bench_tokens.dart';

/// Barra Inferior Reutilizável de Ações do Estande 2.
/// Mantém a mesma posição, altura, fundo e estilo em todas as 4 fases.
class SecondBenchActionBar extends StatelessWidget {
  final Widget? leftContent;
  final String? statusText;
  final String? progressText;
  final List<Widget> actions;

  const SecondBenchActionBar({
    super.key,
    this.leftContent,
    this.statusText,
    this.progressText,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SecondBenchLayoutTokens.actionBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SecondBenchLayoutTokens.primaryGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;

          return Row(
            children: [
              // 1. Esquerda: Instrução ou Status
              Expanded(
                child: leftContent ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (statusText != null) ...[
                          const Icon(
                            Icons.info_outline_rounded,
                            color: SecondBenchLayoutTokens.primaryGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              statusText!,
                              style: TextStyle(
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 13.5,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
              ),

              // 2. Centro: Indicador de Progresso (quando aplicável)
              if (progressText != null && !isCompact) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF04382B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: SecondBenchLayoutTokens.primaryGreen.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 15,
                        color: SecondBenchLayoutTokens.accentGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        progressText!,
                        style: TextStyle(
                          fontFamily: GoogleFonts.rajdhani().fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: SecondBenchLayoutTokens.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // 3. Direita: Ações secundárias e principal
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              ),
            ],
          );
        },
      ),
    );
  }
}
