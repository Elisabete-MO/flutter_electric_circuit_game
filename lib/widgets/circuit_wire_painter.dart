// ignore_for_file: use_null_aware_elements
import 'package:flutter/material.dart';

/// CircuitWirePainter — Desenhador de Circuitos Elétricos de Alta Fidelidade
/// Renderiza fios condutores com efeito neon, junções metálicas (nós) e fluxo de elétrons animado.

class CircuitCanvasWidget extends StatelessWidget {
  final Size canvasSize;
  final List<Path> wirePaths;
  final bool isEnergized;
  final double animationValue; // 0.0 a 1.0 para animação de elétrons
  final Color wireColor;
  final Widget? child;

  const CircuitCanvasWidget({
    super.key,
    required this.canvasSize,
    required this.wirePaths,
    this.isEnergized = false,
    this.animationValue = 0.0,
    this.wireColor = const Color(0xFF10B981),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: canvasSize.width,
      height: canvasSize.height,
      child: Stack(
        children: [
          CustomPaint(
            size: canvasSize,
            painter: _CircuitWirePainter(
              wirePaths: wirePaths,
              isEnergized: isEnergized,
              animationValue: animationValue,
              wireColor: wireColor,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _CircuitWirePainter extends CustomPainter {
  final List<Path> wirePaths;
  final bool isEnergized;
  final double animationValue;
  final Color wireColor;

  _CircuitWirePainter({
    required this.wirePaths,
    required this.isEnergized,
    required this.animationValue,
    required this.wireColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in wirePaths) {
      // 1. Trilha de Fundo / Sombra Neon
      if (isEnergized) {
        final glowPaint = Paint()
          ..color = wireColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawPath(path, glowPaint);
      }

      // 2. Fio Condutor Metálico Core (Cobre/Neon)
      final corePaint = Paint()
        ..color = isEnergized ? wireColor : const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, corePaint);

      // 3. Fio Interno Brilhante
      final innerPaint = Paint()
        ..color = isEnergized ? Colors.white : const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, innerPaint);

      // 4. Fluxo Animado de Elétrons (Partículas Pulsantes)
      if (isEnergized) {
        final metrics = path.computeMetrics();
        for (final metric in metrics) {
          final totalLength = metric.length;
          final particleCount = (totalLength / 35).clamp(2, 20).toInt();

          for (int i = 0; i < particleCount; i++) {
            final distance = ((i / particleCount + animationValue) % 1.0) * totalLength;
            final tangent = metric.getTangentForOffset(distance);
            if (tangent != null) {
              // Partícula de Elétron (Padronizada com Estande 4: Aura amarela + Núcleo branco)
              final glowPaint = Paint()
                ..color = const Color(0xFFFEF08A)
                ..style = PaintingStyle.fill
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
              canvas.drawCircle(tangent.position, 4.5, glowPaint);

              final coreDotPaint = Paint()
                ..color = Colors.white
                ..style = PaintingStyle.fill;
              canvas.drawCircle(tangent.position, 2.0, coreDotPaint);
            }
          }
        }
      }

      // 5. Terminais / Nós de Conexão Metálica nos Extremos
      final metrics = path.computeMetrics();
      for (final metric in metrics) {
        final startTan = metric.getTangentForOffset(0);
        final endTan = metric.getTangentForOffset(metric.length);

        if (startTan != null) _drawNode(canvas, startTan.position);
        if (endTan != null) _drawNode(canvas, endTan.position);
      }
    }
  }

  void _drawNode(Canvas canvas, Offset pos) {
    final ringPaint = Paint()
      ..color = const Color(0xFFF59E0B) // Latão / Cobre
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 5.0, ringPaint);

    final holePaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(pos, 2.5, holePaint);
  }

  @override
  bool shouldRepaint(covariant _CircuitWirePainter oldDelegate) {
    return oldDelegate.isEnergized != isEnergized ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.wireColor != wireColor;
  }
}
