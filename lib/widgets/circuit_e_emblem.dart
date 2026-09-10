import 'package:flutter/material.dart';
import 'circuit_e_path.dart';

/// Emblema oficial do EletroLab:
class CircuitEEmblem extends StatelessWidget {
  const CircuitEEmblem({
    super.key,
    required this.size,
    this.progress = 1.0,
    this.pulseGlow = true,
    this.color,
  });

  /// Dimensão do emblema (largura e altura)
  final double size;

  /// Nível de energização (0.0 a 1.0)
  final double progress;

  /// Se deve exibir o glow neon pulsante
  final bool pulseGlow;

  /// Cor sólida opcional para renderização monocromática (ex: todo branco)
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        isComplex: true,
        willChange: false,
        painter: _CircuitEVectorPainter(
          progress: progress.clamp(0.0, 1.0),
          pulseGlow: pulseGlow,
          color: color,
        ),
      ),
    );
  }
}

class _CircuitEVectorPainter extends CustomPainter {
  final double progress;
  final bool pulseGlow;
  final Color? color;

  // Cache para evitar reconstruir caminhos em repaints frequentes
  Path? _cachedPath;
  List<RRect>? _cachedPadRRects;
  Rect? _cachedBounds;

  _CircuitEVectorPainter({
    required this.progress,
    required this.pulseGlow,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height * 0.88;
    final w = h * ConceptEPathData.aspectRatio;
    final bounds = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: w,
      height: h,
    );

    if (_cachedBounds != bounds || _cachedPath == null) {
      _cachedBounds = bounds;
      _cachedPath = ConceptEPathData.buildPath(bounds);
      _cachedPadRRects = ConceptEPathData.getPadRRects(bounds);
    }

    final path = _cachedPath!;
    final padRRects = _cachedPadRRects!;

    if (color != null) {
      // Renderização monocromática
      if (pulseGlow) {
        final blurRadius = (size.width * 0.05).clamp(2.5, 12.0);
        final glowPaint = Paint()
          ..color = color!.withValues(alpha: 0.45)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);
        canvas.drawPath(path, glowPaint);
        for (final rrect in padRRects) {
          canvas.drawRRect(rrect, glowPaint);
        }
      }

      final corePaint = Paint()
        ..color = color!
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, corePaint);

      final padPaint = Paint()
        ..color = color!
        ..style = PaintingStyle.fill;
      for (final rrect in padRRects) {
        canvas.drawRRect(rrect, padPaint);
      }
      return;
    }

    // Gradiente dinâmico de energização:
    // Ciano Elétrico -> Esmeralda -> Menta -> Ouro Âmbar
    final cyanStart = Color.lerp(
      const Color(0xFF047857),
      const Color(0xFF00E5FF),
      progress,
    )!;
    final mintMid = Color.lerp(
      const Color(0xFF059669),
      const Color(0xFF34D399),
      progress,
    )!;
    final goldEnd = Color.lerp(
      const Color(0xFFB45309),
      const Color(0xFFFBBF24),
      progress,
    )!;
    final amberEnd = Color.lerp(
      const Color(0xFF78350F),
      const Color(0xFFF59E0B),
      progress,
    )!;

    final traceShader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [cyanStart, mintMid, goldEnd, amberEnd],
      stops: const [0.0, 0.40, 0.82, 1.0],
    ).createShader(bounds);

    final goldPadShader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(const Color(0xFFD97706), const Color(0xFFFFFBEB), progress)!,
        Color.lerp(const Color(0xFFB45309), const Color(0xFFFDE68A), progress)!,
        Color.lerp(const Color(0xFF92400E), const Color(0xFFF59E0B), progress)!,
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(bounds);

    // 1. Halo Neon Suave e Difuso de Fundo
    if (pulseGlow && progress > 0.05) {
      final blurRadius = (size.width * 0.045).clamp(2.5, 12.0);

      // Glow suave da linha vetorial
      final glowPaint = Paint()
        ..shader = traceShader
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);
      canvas.drawPath(path, glowPaint);

      // Glow âmbar ao redor dos 9 pads
      final padGlowPaint = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.55 * progress)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius * 1.1);
      for (final rrect in padRRects) {
        canvas.drawRRect(rrect, padGlowPaint);
      }
    }

    // 2. Traçado Vetorial Nítido de Alta Precisão (GPU)
    final corePaint = Paint()
      ..shader = traceShader
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, corePaint);

    // 3. Os 9 Terminais Dourados Preenchidos (Gold Fingers)
    final padFillPaint = Paint()
      ..shader = goldPadShader
      ..style = PaintingStyle.fill;

    final padBorderPaint = Paint()
      ..color = const Color(0xFFFFFBEB).withValues(alpha: 0.92 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width * 0.014).clamp(0.6, 2.0);

    for (final rrect in padRRects) {
      canvas.drawRRect(rrect, padFillPaint);
      canvas.drawRRect(rrect, padBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitEVectorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulseGlow != pulseGlow ||
        oldDelegate.color != color;
  }
}
