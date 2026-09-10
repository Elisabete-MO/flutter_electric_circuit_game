import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/ui_scale.dart';
import 'prof_volts_feedback_dialog.dart';
import 'workbench_sidebar_cards.dart';

/// Moldura Padronizada da Mesa de Laboratório (EletroLab)
/// Utiliza o asset `mesa_eletrolab_vista_superior.png` como fundo vetorial/fotográfico
/// com seletores, cartões de status e controles flutuantes integrados.
class WorkbenchTableFrame extends StatelessWidget {
  final Widget child;
  final bool usePhysicalStyle;
  final ValueSetter<bool> onStyleChanged;
  final Widget? leftHeaderWidget;
  final Widget? rightHeaderWidget;
  final Widget? bottomWidget;
  final bool showModeSelector;
  final String? voltsTip;
  final VoidCallback? onHintPressed;

  const WorkbenchTableFrame({
    super.key,
    required this.child,
    required this.usePhysicalStyle,
    required this.onStyleChanged,
    this.leftHeaderWidget,
    this.rightHeaderWidget,
    this.bottomWidget,
    this.showModeSelector = true,
    this.voltsTip,
    this.onHintPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scale.size(20, min: 14, max: 32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: scale.size(18, min: 10, max: 28),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(scale.size(20, min: 14, max: 32)),
        child: Stack(
          children: [
            // 1. Mesa e Lousa 100% Vetoriais (Nenhum bitmap esticado, nitidez perfeita em qualquer resolução)
            Positioned.fill(
              child: CustomPaint(
                painter: WorkbenchDeskPainter(
                  woodRadius: scale.size(20, min: 14, max: 32),
                  boardRadius: scale.size(16, min: 12, max: 24),
                  borderMargin: scale.spacing(14, min: 8, max: 22),
                ),
              ),
            ),

            // 2. Área Central do Circuito Eletrônico
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  top: scale.spacing(52, min: 38, max: 76),
                  bottom: scale.spacing(48, min: 34, max: 72),
                  left: scale.spacing(18, min: 12, max: 30),
                  right: scale.spacing(18, min: 12, max: 30),
                ),
                child: child,
              ),
            ),

            // 3. Barra Superior Flutuante (Cards de Status, Seletor e Telemetria)
            Positioned(
              top: scale.spacing(12, min: 8, max: 20),
              left: scale.spacing(16, min: 10, max: 28),
              right: scale.spacing(16, min: 10, max: 28),
              child: LayoutBuilder(
                builder: (context, headerConstraints) {
                  final headerW = headerConstraints.maxWidth;
                  final isCompact = headerW < 540;
                  final isUltraCompact = headerW < 400;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Canto Esquerdo: Card de Status
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: leftHeaderWidget != null
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: leftHeaderWidget!,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),

                      // Centro: Seletor de Modo (Esquemático vs Físico 3D)
                      if (showModeSelector)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildVisualModeSelector(
                            context,
                            isCompact: isCompact,
                            isUltraCompact: isUltraCompact,
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      // Canto Direito: Card de Telemetria
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: rightHeaderWidget != null
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: rightHeaderWidget!,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 4. Rodapé Flutuante (ex: Undo / Redo Pill)
            if (bottomWidget != null)
              Positioned(
                bottom: scale.spacing(12, min: 8, max: 20),
                left: 0,
                right: 0,
                child: Center(
                  child: bottomWidget!,
                ),
              ),

            // 5. Botão Flutuante de Dica do Professor Volts (Canto Inferior Direito da Bancada)
            if (voltsTip != null || onHintPressed != null)
              Positioned(
                bottom: scale.spacing(12, min: 8, max: 20),
                right: scale.spacing(14, min: 8, max: 22),
                child: Tooltip(
                  message: 'Dica do Professor Volts',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (onHintPressed != null) {
                          onHintPressed!();
                        } else if (voltsTip != null && voltsTip!.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (ctx) => ProfVoltsTipDialog(voltsTip: voltsTip!),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(scale.size(24, min: 18, max: 32)),
                      child: Container(
                        height: scale.size(40, min: 32, max: 48),
                        padding: EdgeInsets.symmetric(
                          horizontal: scale.spacing(10, min: 7, max: 14),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(
                            scale.size(24, min: 18, max: 32),
                          ),
                          border: Border.all(
                            color: const Color(0xFFF59E0B),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706).withValues(alpha: 0.25),
                              blurRadius: scale.size(8, min: 4, max: 14),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ProfVoltsAvatar(
                              size: scale.size(24, min: 18, max: 30),
                            ),
                            SizedBox(width: scale.spacing(5, min: 3, max: 8)),
                            Text(
                              'Dica',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFB45309),
                                fontWeight: FontWeight.bold,
                                fontSize: scale.font(UiTypography.label),
                              ),
                            ),
                            SizedBox(width: scale.spacing(2, min: 1, max: 4)),
                            Icon(
                              Icons.lightbulb_rounded,
                              size: scale.icon(16, min: 12, max: 20),
                              color: const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualModeSelector(
    BuildContext context, {
    bool isCompact = false,
    bool isUltraCompact = false,
  }) {
    final scale = context.uiScale;

    return Container(
      height: scale.size(36, min: 30, max: 54),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(scale.size(20, min: 16, max: 30)),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: scale.size(8, min: 4, max: 14),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opção 1: Esquemático
          GestureDetector(
            onTap: () => onStyleChanged(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isUltraCompact
                    ? 8
                    : (isCompact ? 10 : scale.spacing(14, min: 10, max: 24)),
                vertical: scale.spacing(4, min: 2, max: 8),
              ),
              decoration: BoxDecoration(
                color: !usePhysicalStyle
                    ? const Color(0xFF0284C7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
                boxShadow: !usePhysicalStyle
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.architecture_rounded,
                    size: scale.icon(15, min: 13, max: 22),
                    color: !usePhysicalStyle
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  if (!isUltraCompact) ...[
                    SizedBox(width: scale.spacing(5, min: 3, max: 8)),
                    Text(
                      isCompact ? 'Esq.' : 'Esquemático',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: scale.font(12.5, min: 11, max: 18),
                        color: !usePhysicalStyle
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 3),
          // Opção 2: Físico 3D
          GestureDetector(
            onTap: () => onStyleChanged(true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isUltraCompact
                    ? 8
                    : (isCompact ? 10 : scale.spacing(14, min: 10, max: 24)),
                vertical: scale.spacing(4, min: 2, max: 8),
              ),
              decoration: BoxDecoration(
                color: usePhysicalStyle
                    ? const Color(0xFF0284C7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
                boxShadow: usePhysicalStyle
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.electrical_services_rounded,
                    size: scale.icon(15, min: 13, max: 22),
                    color: usePhysicalStyle
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  if (!isUltraCompact) ...[
                    SizedBox(width: scale.spacing(5, min: 3, max: 8)),
                    Text(
                      isCompact ? 'Físico' : 'Físico 3D',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: scale.font(12.5, min: 11, max: 18),
                        color: usePhysicalStyle
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Layout Responsivo Universal para Bancadas do EletroLab (Bancada + Painel Lateral).
///
/// Garante que:
/// - Em telas largas (Desktop/Notebooks), a bancada ocupe o espaço nobre e o painel
///   lateral tenha uma largura proporcional e equilibrada (270-340px), evitando que
///   os cards fiquem "recuados demais" ou esvaziados à direita.
/// - Em telas intermediárias (Tablets/Telas menores), o painel lateral preserve sua
///   legibilidade mínima sem esmagar o conteúdo dos cards.
/// - Em telas compactas (< 720px), faz o reflow responsivo vertical com rolagem suave,
///   impedindo qualquer overflow horizontal.
class WorkbenchResponsiveLayout extends StatelessWidget {
  final Widget workbench;
  final Widget sidePanel;
  final double spacing;

  const WorkbenchResponsiveLayout({
    super.key,
    required this.workbench,
    required this.sidePanel,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Modo Vertical / Empilhado para telas estreitas (portrait ou mobile < 720px)
        if (w < 720) {
          final benchHeight = h > 0
              ? (h * 0.58).clamp(scale.size(320, min: 280, max: 480), scale.size(500, min: 380, max: 640))
              : scale.size(340, min: 300, max: 480);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: benchHeight,
                  child: workbench,
                ),
                SizedBox(height: scale.spacing(spacing, min: 10, max: 24)),
                sidePanel,
              ],
            ),
          );
        }

        // Modo Horizontal com Proporção Otimizada
        // Painel lateral com largura calibrada pelo UiScale (270px a 340px em 1080p, escalando em 2K/4K)
        final sidePanelWidth = scale.cardWidth(
          300.0,
          maxPercent: 0.32,
          min: 270.0,
          max: scale.size(360.0, min: 300.0, max: 540.0),
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: workbench),
            SizedBox(width: scale.spacing(spacing, min: 10, max: 24)),
            SizedBox(
              width: sidePanelWidth,
              child: sidePanel,
            ),
          ],
        );
      },
    );
  }
}

/// Pintor Vetorial da Mesa de Laboratório do EletroLab.
///
/// Renderiza nativamente em canvas:
/// 1. Tampo da mesa em madeira rica com gradiente de iluminação realista.
/// 2. Lousa central / tapete maker (cutting mat) verde-escuro profundo.
/// 3. Moldura de madeira escura com chanfro em relevo de luz e sombra.
/// 4. Grid milimetrado vetorial sutil e nítido em qualquer densidade de tela.
/// 5. Rebites / parafusos de latão dourados com fenda a 45° nos 4 cantos da lousa.
class WorkbenchDeskPainter extends CustomPainter {
  final double woodRadius;
  final double boardRadius;
  final double borderMargin;

  const WorkbenchDeskPainter({
    required this.woodRadius,
    required this.boardRadius,
    required this.borderMargin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final fullRect = Offset.zero & size;
    final woodRRect = RRect.fromRectAndRadius(fullRect, Radius.circular(woodRadius));

    // 1. Tampo da Mesa (Madeira Vetorial com gradiente realista de carvalho maker)
    final woodPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE29B4D), // Carvalho claro no topo (iluminação zenital)
          Color(0xFFD48A3C),
          Color(0xFFC47A2C),
          Color(0xFFB0681B), // Sombra suave na base
        ],
        stops: [0.0, 0.35, 0.70, 1.0],
      ).createShader(fullRect);

    canvas.drawRRect(woodRRect, woodPaint);

    // Textura rica da madeira de carvalho (pranchas, veios sinuosos, nós e bisel 3D)
    canvas.save();
    canvas.clipRRect(woodRRect);
    _drawWoodTexture(canvas, size);
    canvas.restore();

    // 2. Lousa Verde Central / Tapete de Montagem Maker
    final boardMarginHorizontal = borderMargin;
    final boardMarginVertical = borderMargin * 0.85;

    final boardRect = Rect.fromLTRB(
      boardMarginHorizontal,
      boardMarginVertical,
      size.width - boardMarginHorizontal,
      size.height - boardMarginVertical,
    );

    if (boardRect.width <= 10 || boardRect.height <= 10) return;

    final boardRRect = RRect.fromRectAndRadius(boardRect, Radius.circular(boardRadius));

    // Sombra externa suave da lousa projetada na mesa
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(boardRRect.shift(const Offset(0, 3)), shadowPaint);

    // Fundo do Tapete Verde Esmeralda (Cutting Mat de Bancada)
    final matPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: const [
          Color(0xFF0C3829), // Centro esmeralda profundo
          Color(0xFF07241A),
          Color(0xFF031610), // Bordas escuras
        ],
      ).createShader(boardRect);
    canvas.drawRRect(boardRRect, matPaint);

    // 3. Grid Milimetrado Vetorial (alinhado e nítido)
    canvas.save();
    canvas.clipRRect(boardRRect);

    final gridPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.07)
      ..strokeWidth = 1.0;

    const double gridSpacing = 22.0;
    for (double x = boardRect.left + (boardRect.width % gridSpacing) / 2; x < boardRect.right; x += gridSpacing) {
      canvas.drawLine(Offset(x, boardRect.top), Offset(x, boardRect.bottom), gridPaint);
    }
    for (double y = boardRect.top + (boardRect.height % gridSpacing) / 2; y < boardRect.bottom; y += gridSpacing) {
      canvas.drawLine(Offset(boardRect.left, y), Offset(boardRect.right, y), gridPaint);
    }

    // Moldura chanfrada de madeira escura ao redor da lousa com bisel
    final framePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF5A381C), // Bisel superior iluminado
          Color(0xFF351F0D),
          Color(0xFF241407), // Bisel inferior em sombra
        ],
      ).createShader(boardRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawRRect(boardRRect, framePaint);

    // Vinheta interna suave
    final innerVignette = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(boardRRect, innerVignette);

    canvas.restore();

    // 4. Parafusos / Rebites de Latão Dourados nos 4 cantos da moldura
    final screwOffset = boardRadius * 0.95;
    final List<Offset> screwCenters = [
      Offset(boardRect.left + screwOffset, boardRect.top + screwOffset),
      Offset(boardRect.right - screwOffset, boardRect.top + screwOffset),
      Offset(boardRect.left + screwOffset, boardRect.bottom - screwOffset),
      Offset(boardRect.right - screwOffset, boardRect.bottom - screwOffset),
    ];

    const double screwRadius = 5.0;
    for (final center in screwCenters) {
      // Sombra do parafuso
      canvas.drawCircle(
        center + const Offset(0, 1.2),
        screwRadius,
        Paint()..color = Colors.black.withValues(alpha: 0.50),
      );

      // Corpo de latão com gradiente metálico
      final screwPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFBE486),
            Color(0xFFD4AF37),
            Color(0xFF8C6B1B),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: screwRadius));
      canvas.drawCircle(center, screwRadius, screwPaint);

      // Borda metálica fina
      canvas.drawCircle(
        center,
        screwRadius,
        Paint()
          ..color = const Color(0xFF634A12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      // Fenda a 45 graus
      final fendaPaint = Paint()
        ..color = const Color(0xFF4A3409)
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center + const Offset(-2.0, -2.0),
        center + const Offset(2.0, 2.0),
        fendaPaint,
      );
    }
  }

  void _drawWoodTexture(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // A. Pranchas de carvalho (linhas horizontais divisórias sutis)
    final double plankHeight = math.max(38.0, h / 6.5);
    final plankDark = Paint()
      ..color = const Color(0xFF532407).withValues(alpha: 0.16)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final plankLight = Paint()
      ..color = const Color(0xFFFFE5B4).withValues(alpha: 0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double y = plankHeight; y < h; y += plankHeight) {
      final pathDark = Path()..moveTo(0, y);
      final pathLight = Path()..moveTo(0, y + 1.2);
      for (double x = 20; x <= w; x += 20) {
        final dy = 0.6 * math.sin(x * 0.02 + y);
        pathDark.lineTo(x, y + dy);
        pathLight.lineTo(x, y + 1.2 + dy);
      }
      canvas.drawPath(pathDark, plankDark);
      canvas.drawPath(pathLight, plankLight);
    }

    // B. Veios e estrias finas orgânicas da madeira
    final fiberDark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fiberLight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double fiberStep = math.max(5.0, h / 45);
    for (double y = fiberStep * 0.5; y < h; y += fiberStep) {
      final double waveFreq = 0.008 + ((y * 17) % 7) * 0.0015;
      final double waveAmp = 1.2 + ((y * 29) % 5) * 0.6;
      final double yOffsetPhase = (y * 0.13) % (2 * math.pi);

      final bool isHighlight = (y.toInt() % 3 == 0);
      final double alpha = isHighlight ? 0.045 : 0.065;

      final paint = isHighlight
          ? (fiberLight
            ..color = const Color(0xFFFFE8B8).withValues(alpha: alpha)
            ..strokeWidth = (y.toInt() % 2 == 0) ? 1.0 : 0.6)
          : (fiberDark
            ..color = const Color(0xFF4A1F04).withValues(alpha: alpha)
            ..strokeWidth = (y.toInt() % 2 == 0) ? 1.2 : 0.8);

      final path = Path()..moveTo(0, y);
      const double stepX = 25.0;
      for (double x = stepX; x <= w; x += stepX) {
        final curveY = y + waveAmp * math.sin(x * waveFreq + yOffsetPhase);
        path.lineTo(x, curveY);
      }
      canvas.drawPath(path, paint);
    }

    // C. Nós / Anéis de crescimento suaves de carvalho nos cantos
    _drawWoodKnot(canvas, Offset(w * 0.14, h * 0.22), radiusX: 52, radiusY: 14);
    _drawWoodKnot(canvas, Offset(w * 0.86, h * 0.78), radiusX: 62, radiusY: 16);

    // D. Bisel de relevo e espessura do tampo
    final topHighlight = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, 3))
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(4, 1), Offset(w - 4, 1), topHighlight);

    final bottomShadow = Paint()
      ..color = const Color(0xFF381502).withValues(alpha: 0.45)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(4, h - 1.2), Offset(w - 4, h - 1.2), bottomShadow);
  }

  void _drawWoodKnot(
    Canvas canvas,
    Offset center, {
    required double radiusX,
    required double radiusY,
  }) {
    for (int ring = 1; ring <= 4; ring++) {
      final rx = radiusX * (ring / 4.0);
      final ry = radiusY * (ring / 4.0);
      final knotPaint = Paint()
        ..color = (ring % 2 == 0)
            ? const Color(0xFF582405).withValues(alpha: 0.08)
            : const Color(0xFFFFD99E).withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
        knotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WorkbenchDeskPainter oldDelegate) {
    return oldDelegate.woodRadius != woodRadius ||
        oldDelegate.boardRadius != boardRadius ||
        oldDelegate.borderMargin != borderMargin;
  }
}

