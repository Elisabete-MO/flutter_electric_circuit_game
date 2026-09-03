import 'package:flutter/material.dart';

/// Renderizador CustomPainter do Poste de Iluminação Pública (Poste LED)
/// inspirada em luminárias urbanas modernas de LED.
/// Suporta os estados LIGADO (com iluminação em cone e brilho radial) e DESLIGADO.
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
    final w = size.width;
    final h = size.height;

    // Eixo X central do poste vertical
    final poleX = w * 0.32;

    // -------------------------------------------------------------
    // 0. Projeção Cone de Luz (quando LIGADO)
    // -------------------------------------------------------------
    if (isActive) {
      final headX = w * 0.72;
      final headY = h * 0.14;

      // Facho de luz cônico em leque projetado para baixo
      final lightPath = Path()
        ..moveTo(headX - w * 0.08, headY)
        ..lineTo(headX + w * 0.12, headY + h * 0.02)
        ..lineTo(headX + w * 0.28, h * 0.98)
        ..lineTo(headX - w * 0.35, h * 0.98)
        ..close();

      final lightGradient = LinearGradient(
        colors: [
          const Color(0xFFFACC15).withValues(alpha: 0.55 * brightnessRatio),
          const Color(0xFFF59E0B).withValues(alpha: 0.25 * brightnessRatio),
          const Color(0xFFF59E0B).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

      final lightPaint = Paint()
        ..shader = lightGradient.createShader(Rect.fromLTWH(0, headY, w, h - headY));

      canvas.drawPath(lightPath, lightPaint);

      // Brilho Halo Radial em volta da luminária
      final auraPaint = Paint()
        ..color = const Color(0xFFFACC15).withValues(alpha: 0.6 * brightnessRatio)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(headX, headY + 2), w * 0.12, auraPaint);
    }

    // -------------------------------------------------------------
    // 1. Sombra Projetada no Chão (Base)
    // -------------------------------------------------------------
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(poleX, h * 0.97),
        width: w * 0.35,
        height: h * 0.05,
      ),
      shadowPaint,
    );

    // -------------------------------------------------------------
    // 2. Base Cônica / Pedestal Metálico
    // -------------------------------------------------------------
    final baseBottomY = h * 0.96;
    final baseTopY = h * 0.82;
    final baseWidthBottom = w * 0.24;
    final baseWidthTop = w * 0.14;

    final basePath = Path()
      ..moveTo(poleX - baseWidthBottom / 2, baseBottomY)
      ..lineTo(poleX - baseWidthTop / 2, baseTopY)
      ..lineTo(poleX + baseWidthTop / 2, baseTopY)
      ..lineTo(poleX + baseWidthBottom / 2, baseBottomY)
      ..close();

    final baseGradient = const LinearGradient(
      colors: [
        Color(0xFF94A3B8),
        Color(0xFF64748B),
        Color(0xFF334155),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    canvas.drawPath(
      basePath,
      Paint()..shader = baseGradient.createShader(Rect.fromLTWH(poleX - baseWidthBottom / 2, baseTopY, baseWidthBottom, baseBottomY - baseTopY)),
    );

    // Borda/Rodapé da Base
    final footRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(poleX, baseBottomY), width: baseWidthBottom + 4, height: h * 0.03),
      const Radius.circular(2),
    );
    canvas.drawRRect(footRect, Paint()..color = const Color(0xFF475569));

    // -------------------------------------------------------------
    // 3. Haste Vertical Principal (Poste)
    // -------------------------------------------------------------
    final poleTopY = h * 0.10;
    final poleWidth = w * 0.065;

    final poleRect = Rect.fromLTWH(
      poleX - poleWidth / 2,
      poleTopY,
      poleWidth,
      baseTopY - poleTopY,
    );

    final poleGradient = const LinearGradient(
      colors: [
        Color(0xFFCBD5E1),
        Color(0xFF94A3B8),
        Color(0xFF475569),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    canvas.drawRect(poleRect, Paint()..shader = poleGradient.createShader(poleRect));

    // Anéis / Juntas Metálicas (Collars) ao longo do poste
    final collarY1 = h * 0.58;
    final collarY2 = h * 0.35;
    for (final collarY in [collarY1, collarY2]) {
      final collarRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(poleX, collarY), width: poleWidth + 5, height: h * 0.022),
        const Radius.circular(3),
      );
      canvas.drawRRect(collarRect, Paint()..color = const Color(0xFF64748B));
    }

    // Tampa do topo do poste
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(poleX, poleTopY - h * 0.015), width: poleWidth + 4, height: h * 0.03),
      const Radius.circular(3),
    );
    canvas.drawRRect(capRect, Paint()..color = const Color(0xFF475569));

    // -------------------------------------------------------------
    // 4. Braço Curvado da Luminária (Arc)
    // -------------------------------------------------------------
    final armStartX = poleX;
    final armStartY = h * 0.14;
    final armEndX = w * 0.65;
    final armEndY = h * 0.08;

    final armPath = Path()
      ..moveTo(armStartX, armStartY)
      ..cubicTo(
        armStartX + w * 0.15, armStartY - h * 0.06,
        armEndX - w * 0.10, armEndY - h * 0.02,
        armEndX, armEndY,
      );

    final armPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(armPath, armPaint);

    // Highlights no braço curvado
    final armHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(armPath, armHighlightPaint);

    // -------------------------------------------------------------
    // 5. Cabeça da Luminária LED (Street Light Housing)
    // -------------------------------------------------------------
    final headX = w * 0.72;
    final headY = h * 0.09;
    final headW = w * 0.28;
    final headH = h * 0.07;

    // Carcaça metálica (Trapezoidal suavemente inclinada)
    final headPath = Path()
      ..moveTo(headX - headW / 2, headY)
      ..lineTo(headX + headW / 2, headY + h * 0.02)
      ..lineTo(headX + headW * 0.4, headY + headH + h * 0.01)
      ..lineTo(headX - headW * 0.45, headY + headH)
      ..close();

    final headGradient = const LinearGradient(
      colors: [
        Color(0xFF475569),
        Color(0xFF334155),
        Color(0xFF1E293B),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    canvas.drawPath(
      headPath,
      Paint()..shader = headGradient.createShader(Rect.fromLTWH(headX - headW / 2, headY, headW, headH)),
    );

    // -------------------------------------------------------------
    // 6. Painel de Lentes LED (Parte inferior da luminária)
    // -------------------------------------------------------------
    final lensY = headY + headH * 0.7;
    final lensPath = Path()
      ..moveTo(headX - headW * 0.42, lensY)
      ..lineTo(headX + headW * 0.38, lensY + h * 0.015)
      ..lineTo(headX + headW * 0.35, lensY + h * 0.035)
      ..lineTo(headX - headW * 0.40, lensY + h * 0.025)
      ..close();

    if (isActive) {
      // Estado LIGADO: Amarelo radiante brilhante
      final lensPaint = Paint()
        ..color = const Color(0xFFFACC15)
        ..style = PaintingStyle.fill;
      canvas.drawPath(lensPath, lensPaint);

      // Núcleo branco incandescente
      final corePath = Path()
        ..moveTo(headX - headW * 0.30, lensY + 2)
        ..lineTo(headX + headW * 0.25, lensY + h * 0.012 + 2)
        ..lineTo(headX + headW * 0.22, lensY + h * 0.025)
        ..lineTo(headX - headW * 0.28, lensY + h * 0.020)
        ..close();
      canvas.drawPath(corePath, Paint()..color = const Color(0xFFFFFBEB));
    } else {
      // Estado DESLIGADO: Painel cinza fosco / leitoso
      final lensPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.fill;
      canvas.drawPath(lensPath, lensPaint);

      // Borda sutil do painel leitoso
      canvas.drawPath(
        lensPath,
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StreetLampPainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.brightnessRatio != brightnessRatio ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
