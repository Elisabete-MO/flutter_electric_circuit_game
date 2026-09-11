import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renderizador vetorial de Alta Fidelidade da Maquete da Horta Monitorada (Top-Down).
///
/// Apresenta:
/// - Canteiros de cultivo com textura de solo rica e moldura com chanfro de madeira/alumínio.
/// - Hortaliças vetoriais detalhadas (Alfaces com folhas frisadas em camadas concêntricas, Tomateiros com cachos de frutos vermelhos e brilho).
/// - Trilhos de Grow LED com calha de alumínio extrudado e cone de luz gradiente (*bloom*).
/// - Sondas de umidade com pontas douradas, LEDs de status e ondas de pulso telemétrico.
/// - Exaustores axiais de canto com carcaça industrial, grade de proteção e pás aerodinâmicas giratórias.
/// - Sistema de tubulação de irrigação por gotejamento com gotas d'água animadas.
class HortaTopDownPainter extends CustomPainter {
  final double animValue;
  final bool showGrowLights;
  final double growLightIntensity; // 0.0 a 1.0
  final bool showMoistureProbes;
  final double soilMoisture; // 0.0 (seco) a 1.0 (úmido)
  final bool showCoolingFans;
  final bool isFanActive;
  final double fanSpeed; // 0.0 a 1.0
  final bool showIrrigation;
  final bool isIrrigating;
  final bool showMasterBus;
  final bool isMasterActive;

  HortaTopDownPainter({
    required this.animValue,
    this.showGrowLights = true,
    this.growLightIntensity = 0.85,
    this.showMoistureProbes = true,
    this.soilMoisture = 0.70,
    this.showCoolingFans = true,
    this.isFanActive = true,
    this.fanSpeed = 1.0,
    this.showIrrigation = true,
    this.isIrrigating = false,
    this.showMasterBus = true,
    this.isMasterActive = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRect(rect);

    // 1. Piso da Estufa / Grid Tecnológico
    _drawBaseFloor(canvas, size);

    // 2. Canteiros com Solo e Vegetais
    _drawGardenBedsAndCrops(canvas, size);

    // 3. Camada M4: Tubulação de Irrigação
    if (showIrrigation) {
      _drawIrrigationPipes(canvas, size);
    }

    // 4. Camada M2: Sondas de Umidade
    if (showMoistureProbes) {
      _drawSoilMoistureProbes(canvas, size);
    }

    // 5. Camada M3: Exaustores/Ventiladores de Canto
    if (showCoolingFans) {
      _drawCornerCoolingFans(canvas, size);
    }

    // 6. Camada M1: Trilhos de Luz de Cultivo (Grow Light)
    if (showGrowLights) {
      _drawGrowLightRails(canvas, size);
    }

    // 7. Camada M5: Painel de Telemetria e Barramento
    if (showMasterBus) {
      _drawMasterStatusOverlay(canvas, size);
    }

    canvas.restore();
  }

  void _drawBaseFloor(Canvas canvas, Size size) {
    final outerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(6, 6, size.width - 12, size.height - 12),
      const Radius.circular(14),
    );

    // Piso estufa
    canvas.drawRRect(outerRRect, Paint()..color = const Color(0xFF0F172A));
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Grid sutil
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const step = 22.0;
    for (double x = 14; x < size.width - 12; x += step) {
      canvas.drawLine(Offset(x, 14), Offset(x, size.height - 14), gridPaint);
    }
    for (double y = 14; y < size.height - 12; y += step) {
      canvas.drawLine(Offset(14, y), Offset(size.width - 14, y), gridPaint);
    }
  }

  void _drawGardenBedsAndCrops(Canvas canvas, Size size) {
    // Canteiro Superior
    final topBedRect = Rect.fromLTWH(18, 18, size.width - 96, (size.height - 52) * 0.44);
    _drawSingleBed(canvas, topBedRect, isTopBed: true);

    // Canteiros Inferiores
    final bottomBedHeight = (size.height - 52) * 0.46;
    final bottomBedY = topBedRect.bottom + 12;
    final bedWidth = (size.width - 110) / 2;

    final bottomLeftRect = Rect.fromLTWH(18, bottomBedY, bedWidth, bottomBedHeight);
    final bottomRightRect = Rect.fromLTWH(18 + bedWidth + 12, bottomBedY, bedWidth, bottomBedHeight);

    _drawSingleBed(canvas, bottomLeftRect, isTopBed: false);
    _drawSingleBed(canvas, bottomRightRect, isTopBed: false);
  }

  void _drawSingleBed(Canvas canvas, Rect bedRect, {required bool isTopBed}) {
    // Cor do solo com transição suave de seca para úmido
    final drySoil = const Color(0xFF453221);
    final wetSoil = const Color(0xFF1B120C);
    final soilColor = Color.lerp(drySoil, wetSoil, soilMoisture.clamp(0.0, 1.0))!;

    final bedRRect = RRect.fromRectAndRadius(bedRect, const Radius.circular(10));

    // Sombra interna do canteiro
    canvas.drawRRect(
      bedRRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Solo
    canvas.drawRRect(bedRRect, Paint()..color = soilColor);

    // Moldura com chanfro de alumínio/madeira
    canvas.drawRRect(
      bedRRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF64748B), Color(0xFF475569), Color(0xFF334155)],
        ).createShader(bedRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    // Textura orgânica de terra com pontos de nutrientes
    final specklePaint = Paint()..color = Colors.black38;
    final random = math.Random(bedRect.left.toInt());
    for (int i = 0; i < 20; i++) {
      final sx = bedRect.left + 6 + random.nextDouble() * (bedRect.width - 12);
      final sy = bedRect.top + 6 + random.nextDouble() * (bedRect.height - 12);
      canvas.drawCircle(Offset(sx, sy), 1.2, specklePaint);
    }

    // Vegetais
    if (isTopBed) {
      _drawLettuceAndTomatoRow(canvas, Rect.fromLTWH(bedRect.left + 10, bedRect.top + 8, bedRect.width - 20, bedRect.height - 16));
    } else {
      _drawSeedlingRow(canvas, Rect.fromLTWH(bedRect.left + 8, bedRect.top + 8, bedRect.width - 16, bedRect.height - 16));
    }
  }

  void _drawLettuceAndTomatoRow(Canvas canvas, Rect area) {
    final cols = (area.width / 42).floor().clamp(3, 7);
    final colStep = area.width / cols;

    for (int c = 0; c < cols; c++) {
      final cx = area.left + colStep * c + colStep / 2;
      final cy = area.top + area.height / 2;

      if (c < cols - 2) {
        _drawOrganicLettuce(canvas, Offset(cx, cy), radius: 15);
      } else {
        _drawOrganicTomato(canvas, Offset(cx, cy));
      }
    }
  }

  void _drawOrganicLettuce(Canvas canvas, Offset center, {required double radius}) {
    final leafTones = [
      const Color(0xFF15803D),
      const Color(0xFF22C55E),
      const Color(0xFF4ADE80),
      const Color(0xFF86EFAC),
    ];

    for (int r = 0; r < leafTones.length; r++) {
      final currentR = radius * (1.0 - (r * 0.22));
      final tone = leafTones[r];

      final leafPath = Path();
      const petals = 6;
      for (int i = 0; i < petals; i++) {
        final angle = (i * 2 * math.pi / petals) + (r * 0.4);
        final px = center.dx + math.cos(angle) * currentR;
        final py = center.dy + math.sin(angle) * currentR;
        if (i == 0) {
          leafPath.moveTo(px, py);
        } else {
          final cpAngle = angle - (math.pi / petals);
          final cpx = center.dx + math.cos(cpAngle) * (currentR * 1.15);
          final cpy = center.dy + math.sin(cpAngle) * (currentR * 1.15);
          leafPath.quadraticBezierTo(cpx, cpy, px, py);
        }
      }
      leafPath.close();

      canvas.drawPath(leafPath, Paint()..color = tone);
      canvas.drawPath(
        leafPath,
        Paint()
          ..color = const Color(0xFF14532D).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  void _drawOrganicTomato(Canvas canvas, Offset center) {
    // Folhas do tomateiro
    final leafPaint = Paint()..color = const Color(0xFF16A34A);
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 + math.pi / 4;
      final lx = center.dx + math.cos(angle) * 11;
      final ly = center.dy + math.sin(angle) * 11;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(lx, ly), width: 13, height: 7),
        leafPaint,
      );
    }

    // Tomatinhos cereja brilhantes
    final offsets = [
      Offset(center.dx - 4.5, center.dy - 3),
      Offset(center.dx + 4.5, center.dy + 3),
      Offset(center.dx, center.dy + 5.5),
    ];

    for (final pos in offsets) {
      // Tomate
      canvas.drawCircle(
        pos,
        4.2,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFFF87171), Color(0xFFEF4444), Color(0xFFB91C1C)],
          ).createShader(Rect.fromCircle(center: pos, radius: 4.2)),
      );

      // Reflexo brilhante
      canvas.drawCircle(Offset(pos.dx - 1.2, pos.dy - 1.2), 1.2, Paint()..color = Colors.white70);

      // Sépalas verdes no topo do tomate
      final calyxPaint = Paint()..color = const Color(0xFF15803D)..strokeWidth = 1.0;
      canvas.drawLine(pos, Offset(pos.dx - 2, pos.dy - 3), calyxPaint);
      canvas.drawLine(pos, Offset(pos.dx + 2, pos.dy - 3), calyxPaint);
    }
  }

  void _drawSeedlingRow(Canvas canvas, Rect area) {
    final cols = (area.width / 30).floor().clamp(2, 6);
    final colStep = area.width / cols;

    for (int c = 0; c < cols; c++) {
      final cx = area.left + colStep * c + colStep / 2;
      final cy = area.top + area.height / 2;

      // Par de folhas cotiledonares
      final leafPaint = Paint()..color = const Color(0xFF22C55E);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - 4.5, cy), width: 8, height: 4.5),
        leafPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 4.5, cy), width: 8, height: 4.5),
        leafPaint,
      );
      canvas.drawCircle(Offset(cx, cy), 1.8, Paint()..color = const Color(0xFF15803D));
    }
  }

  void _drawGrowLightRails(Canvas canvas, Size size) {
    final topBedRect = Rect.fromLTWH(18, 18, size.width - 96, (size.height - 52) * 0.44);
    final railY = topBedRect.top + topBedRect.height * 0.35;
    final railLeft = topBedRect.left + 12;
    final railRight = topBedRect.right - 12;

    final intensity = growLightIntensity.clamp(0.0, 1.0);

    if (intensity > 0.05) {
      // Cone de luz e glow estendido
      final glowRect = Rect.fromLTRB(railLeft - 8, topBedRect.top, railRight + 8, topBedRect.bottom);
      final glowColor = Color.lerp(
        const Color(0xFFFBBF24),
        const Color(0xFFA855F7),
        0.5,
      )!.withValues(alpha: 0.32 * intensity);

      canvas.drawRect(
        glowRect,
        Paint()
          ..color = glowColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    // Calha de Alumínio Extrudado
    final railRect = Rect.fromLTRB(railLeft, railY - 5, railRight, railY + 5);
    final railRRect = RRect.fromRectAndRadius(railRect, const Radius.circular(4));

    canvas.drawRRect(
      railRRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF64748B), Color(0xFF334155), Color(0xFF1E293B)],
        ).createShader(railRect),
    );
    canvas.drawRRect(
      railRRect,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Diodos LED emissores
    final ledColor = Color.lerp(
      const Color(0xFF475569),
      const Color(0xFFFDE047),
      intensity,
    )!;

    const ledCount = 8;
    final ledStep = (railRight - railLeft - 16) / (ledCount - 1);
    for (int i = 0; i < ledCount; i++) {
      final lx = railLeft + 8 + ledStep * i;
      canvas.drawCircle(Offset(lx, railY), 2.2, Paint()..color = ledColor);
      if (intensity > 0.1) {
        canvas.drawCircle(
          Offset(lx, railY),
          4.5,
          Paint()
            ..color = ledColor.withValues(alpha: 0.6 * intensity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  void _drawSoilMoistureProbes(Canvas canvas, Size size) {
    final bottomBedHeight = (size.height - 52) * 0.46;
    final bottomBedY = 18 + (size.height - 52) * 0.44 + 12;
    final bedWidth = (size.width - 110) / 2;

    final probes = [
      Offset(18 + bedWidth * 0.75, bottomBedY + bottomBedHeight * 0.5),
      Offset(18 + bedWidth + 12 + bedWidth * 0.75, bottomBedY + bottomBedHeight * 0.5),
    ];

    for (final pos in probes) {
      final probeRect = Rect.fromCenter(center: pos, width: 16, height: 30);
      final probeRRect = RRect.fromRectAndRadius(probeRect, const Radius.circular(6));

      // Sombra
      canvas.drawRRect(
        probeRRect.shift(const Offset(1, 2)),
        Paint()..color = Colors.black38,
      );

      // Placa da sonda (PCB azul)
      canvas.drawRRect(probeRRect, Paint()..color = const Color(0xFF0284C7));
      canvas.drawRRect(
        probeRRect,
        Paint()
          ..color = const Color(0xFF38BDF8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // LED indicador na cabeça da sonda
      final statusColor = soilMoisture < 0.35
          ? const Color(0xFFEF4444) // Alerta seca
          : const Color(0xFF10B981); // OK

      canvas.drawCircle(Offset(pos.dx, pos.dy - 6), 3.5, Paint()..color = statusColor);

      // Anéis de pulso telemétrico
      final pulseRadius = 5.0 + 4.5 * math.sin(animValue * 2 * math.pi).abs();
      canvas.drawCircle(
        Offset(pos.dx, pos.dy - 6),
        pulseRadius,
        Paint()
          ..color = statusColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  void _drawCornerCoolingFans(Canvas canvas, Size size) {
    final fanCenters = [
      Offset(size.width - 44, 46),
      Offset(size.width - 44, size.height - 46),
    ];

    for (final center in fanCenters) {
      // Carcaça circular do cooler
      canvas.drawCircle(
        center,
        22,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
          ).createShader(Rect.fromCircle(center: center, radius: 22)),
      );
      canvas.drawCircle(
        center,
        22,
        Paint()
          ..color = const Color(0xFF0284C7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      // Parafusos nos cantos da carcaça
      final screwPaint = Paint()..color = const Color(0xFF94A3B8);
      canvas.drawCircle(Offset(center.dx - 14, center.dy - 14), 1.5, screwPaint);
      canvas.drawCircle(Offset(center.dx + 14, center.dy - 14), 1.5, screwPaint);
      canvas.drawCircle(Offset(center.dx - 14, center.dy + 14), 1.5, screwPaint);
      canvas.drawCircle(Offset(center.dx + 14, center.dy + 14), 1.5, screwPaint);

      // Pás do cooler girando
      canvas.save();
      canvas.translate(center.dx, center.dy);
      if (isFanActive) {
        canvas.rotate(animValue * 2 * math.pi * fanSpeed.clamp(0.2, 2.0));
      }

      final bladePaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        ).createShader(const Rect.fromLTWH(-18, -18, 36, 36));

      for (int b = 0; b < 4; b++) {
        canvas.rotate(math.pi / 2);
        final bladePath = Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(7, -8, 3, -18)
          ..lineTo(-3, -18)
          ..quadraticBezierTo(-7, -8, 0, 0);
        canvas.drawPath(bladePath, bladePaint);
      }

      // Hub central
      canvas.drawCircle(Offset.zero, 5.5, Paint()..color = const Color(0xFF0F172A));
      canvas.drawCircle(Offset.zero, 3.0, Paint()..color = const Color(0xFF0284C7));
      canvas.drawCircle(Offset.zero, 1.2, Paint()..color = Colors.white);
      canvas.restore();
    }
  }

  void _drawIrrigationPipes(Canvas canvas, Size size) {
    final topBedRect = Rect.fromLTWH(18, 18, size.width - 96, (size.height - 52) * 0.44);
    final pipePaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Tubo principal
    final pipeY = topBedRect.bottom - 10;
    canvas.drawLine(
      Offset(topBedRect.left + 6, pipeY),
      Offset(topBedRect.right - 6, pipeY),
      pipePaint,
    );

    // Brilho especular no duto
    canvas.drawLine(
      Offset(topBedRect.left + 6, pipeY - 1.0),
      Offset(topBedRect.right - 6, pipeY - 1.0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Gotas de irrigação ativas
    if (isIrrigating) {
      final dropPaint = Paint()..color = const Color(0xFF38BDF8);
      const dropCount = 5;
      final step = (topBedRect.width - 24) / dropCount;

      for (int i = 0; i < dropCount; i++) {
        final dx = topBedRect.left + 12 + step * i;
        final dropOffset = (animValue * 14) % 12;
        canvas.drawCircle(Offset(dx, pipeY + 3 + dropOffset), 2.2, dropPaint);
        canvas.drawCircle(Offset(dx - 0.6, pipeY + 2.4 + dropOffset), 0.8, Paint()..color = Colors.white70);
      }
    }
  }

  void _drawMasterStatusOverlay(Canvas canvas, Size size) {
    final hudRect = Rect.fromLTWH(size.width - 82, (size.height - 54) / 2, 74, 54);
    final hudRRect = RRect.fromRectAndRadius(hudRect, const Radius.circular(8));

    canvas.drawRRect(hudRRect, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.9));
    canvas.drawRRect(
      hudRRect,
      Paint()
        ..color = isMasterActive ? const Color(0xFF10B981) : const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: isMasterActive ? 'SISTEMA\nATIVO' : 'SISTEMA\nSTANDBY',
        style: GoogleFonts.rajdhani(
          color: isMasterActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
          fontSize: 9.0,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(hudRect.center.dx - tp.width / 2, hudRect.center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant HortaTopDownPainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.showGrowLights != showGrowLights ||
        oldDelegate.growLightIntensity != growLightIntensity ||
        oldDelegate.showMoistureProbes != showMoistureProbes ||
        oldDelegate.soilMoisture != soilMoisture ||
        oldDelegate.showCoolingFans != showCoolingFans ||
        oldDelegate.isFanActive != isFanActive ||
        oldDelegate.fanSpeed != fanSpeed ||
        oldDelegate.showIrrigation != showIrrigation ||
        oldDelegate.isIrrigating != isIrrigating ||
        oldDelegate.showMasterBus != showMasterBus ||
        oldDelegate.isMasterActive != isMasterActive;
  }
}
