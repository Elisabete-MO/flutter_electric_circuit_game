import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/burned_effects_painter.dart';

/// Painter de bancada para o Estande 5 (Letreiros LED).
/// Renderiza:
/// - Bateria 9V horizontal realista com acabamento em cobre, terminais e snap clip
/// - Cabos flexíveis em curvas catenárias suaves (sem colisão com o dock inferior)
/// - Protoboard com escala harmonizada, numeração 1-20, letras a-j e canal central
/// - Chave táctil (Pushbutton) de 4 pinos na vala central
/// - LED 5mm realista com cúpula de epóxi, chanfro no cátodo e pernas metálicas inseridas
/// - Resistor cerâmico detalhado com badge translúcido de alta legibilidade
/// - Letreiro(s) luminoso(s) com hastes de suporte integradas e efeito neon
class LetrerosLedBreadboardPainter extends CustomPainter {
  final double animationValue;
  final bool usePhysicalStyle;
  final bool isClosed;
  final bool isBurnt;
  final bool isDim;
  final String signTitle;
  final Color signColor;
  final String? secondSignTitle;
  final Color? secondSignColor;
  final bool secondSignLit;
  final bool secondBranchActive;
  final bool hasResistor;
  final String resistorValue;
  final bool resistorInCorrectTrack;
  final bool hasLed;
  final bool ledDirectPolarity;
  final bool jumperConnected;
  final bool showPushButton;
  final bool isPushButtonPressed;

  LetrerosLedBreadboardPainter({
    required this.animationValue,
    this.usePhysicalStyle = true,
    required this.isClosed,
    this.isBurnt = false,
    this.isDim = false,
    this.signTitle = 'SAÍDA',
    this.signColor = const Color(0xFFEF4444),
    this.secondSignTitle,
    this.secondSignColor,
    this.secondSignLit = false,
    this.secondBranchActive = false,
    this.hasResistor = true,
    this.resistorValue = '680 Ω',
    this.resistorInCorrectTrack = true,
    this.hasLed = true,
    this.ledDirectPolarity = true,
    this.jumperConnected = true,
    this.showPushButton = true,
    this.isPushButtonPressed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (usePhysicalStyle) {
      _paintPhysicalWorkbench(canvas, size);
    } else {
      _paintSchematicWorkbench(canvas, size);
    }
  }

  // =========================================================================
  // MODO FÍSICO REALISTA
  // =========================================================================

  void _paintPhysicalWorkbench(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Letreiro(s) Luminoso(s) no topo
    if (secondSignTitle != null) {
      _drawDualSignBoards(canvas, size);
    } else {
      _drawSingleSignBoard(canvas, size);
    }

    // 2. Proporções da Protoboard (elevada para liberar o dock inferior)
    final bbLeft = (w * 0.32).clamp(180.0, 290.0);
    final bbWidth = (w - bbLeft - (w * 0.04)).clamp(270.0, 520.0);
    final bbTop = (h * 0.24).clamp(70.0, 115.0);
    final bbHeight = (h * 0.54).clamp(170.0, 240.0);
    final breadboardRect = Rect.fromLTWH(bbLeft, bbTop, bbWidth, bbHeight);

    // 3. Proporções da Bateria 9V (Horizontal à esquerda, perfeitamente alinhada ao centro da protoboard)
    final batWidth = (w * 0.20).clamp(105.0, 155.0);
    final batHeight = (batWidth * 0.60).clamp(62.0, 92.0);
    final batLeft = (w * 0.04).clamp(14.0, 32.0);
    final batTop = bbTop + (bbHeight - batHeight) * 0.48;
    final batteryRect = Rect.fromLTWH(batLeft, batTop, batWidth, batHeight);

    // Desenhar Bateria 9V Horizontal
    _drawHorizontal9VBattery(canvas, batteryRect);

    // Desenhar Protoboard
    _drawBreadboard(canvas, breadboardRect);

    // Desenhar Componentes e Fiação
    _drawCircuitElements(canvas, size, batteryRect, breadboardRect);
  }

  /// Desenha a Bateria 9V deitada horizontalmente
  void _drawHorizontal9VBattery(Canvas canvas, Rect rect) {
    // Sombra suave da bateria
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(3, 5)), const Radius.circular(8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    const bodyRadius = Radius.circular(8);

    // 1. Bloco preto principal da bateria (~72% da largura)
    final blackPartWidth = rect.width * 0.72;
    final blackRect = Rect.fromLTWH(rect.left, rect.top, blackPartWidth, rect.height);
    final blackPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF262626), Color(0xFF171717), Color(0xFF0F172A)],
      ).createShader(blackRect);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        blackRect,
        topLeft: bodyRadius,
        bottomLeft: bodyRadius,
      ),
      blackPaint,
    );

    // 2. Faixa vertical de cobre/bronze (~28% da largura)
    final copperPartWidth = rect.width - blackPartWidth;
    final copperRect = Rect.fromLTWH(rect.left + blackPartWidth, rect.top, copperPartWidth, rect.height);
    final copperPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEA580C), Color(0xFFD97706), Color(0xFFB45309), Color(0xFF78350F)],
        stops: [0.0, 0.3, 0.7, 1.0],
      ).createShader(copperRect);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        copperRect,
        topRight: bodyRadius,
        bottomRight: bodyRadius,
      ),
      copperPaint,
    );

    // Linha de divisão vertical
    canvas.drawLine(
      Offset(copperRect.left, copperRect.top),
      Offset(copperRect.left, copperRect.bottom),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.8)
        ..strokeWidth = 1.5,
    );

    // Borda sutil
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, bodyRadius),
      Paint()
        ..color = const Color(0xFF334155).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 3. Rótulo "9V"
    final textPainter = TextPainter(
      text: TextSpan(
        text: '9V',
        style: GoogleFonts.rajdhani(
          color: Colors.white.withValues(alpha: 0.92),
          fontWeight: FontWeight.bold,
          fontSize: (rect.height * 0.42).clamp(17.0, 28.0),
          letterSpacing: 2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        blackRect.center.dx - textPainter.width / 2,
        blackRect.center.dy - textPainter.height / 2,
      ),
    );

    // 4. Marcações "+" e "-" na faixa de cobre
    final posTerminalY = rect.top + rect.height * 0.28;
    final negTerminalY = rect.top + rect.height * 0.72;

    final posSignPainter = TextPainter(
      text: TextSpan(
        text: '+',
        style: GoogleFonts.rajdhani(
          color: const Color(0xFFFEF08A),
          fontWeight: FontWeight.bold,
          fontSize: (rect.height * 0.26).clamp(13.0, 18.0),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    posSignPainter.paint(
      canvas,
      Offset(copperRect.center.dx - posSignPainter.width / 2, posTerminalY - posSignPainter.height / 2),
    );

    final negSignPainter = TextPainter(
      text: TextSpan(
        text: '–',
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: (rect.height * 0.26).clamp(13.0, 18.0),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    negSignPainter.paint(
      canvas,
      Offset(copperRect.center.dx - negSignPainter.width / 2, negTerminalY - negSignPainter.height / 2),
    );

    // 5. Terminais metálicos no lado direito
    final termRightX = rect.right;
    final termPosCenter = Offset(termRightX + 4, posTerminalY);
    final termNegCenter = Offset(termRightX + 4, negTerminalY);

    // Terminal Positivo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: termPosCenter, width: 7, height: rect.height * 0.22),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawCircle(termPosCenter, 3.2, Paint()..color = const Color(0xFFE2E8F0));

    // Terminal Negativo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: termNegCenter, width: 7, height: rect.height * 0.24),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF64748B),
    );
    canvas.drawCircle(termNegCenter, 2.8, Paint()..color = const Color(0xFF1E293B));

    // 6. Snap Clip Connector (Presilha escura conectada aos terminais)
    final clipBarRect = Rect.fromLTWH(
      termRightX + 6,
      rect.top + rect.height * 0.12,
      7,
      rect.height * 0.76,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(clipBarRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(clipBarRect, const Radius.circular(3)),
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Rebites do clip
    canvas.drawCircle(Offset(clipBarRect.center.dx, posTerminalY), 2.2, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(Offset(clipBarRect.center.dx, negTerminalY), 2.2, Paint()..color = const Color(0xFFCBD5E1));
  }

  /// Desenha a Protoboard realista com furos, canal central e identificação
  void _drawBreadboard(Canvas canvas, Rect rect) {
    // Sombra da Protoboard
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(3, 5)), const Radius.circular(12)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // Corpo plástico branco/gelo
    final boardPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF8FAFC), Color(0xFFEDEFEF), Color(0xFFE2E8F0)],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      boardPaint,
    );

    // Borda plástica externa
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Notches de encaixe nas laterais
    _drawBreadboardNotches(canvas, rect);

    // Canal central (Trench divider)
    final trenchY = rect.top + rect.height * 0.50;
    final trenchRect = Rect.fromLTWH(rect.left + 16, trenchY - 3.5, rect.width - 32, 7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(trenchRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawLine(
      Offset(trenchRect.left + 4, trenchY),
      Offset(trenchRect.right - 4, trenchY),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 1.2,
    );

    // Barramentos de Alimentação (+ Vermelho e - Azul)
    final topPowerYMinus = rect.top + rect.height * 0.08;
    final topPowerYPlus = rect.top + rect.height * 0.16;
    final botPowerYMinus = rect.top + rect.height * 0.84;
    final botPowerYPlus = rect.top + rect.height * 0.92;

    final busLeft = rect.left + 22.0;
    final busRight = rect.right - 22.0;

    // Linhas de polaridade com rótulos
    _drawPowerRailLine(canvas, Offset(busLeft, topPowerYMinus), Offset(busRight, topPowerYMinus), const Color(0xFF3B82F6), '-');
    _drawPowerRailLine(canvas, Offset(busLeft, topPowerYPlus), Offset(busRight, topPowerYPlus), const Color(0xFFEF4444), '+');
    _drawPowerRailLine(canvas, Offset(busLeft, botPowerYMinus), Offset(busRight, botPowerYMinus), const Color(0xFF3B82F6), '-');
    _drawPowerRailLine(canvas, Offset(busLeft, botPowerYPlus), Offset(busRight, botPowerYPlus), const Color(0xFFEF4444), '+');

    // Matriz de furos e rótulos
    _drawBreadboardTiePoints(canvas, rect);
  }

  void _drawBreadboardNotches(Canvas canvas, Rect rect) {
    final notchPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    // Notches esquerdos
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left - 3, rect.top + rect.height * 0.28, 6, 12),
        const Radius.circular(3),
      ),
      notchPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left - 3, rect.top + rect.height * 0.68, 6, 12),
        const Radius.circular(3),
      ),
      notchPaint,
    );

    // Notches direitos
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.right - 3, rect.top + rect.height * 0.28, 6, 12),
        const Radius.circular(3),
      ),
      notchPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.right - 3, rect.top + rect.height * 0.68, 6, 12),
        const Radius.circular(3),
      ),
      notchPaint,
    );
  }

  void _drawPowerRailLine(Canvas canvas, Offset start, Offset end, Color color, String sign) {
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = color.withValues(alpha: 0.80)
        ..strokeWidth = 1.4,
    );

    final signPainter = TextPainter(
      text: TextSpan(
        text: sign,
        style: GoogleFonts.rajdhani(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    signPainter.paint(canvas, Offset(start.dx - 10, start.dy - signPainter.height / 2));
    signPainter.paint(canvas, Offset(end.dx + 4, end.dy - signPainter.height / 2));
  }

  void _drawBreadboardTiePoints(Canvas canvas, Rect rect) {
    const cols = 20;
    final startX = rect.left + 32.0;
    final stepX = (rect.width - 64.0) / (cols - 1);

    final holeBgPaint = Paint()..color = const Color(0xFF64748B);
    final holeCorePaint = Paint()..color = const Color(0xFF0F172A);

    final topPowerYMinus = rect.top + rect.height * 0.08;
    final topPowerYPlus = rect.top + rect.height * 0.16;

    final rowStepTop = (rect.height * 0.22) / 4;
    final rowStartYTop = rect.top + rect.height * 0.24;

    final rowStepBot = (rect.height * 0.22) / 4;
    final rowStartYBot = rect.top + rect.height * 0.54;

    final botPowerYMinus = rect.top + rect.height * 0.84;
    final botPowerYPlus = rect.top + rect.height * 0.92;

    final rowLabelsTop = ['j', 'i', 'h', 'g', 'f'];
    final rowLabelsBot = ['e', 'd', 'c', 'b', 'a'];

    for (int r = 0; r < 5; r++) {
      final yTop = rowStartYTop + r * rowStepTop;
      final yBot = rowStartYBot + r * rowStepBot;

      _drawRowLetter(canvas, rowLabelsTop[r], Offset(rect.left + 12, yTop));
      _drawRowLetter(canvas, rowLabelsTop[r], Offset(rect.right - 16, yTop));

      _drawRowLetter(canvas, rowLabelsBot[r], Offset(rect.left + 12, yBot));
      _drawRowLetter(canvas, rowLabelsBot[r], Offset(rect.right - 16, yBot));
    }

    for (int col = 0; col < cols; col++) {
      final cx = startX + col * stepX;

      // Alimentação topo
      _drawSingleHole(canvas, Offset(cx, topPowerYMinus), holeBgPaint, holeCorePaint);
      _drawSingleHole(canvas, Offset(cx, topPowerYPlus), holeBgPaint, holeCorePaint);

      // Banco superior (5 furos)
      for (int r = 0; r < 5; r++) {
        _drawSingleHole(canvas, Offset(cx, rowStartYTop + r * rowStepTop), holeBgPaint, holeCorePaint);
      }

      // Banco inferior (5 furos)
      for (int r = 0; r < 5; r++) {
        _drawSingleHole(canvas, Offset(cx, rowStartYBot + r * rowStepBot), holeBgPaint, holeCorePaint);
      }

      // Alimentação baixo
      _drawSingleHole(canvas, Offset(cx, botPowerYMinus), holeBgPaint, holeCorePaint);
      _drawSingleHole(canvas, Offset(cx, botPowerYPlus), holeBgPaint, holeCorePaint);

      // Números de colunas
      if (col % 5 == 0 || col == cols - 1) {
        final colNum = (col + 1).toString();
        final numPainter = TextPainter(
          text: TextSpan(
            text: colNum,
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 8.0,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        numPainter.paint(canvas, Offset(cx - numPainter.width / 2, rect.top + 1));
      }
    }
  }

  void _drawRowLetter(Canvas canvas, String letter, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.rajdhani(
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w600,
          fontSize: 7.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _drawSingleHole(Canvas canvas, Offset center, Paint bg, Paint core) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCircle(center: center, radius: 2.0), const Radius.circular(0.5)),
      bg,
    );
    canvas.drawCircle(center, 1.0, core);
  }

  /// Desenha os cabos flexíveis da bateria, jumpers da protoboard, resistor, LED e pushbutton
  void _drawCircuitElements(Canvas canvas, Size size, Rect batRect, Rect bbRect) {
    // Snap clip saída dos cabos
    final clipX = batRect.right + 13;
    final posTermY = batRect.top + batRect.height * 0.28;
    final negTermY = batRect.top + batRect.height * 0.72;

    final wirePosStart = Offset(clipX, posTermY);
    final wireNegStart = Offset(clipX, negTermY);

    // Barramento de alimentação da Protoboard
    final topPowerYPlus = bbRect.top + bbRect.height * 0.16;
    final botPowerYMinus = bbRect.top + bbRect.height * 0.84;

    final bbPowerTopPlus = Offset(bbRect.left + 32, topPowerYPlus);
    final bbPowerBotMinus = Offset(bbRect.left + 32, botPowerYMinus);

    // 1. Cabo flexível Vermelho da Bateria ao Barramento (+) com curva fluida catenária
    final wirePosCtrl1 = Offset(clipX + (bbRect.left - clipX) * 0.40, posTermY - 18);
    final wirePosCtrl2 = Offset(bbPowerTopPlus.dx - 30, topPowerYPlus - 10);
    _drawCurvedWire(
      canvas,
      wirePosStart,
      wirePosCtrl1,
      wirePosCtrl2,
      bbPowerTopPlus,
      const Color(0xFFEF4444),
      isActive: true,
      thickness: 3.6,
    );

    // 2. Cabo flexível Preto da Bateria ao Barramento (-) com arco suave e limpo
    final wireNegCtrl1 = Offset(clipX + (bbRect.left - clipX) * 0.45, negTermY + 20);
    final wireNegCtrl2 = Offset(bbPowerBotMinus.dx - 30, botPowerYMinus + 10);
    _drawCurvedWire(
      canvas,
      wireNegStart,
      wireNegCtrl1,
      wireNegCtrl2,
      bbPowerBotMinus,
      const Color(0xFF1E293B),
      isActive: true,
      thickness: 3.6,
    );

    // Coordenadas das colunas na protoboard
    const cols = 20;
    final startX = bbRect.left + 32.0;
    final stepX = (bbRect.width - 64.0) / (cols - 1);

    // Posições no Ramo 1 (Principal)
    final col3X = startX + 3 * stepX;
    final col6X = startX + 6 * stepX;
    final col9X = startX + 9 * stepX;

    // Furo Barramento (+) Coluna 3
    final holePlusCol3 = Offset(col3X, topPowerYPlus);
    final holeTrackTopCol3 = Offset(col3X, bbRect.top + bbRect.height * 0.24);

    // Fio jumper Vermelho do barramento (+) para a Coluna 3 (linha j)
    if (jumperConnected) {
      _drawJumperWire(canvas, holePlusCol3, holeTrackTopCol3, const Color(0xFFEF4444), isActive: isClosed);
    } else {
      // Jumper desconectado / aberto (Missão 3)
      _drawDisconnectedJumper(canvas, holePlusCol3, Offset(col3X + 14, holePlusCol3.dy + 12), const Color(0xFFEF4444));
    }

    // Resistor: Conecta Coluna 3 à Coluna 6 (na linha h)
    final rowStepTop = (bbRect.height * 0.22) / 4;
    final rowHY = bbRect.top + bbRect.height * 0.24 + 2 * rowStepTop;

    if (hasResistor) {
      final rStart = Offset(col3X, rowHY);
      final rEnd = resistorInCorrectTrack
          ? Offset(col6X, rowHY)
          : Offset(col6X + 12, bbRect.top + bbRect.height * 0.12); // Fora da trilha

      _drawPhysicalResistor(canvas, rStart, rEnd, resistorValue);
    }

    // LED 1 (5mm): Conecta Coluna 6 à Coluna 9 (na linha f)
    final rowFY = bbRect.top + bbRect.height * 0.24 + 4 * rowStepTop;
    if (hasLed) {
      final ledAnodeHole = Offset(col6X, rowFY);
      final ledCathodeHole = Offset(col9X, rowFY);

      _drawPhysical5mmLed(
        canvas,
        anodePos: ledDirectPolarity ? ledAnodeHole : ledCathodeHole,
        cathodePos: ledDirectPolarity ? ledCathodeHole : ledAnodeHole,
        color: signColor,
        isLit: isClosed,
        isBurnt: isBurnt,
        isDim: isDim,
        directPolarity: ledDirectPolarity,
      );
    }

    // Pushbutton na vala central (Coluna 9)
    if (showPushButton) {
      final buttonColX = startX + 9 * stepX;
      final trenchCenterY = bbRect.top + bbRect.height * 0.50;
      _drawTactilePushButton(canvas, Offset(buttonColX, trenchCenterY), isPressed: isClosed);
    }

    // Jumper Preto de Retorno: Da Coluna 9 (linha a do banco inferior) para o barramento (-) inferior
    final rowStepBot = (bbRect.height * 0.22) / 4;
    final rowAY = bbRect.top + bbRect.height * 0.54 + 4 * rowStepBot;
    final holeTrackBotCol9 = Offset(col9X, rowAY);
    final holeMinusCol9 = Offset(col9X, botPowerYMinus);
    _drawJumperWire(canvas, holeTrackBotCol9, holeMinusCol9, const Color(0xFF1E293B), isActive: isClosed);

    // Se houver segundo ramo (Missão 5 - Entrada e Saída em Paralelo)
    if (secondSignTitle != null) {
      final col13X = startX + 13 * stepX;
      final col16X = startX + 16 * stepX;
      final col19X = startX + 19 * stepX;

      // Jumper (+) Ramo 2
      final holePlusCol13 = Offset(col13X, topPowerYPlus);
      final holeTrackTopCol13 = Offset(col13X, bbRect.top + bbRect.height * 0.24);
      _drawJumperWire(canvas, holePlusCol13, holeTrackTopCol13, const Color(0xFF10B981), isActive: secondSignLit);

      // Resistor Ramo 2 (680 Ω)
      final r2Start = Offset(col13X, rowHY);
      final r2End = Offset(col16X, rowHY);
      _drawPhysicalResistor(canvas, r2Start, r2End, '680 Ω');

      // LED 2 (Verde 5mm)
      final led2Anode = Offset(col16X, rowFY);
      final led2Cathode = Offset(col19X, rowFY);
      _drawPhysical5mmLed(
        canvas,
        anodePos: led2Anode,
        cathodePos: led2Cathode,
        color: secondSignColor ?? const Color(0xFF10B981),
        isLit: secondSignLit,
        isBurnt: false,
        isDim: false,
        directPolarity: true,
      );

      // Pushbutton Ramo 2
      if (showPushButton) {
        final btn2X = startX + 19 * stepX;
        final trenchY = bbRect.top + bbRect.height * 0.50;
        _drawTactilePushButton(canvas, Offset(btn2X, trenchY), isPressed: secondSignLit);
      }

      // Jumper (-) Ramo 2
      final holeTrackBotCol19 = Offset(col19X, rowAY);
      final holeMinusCol19 = Offset(col19X, botPowerYMinus);
      _drawJumperWire(canvas, holeTrackBotCol19, holeMinusCol19, const Color(0xFF1E293B), isActive: secondSignLit);
    }
  }

  /// Desenha uma curva de fio suave usando curvas de Bézier
  void _drawCurvedWire(
    Canvas canvas,
    Offset start,
    Offset ctrl1,
    Offset ctrl2,
    Offset end,
    Color color, {
    bool isActive = true,
    double thickness = 3.6,
  }) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, end.dx, end.dy);

    // Sombra do cabo
    canvas.drawPath(
      path.shift(const Offset(2, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..strokeWidth = thickness + 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Corpo isolante do cabo
    canvas.drawPath(
      path,
      Paint()
        ..color = isActive ? color : color.withValues(alpha: 0.6)
        ..strokeWidth = thickness
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Brilho especular suave
    canvas.drawPath(
      path.shift(const Offset(-0.6, -0.6)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Pino condutor na ponta
    canvas.drawCircle(end, 2.5, Paint()..color = const Color(0xFF94A3B8));

    // Elétrons em movimento
    if (isActive && isClosed) {
      _drawFlowingElectrons(canvas, path);
    }
  }

  /// Desenha um jumper de protoboard com isolamento colorido
  void _drawJumperWire(Canvas canvas, Offset start, Offset end, Color color, {bool isActive = true}) {
    final midY = (start.dy + end.dy) / 2;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx, midY)
      ..lineTo(end.dx, midY)
      ..lineTo(end.dx, end.dy);

    // Sombra
    canvas.drawPath(
      path.shift(const Offset(1.5, 2.5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..strokeWidth = 3.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Isolamento
    canvas.drawPath(
      path,
      Paint()
        ..color = isActive ? color : color.withValues(alpha: 0.5)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Brilho
    canvas.drawPath(
      path.shift(const Offset(-0.5, -0.5)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 0.9
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Pinos metálicos nos furos
    canvas.drawCircle(start, 2.2, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(end, 2.2, Paint()..color = const Color(0xFF94A3B8));

    // Elétrons
    if (isActive) {
      _drawFlowingElectrons(canvas, path);
    }
  }

  void _drawDisconnectedJumper(Canvas canvas, Offset start, Offset brokenEnd, Color color) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(start.dx + 10, start.dy + 2, brokenEnd.dx, brokenEnd.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..strokeWidth = 2.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Terminal solto com indicador de alerta
    canvas.drawCircle(brokenEnd, 3.0, Paint()..color = Colors.amberAccent);
    canvas.drawCircle(
      brokenEnd,
      5.5,
      Paint()
        ..color = Colors.amberAccent.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  /// Desenha a chave táctil (Pushbutton de 4 pinos) na vala central
  void _drawTactilePushButton(Canvas canvas, Offset center, {bool isPressed = false}) {
    const btnSize = 16.0;
    final btnRect = Rect.fromCenter(center: center, width: btnSize, height: btnSize);

    // Pernas nos 4 cantos
    final pinPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final pinOffset = btnSize / 2 + 3.0;
    canvas.drawLine(Offset(center.dx - 5, center.dy - pinOffset), Offset(center.dx - 5, center.dy - btnSize / 2), pinPaint);
    canvas.drawLine(Offset(center.dx + 5, center.dy - pinOffset), Offset(center.dx + 5, center.dy - btnSize / 2), pinPaint);
    canvas.drawLine(Offset(center.dx - 5, center.dy + btnSize / 2), Offset(center.dx - 5, center.dy + pinOffset), pinPaint);
    canvas.drawLine(Offset(center.dx + 5, center.dy + btnSize / 2), Offset(center.dx + 5, center.dy + pinOffset), pinPaint);

    // Sombra
    canvas.drawRRect(
      RRect.fromRectAndRadius(btnRect.shift(const Offset(1, 2)), const Radius.circular(3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Corpo preto quadrado
    canvas.drawRRect(
      RRect.fromRectAndRadius(btnRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF1E293B),
    );

    // Borda metálica circular
    canvas.drawCircle(
      center,
      btnSize * 0.38,
      Paint()..color = const Color(0xFFCBD5E1),
    );

    // Êmbolo central (botão preto/cinza)
    final plungerRadius = isPressed ? btnSize * 0.24 : btnSize * 0.28;
    canvas.drawCircle(
      center,
      plungerRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: isPressed
              ? [const Color(0xFF059669), const Color(0xFF047857)]
              : [const Color(0xFF334155), const Color(0xFF0F172A)],
        ).createShader(Rect.fromCircle(center: center, radius: plungerRadius)),
    );
  }

  /// Desenha o resistor cerâmico com badge de valor com alto contraste
  void _drawPhysicalResistor(Canvas canvas, Offset start, Offset end, String value) {
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final width = (end.dx - start.dx).abs().clamp(26.0, 46.0);
    const height = 9.5;

    // Terminais metálicos
    final leadPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, Offset(center.dx - width / 2, center.dy), leadPaint);
    canvas.drawLine(Offset(center.dx + width / 2, center.dy), end, leadPaint);

    // Sombra do corpo
    final bodyRect = Rect.fromCenter(center: center, width: width, height: height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect.shift(const Offset(1.0, 1.8)), const Radius.circular(4.5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // Corpo cerâmico bege
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFDE68A), Color(0xFFD4B996), Color(0xFFB49B7A)],
      ).createShader(bodyRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4.5)),
      bodyPaint,
    );

    // Faixas de código de cores
    final bands = _getResistorBands(value);
    final bandStep = width / (bands.length + 1);
    for (int i = 0; i < bands.length; i++) {
      final bx = bodyRect.left + (i + 1) * bandStep;
      canvas.drawLine(
        Offset(bx, bodyRect.top + 0.5),
        Offset(bx, bodyRect.bottom - 0.5),
        Paint()
          ..color = bands[i]
          ..strokeWidth = 2.2,
      );
    }

    // Badge de texto translúcido
    final textPainter = TextPainter(
      text: TextSpan(
        text: value,
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 8.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - height / 2 - 8),
      width: textPainter.width + 8,
      height: textPainter.height + 3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.88),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - height / 2 - 8 - textPainter.height / 2));
  }

  List<Color> _getResistorBands(String value) {
    if (value.contains('680')) {
      return [const Color(0xFF2563EB), const Color(0xFF6B7280), const Color(0xFF78350F), const Color(0xFFEAB308)];
    } else if (value.contains('6.8') || value.contains('6,8')) {
      return [const Color(0xFF2563EB), const Color(0xFF6B7280), const Color(0xFFDC2626), const Color(0xFFEAB308)];
    } else {
      return [const Color(0xFF2563EB), const Color(0xFF6B7280), const Color(0xFF171717), const Color(0xFFEAB308)];
    }
  }

  /// Desenha o LED 5mm realista com pernas metálicas visíveis e cúpula
  void _drawPhysical5mmLed(
    Canvas canvas, {
    required Offset anodePos,
    required Offset cathodePos,
    required Color color,
    required bool isLit,
    required bool isBurnt,
    required bool isDim,
    required bool directPolarity,
  }) {
    final center = Offset((anodePos.dx + cathodePos.dx) / 2, (anodePos.dy + cathodePos.dy) / 2 - 16);

    // Pernas metálicas entrando nos furos
    final leadPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Perna Ânodo (com curva de ressalto na parte superior)
    final anodePath = Path()
      ..moveTo(anodePos.dx, anodePos.dy)
      ..lineTo(anodePos.dx, center.dy + 8)
      ..lineTo(directPolarity ? center.dx - 3 : center.dx + 3, center.dy + 8)
      ..lineTo(directPolarity ? center.dx - 3 : center.dx + 3, center.dy + 5);
    canvas.drawPath(anodePath, leadPaint);

    // Perna Cátodo (reta)
    final cathodePath = Path()
      ..moveTo(cathodePos.dx, cathodePos.dy)
      ..lineTo(cathodePos.dx, center.dy + 8)
      ..lineTo(directPolarity ? center.dx + 3 : center.dx - 3, center.dy + 8)
      ..lineTo(directPolarity ? center.dx + 3 : center.dx - 3, center.dy + 5);
    canvas.drawPath(cathodePath, leadPaint);

    // Pinos de inserção nos furos
    canvas.drawCircle(anodePos, 2.0, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(cathodePos, 2.0, Paint()..color = const Color(0xFFCBD5E1));

    // Dimensões do LED DIP 5mm
    const ledRadius = 10.5;
    final domeRect = Rect.fromCircle(center: center, radius: ledRadius);

    // Sombra do LED
    canvas.drawCircle(
      center.translate(1.5, 3),
      ledRadius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    if (isBurnt) {
      // LED Queimado (cor cinza escuro / fuligem)
      canvas.drawCircle(center, ledRadius, Paint()..color = const Color(0xFF4B5563));
      drawBurnedSmokeAndEmbers(canvas, const Size(ledRadius * 3, ledRadius * 3), center.dx, center.dy, animationValue, isDark: false);
      return;
    }

    final effColor = isLit ? color : color.withValues(alpha: 0.35);

    // Glow radiante se aceso
    if (isLit) {
      final glowAlpha = isDim ? 0.28 : 0.75;
      final glowRadius = isDim ? 16.0 : 28.0;
      canvas.drawCircle(
        center,
        glowRadius,
        Paint()
          ..color = color.withValues(alpha: glowAlpha * 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, isDim ? 5 : 12),
      );
      canvas.drawCircle(
        center,
        glowRadius * 0.6,
        Paint()
          ..color = color.withValues(alpha: glowAlpha * 0.65)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, isDim ? 3 : 6),
      );
    }

    // Corpo de epóxi translúcido
    final domePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        colors: [
          Colors.white.withValues(alpha: isLit ? 0.95 : 0.45),
          effColor,
          effColor.withValues(alpha: 0.9),
          const Color(0xFF0F172A).withValues(alpha: 0.35),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(domeRect);
    canvas.drawCircle(center, ledRadius, domePaint);

    // Flange (anel de base) com chanfro do lado do cátodo
    final flangeY = center.dy + 5;
    final cathodeLeft = !directPolarity;
    canvas.drawLine(
      Offset(center.dx - ledRadius + (cathodeLeft ? 2.5 : 0), flangeY),
      Offset(center.dx + ledRadius - (cathodeLeft ? 0 : 2.5), flangeY),
      Paint()
        ..color = effColor
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // Identificação Ânodo (+) e Cátodo (–)
    final aLabel = TextPainter(
      text: TextSpan(text: 'A (+)', style: GoogleFonts.rajdhani(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 8)),
      textDirection: TextDirection.ltr,
    )..layout();
    aLabel.paint(canvas, Offset(anodePos.dx - aLabel.width / 2, anodePos.dy + 3));

    final kLabel = TextPainter(
      text: TextSpan(text: 'K (–)', style: GoogleFonts.rajdhani(color: const Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 8)),
      textDirection: TextDirection.ltr,
    )..layout();
    kLabel.paint(canvas, Offset(cathodePos.dx - kLabel.width / 2, cathodePos.dy + 3));
  }

  /// Desenha o letreiro luminoso com hastes de suporte integradas à bancada
  void _drawSingleSignBoard(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final signWidth = (w * 0.40).clamp(170.0, 280.0);
    final signHeight = (h * 0.16).clamp(36.0, 52.0);
    final signRect = Rect.fromCenter(
      center: Offset(w * 0.64, h * 0.13),
      width: signWidth,
      height: signHeight,
    );

    // Hastes metálicas verticais duplas de sustentação
    final strutPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 2.0;

    final strut1X = signRect.left + 30;
    final strut2X = signRect.right - 30;
    final strutEndY = (h * 0.24).clamp(70.0, 115.0);

    canvas.drawLine(Offset(strut1X, signRect.bottom), Offset(strut1X, strutEndY), strutPaint);
    canvas.drawLine(Offset(strut2X, signRect.bottom), Offset(strut2X, strutEndY), strutPaint);

    // Bornes de fixação
    canvas.drawCircle(Offset(strut1X, strutEndY), 3.0, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(Offset(strut2X, strutEndY), 3.0, Paint()..color = const Color(0xFF94A3B8));

    _renderSignBoardBox(
      canvas,
      signRect,
      title: signTitle,
      color: signColor,
      isLit: isClosed,
      isBurnt: isBurnt,
      isDim: isDim,
    );
  }

  /// Desenha dois letreiros lado a lado (Missão 5)
  void _drawDualSignBoards(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final signWidth = (w * 0.24).clamp(105.0, 170.0);
    final signHeight = (h * 0.16).clamp(36.0, 52.0);

    // Letreiro 1 (SAÍDA / Vermelho)
    final sign1Rect = Rect.fromCenter(
      center: Offset(w * 0.48, h * 0.13),
      width: signWidth,
      height: signHeight,
    );
    _renderSignBoardBox(
      canvas,
      sign1Rect,
      title: signTitle,
      color: signColor,
      isLit: isClosed,
      isBurnt: isBurnt,
      isDim: isDim,
    );

    // Letreiro 2 (ENTRADA / Verde)
    final sign2Rect = Rect.fromCenter(
      center: Offset(w * 0.78, h * 0.13),
      width: signWidth,
      height: signHeight,
    );
    _renderSignBoardBox(
      canvas,
      sign2Rect,
      title: secondSignTitle ?? 'ENTRADA',
      color: secondSignColor ?? const Color(0xFF10B981),
      isLit: secondSignLit,
      isBurnt: false,
      isDim: false,
    );
  }

  void _renderSignBoardBox(
    Canvas canvas,
    Rect rect, {
    required String title,
    required Color color,
    required bool isLit,
    required bool isBurnt,
    required bool isDim,
  }) {
    final effColor = isBurnt
        ? const Color(0xFF6B7280)
        : isLit
            ? color
            : const Color(0xFF334155);

    // Sombra
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(2, 4)), const Radius.circular(10)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Acrílico preto translúcido
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F172A), Color(0xFF020617)],
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), bgPaint);

    // Glow na borda
    if (isLit && !isBurnt) {
      final glowAlpha = isDim ? 0.20 : 0.55;
      final blur = isDim ? 8.0 : 18.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)),
        Paint()
          ..color = color.withValues(alpha: glowAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
      );
    }

    // Borda sólida
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = effColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Parafusos nos cantos
    const screwOffset = 5.5;
    const screwRadius = 1.8;
    final screwPaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawCircle(Offset(rect.left + screwOffset, rect.top + screwOffset), screwRadius, screwPaint);
    canvas.drawCircle(Offset(rect.right - screwOffset, rect.top + screwOffset), screwRadius, screwPaint);
    canvas.drawCircle(Offset(rect.left + screwOffset, rect.bottom - screwOffset), screwRadius, screwPaint);
    canvas.drawCircle(Offset(rect.right - screwOffset, rect.bottom - screwOffset), screwRadius, screwPaint);

    // Texto Neon Central
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: GoogleFonts.rajdhani(
          color: effColor,
          fontWeight: FontWeight.bold,
          fontSize: (rect.height * 0.44).clamp(13.0, 23.0),
          letterSpacing: 3.0,
          shadows: isLit && !isBurnt
              ? [
                  Shadow(color: color.withValues(alpha: isDim ? 0.4 : 0.9), blurRadius: isDim ? 6 : 14),
                  Shadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 3),
                ]
              : [],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2, rect.center.dy - textPainter.height / 2),
    );

    // Fumaça se queimado
    if (isBurnt) {
      drawBurnedSmokeAndEmbers(canvas, Size(rect.width, rect.height), rect.center.dx, rect.center.dy, animationValue, isDark: true);
    }
  }

  // =========================================================================
  // MODO ESQUEMÁTICO
  // =========================================================================

  void _paintSchematicWorkbench(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final activeLinePaint = Paint()
      ..color = isClosed ? const Color(0xFF10B981) : const Color(0xFF0F172A)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final cx = w * 0.50;
    final cy = h * 0.50;
    final loopW = w * 0.60;
    final loopH = h * 0.55;

    final leftX = cx - loopW / 2;
    final rightX = cx + loopW / 2;
    final topY = cy - loopH / 2;
    final botY = cy + loopH / 2;

    // Ramo da Bateria 9V (Esquerda)
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, cy - 25), activeLinePaint);
    canvas.drawLine(Offset(leftX, cy + 25), Offset(leftX, botY), activeLinePaint);
    _drawSchematicBattery(canvas, Offset(leftX, cy), '9V');

    // Ramo Superior com Resistor
    canvas.drawLine(Offset(leftX, topY), Offset(cx - 35, topY), activeLinePaint);
    canvas.drawLine(Offset(cx + 35, topY), Offset(rightX, topY), activeLinePaint);
    _drawSchematicResistor(canvas, Offset(cx, topY), resistorValue);

    // Ramo Direito com LED
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, cy - 30), activeLinePaint);
    canvas.drawLine(Offset(rightX, cy + 30), Offset(rightX, botY), activeLinePaint);
    _drawSchematicLed(canvas, Offset(rightX, cy), isLit: isClosed, directPolarity: ledDirectPolarity);

    // Ramo Inferior de Retorno (GND)
    canvas.drawLine(Offset(rightX, botY), Offset(leftX, botY), activeLinePaint);

    // Título do Esquema
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'DIAGRAMA ESQUEMÁTICO — $signTitle',
        style: GoogleFonts.rajdhani(
          color: const Color(0xFF334155),
          fontWeight: FontWeight.bold,
          fontSize: 15,
          letterSpacing: 2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - 10));
  }

  void _drawSchematicBattery(Canvas canvas, Offset pos, String label) {
    final p = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 3.0;

    canvas.drawLine(Offset(pos.dx - 18, pos.dy - 7), Offset(pos.dx + 18, pos.dy - 7), p);
    canvas.drawLine(Offset(pos.dx - 10, pos.dy + 7), Offset(pos.dx + 10, pos.dy + 7), p);

    final tp = TextPainter(
      text: TextSpan(text: label, style: GoogleFonts.rajdhani(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - 30 - tp.width, pos.dy - tp.height / 2));
  }

  void _drawSchematicResistor(Canvas canvas, Offset pos, String label) {
    final path = Path()
      ..moveTo(pos.dx - 26, pos.dy)
      ..lineTo(pos.dx - 18, pos.dy - 8)
      ..lineTo(pos.dx - 9, pos.dy + 8)
      ..lineTo(pos.dx, pos.dy - 8)
      ..lineTo(pos.dx + 9, pos.dy + 8)
      ..lineTo(pos.dx + 18, pos.dy - 8)
      ..lineTo(pos.dx + 26, pos.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    final tp = TextPainter(
      text: TextSpan(text: label, style: GoogleFonts.rajdhani(color: const Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - 24));
  }

  void _drawSchematicLed(Canvas canvas, Offset pos, {required bool isLit, required bool directPolarity}) {
    final p = Paint()
      ..color = isLit ? const Color(0xFF10B981) : const Color(0xFF0F172A)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final dir = directPolarity ? 1.0 : -1.0;
    final triangle = Path()
      ..moveTo(pos.dx - 14, pos.dy - 12 * dir)
      ..lineTo(pos.dx + 14, pos.dy - 12 * dir)
      ..lineTo(pos.dx, pos.dy + 12 * dir)
      ..close();

    canvas.drawPath(triangle, p);
    canvas.drawLine(Offset(pos.dx - 14, pos.dy + 12 * dir), Offset(pos.dx + 14, pos.dy + 12 * dir), p);

    final a1 = Path()
      ..moveTo(pos.dx + 16, pos.dy - 6)
      ..lineTo(pos.dx + 26, pos.dy - 14)
      ..lineTo(pos.dx + 21, pos.dy - 14)
      ..moveTo(pos.dx + 26, pos.dy - 14)
      ..lineTo(pos.dx + 26, pos.dy - 9);
    canvas.drawPath(a1, p);
  }

  void _drawFlowingElectrons(Canvas canvas, Path path) {
    const electronCount = 7;
    final glowPaint = Paint()
      ..color = const Color(0xFFFDE047)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    final corePaint = Paint()..color = const Color(0xFFFEF08A);

    for (final metric in path.computeMetrics()) {
      final length = metric.length;
      for (int i = 0; i < electronCount; i++) {
        final distance = ((animationValue + (i / electronCount)) % 1.0) * length;
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final pos = tangent.position;
          canvas.drawCircle(pos, 3.5, glowPaint);
          canvas.drawCircle(pos, 1.8, corePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LetrerosLedBreadboardPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.usePhysicalStyle != usePhysicalStyle ||
        oldDelegate.isClosed != isClosed ||
        oldDelegate.isBurnt != isBurnt ||
        oldDelegate.isDim != isDim ||
        oldDelegate.hasResistor != hasResistor ||
        oldDelegate.resistorValue != resistorValue ||
        oldDelegate.resistorInCorrectTrack != resistorInCorrectTrack ||
        oldDelegate.hasLed != hasLed ||
        oldDelegate.ledDirectPolarity != ledDirectPolarity ||
        oldDelegate.jumperConnected != jumperConnected ||
        oldDelegate.secondSignLit != secondSignLit ||
        oldDelegate.showPushButton != showPushButton ||
        oldDelegate.isPushButtonPressed != isPushButtonPressed;
  }
}
