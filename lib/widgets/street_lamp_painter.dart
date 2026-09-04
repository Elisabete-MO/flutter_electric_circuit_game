import 'package:flutter/material.dart';

/// Renderizador CustomPainter do Poste de Iluminação Pública (Poste LED)
/// com perspectiva Top-Down (vista superior de maquete/planta baixa).
/// Suporta os estados LIGADO (com iluminação radial em leque e brilho) e DESLIGADO.
class StreetLampPainter extends CustomPainter {
  StreetLampPainter({
    this.isActive = false,
    this.brightnessRatio = 1.0,
    this.isDarkMode = false,
  });

  final bool isActive;
  final double brightnessRatio;
  final bool isDarkMode;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.38;

    // -------------------------------------------------------------
    // 0. Brilho Radial Top-Down na Rua (quando LIGADO)
    // -------------------------------------------------------------
    if (isActive) {
      // 0.1 Halo externo suave em leque/radial
      final outerGlowPaint = Paint()
        ..color = const Color(0xFFFACC15).withValues(alpha: 0.35 * brightnessRatio)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(Offset(cx, cy), radius * 1.3, outerGlowPaint);

      // 0.2 Halo intermediario mais forte
      final innerGlowPaint = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.50 * brightnessRatio)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(cx, cy), radius * 0.85, innerGlowPaint);

      // 0.3 Faceta de iluminação incandescente central
      final coreGlowPaint = Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.70 * brightnessRatio)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(cx, cy), radius * 0.5, coreGlowPaint);
    }

    // -------------------------------------------------------------
    // 1. Sombra da Luminária e Poste no Chão
    // -------------------------------------------------------------
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(cx + 2, cy + 3), radius * 0.65, shadowPaint);

    // -------------------------------------------------------------
    // 2. Base do Poste de Maquete (Vista Superior - Flange Circular)
    // -------------------------------------------------------------
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF64748B), Color(0xFF334155), Color(0xFF1E293B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 18));

    canvas.drawCircle(Offset(cx, cy), 18, basePaint);

    // Anel externo da base metallic
    final ringPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(cx, cy), 18, ringPaint);

    // Parafusos de fixação na base da maquete (4 pontos)
    final boltPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 12, cy - 12), 1.8, boltPaint);
    canvas.drawCircle(Offset(cx + 12, cy - 12), 1.8, boltPaint);
    canvas.drawCircle(Offset(cx - 12, cy + 12), 1.8, boltPaint);
    canvas.drawCircle(Offset(cx + 12, cy + 12), 1.8, boltPaint);

    // -------------------------------------------------------------
    // 3. Cabeça do Cúpula da Luminária LED (Formato Aerodinâmico Top-Down)
    // -------------------------------------------------------------
    final hoodRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 28, height: 28),
      const Radius.circular(8),
    );

    final hoodGradient = const LinearGradient(
      colors: [Color(0xFF475569), Color(0xFF334155), Color(0xFF0F172A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    canvas.drawRRect(hoodRect, Paint()..shader = hoodGradient.createShader(hoodRect.outerRect));

    // Borda metálica da cúpula
    canvas.drawRRect(
      hoodRect,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // -------------------------------------------------------------
    // 4. Lente Central de LED (Difusor Luminoso)
    // -------------------------------------------------------------
    final lensRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 18, height: 18),
      const Radius.circular(5),
    );

    if (isActive) {
      // Estado LIGADO: LED amarelo/branco radiante
      final lensPaint = Paint()
        ..color = const Color(0xFFFACC15)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(lensRect, lensPaint);

      // Centro incandescente
      final coreLens = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 10, height: 10),
        const Radius.circular(3),
      );
      canvas.drawRRect(coreLens, Paint()..color = const Color(0xFFFFFBEB));
    } else {
      // Estado DESLIGADO: Vidro cinza leitoso fosco
      final lensPaint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(lensRect, lensPaint);

      canvas.drawRRect(
        lensRect,
        Paint()
          ..color = const Color(0xFF64748B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    // -------------------------------------------------------------
    // 5. Anéis dos Terminais de Conexão de Fio (Esquerda / Direita)
    // -------------------------------------------------------------
    final termPaint = Paint()
      ..color = const Color(0xFFB87333)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx - 24, cy), 3.5, termPaint);
    canvas.drawCircle(Offset(cx + 24, cy), 3.5, termPaint);
  }

  @override
  bool shouldRepaint(covariant StreetLampPainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.brightnessRatio != brightnessRatio ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
