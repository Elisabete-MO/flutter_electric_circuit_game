import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Painter customizado do Estande 11 (Praça da Maquete Coletiva — Equipe Urbana).
/// Renderiza:
/// - Modo Físico: Maquete tridimensional da comunidade (Casas com janelas iluminadas,
///   Avenida central com 4 postes de iluminação pública, Estufa Bio-Tech comunitária,
///   Portão automatizado da escola e Monumento Alpha Lumen central).
/// - Modo Esquemático: Barramento de distribuição em paralelo com 4 ramais independentes.
/// - Elétrons em fluxo distribuído por toda a rede urbana.
class PracaMaquetePainter extends CustomPainter {
  final int missionIndex;
  final double animValue;
  final bool usePhysicalStyle;

  // Estados dos subsistemas da maquete
  final bool housesOn;
  final bool streetlightsOn;
  final bool faultyStreetlightIsolated; // Se 1 poste queimou mas os outros 3 continuam acesos
  final bool greenhouseOn;
  final bool gateOn;
  final bool alphaMonumentOn;
  final bool isMainGridEnergized;

  PracaMaquetePainter({
    required this.missionIndex,
    required this.animValue,
    required this.usePhysicalStyle,
    this.housesOn = false,
    this.streetlightsOn = false,
    this.faultyStreetlightIsolated = false,
    this.greenhouseOn = false,
    this.gateOn = false,
    this.alphaMonumentOn = false,
    this.isMainGridEnergized = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (usePhysicalStyle) {
      _paintPhysical(canvas, size);
    } else {
      _paintSchematic(canvas, size);
    }
  }

  // =========================================================================
  // MODO FÍSICO REALISTA (MINIATURA URBANA)
  // =========================================================================

  void _paintPhysical(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fundo da Bancada da Maquete (Grama / Pátio Urbano)
    final boardRect = Rect.fromLTWH(w * 0.04, h * 0.18, w * 0.92, h * 0.72);
    final boardRRect = RRect.fromRectAndRadius(boardRect, const Radius.circular(20));

    // Grama e solo urbano
    final grassPaint = Paint()..color = const Color(0xFF064E3B);
    final framePaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(boardRRect, grassPaint);
    canvas.drawRRect(boardRRect, framePaint);

    // 1. Avenida Central Asfaltada (Cortando a maquete)
    final roadRect = Rect.fromLTWH(boardRect.left + 20, boardRect.top + boardRect.height * 0.44, boardRect.width - 40, 56);
    canvas.drawRect(roadRect, Paint()..color = const Color(0xFF1E293B));

    // Faixas tracejadas da avenida
    final dashPaint = Paint()
      ..color = const Color(0xFFFDE047)
      ..strokeWidth = 2.0;
    for (double x = roadRect.left + 10; x < roadRect.right - 10; x += 32) {
      canvas.drawLine(Offset(x, roadRect.center.dy), Offset(x + 18, roadRect.center.dy), dashPaint);
    }

    // 2. Setor Residencial (Topo Esquerdo)
    _drawResidentialSector(canvas, Rect.fromLTWH(boardRect.left + 30, boardRect.top + 20, boardRect.width * 0.32, boardRect.height * 0.36));

    // 3. Estufa Bio-Tech Comunitária (Topo Direito)
    _drawGreenhouseMini(canvas, Rect.fromLTWH(boardRect.right - boardRect.width * 0.32 - 30, boardRect.top + 20, boardRect.width * 0.32, boardRect.height * 0.36));

    // 4. Portão da Escola & Acesso (Base Direita)
    _drawSchoolGateMini(canvas, Rect.fromLTWH(boardRect.right - boardRect.width * 0.34 - 30, boardRect.bottom - boardRect.height * 0.34 - 10, boardRect.width * 0.34, boardRect.height * 0.34));

    // 5. Postes de Iluminação Pública ao longo da Avenida
    _drawStreetlightPoles(canvas, roadRect);

    // 6. Monumento Central Alpha Lumen (Praça Central)
    final centerPos = Offset(boardRect.center.dx, boardRect.center.dy + 8);
    _drawAlphaLumenMonument(canvas, centerPos);

    // 7. Linhas Elétricas e Elétrons em Fluxo
    _drawGridLines(canvas, boardRect, centerPos);
  }

  void _drawResidentialSector(Canvas canvas, Rect rect) {
    // 3 Casas geminadas
    final houseCount = 3;
    final w = rect.width / houseCount - 8;
    final h = rect.height - 10;

    for (int i = 0; i < houseCount; i++) {
      final left = rect.left + i * (w + 10);
      final houseRect = Rect.fromLTWH(left, rect.bottom - h + 10, w, h - 10);

      // Paredes
      final wallPaint = Paint()..color = const Color(0xFF334155);
      canvas.drawRect(houseRect, wallPaint);

      // Telhado triangular
      final roofPath = Path()
        ..moveTo(houseRect.left - 4, houseRect.top)
        ..lineTo(houseRect.center.dx, houseRect.top - 18)
        ..lineTo(houseRect.right + 4, houseRect.top)
        ..close();
      canvas.drawPath(roofPath, Paint()..color = const Color(0xFF991B1B));

      // Janelas com iluminação quente
      final winY = houseRect.top + 14;
      for (int wIdx = 0; wIdx < 2; wIdx++) {
        final winX = houseRect.left + 8 + wIdx * (houseRect.width - 24);
        final winRect = Rect.fromLTWH(winX, winY, 12, 14);

        final winColor = housesOn ? const Color(0xFFFBBF24) : const Color(0xFF0F172A);
        canvas.drawRect(winRect, Paint()..color = winColor);

        if (housesOn) {
          final glowPaint = Paint()
            ..color = const Color(0xFFFBBF24).withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
          canvas.drawRect(winRect, glowPaint);
        }
      }

      // Porta
      final doorRect = Rect.fromLTWH(houseRect.center.dx - 6, houseRect.bottom - 16, 12, 16);
      canvas.drawRect(doorRect, Paint()..color = const Color(0xFF475569));
    }

    final tp = TextPainter(
      text: TextSpan(
        text: 'VILA RESIDENCIAL',
        style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rect.left, rect.top - 4));
  }

  void _drawGreenhouseMini(Canvas canvas, Rect rect) {
    final ghRect = Rect.fromLTWH(rect.left + 10, rect.top + 14, rect.width - 20, rect.height - 24);
    final ghPaint = Paint()
      ..color = const Color(0xFFE0F2FE).withValues(alpha: greenhouseOn ? 0.45 : 0.15)
      ..style = PaintingStyle.fill;
    final framePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(ghRect, const Radius.circular(8));
    canvas.drawRRect(rrect, ghPaint);
    canvas.drawRRect(rrect, framePaint);

    if (greenhouseOn) {
      final growGlow = Paint()
        ..color = const Color(0xFFEC4899).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(ghRect.center, 18, growGlow);
    }

    // Mudas verdes dentro
    for (int i = 0; i < 3; i++) {
      final x = ghRect.left + 12 + i * (ghRect.width / 3);
      canvas.drawCircle(Offset(x, ghRect.bottom - 8), 4, Paint()..color = const Color(0xFF22C55E));
    }

    final tp = TextPainter(
      text: TextSpan(
        text: 'ESTUFA COMUNITÁRIA',
        style: GoogleFonts.rajdhani(color: const Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rect.left + 10, rect.top - 4));
  }

  void _drawSchoolGateMini(Canvas canvas, Rect rect) {
    final gRect = Rect.fromLTWH(rect.left + 10, rect.top + 16, rect.width - 20, rect.height - 26);
    final wallPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRRect(RRect.fromRectAndRadius(gRect, const Radius.circular(8)), wallPaint);

    // Gradil do portão
    final gateWidth = gRect.width * 0.6;
    final gateLeft = gateOn ? gRect.left + gRect.width * 0.35 : gRect.left + 8;
    final gateRect = Rect.fromLTWH(gateLeft, gRect.top + 8, gateWidth, gRect.height - 16);

    canvas.drawRect(
      gateRect,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // Giroflex amarelo
    final beaconColor = gateOn ? const Color(0xFFFBBF24) : const Color(0xFF64748B);
    canvas.drawCircle(Offset(gRect.left + 16, gRect.top + 6), 5, Paint()..color = beaconColor);
    if (gateOn) {
      canvas.drawCircle(
        Offset(gRect.left + 16, gRect.top + 6),
        10,
        Paint()
          ..color = const Color(0xFFFBBF24).withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    final tp = TextPainter(
      text: TextSpan(
        text: 'PORTÃO DA ESCOLA',
        style: GoogleFonts.rajdhani(color: const Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rect.left + 10, rect.top - 4));
  }

  void _drawStreetlightPoles(Canvas canvas, Rect road) {
    final poleCount = 4;
    final spacing = road.width / (poleCount + 1);

    for (int i = 1; i <= poleCount; i++) {
      final x = road.left + i * spacing;
      final yTop = road.top - 18;
      final yBase = road.top + 4;

      // Poste de metal
      canvas.drawLine(Offset(x, yBase), Offset(x, yTop), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2.5);
      // Braço da luminária
      canvas.drawLine(Offset(x, yTop), Offset(x + 8, yTop + 2), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2.0);

      // Lâmpada (o poste 2 pode simular falha isolada na M2)
      final isPoleOff = faultyStreetlightIsolated && i == 2;
      final isLit = streetlightsOn && !isPoleOff;

      final lampColor = isLit ? const Color(0xFFFEF08A) : const Color(0xFF475569);
      canvas.drawCircle(Offset(x + 8, yTop + 4), 3.5, Paint()..color = lampColor);

      if (isLit) {
        // Cone de luz suave no asfalto
        final conePath = Path()
          ..moveTo(x + 8, yTop + 4)
          ..lineTo(x + 24, road.bottom - 6)
          ..lineTo(x - 8, road.bottom - 6)
          ..close();
        final conePaint = Paint()
          ..color = const Color(0xFFFEF08A).withValues(alpha: 0.20)
          ..style = PaintingStyle.fill;
        canvas.drawPath(conePath, conePaint);
      }
    }
  }

  void _drawAlphaLumenMonument(Canvas canvas, Offset center) {
    // Base circular do monumento
    final basePaint = Paint()..color = const Color(0xFF0F172A);
    final borderPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 22, basePaint);
    canvas.drawCircle(center, 22, borderPaint);

    // Emblema Central Alpha Lumen / Átomo
    final starColor = alphaMonumentOn ? const Color(0xFFA78BFA) : const Color(0xFF64748B);
    canvas.drawCircle(center, 7, Paint()..color = starColor);

    if (alphaMonumentOn) {
      final glowPaint = Paint()
        ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, 28, glowPaint);
    }

    final tp = TextPainter(
      text: TextSpan(
        text: 'PRAÇA ALPHA',
        style: GoogleFonts.rajdhani(color: const Color(0xFFA78BFA), fontSize: 9, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 24));
  }

  void _drawGridLines(Canvas canvas, Rect board, Offset center) {
    if (!isMainGridEnergized) return;

    final wirePaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final electronPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;

    // Ramal 1: Centro -> Casas
    final pRes = Offset(board.left + board.width * 0.18, board.top + board.height * 0.32);
    canvas.drawLine(center, pRes, wirePaint);

    // Ramal 2: Centro -> Estufa
    final pGreen = Offset(board.right - board.width * 0.18, board.top + board.height * 0.32);
    canvas.drawLine(center, pGreen, wirePaint);

    // Ramal 3: Centro -> Portão
    final pGate = Offset(board.right - board.width * 0.18, board.bottom - board.height * 0.25);
    canvas.drawLine(center, pGate, wirePaint);

    // Fluxo de elétrons se energizado
    if (housesOn || streetlightsOn || greenhouseOn || gateOn) {
      final t = animValue;
      for (final target in [pRes, pGreen, pGate]) {
        final pos = Offset.lerp(center, target, t)!;
        canvas.drawCircle(pos, 3.5, electronPaint);
      }
    }
  }

  // =========================================================================
  // MODO ESQUEMÁTICO TÉCNICO
  // =========================================================================

  void _paintSchematic(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final wirePaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Barramento Principal de 12V em paralelo
    final busLeft = w * 0.10;
    final busRight = w * 0.90;
    final busTop = h * 0.28;
    final busBottom = h * 0.74;

    // Linha Positiva (+12V) no topo
    canvas.drawLine(Offset(busLeft, busTop), Offset(busRight, busTop), wirePaint..color = const Color(0xFFEF4444));
    // Linha Negativa (GND) na base
    canvas.drawLine(Offset(busLeft, busBottom), Offset(busRight, busBottom), wirePaint..color = const Color(0xFF0284C7));

    // Fonte de Alimentação da Maquete à esquerda
    _drawSchematicSource(canvas, Offset(busLeft + 20, (busTop + busBottom) / 2));

    // 4 Ramos em Paralelo
    final branchSpacing = (busRight - busLeft - 80) / 4;

    // Ramo 1: Casas (Cargas Resistivas / Lâmpadas)
    final x1 = busLeft + 80 + branchSpacing * 0.5;
    _drawSchematicBranch(canvas, x1, busTop, busBottom, 'CASAS (PARALELO)', housesOn, const Color(0xFFFBBF24));

    // Ramo 2: Postes de Iluminação Pública
    final x2 = busLeft + 80 + branchSpacing * 1.5;
    _drawSchematicBranch(canvas, x2, busTop, busBottom, 'ILUM. PÚBLICA', streetlightsOn, const Color(0xFFFEF08A));

    // Ramo 3: Estufa Bio-Tech (LDR + LED)
    final x3 = busLeft + 80 + branchSpacing * 2.5;
    _drawSchematicBranch(canvas, x3, busTop, busBottom, 'ESTUFA BIO-TECH', greenhouseOn, const Color(0xFF10B981));

    // Ramo 4: Portão da Escola (Relé + Motor)
    final x4 = busLeft + 80 + branchSpacing * 3.5;
    _drawSchematicBranch(canvas, x4, busTop, busBottom, 'PORTÃO ESCOLA', gateOn, const Color(0xFFF59E0B));
  }

  void _drawSchematicSource(Canvas canvas, Offset center) {
    final bg = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromCenter(center: center, width: 30, height: 50), bg);

    final p = Paint()..color = Colors.white..strokeWidth = 3.0;
    canvas.drawLine(Offset(center.dx - 14, center.dy - 8), Offset(center.dx + 14, center.dy - 8), p);
    canvas.drawLine(Offset(center.dx - 8, center.dy + 8), Offset(center.dx + 8, center.dy + 8), p..strokeWidth = 4.5);

    final tp = TextPainter(
      text: TextSpan(text: 'SUBESTAÇÃO\n12V DC', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, height: 1.1)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 26));
  }

  void _drawSchematicBranch(Canvas canvas, double x, double top, double bottom, String label, bool isActive, Color activeColor) {
    final branchPaint = Paint()
      ..color = isActive ? activeColor : const Color(0xFF475569)
      ..strokeWidth = 2.5;

    canvas.drawLine(Offset(x, top), Offset(x, bottom), branchPaint);

    // Círculo de Carga / Consumidor
    final centerY = (top + bottom) / 2;
    canvas.drawCircle(Offset(x, centerY), 14, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset(x, centerY), 14, Paint()..color = isActive ? activeColor : const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: GoogleFonts.rajdhani(color: isActive ? activeColor : Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, centerY + 18));
  }

  @override
  bool shouldRepaint(covariant PracaMaquetePainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.usePhysicalStyle != usePhysicalStyle ||
        oldDelegate.housesOn != housesOn ||
        oldDelegate.streetlightsOn != streetlightsOn ||
        oldDelegate.faultyStreetlightIsolated != faultyStreetlightIsolated ||
        oldDelegate.greenhouseOn != greenhouseOn ||
        oldDelegate.gateOn != gateOn ||
        oldDelegate.alphaMonumentOn != alphaMonumentOn ||
        oldDelegate.isMainGridEnergized != isMainGridEnergized;
  }
}
