import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final double circleSize = compact ? 30.0 : 36.0;
    final double iconSize = compact ? 18.0 : 22.0;
    final double titleFontSize = compact ? 17.0 : 20.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xAA03241B), // Cápsula glassmorphic verde esmeralda
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
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
                        blurRadius: 10,
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
                const SizedBox(width: 8),

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
                      const SizedBox(height: 1),
                      Text(
                        'Laboratório Virtual de Circuitos',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF34D399),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
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
      ),
    );
  }
}
