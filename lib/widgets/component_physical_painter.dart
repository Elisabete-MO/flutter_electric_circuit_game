import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/first_step_component.dart';
import 'burned_effects_painter.dart';

/// Renderizador CustomPainter dos componentes em seu aspecto hiper-realista (3D Vetorial)
/// ajustados proporcionalmente para preencher a célula do grid.
class ComponentPhysicalPainter extends CustomPainter {
  ComponentPhysicalPainter({
    required this.type,
    this.isActive = false,
    this.isBurned = false,
    required this.isDarkMode,
    this.value = 10.0,
    this.animationValue = 0.0,
    this.wireKind = 'series',
  });

  final ComponentType type;
  final bool isActive;
  final bool isBurned;
  final bool isDarkMode;
  final double value;
  final double animationValue;
  final String wireKind;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final double minDim = math.min(size.width, size.height);
    final double scale = minDim < 68.0 ? (minDim / 68.0) : 1.0;

    if (scale < 1.0) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(scale);
      canvas.translate(-cx, -cy);
    }

    switch (type) {
      case ComponentType.battery:
        _drawPhysicalBattery(canvas, size, cx, cy);
        break;
      case ComponentType.connectingWire:
        _drawPhysicalWire(canvas, size, cx, cy);
        break;
      case ComponentType.switchComponent:
        _drawPhysicalSwitch(canvas, size, cx, cy);
        break;
      case ComponentType.bulb:
        _drawPhysicalBulb(canvas, size, cx, cy);
        break;
      case ComponentType.resistor:
        _drawPhysicalResistor(canvas, size, cx, cy);
        break;
      case ComponentType.diode:
        _drawPhysicalDiode(canvas, size, cx, cy);
        break;
      case ComponentType.led:
        _drawPhysicalLED(canvas, size, cx, cy);
        break;
      case ComponentType.motor:
        _drawPhysicalMotor(canvas, size, cx, cy);
        break;
      case ComponentType.potentiometer:
        _drawPhysicalPotentiometer(canvas, size, cx, cy);
        break;
      case ComponentType.powerSupply:
        _drawPhysicalPowerSupply(canvas, size, cx, cy);
        break;
      case ComponentType.fuse:
        _drawPhysicalFuse(canvas, size, cx, cy);
        break;
      case ComponentType.capacitor:
        _drawPhysicalCapacitor(canvas, size, cx, cy);
        break;
      case ComponentType.buzzer:
        _drawPhysicalBuzzer(canvas, size, cx, cy);
        break;
    }

    if (isBurned) {
      drawBurnedSmokeAndEmbers(
        canvas,
        size,
        cx,
        cy,
        animationValue,
        isDark: isDarkMode,
      );
    }

    if (scale < 1.0) {
      canvas.restore();
    }
  }

  /// Desenha as hastes metálicas estanhadas de bancada com textura 3D e ponto de solda
  void _drawCleanLeads(Canvas canvas, Size size, double cx, double cy, double leftEdgeX, double rightEdgeX) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final leadBasePaint = Paint()
      ..shader = LinearGradient(
        colors: isDarkMode
            ? const [Color(0xFFCBD5E1), Color(0xFF64748B), Color(0xFF1E293B)]
            : const [Color(0xFFFFFFFF), Color(0xFFB0BEC5), Color(0xFF455A64)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, cy - 2, size.width, 4))
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;

    final leadHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    if (leftEdgeX > 0) {
      canvas.drawLine(Offset(0, cy + 2.0), Offset(leftEdgeX, cy + 2.0), shadowPaint);
      canvas.drawLine(Offset(0, cy), Offset(leftEdgeX, cy), leadBasePaint);
      canvas.drawLine(Offset(0, cy - 1.0), Offset(leftEdgeX, cy - 1.0), leadHighlightPaint);

      // Ponto de solda na junção
      _drawSolderBlob(canvas, Offset(leftEdgeX, cy));
    }

    if (rightEdgeX < size.width) {
      canvas.drawLine(Offset(rightEdgeX, cy + 2.0), Offset(size.width, cy + 2.0), shadowPaint);
      canvas.drawLine(Offset(rightEdgeX, cy), Offset(size.width, cy), leadBasePaint);
      canvas.drawLine(Offset(rightEdgeX, cy - 1.0), Offset(size.width, cy - 1.0), leadHighlightPaint);

      // Ponto de solda na junção
      _drawSolderBlob(canvas, Offset(rightEdgeX, cy));
    }
  }

  /// Desenha uma gota de solda estaño-chumbo 3D
  void _drawSolderBlob(Canvas canvas, Offset pos) {
    final blobPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: const [Color(0xFFFFFFFF), Color(0xFFCFD8DC), Color(0xFF546E7A)],
      ).createShader(Rect.fromCircle(center: pos, radius: 3.5));
    canvas.drawCircle(pos, 3.2, blobPaint);
  }

  /// --------------------------------------------------------------------------
  /// SUPORTE DE PILHAS AA / BATERIA 4.5V (Hiper-realista 3D - Conforme referência)
  /// --------------------------------------------------------------------------
  void _drawPhysicalBattery(Canvas canvas, Size size, double cx, double cy) {
    // Dimensões do Suporte Plastico Preto de Pilhas AA
    const double holderWidth = 44.0;
    const double holderHeight = 32.0;
    final double holderLeft = cx - holderWidth / 2;
    final double holderTop = cy - holderHeight / 2;

    final holderRect = Rect.fromLTWH(holderLeft, holderTop, holderWidth, holderHeight);
    final holderRRect = RRect.fromRectAndRadius(holderRect, const Radius.circular(4.0));

    // 1. Sombra do Suporte de Pilhas
    canvas.drawRRect(
      holderRRect.shift(const Offset(2.0, 3.5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );

    // 2. Corpo do Suporte Plástico Preto Fosco
    final housingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(holderRect);
    canvas.drawRRect(holderRRect, housingPaint);

    // Moldura chanfrada de contorno fino do suporte
    canvas.drawRRect(
      holderRRect,
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Divisória Central de Plástico do Suporte
    canvas.drawLine(
      Offset(cx, holderTop + 2),
      Offset(cx, holderTop + holderHeight - 2),
      Paint()
        ..color = const Color(0xFF020617)
        ..strokeWidth = 1.6,
    );

    // 3. Pilhas AA Turquesa / Teal (2 compartimentos pareados conforme a imagem de referência)
    const double cellW = 18.0;
    const double cellH = 26.0;
    final double cellY = cy - cellH / 2;

    // A) Pilha AA Esquerda (Invertida: Polo Positivo + embaixo)
    final leftCellRect = Rect.fromLTWH(cx - cellW - 1.5, cellY, cellW, cellH);
    _drawAABatteryCell(
      canvas,
      leftCellRect,
      isPositiveTop: false,
      label: 'AA 1.5V',
    );

    // B) Pilha AA Direita (Polo Positivo + em cima)
    final rightCellRect = Rect.fromLTWH(cx + 1.5, cellY, cellW, cellH);
    _drawAABatteryCell(
      canvas,
      rightCellRect,
      isPositiveTop: true,
      label: 'AA 1.5V',
    );

    // 4. Molas e Contatos Metálicos Prateados no Topo e Fundo do Holder
    final metallicPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF1F5F9), Color(0xFF94A3B8), Color(0xFF475569)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(holderRect);

    // Contatos Metálicos Superiores (Pino Prata / Mola)
    canvas.drawRect(Rect.fromLTWH(cx - 15, holderTop, 6, 2), metallicPaint);
    canvas.drawRect(Rect.fromLTWH(cx + 9, holderTop, 6, 2), metallicPaint);

    // Contatos Metálicos Inferiores
    canvas.drawRect(Rect.fromLTWH(cx - 15, holderTop + holderHeight - 2, 6, 2), metallicPaint);
    canvas.drawRect(Rect.fromLTWH(cx + 9, holderTop + holderHeight - 2, 6, 2), metallicPaint);

    // 5. Cabos Elétricos de Saída (Vermelho + para a esquerda, Azul - para a direita)
    canvas.drawLine(
      Offset(holderLeft, cy),
      Offset(0, cy),
      Paint()
        ..color = const Color(0xFFEF4444)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(holderLeft + holderWidth, cy),
      Offset(size.width, cy),
      Paint()
        ..color = const Color(0xFF2563EB)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );

    // Terminais metálicos para conexão limpa nos polos da bancada
    _drawCleanLeads(canvas, size, cx, cy, holderLeft, holderLeft + holderWidth);
  }

  /// Desenha uma pilha individual AA turquesa (Teal) fotorrealista com polos + e -
  void _drawAABatteryCell(Canvas canvas, Rect rect, {required bool isPositiveTop, required String label}) {
    final cellRRect = RRect.fromRectAndRadius(rect, const Radius.circular(3.0));

    // Corpo Turquesa/Teal Principal da Pilha AA (Conforme a imagem de referência do usuário)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0D9488), Color(0xFF0F766E), Color(0xFF115E59)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect);
    canvas.drawRRect(cellRRect, bodyPaint);

    // Bloco/Faixa de Destaque Turquesa Claro do Polo Positivo (+)
    final posHeight = rect.height * 0.35;
    final posRect = isPositiveTop
        ? Rect.fromLTWH(rect.left, rect.top, rect.width, posHeight)
        : Rect.fromLTWH(rect.left, rect.bottom - posHeight, rect.width, posHeight);

    final posPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6), Color(0xFF0D9488)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(posRect);

    canvas.save();
    canvas.clipRRect(cellRRect);
    canvas.drawRect(posRect, posPaint);

    // Brilho Especular no Topo/Corpo da Pilha
    canvas.drawLine(
      Offset(rect.left + 2, rect.top + 1),
      Offset(rect.right - 2, rect.top + 1),
      Paint()..color = Colors.white.withValues(alpha: 0.45)..strokeWidth = 0.8,
    );
    canvas.restore();

    // Marcador de Polo Positivo '+'
    final posCenterY = isPositiveTop ? rect.top + posHeight / 2 : rect.bottom - posHeight / 2;
    final posText = TextPainter(
      text: TextSpan(
        text: '+',
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    posText.paint(canvas, Offset(rect.center.dx - posText.width / 2, posCenterY - posText.height / 2));

    // Marcador de Polo Negativo '-'
    final negCenterY = isPositiveTop ? rect.bottom - (rect.height - posHeight) / 2 : rect.top + (rect.height - posHeight) / 2;
    final negText = TextPainter(
      text: TextSpan(
        text: '—',
        style: GoogleFonts.rajdhani(
          color: Colors.white.withValues(alpha: 0.85),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    negText.paint(canvas, Offset(rect.center.dx - negText.width / 2, negCenterY - negText.height / 2));

    // Inscrição 'AA 1.5V' na lateral do corpo da pilha
    canvas.save();
    final textCenterY = isPositiveTop ? rect.top + rect.height * 0.65 : rect.top + rect.height * 0.35;
    canvas.translate(rect.center.dx, textCenterY);
    canvas.rotate(-math.pi / 2);

    final labelPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 8.5,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(canvas, Offset(-labelPainter.width / 2, -labelPainter.height / 2));
    canvas.restore();
  }

  void _drawPhysicalWire(Canvas canvas, Size size, double cx, double cy) {
    if (wireKind == 'junction') {
      _drawPhysicalJunctionNode(canvas, size, cx, cy);
    } else if (wireKind == 'parallel') {
      _drawPhysicalParallelWire(canvas, size, cx, cy);
    } else {
      _drawPhysicalSeriesWire(canvas, size, cx, cy);
    }
  }

  /// 1. Fio Condutor em Série 3D (Silicone com conectores metálicos nas extremidades)
  void _drawPhysicalSeriesWire(Canvas canvas, Size size, double cx, double cy) {
    final leftX = 0.0;
    final rightX = size.width;

    // Sombra do fio no plano de bancada
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.22)
      ..strokeWidth = 6.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawLine(Offset(leftX + 4, cy + 2.5), Offset(rightX - 4, cy + 2.5), shadowPaint);

    // Corpo do Fio em Silicone Azul Industrial
    final wirePaint = Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF0369A1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, cy - 3, size.width, 6))
      ..strokeWidth = 5.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(leftX + 2, cy), Offset(rightX - 2, cy), wirePaint);

    // Brilho Especular no Topo do Fio
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(leftX + 4, cy - 1.4), Offset(rightX - 4, cy - 1.4), highlightPaint);

    // Terminais Metálicos Cilíndricos 3D (Pin Headers) nas duas extremidades
    _drawJumperHeaderPin(canvas, Offset(leftX + 6, cy), 0);
    _drawJumperHeaderPin(canvas, Offset(rightX - 6, cy), math.pi);
  }

  /// 2. Nó de Junção / Bifurcação 3D (Bloco Conector T com 3 saídas e indicador)
  void _drawPhysicalJunctionNode(Canvas canvas, Size size, double cx, double cy) {
    // Fio Horizontal Passante
    _drawPhysicalSeriesWire(canvas, size, cx, cy);

    // Haste Vertical para a Terceira Conexão (Nó T)
    final verticalStemY = cy + 18.0;

    final stemShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawLine(Offset(cx + 2, cy), Offset(cx + 2, verticalStemY), stemShadowPaint);

    final stemPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFA855F7), Color(0xFF7E22CE), Color(0xFF581C87)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(cx - 3, cy, 6, 18))
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx, verticalStemY), stemPaint);

    // Bloco de Junção Central (Módulo Plástico Selado de Conexão T)
    final blockRect = Rect.fromCenter(center: Offset(cx, cy), width: 28, height: 20);
    final blockRRect = RRect.fromRectAndRadius(blockRect, const Radius.circular(5.0));

    // Sombra do Bloco
    canvas.drawRRect(
      blockRRect.shift(const Offset(2.0, 3.0)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );

    // Corpo Escuro do Conector T
    final blockPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(blockRect);
    canvas.drawRRect(blockRRect, blockPaint);

    canvas.drawRRect(
      blockRRect,
      Paint()
        ..color = const Color(0xFFA855F7).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Ponto Dourado/Cobre do Nó Elétrico no Centro
    final nodeDotCenter = Offset(cx, cy);
    final nodeShader = const RadialGradient(
      colors: [Color(0xFFFDE047), Color(0xFFCA8A04), Color(0xFF854D0E)],
    ).createShader(Rect.fromCircle(center: nodeDotCenter, radius: 4.5));

    canvas.drawCircle(nodeDotCenter, 4.5, Paint()..shader = nodeShader);
    canvas.drawCircle(nodeDotCenter, 1.5, Paint()..color = Colors.white);

    // Terminal na ponta vertical
    _drawJumperHeaderPin(canvas, Offset(cx, verticalStemY), math.pi / 2);
  }

  /// 3. Fiação Paralela 3D (Cabo Par Paralelo / Fio Duplo Vermelho e Azul)
  void _drawPhysicalParallelWire(Canvas canvas, Size size, double cx, double cy) {
    final leftX = 0.0;
    final rightX = size.width;

    final dy = 7.0;
    final topWireY = cy - dy;
    final bottomWireY = cy + dy;

    // Sombra dos dois fios
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.20)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawLine(Offset(leftX + 4, topWireY + 2), Offset(rightX - 4, topWireY + 2), shadowPaint);
    canvas.drawLine(Offset(leftX + 4, bottomWireY + 2), Offset(rightX - 4, bottomWireY + 2), shadowPaint);

    // Fio Superior (Vermelho +)
    final redWirePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF87171), Color(0xFFDC2626), Color(0xFF991B1B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, topWireY - 2, size.width, 4))
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(leftX + 2, topWireY), Offset(rightX - 2, topWireY), redWirePaint);

    // Fio Inferior (Azul -)
    final blueWirePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF60A5FA), Color(0xFF2563EB), Color(0xFF1D4ED8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, bottomWireY - 2, size.width, 4))
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(leftX + 2, bottomWireY), Offset(rightX - 2, bottomWireY), blueWirePaint);

    // Destaques especulares
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.60)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(leftX + 4, topWireY - 1.2), Offset(rightX - 4, topWireY - 1.2), highlightPaint);
    canvas.drawLine(Offset(leftX + 4, bottomWireY - 1.2), Offset(rightX - 4, bottomWireY - 1.2), highlightPaint);

    // Braçadeira / Junta isolante preta unindo o par de fios no centro
    final bandRect = Rect.fromCenter(center: Offset(cx, cy), width: 10, height: 22);
    final bandRRect = RRect.fromRectAndRadius(bandRect, const Radius.circular(2.5));
    canvas.drawRRect(bandRRect, Paint()..color = const Color(0xFF18181B));
    canvas.drawRRect(
      bandRRect,
      Paint()
        ..color = const Color(0xFF52525B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Terminais Duplos
    _drawJumperHeaderPin(canvas, Offset(leftX + 5, topWireY), 0);
    _drawJumperHeaderPin(canvas, Offset(rightX - 5, topWireY), math.pi);
    _drawJumperHeaderPin(canvas, Offset(leftX + 5, bottomWireY), 0);
    _drawJumperHeaderPin(canvas, Offset(rightX - 5, bottomWireY), math.pi);
  }

  void _drawJumperHeaderPin(Canvas canvas, Offset pos, double angle) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    // Rotaciona para alinhar a capa cilíndrica e o pino ao longo da direção exata do fio
    canvas.rotate(angle - math.pi / 2);

    // 1. Sombra do pino/conector
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(1.5, 4.0), width: 7.0, height: 22.0),
        const Radius.circular(3.0),
      ),
      shadowPaint,
    );

    // 2. Pino metálico prateado (saindo da parte inferior da capa preta)
    final pinShader = const LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFCFD8DC), Color(0xFF607D8B)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(-1.5, 5.0, 3.0, 10.0));

    final pinPaint = Paint()
      ..shader = pinShader
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(0, 5.0), const Offset(0, 14.0), pinPaint);

    // 3. Capa plástica preta (Cilindro igual à foto de referência)
    final headerRect = Rect.fromCenter(center: const Offset(0, 0), width: 7.2, height: 13.0);
    final headerRRect = RRect.fromRectAndRadius(headerRect, const Radius.circular(3.0));

    final headerShader = const LinearGradient(
      colors: [Color(0xFF607D8B), Color(0xFF263238), Color(0xFF101719), Color(0xFF000000)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(headerRect);

    canvas.drawRRect(headerRRect, Paint()..shader = headerShader);

    // Encaixe superior (borda onde o fio entra na capa preta)
    canvas.drawCircle(
      const Offset(0, -6.0),
      3.2,
      Paint()..color = const Color(0xFF1C2526),
    );

    canvas.restore();
  }

  /// --------------------------------------------------------------------------
  /// INTERRUPTOR DE ALAVANCA TIPO TOGGLE SWITCH 3D (Chave Basculante Metálica)
  /// --------------------------------------------------------------------------
  void _drawPhysicalSwitch(Canvas canvas, Size size, double cx, double cy) {
    const boxWidth = 56.0;
    const boxHeight = 44.0;
    final boxRect = Rect.fromCenter(center: Offset(cx, cy), width: boxWidth, height: boxHeight);
    final boxRRect = RRect.fromRectAndRadius(boxRect, const Radius.circular(8.0));

    // Hastes metálicas de bancada laterais
    _drawCleanLeads(canvas, size, cx, cy, cx - 28, cx + 28);

    // 1. Sombra projetada do componente
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect.translate(2.5, 4.0), const Radius.circular(8.0)),
      Paint()..color = Colors.black.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 2. Bornes de conexão metálicos / Parafusos laterais
    final terminalPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFCBD5E1), Color(0xFF64748B), Color(0xFF334155)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(boxRect.left - 6, cy - 6, 8, 12));

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(boxRect.left - 6, cy - 6, 8, 12), const Radius.circular(2)),
      terminalPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(boxRect.right - 2, cy - 6, 8, 12), const Radius.circular(2)),
      terminalPaint,
    );

    // 3. Corpo escuro isolante de plástico (Navy / Dark Slate Matte)
    final bodyShader = LinearGradient(
      colors: isDarkMode
          ? const [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)]
          : const [Color(0xFF475569), Color(0xFF1E293B), Color(0xFF0F172A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(boxRect);
    canvas.drawRRect(boxRRect, Paint()..shader = bodyShader);

    // Moldura chanfrada do corpo
    canvas.drawRRect(
      boxRRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 4. Placa Central de Metal Escovado (Painel Bezel Cromado da Alavanca)
    final bezelRect = Rect.fromCenter(center: Offset(cx, cy), width: 34, height: 26);
    final bezelRRect = RRect.fromRectAndRadius(bezelRect, const Radius.circular(4.0));

    final bezelShader = const LinearGradient(
      colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bezelRect);

    canvas.drawRRect(bezelRRect, Paint()..shader = bezelShader);
    canvas.drawRRect(
      bezelRRect,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Parafusos de fixação nos 4 cantos da placa bezel
    final screwPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawCircle(Offset(bezelRect.left + 3, bezelRect.top + 3), 1.2, screwPaint);
    canvas.drawCircle(Offset(bezelRect.right - 3, bezelRect.top + 3), 1.2, screwPaint);
    canvas.drawCircle(Offset(bezelRect.left + 3, bezelRect.bottom - 3), 1.2, screwPaint);
    canvas.drawCircle(Offset(bezelRect.right - 3, bezelRect.bottom - 3), 1.2, screwPaint);

    // 5. LED Indicador de Status / Estado (ON / OFF)
    final ledCenter = Offset(cx, cy + 7);
    if (isActive) {
      // Glow Verde quando LIGADO
      canvas.drawCircle(
        ledCenter,
        5.5,
        Paint()
          ..color = const Color(0xFF10B981).withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(ledCenter, 3.0, Paint()..color = const Color(0xFF34D399));
      canvas.drawCircle(ledCenter, 1.2, Paint()..color = Colors.white);
    } else {
      // Ponto escuro/inativo quando DESLIGADO
      canvas.drawCircle(ledCenter, 2.5, Paint()..color = const Color(0xFF334155));
      canvas.drawCircle(ledCenter, 2.5, Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 0.8);
    }

    // 6. Base Esférica da Haste da Alavanca
    final pivotCenter = Offset(cx, cy - 3);
    canvas.drawCircle(pivotCenter, 7.5, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(pivotCenter, 7.5, Paint()..color = const Color(0xFF64748B)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // 7. Haste Metálica Basculante (Alavanca 3D em Tom Cromado)
    // Tilted Left when OFF, Tilted Right when ON
    final leverAngle = isActive ? 0.40 : -0.40; // Radianos
    final leverLength = 18.0;
    final tipX = pivotCenter.dx + leverLength * math.sin(leverAngle);
    final tipY = pivotCenter.dy - leverLength * math.cos(leverAngle);

    // Sombra da alavanca projetada no bezel
    canvas.drawLine(
      pivotCenter.translate(1.5, 1.5),
      Offset(tipX + 2, tipY + 2),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round,
    );

    // Haste Metálica Cromada
    final leverPaint = Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFFFFFFFF), Color(0xFFCBD5E1), Color(0xFF64748B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromPoints(pivotCenter, Offset(tipX, tipY)))
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(pivotCenter, Offset(tipX, tipY), leverPaint);

    // Esfera/Knob metálico na ponta da alavanca
    final knobCenter = Offset(tipX, tipY);
    final knobShader = RadialGradient(
      colors: const [Color(0xFFFFFFFF), Color(0xFF94A3B8), Color(0xFF475569)],
      center: const Alignment(-0.3, -0.3),
      radius: 0.8,
    ).createShader(Rect.fromCircle(center: knobCenter, radius: 4.5));

    canvas.drawCircle(knobCenter, 4.5, Paint()..shader = knobShader);
    canvas.drawCircle(
      knobCenter,
      4.5,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  /// --------------------------------------------------------------------------
  /// LÂMPADA INCANDESCENTE E10 DE LABORATÓRIO (Bulb 3D - Expandida)
  /// --------------------------------------------------------------------------
  void _drawPhysicalBulb(Canvas canvas, Size size, double cx, double cy) {
    final socketCenter = Offset(cx, cy + 6);
    final socketRect = Rect.fromCenter(center: socketCenter, width: 32, height: 22);
    final bulbCenter = Offset(cx, cy - 20);
    const bulbRadius = 22.0;

    // 2 Terminais metálicos inferiores no soquete
    final pinLeftPos = Offset(cx - 7, socketRect.bottom + 7);
    final pinRightPos = Offset(cx + 7, socketRect.bottom + 7);

    // Terminal de pino esquerdo (Metal Prata 3D)
    canvas.drawLine(Offset(cx - 7, socketRect.bottom), pinLeftPos, Paint()..color = const Color(0xFF475569)..strokeWidth = 3.5..strokeCap = StrokeCap.round);
    canvas.drawCircle(pinLeftPos, 2.5, Paint()..color = const Color(0xFF94A3B8));

    // Terminal de pino direito (Metal Prata 3D)
    canvas.drawLine(Offset(cx + 7, socketRect.bottom), pinRightPos, Paint()..color = const Color(0xFF475569)..strokeWidth = 3.5..strokeCap = StrokeCap.round);
    canvas.drawCircle(pinRightPos, 2.5, Paint()..color = const Color(0xFF94A3B8));

    // 1. Soquete roscado de latão/alumínio E10
    canvas.drawRRect(
      RRect.fromRectAndRadius(socketRect.translate(2, 3), const Radius.circular(4)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    final socketShader = const LinearGradient(
      colors: [Color(0xFF475569), Color(0xFF1E293B), Color(0xFF0F172A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(socketRect);
    canvas.drawRRect(RRect.fromRectAndRadius(socketRect, const Radius.circular(4)), Paint()..shader = socketShader);

    // Roscas espirais de contato metálico (Prateado / Aço)
    final threadPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.6;
    canvas.drawLine(Offset(socketRect.left + 3, socketRect.top + 6), Offset(socketRect.right - 3, socketRect.top + 6), threadPaint);
    canvas.drawLine(Offset(socketRect.left + 3, socketRect.top + 13), Offset(socketRect.right - 3, socketRect.top + 13), threadPaint);

    // Ponto de solda metálico na base inferior do soquete
    canvas.drawCircle(Offset(cx, socketRect.bottom + 1.5), 3.5, Paint()..color = const Color(0xFFCBD5E1));

    // 2. Glow estendido fotorrealista quando aceso
    if (isActive) {
      canvas.drawCircle(
        bulbCenter,
        bulbRadius + 42,
        Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
      canvas.drawCircle(
        bulbCenter,
        bulbRadius + 22,
        Paint()
          ..color = const Color(0xFFFF9100).withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    // Sombra sob o domo de vidro
    canvas.drawCircle(
      bulbCenter.translate(3, 4),
      bulbRadius,
      Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // 3. Bulbo de vidro soprados com iluminação esférica 3D
    final glassPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.45),
        radius: 0.85,
        colors: isActive
            ? const [Color(0xFFFFFFFF), Color(0xFFFFF59D), Color(0xFFFFB300)]
            : (isDarkMode
                ? const [Color(0x40FFFFFF), Color(0x1AFFFFFF), Color(0x00FFFFFF)]
                : const [Color(0xFFFFFFFF), Color(0xFFECEFF1), Color(0xFFB0BEC5)]),
      ).createShader(Rect.fromCircle(center: bulbCenter, radius: bulbRadius));
    canvas.drawCircle(bulbCenter, bulbRadius, glassPaint);

    // Borda reflexiva do vidro
    final glassBorder = Paint()
      ..color = isActive ? Colors.amber.withValues(alpha: 0.8) : Colors.blueGrey.shade200
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(bulbCenter, bulbRadius, glassBorder);

    // Brilhos especulares duplos no vidro
    canvas.drawCircle(
      Offset(bulbCenter.dx - 7.0, bulbCenter.dy - 7.5),
      5.5,
      Paint()..color = Colors.white.withValues(alpha: isActive ? 0.95 : 0.7),
    );
    canvas.drawCircle(
      Offset(bulbCenter.dx + 8.0, bulbCenter.dy + 8.0),
      2.5,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );

    // 4. Hastes internas de suporte de níquel e Filamento de Tungstênio em V
    final supportPaint = Paint()
      ..color = isActive ? const Color(0xFFFF3D00) : const Color(0xFF546E7A)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx - 6, cy - 6), Offset(cx - 4, cy - 20), supportPaint);
    canvas.drawLine(Offset(cx + 6, cy - 6), Offset(cx + 4, cy - 20), supportPaint);

    final filPath = Path()
      ..moveTo(cx - 4, cy - 20)
      ..lineTo(cx - 2, cy - 26)
      ..lineTo(cx, cy - 23)
      ..lineTo(cx + 2, cy - 26)
      ..lineTo(cx + 4, cy - 20);

    canvas.drawPath(
      filPath,
      Paint()
        ..color = isActive ? Colors.white : const Color(0xFF37474F)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  /// --------------------------------------------------------------------------
  /// RESISTOR DE FILME DE CARBONO 1/4W (Dumbbell Ceramic Shape 3D - Expandido)
  /// --------------------------------------------------------------------------
  List<Color> _getResistorColors(double val) {
    if (val <= 0) val = 10.0;
    final int valInt = val.round();
    final String str = valInt.toString();
    int d1 = int.parse(str[0]);
    int d2 = str.length > 1 ? int.parse(str[1]) : 0;
    int zeros = str.length - 2;
    if (zeros < 0) zeros = 0;

    final colorMap = [
      const Color(0xFF212121), // 0 Preto
      const Color(0xFF6D4C41), // 1 Marrom
      const Color(0xFFE53935), // 2 Vermelho
      const Color(0xFFFB8C00), // 3 Laranja
      const Color(0xFFFFD600), // 4 Amarelo
      const Color(0xFF43A047), // 5 Verde
      const Color(0xFF1E88E5), // 6 Azul
      const Color(0xFF8E24AA), // 7 Violeta
      const Color(0xFF757575), // 8 Cinza
      const Color(0xFFFFFFFF), // 9 Branco
    ];

    final c1 = colorMap[d1.clamp(0, 9)];
    final c2 = colorMap[d2.clamp(0, 9)];
    final c3 = colorMap[zeros.clamp(0, 9)];
    const c4 = Color(0xFFFFD54F);

    return [c1, c2, c3, c4];
  }

  void _drawPhysicalResistor(Canvas canvas, Size size, double cx, double cy) {
    const resWidth = 64.0;
    const centerHeight = 19.0;
    const bulbHeight = 24.0;

    final resRect = Rect.fromCenter(center: Offset(cx, cy), width: resWidth, height: bulbHeight);

    _drawCleanLeads(canvas, size, cx, cy, resRect.left - 2, resRect.right + 2);

    // Sombra 3D
    canvas.drawRRect(
      RRect.fromRectAndRadius(resRect.translate(2.5, 4.5), const Radius.circular(8)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 1. Corpo Cerâmico abuloado em haltere
    final bodyPath = Path()
      ..moveTo(resRect.left, cy - bulbHeight / 2)
      ..arcToPoint(Offset(resRect.left + 9, cy - centerHeight / 2), radius: const Radius.circular(6))
      ..lineTo(resRect.right - 9, cy - centerHeight / 2)
      ..arcToPoint(Offset(resRect.right, cy - bulbHeight / 2), radius: const Radius.circular(6))
      ..lineTo(resRect.right, cy + bulbHeight / 2)
      ..arcToPoint(Offset(resRect.right - 9, cy + centerHeight / 2), radius: const Radius.circular(6))
      ..lineTo(resRect.left + 9, cy + centerHeight / 2)
      ..arcToPoint(Offset(resRect.left, cy + bulbHeight / 2), radius: const Radius.circular(6))
      ..close();

    final ceramicShader = const LinearGradient(
      colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2), Color(0xFFFFCC80), Color(0xFFD7CCC8)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(resRect);

    canvas.drawPath(bodyPath, Paint()..shader = ceramicShader);

    // 2. Faixas de cores dinâmicas
    final colors = _getResistorColors(value);
    final bandPositions = [-19.0, -7.5, 4.0, 17.5];
    for (var i = 0; i < colors.length; i++) {
      final h = (i == 0 || i == 3) ? bulbHeight : centerHeight;
      canvas.drawRect(
        Rect.fromLTWH(cx + bandPositions[i], cy - h / 2, 5.5, h),
        Paint()..color = colors[i],
      );
      if (i == 3) {
        canvas.drawRect(
          Rect.fromLTWH(cx + bandPositions[i] + 1.5, cy - h / 2, 1.5, h),
          Paint()..color = Colors.white.withValues(alpha: 0.7),
        );
      }
    }

    // 3. Brilho especular longitudinal
    canvas.drawLine(
      Offset(resRect.left + 4, cy - centerHeight / 2 + 1.8),
      Offset(resRect.right - 4, cy - centerHeight / 2 + 1.8),
      Paint()..color = Colors.white.withValues(alpha: 0.75)..strokeWidth = 1.8,
    );
  }

  /// --------------------------------------------------------------------------
  /// DIODO RETIFICADOR 1N4007 (Epoxy Package DO-41 - Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalDiode(Canvas canvas, Size size, double cx, double cy) {
    final diodeRect = Rect.fromCenter(center: Offset(cx, cy), width: 62, height: 22);
    final diodeRRect = RRect.fromRectAndRadius(diodeRect, const Radius.circular(6.0));

    _drawCleanLeads(canvas, size, cx, cy, diodeRect.left - 2, diodeRect.right + 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(diodeRect.translate(2.5, 4.0), const Radius.circular(6.0)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Corpo de Epóxi Preto fosco usinado
    final bodyShader = const LinearGradient(
      colors: [Color(0xFF424242), Color(0xFF212121), Color(0xFF000000)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(diodeRect);
    canvas.drawRRect(diodeRRect, Paint()..shader = bodyShader);

    // Anel prateado de Cátodo
    canvas.drawRect(
      Rect.fromLTWH(diodeRect.left + 9, diodeRect.top, 7.5, 22),
      Paint()..color = const Color(0xFFCFD8DC),
    );

    // Micro-gravação do código "1N4007"
    TextPainter(
      text: const TextSpan(
        text: '1N4007',
        style: TextStyle(color: Color(0xFF90A4AE), fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset(cx - 3, cy - 4.5));

    // Highlight especular
    canvas.drawLine(
      Offset(diodeRect.left + 3, diodeRect.top + 1.8),
      Offset(diodeRect.right - 3, diodeRect.top + 1.8),
      Paint()..color = Colors.white.withValues(alpha: 0.45)..strokeWidth = 1.4,
    );
  }

  /// --------------------------------------------------------------------------
  /// DIODO EMISSOR DE LUZ - LED 5mm 3D (Expandido)
  /// --------------------------------------------------------------------------
  /// --------------------------------------------------------------------------
  /// DIODO EMISSOR DE LUZ - LED 5mm 3D ULTRARREALISTA (Referência Componente T-1¾)
  /// --------------------------------------------------------------------------
  void _drawPhysicalLED(Canvas canvas, Size size, double cx, double cy) {
    // 1. Hastes de conexão de bancada
    _drawCleanLeads(canvas, size, cx, cy, cx - 16, cx + 16);

    // Geometria do Pacote de LED 5mm (Domo + Cilindro + Flange de Base)
    const double domeRadius = 14.0;
    const double cylinderHeight = 15.0;
    const double flangeWidth = 32.0;
    const double flangeHeight = 5.0;

    final double ledTopY = cy - 18.0;
    final double domeStartY = ledTopY + domeRadius;
    final double cylinderBottomY = domeStartY + cylinderHeight;
    final double flangeBottomY = cylinderBottomY + flangeHeight;

    // 2. Pernas/Terminais metálicos verticais (Ânodo + longo à esquerda, Cátodo - curto à direita)
    final pinPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF64748B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - 15, flangeBottomY, 30, 25));

    final pinCapPaint = Paint()..color = const Color(0xFFCBD5E1);

    // Perna Ânodo (+) - mais longa (esquerda)
    final anodeX = cx - 5.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(anodeX - 1.2, flangeBottomY, 2.4, 22), const Radius.circular(0.8)),
      pinPaint,
    );
    // Trava/Entalhe da perna do ânodo
    canvas.drawRect(Rect.fromLTWH(anodeX - 2.0, flangeBottomY + 6, 4.0, 1.8), pinCapPaint);

    // Perna Cátodo (-) - mais curta (direita)
    final cathodeX = cx + 5.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cathodeX - 1.2, flangeBottomY, 2.4, 16), const Radius.circular(0.8)),
      pinPaint,
    );
    // Trava/Entalhe da perna do cátodo
    canvas.drawRect(Rect.fromLTWH(cathodeX - 2.0, flangeBottomY + 6, 4.0, 1.8), pinCapPaint);

    // 3. Efeito de Fotoluminescência Neon Radial (quando energizado / isActive)
    if (isActive) {
      final glowCenter = Offset(cx, domeStartY);
      canvas.drawCircle(
        glowCenter,
        domeRadius + 28,
        Paint()
          ..color = const Color(0xFFEF4444).withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
      canvas.drawCircle(
        glowCenter,
        domeRadius + 14,
        Paint()
          ..color = const Color(0xFFF87171).withValues(alpha: 0.65)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      final rayPaint = Paint()
        ..color = const Color(0xFFFECACA).withValues(alpha: 0.95)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx - 16, ledTopY - 6), Offset(cx - 24, ledTopY - 16), rayPaint);
      canvas.drawLine(Offset(cx + 16, ledTopY - 6), Offset(cx + 24, ledTopY - 16), rayPaint);
      canvas.drawLine(Offset(cx, ledTopY - 10), Offset(cx, ledTopY - 22), rayPaint);
    }

    // Sombra projetada sob o corpo do LED
    final shadowBounds = Rect.fromLTRB(cx - 16, ledTopY, cx + 16, flangeBottomY);
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowBounds.translate(2, 3), const Radius.circular(10)),
      Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 4. Armação Metálica Interna (Lead Frame - Anvil & Post)
    // Haste do Cátodo com Taça Refletora (Anvil)
    final anvilPath = Path()
      ..moveTo(cathodeX - 0.8, cylinderBottomY)
      ..lineTo(cathodeX - 0.8, domeStartY + 2)
      ..lineTo(cx + 1.0, domeStartY - 2)
      ..lineTo(cx - 4.5, domeStartY - 7)
      ..lineTo(cx - 6.5, domeStartY - 2)
      ..lineTo(cathodeX - 3.5, domeStartY + 2)
      ..close();
    canvas.drawPath(anvilPath, Paint()..color = const Color(0xFFCBD5E1).withValues(alpha: 0.85));

    // Haste do Ânodo (Post)
    final postPath = Path()
      ..moveTo(anodeX + 0.8, cylinderBottomY)
      ..lineTo(anodeX + 0.8, domeStartY + 1)
      ..lineTo(anodeX - 2.5, domeStartY - 4)
      ..lineTo(anodeX - 0.5, domeStartY - 4)
      ..close();
    canvas.drawPath(postPath, Paint()..color = const Color(0xFFE2E8F0).withValues(alpha: 0.85));

    // Micro Fio de Ouro (Bond Wire) ligando a fita ao chip
    final wirePath = Path()
      ..moveTo(anodeX - 1.5, domeStartY - 4)
      ..quadraticBezierTo(cx - 5, domeStartY - 9, cx - 3, domeStartY - 5);
    canvas.drawPath(
      wirePath,
      Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Chip Semicondutor (LED Die) dentro da taça da Anvil
    final dieRect = Rect.fromCenter(center: Offset(cx - 3.5, domeStartY - 4.5), width: 2.2, height: 2.2);
    canvas.drawRect(
      dieRect,
      Paint()..color = isActive ? const Color(0xFFFFFFFF) : const Color(0xFFFEF08A),
    );

    // 5. Corpo de Resina Epóxi Translúcida Vermelha (Domo + Cilindro)
    final ledPath = Path();
    ledPath.moveTo(cx - domeRadius, cylinderBottomY);
    ledPath.lineTo(cx - domeRadius, domeStartY);
    ledPath.arcToPoint(
      Offset(cx + domeRadius, domeStartY),
      radius: const Radius.circular(domeRadius),
      clockwise: true,
    );
    ledPath.lineTo(cx + domeRadius, cylinderBottomY);
    ledPath.close();

    final ledBodyRect = Rect.fromLTRB(cx - domeRadius, ledTopY, cx + domeRadius, cylinderBottomY);
    final ledShader = RadialGradient(
      center: const Alignment(-0.35, -0.45),
      radius: 0.85,
      colors: isActive
          ? const [
              Color(0xFFFEF2F2),
              Color(0xFFF87171),
              Color(0xFFEF4444),
              Color(0xFFDC2626),
              Color(0xFF991B1B),
            ]
          : const [
              Color(0xFFFCA5A5),
              Color(0xFFEF4444),
              Color(0xFFDC2626),
              Color(0xFFB91C1C),
              Color(0xFF7F1D1D),
            ],
      stops: const [0.0, 0.25, 0.55, 0.8, 1.0],
    ).createShader(ledBodyRect);

    canvas.drawPath(ledPath, Paint()..shader = ledShader);

    // 6. Flange / Anel de Base Proeminente (Borda inferior do LED igual à foto)
    final flangeRect = Rect.fromLTRB(cx - (flangeWidth / 2), cylinderBottomY - 1, cx + (flangeWidth / 2), flangeBottomY);
    final flangeRRect = RRect.fromRectAndRadius(flangeRect, const Radius.circular(2.0));

    final flangeShader = LinearGradient(
      colors: isActive
          ? const [Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFF991B1B)]
          : const [Color(0xFFDC2626), Color(0xFFB91C1C), Color(0xFF7F1D1D)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(flangeRect);

    canvas.drawRRect(flangeRRect, Paint()..shader = flangeShader);

    // Destaque brilhante na borda da flange
    canvas.drawLine(
      Offset(cx - (flangeWidth / 2) + 2, cylinderBottomY + 1),
      Offset(cx + (flangeWidth / 2) - 2, cylinderBottomY + 1),
      Paint()..color = Colors.white.withValues(alpha: 0.4)..strokeWidth = 1.0,
    );

    // 7. Reflexos Especulares Glossy do Domo de Plástico (IGUAL À FOTO DA REFERÊNCIA)
    final mainStreakPath = Path()
      ..moveTo(cx - 7.5, ledTopY + 3)
      ..cubicTo(
        cx - 11.5, domeStartY - 2,
        cx - 11.5, domeStartY + 6,
        cx - 8.5, cylinderBottomY - 3,
      );

    canvas.drawPath(
      mainStreakPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(cx + 6.0, domeStartY - 6.0),
      1.8,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  /// --------------------------------------------------------------------------
  /// MOTOR CC CILÍNDRICO 130 DE LABORATÓRIO (Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalMotor(Canvas canvas, Size size, double cx, double cy) {
    final motorCenter = Offset(cx - 8, cy);
    final motorRect = Rect.fromCenter(center: motorCenter, width: 54, height: 34);

    _drawCleanLeads(canvas, size, cx, cy, motorRect.left - 8, cx + 36);

    // Sombra do corpo cilíndrico
    canvas.drawRRect(
      RRect.fromRectAndRadius(motorRect.translate(3, 5), const Radius.circular(7.0)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Tampa traseira de plástico preta
    final capBackRect = Rect.fromLTWH(motorRect.left - 7, cy - 13, 8, 26);
    canvas.drawRRect(RRect.fromRectAndRadius(capBackRect, const Radius.circular(3)), Paint()..color = const Color(0xFF1E293B));

    // Corpo metálico cilíndrico de aço escovado
    final motorGradient = Paint()
      ..shader = LinearGradient(
        colors: isActive
            ? const [Color(0xFFFFFFFF), Color(0xFFCBD5E1), Color(0xFF64748B), Color(0xFF334155)]
            : const [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(motorRect);

    canvas.drawRRect(RRect.fromRectAndRadius(motorRect, const Radius.circular(7.0)), motorGradient);

    // Fresta de ventilação lateral
    final ventSlot = Rect.fromLTWH(cx - 12, cy - 8, 14, 11);
    canvas.drawRRect(RRect.fromRectAndRadius(ventSlot, const Radius.circular(2.0)), Paint()..color = const Color(0xFF0F172A));
    canvas.drawRect(Rect.fromLTWH(cx - 9, cy - 6, 8, 7), Paint()..color = const Color(0xFFD97706));

    // Eixo rotativo de Aço Inox
    final shaftPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFCBD5E1), Color(0xFF64748B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(motorRect.right, cy - 3, 12, 6))
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(motorRect.right, cy), Offset(motorRect.right + 11, cy), shaftPaint);

    // Hélice / Rotor 3D
    final discCenter = Offset(motorRect.right + 11, cy);
    const fanRadius = 19.0;

    canvas.drawCircle(discCenter, fanRadius, Paint()..color = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9));
    canvas.drawCircle(
      discCenter,
      fanRadius,
      Paint()
        ..color = const Color(0xFF00F5D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    final angle = isActive ? (DateTime.now().millisecondsSinceEpoch / 20) % (2 * math.pi) : 0.0;

    for (int i = 0; i < 4; i++) {
      final bladeAngle = angle + (i * math.pi / 2);
      final pEnd = Offset(
        discCenter.dx + (fanRadius - 1.5) * math.cos(bladeAngle),
        discCenter.dy + (fanRadius - 1.5) * math.sin(bladeAngle),
      );

      final bladePath = Path()
        ..moveTo(discCenter.dx, discCenter.dy)
        ..quadraticBezierTo(
          discCenter.dx + (fanRadius * 0.6) * math.cos(bladeAngle + 0.3),
          discCenter.dy + (fanRadius * 0.6) * math.sin(bladeAngle + 0.3),
          pEnd.dx,
          pEnd.dy,
        );

      canvas.drawPath(
        bladePath,
        Paint()
          ..color = isActive ? const Color(0xFF00F5D4) : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF334155))
          ..strokeWidth = 4.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(discCenter, 4.5, Paint()..color = const Color(0xFFD97706));
    canvas.drawCircle(discCenter, 1.8, Paint()..color = Colors.black);
  }

  /// --------------------------------------------------------------------------
  /// POTENCIÔMETRO ROTATIVO 10k 3D (Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalPotentiometer(Canvas canvas, Size size, double cx, double cy) {
    final knobCenter = Offset(cx, cy);
    const knobRadius = 25.0;

    _drawCleanLeads(canvas, size, cx, cy, cx - knobRadius - 2, cx + knobRadius + 2);

    canvas.drawCircle(
      knobCenter.translate(3, 4),
      knobRadius,
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Corpo metálico de Zinco
    canvas.drawCircle(
      knobCenter,
      knobRadius,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFFF5F5F5), Color(0xFFBDBDBD), Color(0xFF616161), Color(0xFF212121)],
        ).createShader(Rect.fromCircle(center: knobCenter, radius: knobRadius)),
    );

    // Eixo rotativo de alumínio com entalhe indicador
    const angle = -math.pi / 4;
    final indX = knobCenter.dx + (knobRadius - 5.0) * math.cos(angle);
    final indY = knobCenter.dy + (knobRadius - 5.0) * math.sin(angle);
    canvas.drawLine(
      knobCenter,
      Offset(indX, indY),
      Paint()..color = const Color(0xFF00F5D4)..strokeWidth = 3.8..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(knobCenter, 5.0, Paint()..color = const Color(0xFF212121));
  }

  /// --------------------------------------------------------------------------
  /// FONTE DE ALIMENTAÇÃO DE BANCADA (Power Supply 3D - Expandida)
  /// --------------------------------------------------------------------------
  void _drawPhysicalPowerSupply(Canvas canvas, Size size, double cx, double cy) {
    final bodyRect = Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.90, height: size.height * 0.82);
    final rr = RRect.fromRectAndRadius(bodyRect, const Radius.circular(10));

    _drawCleanLeads(canvas, size, cx, cy, bodyRect.left, bodyRect.right);

    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect.translate(3, 5), const Radius.circular(10)),
      Paint()..color = Colors.black.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bodyRect),
    );

    canvas.drawRRect(rr, Paint()..color = const Color(0xFF00F5D4).withValues(alpha: 0.7)..strokeWidth = 1.8..style = PaintingStyle.stroke);

    // Display LCD Digital
    final lcdRect = Rect.fromCenter(center: Offset(cx, cy - 8), width: 68, height: 28);
    canvas.drawRRect(RRect.fromRectAndRadius(lcdRect, const Radius.circular(5)), Paint()..color = const Color(0xFF022C22));
    
    final voltStr = value > 0 ? '${value.toStringAsFixed(1)}V' : '12.0V';
    final textPainter = TextPainter(
      text: TextSpan(
        text: voltStr,
        style: const TextStyle(
          color: Color(0xFF00FF9D),
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - 17));
  }

  /// --------------------------------------------------------------------------
  /// FUSÍVEL DE VIDRO 5x20mm (Cartridge Fuse 3D - Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalFuse(Canvas canvas, Size size, double cx, double cy) {
    final tubeRect = Rect.fromCenter(center: Offset(cx, cy), width: 62, height: 20);

    _drawCleanLeads(canvas, size, cx, cy, tubeRect.left - 2, tubeRect.right + 2);

    // Corpo de Vidro Transparente
    canvas.drawRRect(
      RRect.fromRectAndRadius(tubeRect, const Radius.circular(5)),
      Paint()..color = isDarkMode ? Colors.white24 : const Color(0x66E0F7FA),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tubeRect, const Radius.circular(5)),
      Paint()..color = Colors.cyan.withValues(alpha: 0.6)..strokeWidth = 1.5..style = PaintingStyle.stroke,
    );

    // Terminais metálicos niquelados
    final capLeft = Rect.fromLTWH(tubeRect.left, tubeRect.top, 13, 20);
    final capRight = Rect.fromLTWH(tubeRect.right - 13, tubeRect.top, 13, 20);
    final metalPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFB0BEC5), Color(0xFF546E7A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(capLeft);

    canvas.drawRect(capLeft, metalPaint);
    canvas.drawRect(capRight, metalPaint);

    // Elemento fusível interno
    if (!isBurned) {
      canvas.drawLine(
        Offset(tubeRect.left + 13, cy),
        Offset(tubeRect.right - 13, cy),
        Paint()..color = Colors.amber.shade400..strokeWidth = 2.2,
      );
    } else {
      canvas.drawLine(Offset(tubeRect.left + 13, cy), Offset(cx - 6, cy + 3.5), Paint()..color = Colors.black87..strokeWidth = 2.2);
      canvas.drawLine(Offset(cx + 6, cy - 3.5), Offset(tubeRect.right - 13, cy), Paint()..color = Colors.black87..strokeWidth = 2.2);
    }
  }

  /// --------------------------------------------------------------------------
  /// CAPACITOR ELETROLÍTICO DE ALUMÍNIO (Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalCapacitor(Canvas canvas, Size size, double cx, double cy) {
    final capRect = Rect.fromCenter(center: Offset(cx, cy), width: 36, height: 42);
    final rr = RRect.fromRectAndRadius(capRect, const Radius.circular(7.5));

    _drawCleanLeads(canvas, size, cx, cy, capRect.left - 2, capRect.right + 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect.translate(2.5, 4.0), const Radius.circular(7.5)),
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Casing cilíndrico com manga de PVC azul
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(capRect),
    );

    // Faixa branca de polaridade negativa (-)
    canvas.drawRect(
      Rect.fromLTWH(capRect.left + 3, capRect.top, 8.0, capRect.height),
      Paint()..color = const Color(0xFFECEFF1),
    );
    TextPainter(text: const TextSpan(text: '-', style: TextStyle(color: Color(0xFF0D47A1), fontSize: 13, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(capRect.left + 4.5, capRect.top + 12));

    // Topo de alumínio com estamparia de ranhura de segurança
    canvas.drawRect(Rect.fromLTWH(capRect.left, capRect.top, capRect.width, 4.5), Paint()..color = const Color(0xFFCFD8DC));
  }

  /// --------------------------------------------------------------------------
  /// BUZZER PIEZOELÉTRICO ATIVO (Expandido)
  /// --------------------------------------------------------------------------
  void _drawPhysicalBuzzer(Canvas canvas, Size size, double cx, double cy) {
    final buzzCenter = Offset(cx, cy);
    const buzzRadius = 24.0;

    _drawCleanLeads(canvas, size, cx, cy, buzzCenter.dx - buzzRadius - 2, buzzCenter.dx + buzzRadius + 2);

    canvas.drawCircle(
      buzzCenter.translate(3, 4),
      buzzRadius,
      Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Corpo de plástico Noryl preto
    canvas.drawCircle(
      buzzCenter,
      buzzRadius,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFF37474F), Color(0xFF263238), Color(0xFF102A43)],
        ).createShader(Rect.fromCircle(center: buzzCenter, radius: buzzRadius)),
    );

    // Anel de borda de vedação
    canvas.drawCircle(buzzCenter, buzzRadius, Paint()..color = const Color(0xFF00F5D4).withValues(alpha: 0.5)..strokeWidth = 1.6..style = PaintingStyle.stroke);
    
    // Orifício de ressonância acústica central
    canvas.drawCircle(buzzCenter, 6.5, Paint()..color = Colors.black);

    // Ondas sonoras animadas quando ativo
    if (isActive) {
      final wavePaint = Paint()
        ..color = const Color(0xFF00F5D4).withValues(alpha: 0.85)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCircle(center: buzzCenter, radius: 31), -math.pi / 3, 2 * math.pi / 3, false, wavePaint);
      canvas.drawArc(Rect.fromCircle(center: buzzCenter, radius: 38), -math.pi / 3, 2 * math.pi / 3, false, wavePaint..color = const Color(0xFF00F5D4).withValues(alpha: 0.4));
    }
  }

  @override
  bool shouldRepaint(covariant ComponentPhysicalPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isBurned != isBurned ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.value != value ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.wireKind != wireKind;
  }
}
