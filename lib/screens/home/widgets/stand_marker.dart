import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../models/stand_data.dart';

/// Widget que renderiza o estande da Feira de Ciências com perspectiva top-down 3D,
/// ícones temáticos e badges visuais de status.
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

  IconData _getStandIcon(int number, bool isBancadaLivre) {
    if (isBancadaLivre) return Icons.science_rounded;
    switch (number) {
      case 1:
        return Icons.school_rounded;
      case 2:
        return Icons.tungsten_rounded;
      case 3:
        return Icons.toggle_on_rounded;
      case 4:
        return Icons.alt_route_rounded;
      case 5:
        return Icons.lightbulb_rounded;
      case 6:
        return Icons.autorenew_rounded;
      case 7:
        return Icons.speed_rounded;
      case 8:
        return Icons.shield_rounded;
      case 9:
        return Icons.eco_rounded;
      case 10:
        return Icons.sensor_door_rounded;
      case 11:
        return Icons.location_city_rounded;
      case 12:
        return Icons.handyman_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220);

    final height = widget.width * (2.0 / 3.0); // Proporção 3:2
    final numberFormatted = widget.stand.number < 10
        ? '0${widget.stand.number}'
        : '${widget.stand.number}';

    final bool isTutorial = widget.stand.number == 1;
    final bool isBancadaLivre = widget.stand.isBancadaLivre;
    final bool isCompleted = widget.stand.hasMissions &&
        widget.stand.completedMissions >= widget.stand.totalMissions &&
        widget.stand.totalMissions > 0;

    final IconData standIcon = _getStandIcon(widget.stand.number, isBancadaLivre);

    // Gradiente dinâmico para a placa do card
    final LinearGradient cardGradient = widget.isSelected
        ? const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : (isTutorial
            ? const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : (isBancadaLivre
                ? const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : (isCompleted
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF047857)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF065F46), Color(0xFF022C22)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ))));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: widget.isSelected ? 1.12 : (_isHovered ? 1.06 : 1.0),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Placa em Perspectiva Top-Down 3D com Ícone e Badges
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012) // Projeção de perspectiva 3D
                  ..rotateX(widget.isSelected ? -0.04 : (_isHovered ? -0.06 : -0.14)), // Ângulo top-down
                transformAlignment: Alignment.bottomCenter,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                decoration: BoxDecoration(
                  gradient: cardGradient,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isSelected
                        ? Colors.white
                        : (isTutorial || isBancadaLivre
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.35)),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isSelected
                          ? EletroLabColors.amber.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.45),
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Sombra projetada no piso da quadra
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge com o número do estande
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? const Color(0xFF0F172A)
                            : Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            standIcon,
                            size: 10.5,
                            color: widget.isSelected ? EletroLabColors.amber : Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            numberFormatted,
                            style: TextStyle(
                              color: widget.isSelected ? EletroLabColors.amber : Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: (widget.width * 0.085).clamp(9.0, 11.0),
                            ),
                          ),
                        ],
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
                        shadows: widget.isSelected
                            ? null
                            : const [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
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
                          border: Border.all(color: Colors.white70, width: 0.8),
                        ),
                        child: const Text(
                          'TUTORIAL',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 8.0,
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
                          border: Border.all(color: Colors.white70, width: 0.8),
                        ),
                        child: const Text(
                          'LIVRE',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 8.0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 3),

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
