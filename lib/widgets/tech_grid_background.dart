import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Um fundo tecnológico reutilizável com malha de linhas sutis e iluminação ambiente neon.
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
        // Cor base de fundo
        Container(
          color: theme.scaffoldBackgroundColor,
        ),

        // Gradientes sutis de iluminação de fundo (Neon Ambient Orbs)
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
                  EletroLabColors.electricBlue.withValues(alpha: isDark ? 0.10 : 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -80,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  EletroLabColors.neonPurple.withValues(alpha: isDark ? 0.08 : 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Grade Tecnológica Customizada
        if (showGrid)
          Positioned.fill(
            child: CustomPaint(
              painter: _TechGridPainter(
                gridColor: EletroLabColors.electricBlue.withValues(alpha: isDark ? 0.04 : 0.035),
              ),
            ),
          ),

        // Conteúdo da Tela
        child,
      ],
    );
  }
}

class _TechGridPainter extends CustomPainter {
  final Color gridColor;

  _TechGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const step = 40.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
