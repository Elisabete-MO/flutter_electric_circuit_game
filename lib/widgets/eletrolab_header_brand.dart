import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/ui_scale.dart';

/// Marca oficial do EletroLab para ser exibida nos cabeçalhos de todas as telas.
/// Exibe a badge circular com o ícone de raio verde esmeralda e o título 'EletroLab'
/// envolto em uma cápsula glassmorphic elegante.
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
    final double baseIcon = compact ? 20.0 : 26.0;
    final double baseTitleFont = compact ? 18.0 : 23.0;
    final double baseSubFont = UiTypography.label;

    final double circleSize = scale.size(baseCircle);
    final double iconSize = scale.icon(baseIcon);
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
              // Badge Circular do Raio Verde Esmeralda
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF04382B),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.45),
                      blurRadius: scale.size(10),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.bolt_rounded,
                    color: const Color(0xFF10B981), // Raio Verde Esmeralda
                    size: iconSize,
                  ),
                ),
              ),
              SizedBox(width: scale.spacing(8)),

              // Textos com a tipografia padronizada
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EletroLab',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: titleFontSize,
                      letterSpacing: 0.8,
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
