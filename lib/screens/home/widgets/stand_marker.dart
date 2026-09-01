import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../models/stand_data.dart';

/// Widget que renderiza o estande da Feira de Ciências com badges visuais de status
/// (Tutorial para Estande 01, Modo Livre para Estande 12 e Checkmark para Estandes Concluídos).
class StandMarker extends StatefulWidget {
  final StandData stand;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const StandMarker({
    super.key,
    required this.stand,
    required this.isSelected,
    required this.onTap,
    this.width = 110,
  });

  @override
  State<StandMarker> createState() => _StandMarkerState();
}

class _StandMarkerState extends State<StandMarker> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);

    final height = widget.width * (2.0 / 3.0); // Proporção 3:2
    final numberFormatted = widget.stand.number < 10
        ? '0${widget.stand.number}'
        : '${widget.stand.number}';

    final bool isTutorial = widget.stand.number == 1;
    final bool isBancadaLivre = widget.stand.isBancadaLivre;
    final bool isCompleted = widget.stand.hasMissions &&
        widget.stand.completedMissions >= widget.stand.totalMissions &&
        widget.stand.totalMissions > 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: widget.isSelected ? 1.12 : (_isHovered ? 1.05 : 1.0),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Card no Topo com Número, Nome e Badge de Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? EletroLabColors.amber
                      : (isTutorial
                          ? const Color(0xFF047857) // Verde esmeralda para Tutorial
                          : (isBancadaLivre
                              ? const Color(0xFF0F52BA) // Azul para Bancada Livre
                              : (isCompleted
                                  ? const Color(0xFF065F46) // Verde escuro se concluído
                                  : const Color(0xFF0B2A4A).withValues(alpha: 0.95)))),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: widget.isSelected
                        ? Colors.white
                        : (isTutorial || isBancadaLivre
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.4)),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isSelected
                          ? EletroLabColors.amber.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge com o número do estande
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? const Color(0xFF0F172A)
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        numberFormatted,
                        style: TextStyle(
                          color: widget.isSelected ? EletroLabColors.amber : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: (widget.width * 0.085).clamp(9.0, 11.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Nome do estande
                    Text(
                      widget.stand.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.isSelected ? const Color(0xFF0F172A) : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: (widget.width * 0.09).clamp(9.5, 12.0),
                        letterSpacing: 0.1,
                      ),
                    ),

                    // Tag Especial para Tutorial (Estande 01)
                    if (isTutorial) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'TUTORIAL',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 8.5,
                          ),
                        ),
                      ),
                    ],

                    // Tag Especial para Bancada Livre (Estande 12)
                    if (isBancadaLivre) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'LIVRE',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 8.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // 2. Mesa do Estande (Imagem PNG 3:2) com Badge de Conclusão se aplicável
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: widget.width,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.isSelected
                            ? EletroLabColors.amber
                            : (_isHovered
                                ? EletroLabColors.electricBlue
                                : (isCompleted
                                    ? const Color(0xFF10B981)
                                    : Colors.white30)),
                        width: widget.isSelected ? 3.0 : 1.5,
                      ),
                      boxShadow: [
                        if (widget.isSelected)
                          BoxShadow(
                            color: EletroLabColors.amber.withValues(alpha: 0.7),
                            blurRadius: 18,
                            spreadRadius: 3,
                          )
                        else if (_isHovered)
                          BoxShadow(
                            color: EletroLabColors.electricBlue.withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 1,
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        widget.stand.asset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.blueGrey.shade800,
                            alignment: Alignment.center,
                            child: Text(
                              '#${widget.stand.number}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Badge Flutuante de Estande Concluído (Checkmark Verde)
                  if (isCompleted)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
