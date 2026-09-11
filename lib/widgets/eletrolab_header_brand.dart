import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/ui_scale.dart';
import 'circuit_e_emblem.dart';

/// Marca oficial do EletroLab para ser exibida nos cabeçalhos de todas as telas.
/// Exibe o emblema tecnológico 'E' de circuito e o título dual-tone 'ELETROLAB'
class EletroLabHeaderBrand extends StatelessWidget {
  const EletroLabHeaderBrand({
    super.key,
    this.showSubtitle = true,
    this.compact = false,
  });

  /// Exibir subtítulo 'Laboratório Virtual de Circuitos'
  final bool showSubtitle;

  /// Reduzir o tamanho da badge para layouts mais ajustados
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final double baseCircle = compact ? 34.0 : 44.0;
    final double baseTitleFont = compact ? 17.0 : 22.0;
    final double baseSubFont = UiTypography.label;

    final double circleSize = scale.size(baseCircle);
    final double titleFontSize = scale.font(baseTitleFont);
    final double subtitleFontSize = scale.font(baseSubFont);

    return ClipRRect(
      borderRadius: BorderRadius.circular(scale.size(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: scale.insetsSymmetric(
            horizontal: compact ? 12 : 18,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(
              0xAA03241B,
            ), // Cápsula glassmorphic verde esmeralda
            borderRadius: BorderRadius.circular(scale.size(28)),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: scale.size(10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Emblema Tecnológico de Circuito 'E'
              CircuitEEmblem(
                size: circleSize,
                progress: 1.0,
                pulseGlow: true,
                lowPoly3D: true,
              ),
              SizedBox(width: scale.spacing(9)),

              // Textos com a tipografia dual-tone ELETROLAB 3D
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'ELETRO',
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF),
                            shadows: [
                              Shadow(
                                color: const Color(0xFF0F766E),
                                offset: Offset(0, scale.size(1.0)),
                                blurRadius: 0,
                              ),
                              Shadow(
                                color: const Color(0xFF042F2E),
                                offset: Offset(0, scale.size(2.2)),
                                blurRadius: 0,
                              ),
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                offset: Offset(0, scale.size(4.0)),
                                blurRadius: scale.size(4),
                              ),
                            ],
                          ),
                        ),
                        TextSpan(
                          text: 'LAB',
                          style: TextStyle(
                            color: const Color(0xFFFBBF24),
                            shadows: [
                              Shadow(
                                color: const Color(0xFFD97706),
                                offset: Offset(0, scale.size(1.0)),
                                blurRadius: 0,
                              ),
                              Shadow(
                                color: const Color(0xFF92400E),
                                offset: Offset(0, scale.size(2.2)),
                                blurRadius: 0,
                              ),
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                offset: Offset(0, scale.size(4.0)),
                                blurRadius: scale.size(4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.w900,
                      fontSize: titleFontSize,
                      letterSpacing: 2.0,
                    ),
                  ),
                  if (showSubtitle) ...[
                    SizedBox(height: scale.spacing(1)),
                    Text(
                      'Laboratório Virtual de Circuitos',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF34D399),
                        fontWeight: FontWeight.w600,
                        fontSize: subtitleFontSize,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
