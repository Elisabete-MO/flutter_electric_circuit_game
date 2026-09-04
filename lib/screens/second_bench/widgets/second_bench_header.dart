import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/eletrolab_header_brand.dart';
import '../second_bench_tokens.dart';

/// Cabeçalho único e padronizado do Estande 2 do EletroLab.
class SecondBenchHeader extends StatelessWidget {
  final int currentPhaseId;
  final Set<int> completedPhaseIds;
  final Set<int> unlockedPhaseIds;
  final ValueChanged<int>? onSelectPhase;
  final VoidCallback? onBack;

  const SecondBenchHeader({
    super.key,
    required this.currentPhaseId,
    required this.completedPhaseIds,
    required this.unlockedPhaseIds,
    this.onSelectPhase,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SecondBenchLayoutTokens.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 650;

          return Row(
            children: [
              // 1. Botão de Voltar à esquerda
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: 'Voltar ao Mapa',
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),

              if (!isCompact) ...[
                const SizedBox(width: 4),
                const EletroLabHeaderBrand(compact: true),
                const SizedBox(width: 16),
              ],

              // 2. Progresso das 4 Fases centralizado
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final phaseId = index + 1;
                    final isCurrent = currentPhaseId == phaseId;
                    final isCompleted = completedPhaseIds.contains(phaseId);
                    final isUnlocked = unlockedPhaseIds.contains(phaseId) || phaseId == 1;

                    Color stepColor;
                    if (isCurrent) {
                      stepColor = SecondBenchLayoutTokens.accentGreen;
                    } else if (isCompleted) {
                      stepColor = SecondBenchLayoutTokens.primaryGreen;
                    } else if (isUnlocked) {
                      stepColor = Colors.white54;
                    } else {
                      stepColor = const Color(0xFF334155);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: (isUnlocked && onSelectPhase != null)
                            ? () => onSelectPhase!(phaseId)
                            : null,
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 8 : 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: stepColor.withValues(alpha: isCurrent ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: stepColor,
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCompleted)
                                Icon(Icons.check_circle_rounded, size: 16, color: stepColor)
                              else if (!isUnlocked)
                                const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF64748B))
                              else
                                Text(
                                  '$phaseId',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                                    fontWeight: FontWeight.bold,
                                    color: stepColor,
                                    fontSize: 14,
                                  ),
                                ),
                              if (!isCompact) ...[
                                const SizedBox(width: 6),
                                Text(
                                  'Fase $phaseId',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                    color: stepColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );

        },
      ),
    );
  }
}
