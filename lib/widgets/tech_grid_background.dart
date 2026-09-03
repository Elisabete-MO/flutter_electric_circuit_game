import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Um fundo tecnológico/laboratorial reutilizável estilo Tinkercad & Crack the Circuit.
class TechGridBackground extends StatelessWidget {
  const TechGridBackground({
    super.key,
    required this.child,
    this.showGrid = true,
  });

  final Widget child;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Cor base de fundo (Clean Studio Light por padrão, ou dark se configurado)
        Container(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        ),

        // Gradientes sutis de iluminação ambiental
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  EletroLabColors.electricBlue.withValues(alpha: isDark ? 0.08 : 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Grade de Papel Blueprint / Dotted Grid (Crack the Circuit & Tinkercad Style)
        if (showGrid)
          Positioned.fill(
            child: CustomPaint(
              painter: BlueprintDotGridPainter(isDark: isDark),
            ),
          ),

        // Conteúdo da Tela
        child,
      ],
    );
  }
}

/// Painter de Malha Dotted Grid (Pontos e Linhas no estilo Crack the Circuit / Blueprint)
class BlueprintDotGridPainter extends CustomPainter {
  final bool isDark;

  BlueprintDotGridPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const step = 32.0;

    // Desenha as linhas sutis da malha
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Desenha os pontos de grade nos cruzamentos (Estilo Crack the Circuit Blueprint)
    final dotPaint = Paint()
      ..color = isDark
          ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
          : const Color(0xFF0284C7).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    for (double x = step; x < size.width; x += step) {
      for (double y = step; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 2.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
