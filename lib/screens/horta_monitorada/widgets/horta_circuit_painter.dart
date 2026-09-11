import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Painter de Alta Fidelidade do Estande 09 (Horta Monitorada) baseado em PROTOBOARD (Breadboard 830 pontos).
///
/// Apresenta:
/// 1. MODO FÍSICO 3D COM PROTOBOARD:
///    - Chassi de plástico ABS marfim/off-white com dentes de encaixe lateral e canaleta central.
///    - Barramentos de alimentação (+ Vermelho e - Azul) com inscrições de polaridade.
///    - Matriz de furos de contato niquelados identificados por colunas (1..24) e linhas (a..e / f..j).
///    - Bateria 9V com clip snap conectada aos barramentos da protoboard.
///    - Componentes reais (Potenciômetro, Chave, Resistor 220Ω, LED Grow, LED Alerta, Sensor de Solo e Motores)
///      com seus terminais inseridos nos furos da placa.
///    - Jumpers flexíveis coloridos com pinos de conexão, sombra, brilho 3D e elétrons animados.
///    - Jumpers de saída estendidos que viajam até a maquete da horta.
///
/// 2. MODO ESQUEMÁTICO IEC/ABNT:
///    - Símbolos normatizados padrão para todos os componentes com nós J1..J6.
class HortaCircuitPainter extends CustomPainter {
  final int missionIndex;
  final double animValue;
  final bool usePhysicalStyle;
  final bool isSwitchClosed;
  final double potentiometerValue;
  final double soilMoistureLevel;
  final bool isMotorConnected;
  final bool isPumpConnected;
  final bool isBranch1Active;
  final bool isBranch2Active;
  final bool isBranch3Active;
  final bool isBranch4Active;

  HortaCircuitPainter({
    required this.missionIndex,
    required this.animValue,
    this.usePhysicalStyle = true,
    this.isSwitchClosed = true,
    this.potentiometerValue = 0.8,
    this.soilMoistureLevel = 0.7,
    this.isMotorConnected = true,
    this.isPumpConnected = true,
    this.isBranch1Active = true,
    this.isBranch2Active = true,
    this.isBranch3Active = true,
    this.isBranch4Active = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRect(rect);

    // Fundo da bancada de laboratório
    _drawBenchBackground(canvas, size);

    if (usePhysicalStyle) {
      _drawPhysicalProtoboardWorkbench(canvas, size);
    } else {
      _drawSchematicCircuit(canvas, size);
    }

    canvas.restore();
  }

  void _drawBenchBackground(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
      const Radius.circular(12),
    );

    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF091124));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Grade eletrônica
    final dotPaint = Paint()..color = const Color(0xFF334155).withValues(alpha: 0.35);
    const step = 20.0;
    for (double x = 16; x < size.width - 12; x += step) {
      for (double y = 16; y < size.height - 12; y += step) {
        canvas.drawCircle(Offset(x, y), 0.9, dotPaint);
      }
    }
  }

  // =========================================================================
  // MODO FÍSICO COM PROTOBOARD REALISTA (830 PONTOS)
  // =========================================================================

  void _drawPhysicalProtoboardWorkbench(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Dimensões da Bateria 9V à esquerda
    final batWidth = (w * 0.16).clamp(52.0, 90.0);
    final batHeight = (batWidth * 1.55).clamp(84.0, 140.0);
    final batLeft = 14.0;
    final batTop = (h - batHeight) / 2;
    final batteryRect = Rect.fromLTWH(batLeft, batTop, batWidth, batHeight);

    // 2. Dimensões da Protoboard Central
    final bbLeft = batteryRect.right + 16.0;
    final bbWidth = (w - bbLeft - 14.0).clamp(180.0, 520.0);
    final bbTop = (h * 0.12).clamp(24.0, 60.0);
    final bbHeight = (h * 0.76).clamp(180.0, 320.0);
    final breadboardRect = Rect.fromLTWH(bbLeft, bbTop, bbWidth, bbHeight);

    // 3. Renderizar Protoboard
    _drawBreadboard(canvas, breadboardRect);

    // 4. Renderizar Bateria 9V
    _drawBattery9V(canvas, batteryRect);

    // 5. Jumpers e Conexões
    _drawProtoboardJumpersAndWires(canvas, breadboardRect, batteryRect);

    // 6. Componentes Inseridos na Protoboard
    _drawProtoboardComponents(canvas, breadboardRect);
  }

  void _drawBreadboard(Canvas canvas, Rect rect) {
    // Sombra da Protoboard
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(3, 5)), const Radius.circular(12)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Chassi ABS Fosco Marfim/Off-White
    final boardPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFAFAFA), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), boardPaint);

    // Borda chanfrada
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Encaixes laterais (dentes macho/fêmea típicos)
    final notchPaint = Paint()..color = const Color(0xFFE2E8F0);
    final notchBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (double ny = rect.top + rect.height * 0.30; ny <= rect.top + rect.height * 0.70; ny += rect.height * 0.40) {
      final leftNotch = Rect.fromCenter(center: Offset(rect.left, ny), width: 5, height: 14);
      canvas.drawRRect(RRect.fromRectAndRadius(leftNotch, const Radius.circular(2)), notchPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(leftNotch, const Radius.circular(2)), notchBorder);

      final rightNotch = Rect.fromCenter(center: Offset(rect.right, ny), width: 5, height: 14);
      canvas.drawRRect(RRect.fromRectAndRadius(rightNotch, const Radius.circular(2)), notchPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rightNotch, const Radius.circular(2)), notchBorder);
    }

    // Canaleta Central (Trench)
    final trenchY = rect.top + rect.height * 0.50;
    final trenchRect = Rect.fromLTWH(rect.left + 20, trenchY - 4, rect.width - 40, 8);
    final trenchPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF94A3B8), Color(0xFFCBD5E1), Color(0xFFE2E8F0)],
      ).createShader(trenchRect);
    canvas.drawRRect(RRect.fromRectAndRadius(trenchRect, const Radius.circular(2)), trenchPaint);
    canvas.drawLine(
      Offset(trenchRect.left + 4, trenchY),
      Offset(trenchRect.right - 4, trenchY),
      Paint()..color = const Color(0xFF64748B)..strokeWidth = 1.0,
    );

    // Barramentos de Alimentação (+ e -)
    final topPlusY = rect.top + rect.height * 0.08;
    final topMinusY = rect.top + rect.height * 0.15;
    final botMinusY = rect.top + rect.height * 0.85;
    final botPlusY = rect.top + rect.height * 0.92;

    final busLeft = rect.left + 24.0;
    final busRight = rect.right - 24.0;

    _drawRailLine(canvas, Offset(busLeft, topPlusY), Offset(busRight, topPlusY), const Color(0xFFEF4444), '+');
    _drawRailLine(canvas, Offset(busLeft, topMinusY), Offset(busRight, topMinusY), const Color(0xFF3B82F6), '–');
    _drawRailLine(canvas, Offset(busLeft, botMinusY), Offset(busRight, botMinusY), const Color(0xFF3B82F6), '–');
    _drawRailLine(canvas, Offset(busLeft, botPlusY), Offset(busRight, botPlusY), const Color(0xFFEF4444), '+');

    // Matriz de Furos e Coordenadas
    _drawHolesGrid(canvas, rect, topPlusY, topMinusY, botMinusY, botPlusY);

    // Inscrição Técnica
    final tp = TextPainter(
      text: TextSpan(
        text: 'ELETROLAB · PROTOBOARD 830 PONTOS · HORTA BIO-TECH',
        style: GoogleFonts.rajdhani(
          color: const Color(0xFF94A3B8),
          fontSize: 7.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rect.left + 26, rect.top + 2));
  }

  void _drawRailLine(Canvas canvas, Offset start, Offset end, Color color, String sign) {
    canvas.drawLine(start, end, Paint()..color = color.withValues(alpha: 0.85)..strokeWidth = 1.5);
    final tp = TextPainter(
      text: TextSpan(text: sign, style: GoogleFonts.rajdhani(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(start.dx - 10, start.dy - tp.height / 2));
    tp.paint(canvas, Offset(end.dx + 4, end.dy - tp.height / 2));
  }

  void _drawHolesGrid(Canvas canvas, Rect rect, double topPlusY, double topMinusY, double botMinusY, double botPlusY) {
    const cols = 20;
    final startX = rect.left + 28.0;
    final stepX = (rect.width - 56.0) / (cols - 1);

    final rowStepTop = (rect.height * 0.24) / 4;
    final rowStartYTop = rect.top + rect.height * 0.22;

    final rowStepBot = (rect.height * 0.24) / 4;
    final rowStartYBot = rect.top + rect.height * 0.56;

    // Furos dos Barramentos
    for (int col = 0; col < cols; col++) {
      final cx = startX + col * stepX;
      _drawSingleHole(canvas, Offset(cx, topPlusY));
      _drawSingleHole(canvas, Offset(cx, topMinusY));
      _drawSingleHole(canvas, Offset(cx, botMinusY));
      _drawSingleHole(canvas, Offset(cx, botPlusY));

      // Número da coluna
      if (col % 5 == 0 || col == cols - 1) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${col + 1}',
            style: GoogleFonts.rajdhani(color: const Color(0xFF64748B), fontSize: 6.5, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, rowStartYTop - 10));
      }

      // 5 furos superiores (a..e)
      for (int r = 0; r < 5; r++) {
        _drawSingleHole(canvas, Offset(cx, rowStartYTop + r * rowStepTop));
      }

      // 5 furos inferiores (f..j)
      for (int r = 0; r < 5; r++) {
        _drawSingleHole(canvas, Offset(cx, rowStartYBot + r * rowStepBot));
      }
    }
  }

  void _drawSingleHole(Canvas canvas, Offset pos) {
    // Contato metálico niquelado
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 3.6, height: 3.6), const Radius.circular(0.8)),
      Paint()..color = const Color(0xFF94A3B8),
    );
    // Furo quadrado interno
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 2.2, height: 2.2), const Radius.circular(0.5)),
      Paint()..color = const Color(0xFF1E293B),
    );
  }

  void _drawBattery9V(Canvas canvas, Rect rect) {
    // Sombra
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(3, 4)), const Radius.circular(8)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Corpo metálico escuro
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), bodyPaint);

    // Topo dourado metálico
    final topRect = Rect.fromLTWH(rect.left, rect.top, rect.width, 22);
    final topPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFBBF24), Color(0xFFD97706), Color(0xFFB45309)],
      ).createShader(topRect);
    canvas.drawRRect(
      RRect.fromRectAndCorners(topRect, topLeft: const Radius.circular(8), topRight: const Radius.circular(8)),
      topPaint,
    );

    // Polos metálicos superiores
    final posStud = Offset(rect.left + rect.width * 0.30, rect.top - 2);
    final negStud = Offset(rect.left + rect.width * 0.70, rect.top - 2);

    // Polo Positivo (+)
    canvas.drawCircle(posStud, 5.0, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(posStud, 3.0, Paint()..color = const Color(0xFFEF4444));
    // Polo Negativo (-)
    canvas.drawCircle(negStud, 6.0, Paint()..color = const Color(0xFF64748B));
    canvas.drawCircle(negStud, 3.5, Paint()..color = const Color(0xFF3B82F6));

    // Label 9V
    final tp = TextPainter(
      text: const TextSpan(
        text: '9V\nDC',
        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.1),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.center.dy - 6));
  }

  // -------------------------------------------------------------------------
  // JUMPERS FLEXÍVEIS E CONEXÕES NA PROTOBOARD
  // -------------------------------------------------------------------------

  void _drawProtoboardJumpersAndWires(Canvas canvas, Rect bb, Rect bat) {
    final isEnergized = isSwitchClosed;

    final topPlusY = bb.top + bb.height * 0.08;
    final topMinusY = bb.top + bb.height * 0.15;
    final botMinusY = bb.top + bb.height * 0.85;

    // 1. Cabos de Alimentação da Bateria para a Protoboard
    final batPos = Offset(bat.left + bat.width * 0.30, bat.top - 2);
    final batNeg = Offset(bat.left + bat.width * 0.70, bat.top - 2);

    final railPlusIn = Offset(bb.left + 32, topPlusY);
    final railMinusIn = Offset(bb.left + 32, topMinusY);

    // Cabo Positivo (+) Vermelho da Bateria
    final pBatPlus = Path()
      ..moveTo(batPos.dx, batPos.dy)
      ..cubicTo(batPos.dx, 16, railPlusIn.dx - 16, 16, railPlusIn.dx, railPlusIn.dy);
    _renderRealisticJumper(canvas, pBatPlus, const Color(0xFFEF4444), isEnergized, animValue, railPlusIn);

    // Cabo Negativo (-) Preto/Azul da Bateria
    final pBatNeg = Path()
      ..moveTo(batNeg.dx, batNeg.dy)
      ..cubicTo(batNeg.dx, 28, railMinusIn.dx - 16, 28, railMinusIn.dx, railMinusIn.dy);
    _renderRealisticJumper(canvas, pBatNeg, const Color(0xFF0284C7), isEnergized, animValue, railMinusIn, reverse: true);

    // 2. Jumpers de Interligação Interna dos Componentes na Protoboard
    final rowStartYTop = bb.top + bb.height * 0.22;
    final rowStepTop = (bb.height * 0.24) / 4;
    final rowStartYBot = bb.top + bb.height * 0.56;
    final rowStepBot = (bb.height * 0.24) / 4;

    const cols = 20;
    final startX = bb.left + 28.0;
    final stepX = (bb.width - 56.0) / (cols - 1);

    // Jumper Alimentação: Barramento (+) -> Coluna 4 (Linha A)
    final jPlus = Path()
      ..moveTo(startX + 3 * stepX, topPlusY)
      ..cubicTo(startX + 3 * stepX, topPlusY + 10, startX + 4 * stepX, rowStartYTop - 10, startX + 4 * stepX, rowStartYTop);
    _renderRealisticJumper(canvas, jPlus, const Color(0xFFEF4444), isEnergized, animValue, Offset(startX + 4 * stepX, rowStartYTop));

    // Jumper Retorno: Coluna 18 (Linha J) -> Barramento (-)
    final jMinus = Path()
      ..moveTo(startX + 17 * stepX, rowStartYBot + 4 * rowStepBot)
      ..cubicTo(startX + 17 * stepX, botMinusY - 10, startX + 16 * stepX, botMinusY - 10, startX + 16 * stepX, botMinusY);
    _renderRealisticJumper(canvas, jMinus, const Color(0xFF0284C7), isEnergized, animValue, Offset(startX + 16 * stepX, botMinusY), reverse: true);

    // 3. Jumpers de Saída que se conectam à Maquete da Horta (à direita)
    final exitY = rowStartYTop + 2 * rowStepTop;
    final jExit = Path()
      ..moveTo(startX + 17 * stepX, exitY)
      ..cubicTo(startX + 19 * stepX, exitY, bb.right + 10, exitY, bb.right + 20, exitY);
    _renderRealisticJumper(canvas, jExit, const Color(0xFFFBBF24), isEnergized, animValue, Offset(bb.right + 20, exitY));
  }

  void _renderRealisticJumper(Canvas canvas, Path path, Color color, bool isActive, double anim, Offset pinPos, {bool reverse = false}) {
    // Sombra do Jumper
    canvas.drawPath(
      path.shift(const Offset(1.5, 2.5)),
      Paint()..color = Colors.black.withValues(alpha: 0.25)..strokeWidth = 5.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );

    // Isolamento do Jumper
    canvas.drawPath(
      path,
      Paint()..color = isActive ? color : color.withValues(alpha: 0.45)..strokeWidth = 4.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );

    // Brilho Especular 3D
    canvas.drawPath(
      path.shift(const Offset(0, -0.9)),
      Paint()..color = Colors.white.withValues(alpha: isActive ? 0.38 : 0.15)..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );

    // Pino de Inserção Metálico no Furo
    canvas.drawCircle(pinPos, 3.2, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(pinPos, 1.8, Paint()..color = const Color(0xFFFBBF24));

    // Partículas de Elétrons
    if (isActive) {
      final metrics = path.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final len = metric.length;
        final progress = (anim % 1.0);
        final dist = reverse ? (1.0 - progress) * len : progress * len;
        final p = metric.getTangentForOffset(dist)?.position;
        if (p != null) {
          canvas.drawCircle(p, 3.5, Paint()..color = const Color(0xFFEAB308).withValues(alpha: 0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
          canvas.drawCircle(p, 1.8, Paint()..color = const Color(0xFFFEF08A));
        }
      }
    }
  }

  // -------------------------------------------------------------------------
  // COMPONENTES INSERIDOS NA PROTOBOARD
  // -------------------------------------------------------------------------

  void _drawProtoboardComponents(Canvas canvas, Rect bb) {
    const cols = 20;
    final startX = bb.left + 28.0;
    final stepX = (bb.width - 56.0) / (cols - 1);

    final rowStartYTop = bb.top + bb.height * 0.22;
    final rowStepTop = (bb.height * 0.24) / 4;
    final rowStartYBot = bb.top + bb.height * 0.56;
    final rowStepBot = (bb.height * 0.24) / 4;

    switch (missionIndex) {
      case 0: // M1: Potenciômetro + Chave + Resistor 220Ω + LED Grow
        _drawBreadboardPotentiometer(canvas, Offset(startX + 5 * stepX, rowStartYTop + 2 * rowStepTop));
        _drawBreadboardSwitch(canvas, Offset(startX + 9 * stepX, rowStartYBot + 2 * rowStepBot));
        _drawBreadboardResistor(canvas, Offset(startX + 13 * stepX, rowStartYTop + 2 * rowStepTop), stepX * 2);
        _drawBreadboardGrowLed(canvas, Offset(startX + 17 * stepX, rowStartYTop + 2 * rowStepTop));
        break;

      case 1: // M2: Sonda de Solo + Resistor + LED Alerta + Chave
        _drawBreadboardMoistureModule(canvas, Offset(startX + 5 * stepX, rowStartYTop + 2 * rowStepTop));
        _drawBreadboardResistor(canvas, Offset(startX + 11 * stepX, rowStartYTop + 2 * rowStepTop), stepX * 2);
        _drawBreadboardAlertLed(canvas, Offset(startX + 15 * stepX, rowStartYTop + 2 * rowStepTop));
        _drawBreadboardSwitch(canvas, Offset(startX + 18 * stepX, rowStartYBot + 2 * rowStepBot));
        break;

      case 2: // M3: Chave dos Motores + Cooler DC + Resistor + LED Status
        _drawBreadboardSwitch(canvas, Offset(startX + 5 * stepX, rowStartYBot + 2 * rowStepBot));
        _drawBreadboardDcMotor(canvas, Offset(startX + 10 * stepX, rowStartYTop + 2 * rowStepTop), label: 'COOLER');
        _drawBreadboardResistor(canvas, Offset(startX + 14 * stepX, rowStartYTop + 2 * rowStepTop), stepX * 2);
        _drawBreadboardGrowLed(canvas, Offset(startX + 18 * stepX, rowStartYTop + 2 * rowStepTop));
        break;

      case 3: // M4: Botão de Pulso + Mini-Bomba DC + Sonda + LED
        _drawBreadboardPushButton(canvas, Offset(startX + 5 * stepX, rowStartYBot + 2 * rowStepBot));
        _drawBreadboardWaterPump(canvas, Offset(startX + 10 * stepX, rowStartYTop + 2 * rowStepTop));
        _drawBreadboardMoistureModule(canvas, Offset(startX + 14 * stepX, rowStartYTop + 2 * rowStepTop));
        _drawBreadboardAlertLed(canvas, Offset(startX + 18 * stepX, rowStartYTop + 2 * rowStepTop));
        break;

      case 4: // M5: Barramento Integrado (Todos os 4 ramos)
      default:
        _drawBreadboardSwitch(canvas, Offset(startX + 4 * stepX, rowStartYBot + 2 * rowStepBot));
        _drawBreadboardPotentiometer(canvas, Offset(startX + 7 * stepX, rowStartYTop + 2 * rowStepTop));
        _drawBreadboardGrowLed(canvas, Offset(startX + 10 * stepX, rowStartYTop + 2 * rowStepTop));
        _drawBreadboardDcMotor(canvas, Offset(startX + 13 * stepX, rowStartYTop + 2 * rowStepTop), label: 'COOLER');
        _drawBreadboardMoistureModule(canvas, Offset(startX + 16 * stepX, rowStartYTop + 2 * rowStepTop));
        _drawBreadboardWaterPump(canvas, Offset(startX + 18 * stepX, rowStartYBot + 2 * rowStepBot));
        break;
    }
  }

  void _drawBreadboardPotentiometer(Canvas canvas, Offset center) {
    final rect = Rect.fromCenter(center: center, width: 44, height: 44);

    // Corpo azul
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), Paint()..color = const Color(0xFF0284C7));

    // Dial prateado
    const dialR = 14.0;
    canvas.drawCircle(
      center,
      dialR,
      Paint()..shader = const RadialGradient(colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)]).createShader(Rect.fromCircle(center: center, radius: dialR)),
    );

    // Ponteiro
    const startAngle = 0.75 * math.pi;
    const sweepAngle = 1.5 * math.pi;
    final currentAngle = startAngle + sweepAngle * potentiometerValue.clamp(0.0, 1.0);
    final pX = center.dx + math.cos(currentAngle) * (dialR - 3);
    final pY = center.dy + math.sin(currentAngle) * (dialR - 3);
    canvas.drawCircle(Offset(pX, pY), 2.0, Paint()..color = const Color(0xFF0284C7));

    // Pinos inseridos nos furos
    canvas.drawCircle(Offset(rect.left + 4, rect.bottom + 4), 2.2, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(Offset(center.dx, rect.bottom + 4), 2.2, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(Offset(rect.right - 4, rect.bottom + 4), 2.2, Paint()..color = const Color(0xFF94A3B8));

    final kOhms = (potentiometerValue * 100).toInt();
    final tp = TextPainter(
      text: TextSpan(text: '$kOhms kΩ', style: GoogleFonts.rajdhani(color: const Color(0xFF38BDF8), fontSize: 8.5, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 14));
  }

  void _drawBreadboardSwitch(Canvas canvas, Offset center) {
    final rect = Rect.fromCenter(center: center, width: 40, height: 40);

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = const Color(0xFF334155));

    final isClosed = isSwitchClosed;
    final leverTip = isClosed ? Offset(center.dx + 6, center.dy - 5) : Offset(center.dx - 6, center.dy + 5);

    canvas.drawLine(
      center,
      leverTip,
      Paint()..color = isClosed ? const Color(0xFF10B981) : const Color(0xFFEF4444)..strokeWidth = 4.5..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(leverTip, 3.0, Paint()..color = Colors.white);

    final tp = TextPainter(
      text: TextSpan(
        text: isClosed ? 'ON' : 'OFF',
        style: GoogleFonts.rajdhani(color: isClosed ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontSize: 8.0, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 12));
  }

  void _drawBreadboardResistor(Canvas canvas, Offset center, double span) {
    final bodyRect = Rect.fromCenter(center: center, width: 28, height: 12);

    // Terminais axiais encaixando nos furos da protoboard
    final leadPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2.0..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(center.dx - span, center.dy), Offset(bodyRect.left, center.dy), leadPaint);
    canvas.drawLine(Offset(bodyRect.right, center.dy), Offset(center.dx + span, center.dy), leadPaint);

    // Corpo cerâmico
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)), Paint()..color = const Color(0xFFD4C5B9));

    // Anéis de cores (220Ω)
    final bands = [
      {'color': const Color(0xFFDC2626), 'x': bodyRect.left + 5.0},
      {'color': const Color(0xFFDC2626), 'x': bodyRect.left + 10.0},
      {'color': const Color(0xFF78350F), 'x': bodyRect.left + 15.0},
      {'color': const Color(0xFFFBBF24), 'x': bodyRect.left + 21.0},
    ];
    for (final band in bands) {
      canvas.drawLine(
        Offset(band['x'] as double, bodyRect.top),
        Offset(band['x'] as double, bodyRect.bottom),
        Paint()..color = band['color'] as Color..strokeWidth = 2.0,
      );
    }
  }

  void _drawBreadboardGrowLed(Canvas canvas, Offset center) {
    final isLit = isSwitchClosed && potentiometerValue > 0.05;
    final intensity = potentiometerValue.clamp(0.0, 1.0);

    if (isLit) {
      canvas.drawCircle(
        center,
        18 * intensity,
        Paint()
          ..color = const Color(0xFFF59E0B).withValues(alpha: 0.35 * intensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    final domeColor = isLit ? Color.lerp(const Color(0xFFD97706), const Color(0xFFFDE047), intensity)! : const Color(0xFF475569);
    canvas.drawCircle(center, 9, Paint()..color = domeColor);
    canvas.drawCircle(Offset(center.dx - 2.5, center.dy - 2.5), 2.5, Paint()..color = Colors.white.withValues(alpha: isLit ? 0.75 : 0.3));

    final tp = TextPainter(
      text: TextSpan(text: 'LED GROW', style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 7.5, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 11));
  }

  void _drawBreadboardAlertLed(Canvas canvas, Offset center) {
    final isDryAlert = soilMoistureLevel < 0.35 && isSwitchClosed;

    if (isDryAlert) {
      canvas.drawCircle(
        center,
        18,
        Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.45)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    final ledColor = isDryAlert ? const Color(0xFFEF4444) : const Color(0xFF475569);
    canvas.drawCircle(center, 9, Paint()..color = ledColor);

    final tp = TextPainter(
      text: TextSpan(
        text: isDryAlert ? 'ALERTA' : 'OK',
        style: GoogleFonts.rajdhani(color: isDryAlert ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontSize: 7.5, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 11));
  }

  void _drawBreadboardDcMotor(Canvas canvas, Offset center, {required String label}) {
    canvas.drawCircle(
      center,
      14,
      Paint()..shader = const RadialGradient(colors: [Color(0xFF64748B), Color(0xFF334155)]).createShader(Rect.fromCircle(center: center, radius: 14)),
    );
    canvas.drawCircle(center, 14, Paint()..color = const Color(0xFF0284C7)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (isSwitchClosed) {
      canvas.rotate(animValue * 2 * math.pi * 2.0);
    }
    canvas.drawCircle(Offset.zero, 4, Paint()..color = const Color(0xFFB45309));
    canvas.restore();

    final tp = TextPainter(
      text: TextSpan(text: label, style: GoogleFonts.rajdhani(color: const Color(0xFF38BDF8), fontSize: 7.5, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 15));
  }

  void _drawBreadboardWaterPump(Canvas canvas, Offset center) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 28, height: 28), const Radius.circular(6)),
      Paint()..color = const Color(0xFF0369A1),
    );

    final tp = TextPainter(
      text: const TextSpan(text: '💧', style: TextStyle(fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawBreadboardPushButton(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 14, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(center, 9, Paint()..color = isSwitchClosed ? const Color(0xFF10B981) : const Color(0xFF0284C7));
  }

  void _drawBreadboardMoistureModule(Canvas canvas, Offset center) {
    final rect = Rect.fromCenter(center: center, width: 34, height: 38);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), Paint()..color = const Color(0xFF0284C7));

    final goldPaint = Paint()..color = const Color(0xFFFBBF24)..strokeWidth = 2.2..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(center.dx - 6, center.dy - 8), Offset(center.dx - 6, center.dy + 8), goldPaint);
    canvas.drawLine(Offset(center.dx + 6, center.dy - 8), Offset(center.dx + 6, center.dy + 8), goldPaint);

    final tp = TextPainter(
      text: TextSpan(text: 'SONDA', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 7.0, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 13));
  }

  // =========================================================================
  // MODO ESQUEMÁTICO IEC/ABNT
  // =========================================================================

  void _drawSchematicCircuit(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final wirePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final battCenter = Offset(w * 0.18, h * 0.50);
    final comp1Center = Offset(w * 0.52, h * 0.32);
    final comp2Center = Offset(w * 0.52, h * 0.68);
    final comp3Center = Offset(w * 0.82, h * 0.32);
    final comp4Center = Offset(w * 0.82, h * 0.68);

    final p = Path()
      ..moveTo(battCenter.dx, battCenter.dy - 30)
      ..lineTo(battCenter.dx, comp1Center.dy)
      ..lineTo(comp1Center.dx - 20, comp1Center.dy)
      ..moveTo(comp1Center.dx + 20, comp1Center.dy)
      ..lineTo(comp3Center.dx - 20, comp3Center.dy)
      ..moveTo(comp3Center.dx + 20, comp3Center.dy)
      ..lineTo(comp3Center.dx + 30, comp3Center.dy)
      ..lineTo(comp3Center.dx + 30, comp4Center.dy)
      ..lineTo(comp4Center.dx + 20, comp4Center.dy)
      ..moveTo(comp4Center.dx - 20, comp4Center.dy)
      ..lineTo(comp2Center.dx + 20, comp2Center.dy)
      ..moveTo(comp2Center.dx - 20, comp2Center.dy)
      ..lineTo(battCenter.dx, comp2Center.dy)
      ..lineTo(battCenter.dx, battCenter.dy + 30);

    canvas.drawPath(p, wirePaint);

    _drawSchematicNode(canvas, Offset(comp1Center.dx - 20, comp1Center.dy), 'J1');
    _drawSchematicNode(canvas, Offset(comp1Center.dx + 20, comp1Center.dy), 'J2');
    _drawSchematicNode(canvas, Offset(comp3Center.dx - 20, comp3Center.dy), 'J3');
    _drawSchematicNode(canvas, Offset(comp3Center.dx + 20, comp3Center.dy), 'J4');
    _drawSchematicNode(canvas, Offset(comp2Center.dx - 20, comp2Center.dy), 'J5');
    _drawSchematicNode(canvas, Offset(comp2Center.dx + 20, comp2Center.dy), 'J6');

    _drawSchematicBattery(canvas, battCenter);
    _drawSchematicPotentiometer(canvas, comp1Center);
    _drawSchematicSwitch(canvas, comp2Center);
    _drawSchematicLed(canvas, comp3Center);
    _drawSchematicResistor(canvas, comp4Center);
  }

  void _drawSchematicNode(Canvas canvas, Offset pos, String label) {
    canvas.drawCircle(pos, 3.5, Paint()..color = const Color(0xFFFBBF24));
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: GoogleFonts.rajdhani(color: const Color(0xFFFBBF24), fontSize: 8.0, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - 12));
  }

  void _drawSchematicBattery(Canvas canvas, Offset center) {
    final p = Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 2.5;
    canvas.drawLine(Offset(center.dx - 16, center.dy - 10), Offset(center.dx + 16, center.dy - 10), p);
    canvas.drawLine(Offset(center.dx - 8, center.dy + 10), Offset(center.dx + 8, center.dy + 10), p..strokeWidth = 4.0);

    final tp = TextPainter(
      text: const TextSpan(text: '9V', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx + 20, center.dy - 6));
  }

  void _drawSchematicPotentiometer(Canvas canvas, Offset center) {
    _drawSchematicResistor(canvas, center);
    final arrowPaint = Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 2.0;
    canvas.drawLine(Offset(center.dx, center.dy + 16), Offset(center.dx, center.dy - 8), arrowPaint);
    canvas.drawLine(Offset(center.dx - 4, center.dy - 4), Offset(center.dx, center.dy - 8), arrowPaint);
    canvas.drawLine(Offset(center.dx + 4, center.dy - 4), Offset(center.dx, center.dy - 8), arrowPaint);
  }

  void _drawSchematicSwitch(Canvas canvas, Offset center) {
    final p = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawCircle(Offset(center.dx - 12, center.dy), 3, p);
    canvas.drawCircle(Offset(center.dx + 12, center.dy), 3, p);

    final armPaint = Paint()..color = isSwitchClosed ? const Color(0xFF10B981) : const Color(0xFFEF4444)..strokeWidth = 2.5;
    if (isSwitchClosed) {
      canvas.drawLine(Offset(center.dx - 12, center.dy), Offset(center.dx + 12, center.dy), armPaint);
    } else {
      canvas.drawLine(Offset(center.dx - 12, center.dy), Offset(center.dx + 10, center.dy - 12), armPaint);
    }
  }

  void _drawSchematicLed(Canvas canvas, Offset center) {
    final p = Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 2.0..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(center.dx - 10, center.dy - 10)
      ..lineTo(center.dx - 10, center.dy + 10)
      ..lineTo(center.dx + 8, center.dy)
      ..close();
    canvas.drawPath(path, p);
    canvas.drawLine(Offset(center.dx + 8, center.dy - 10), Offset(center.dx + 8, center.dy + 10), p);

    final arrowPaint = Paint()..color = const Color(0xFFFBBF24)..strokeWidth = 1.5;
    canvas.drawLine(Offset(center.dx + 2, center.dy - 12), Offset(center.dx + 10, center.dy - 20), arrowPaint);
    canvas.drawLine(Offset(center.dx + 8, center.dy - 8), Offset(center.dx + 16, center.dy - 16), arrowPaint);
  }

  void _drawSchematicResistor(Canvas canvas, Offset center) {
    final p = Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 2.0..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(center.dx - 18, center.dy)
      ..lineTo(center.dx - 12, center.dy)
      ..lineTo(center.dx - 8, center.dy - 6)
      ..lineTo(center.dx - 2, center.dy + 6)
      ..lineTo(center.dx + 4, center.dy - 6)
      ..lineTo(center.dx + 10, center.dy + 6)
      ..lineTo(center.dx + 14, center.dy)
      ..lineTo(center.dx + 18, center.dy);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant HortaCircuitPainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.missionIndex != missionIndex ||
        oldDelegate.usePhysicalStyle != usePhysicalStyle ||
        oldDelegate.isSwitchClosed != isSwitchClosed ||
        oldDelegate.potentiometerValue != potentiometerValue ||
        oldDelegate.soilMoistureLevel != soilMoistureLevel ||
        oldDelegate.isMotorConnected != isMotorConnected ||
        oldDelegate.isPumpConnected != isPumpConnected ||
        oldDelegate.isBranch1Active != isBranch1Active ||
        oldDelegate.isBranch2Active != isBranch2Active ||
        oldDelegate.isBranch3Active != isBranch3Active ||
        oldDelegate.isBranch4Active != isBranch4Active;
  }
}
