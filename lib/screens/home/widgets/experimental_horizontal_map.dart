import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../models/stand_data.dart';
import 'stand_info_card.dart';
import 'stand_marker.dart';

/// Configuração personalizada de Scroll permitindo arraste com mouse, touch e trackpad.
class _HorizontalScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// Mapeamento de coordenadas (X, Y) fixas no canvas original de 4096 × 1152 px.
class StandPosition {
  final double x;
  final double y;
  const StandPosition(this.x, this.y);
}

/// Mapeamento preciso das posições dos 12 estandes no cenário expandido de 4096 × 1152 px.
const Map<int, StandPosition> _standCanvasPositions = {
  // Lado Esquerdo (0 a 2048 px)
  1: StandPosition(380, 270),   // Primeiros Passos (Tutorial) - Topo esquerdo
  2: StandPosition(380, 576),   // Acende Aí - Meio esquerdo
  3: StandPosition(380, 880),   // Liga e Desliga - Base esquerda
  4: StandPosition(1060, 360),  // Ruas da Maquete - Topo meio-esquerdo
  5: StandPosition(1060, 792),  // Letreros de LED - Base meio-esquerdo
  6: StandPosition(1620, 360),  // Movimento em Miniatura - Topo próximo à junção

  // Lado Direito (2048 a 4096 px)
  7: StandPosition(2476, 792),  // Mede, Testa e Explica - Base próximo à junção
  8: StandPosition(3040, 270),  // Circuito Seguro - Topo meio-direito
  9: StandPosition(3040, 576),  // Horta Monitorada - Meio meio-direito
  10: StandPosition(3040, 880), // Portão da Escola - Base meio-direito
  11: StandPosition(3580, 360), // Praça da Maquete Coletiva - Topo direito
  12: StandPosition(3780, 780), // Bancada Livre (3D Lab) - Final lado direito
};

/// Versão Experimental do Mapa da Feira de Ciências com Navegação Horizontal Contínua.
///
/// Utiliza 2 imagens de 2048 × 1152 px lado a lado formando 4096 × 1152 px.
class ExperimentalHorizontalMap extends StatefulWidget {
  final List<StandData> stands;
  final StandData? selectedStand;
  final ValueChanged<StandData> onSelectStand;
  final ValueChanged<StandData> onStartMission;
  final VoidCallback onCloseCard;
  final VoidCallback onTapMaqueteColetiva;

  const ExperimentalHorizontalMap({
    super.key,
    required this.stands,
    required this.selectedStand,
    required this.onSelectStand,
    required this.onStartMission,
    required this.onCloseCard,
    required this.onTapMaqueteColetiva,
  });

  @override
  State<ExperimentalHorizontalMap> createState() =>
      _ExperimentalHorizontalMapState();
}

class _ExperimentalHorizontalMapState
    extends State<ExperimentalHorizontalMap> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Posiciona a câmera na junção central ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final double maxScroll = _scrollController.position.maxScrollExtent;
        final double centerOffset = maxScroll / 2.0;
        _scrollController.jumpTo(centerOffset.clamp(0.0, maxScroll));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double mapW = constraints.maxWidth;
        final double mapH = constraints.maxHeight;

        // Dimensões do canvas panorâmico contínuo
        const double canvasW = 4096.0;
        const double canvasH = 1152.0;

        // Escala uniforme para preencher a altura da viewport
        final double scale = (mapH / canvasH).clamp(mapW / canvasW, 2.5);

        final double totalScaledWidth = canvasW * scale;
        final double totalScaledHeight = canvasH * scale;

        // Ordena os estandes por número para o trajeto
        final sortedStands = List<StandData>.from(widget.stands)
          ..sort((a, b) => a.number.compareTo(b.number));

        // Tamanhos dos elementos no canvas
        final double baseTableW = 320.0 * scale;
        final double bancadaLivreW = 410.0 * scale;
        final double logoSize = 380.0 * scale;

        return Stack(
          children: [
            // 1. ÁREA NAVEGÁVEL (Quadra com rolagem exclusivamente horizontal)
            ScrollConfiguration(
              behavior: _HorizontalScrollBehavior(),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: totalScaledWidth,
                  height: totalScaledHeight,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      // A. Imagem Esquerda (X: 0, Y: 0) - 2048 x 1152 px
                      Positioned(
                        left: 0,
                        top: 0,
                        width: 2048.0 * scale,
                        height: totalScaledHeight,
                        child: Image.asset(
                          'assets/stands/quadra_trilha_esquerda_4k.png',
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF042920),
                            child: const Center(
                              child: Text(
                                'Quadra Esquerda 4K',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // B. Imagem Direita (X: 2048, Y: 0) - 2048 x 1152 px
                      Positioned(
                        left: 2048.0 * scale,
                        top: 0,
                        width: 2048.0 * scale,
                        height: totalScaledHeight,
                        child: Image.asset(
                          'assets/stands/quadra_trilha_direita_4k.png',
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF021B15),
                            child: const Center(
                              child: Text(
                                'Quadra Direita 4K',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // C. Trajeto de Progressão Conectando as Fases (1 a 12)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: HorizontalProgressionPathPainter(
                              stands: sortedStands,
                              scale: scale,
                              positions: _standCanvasPositions,
                              centerLogoX: 2048.0 * scale,
                              centerLogoY: 576.0 * scale,
                              centerLogoRadius: logoSize / 2.0,
                            ),
                          ),
                        ),
                      ),

                      // D. Plataforma Central Instituto Alpha Lumen (X = 2048, Y = 576)
                      Positioned(
                        left: (2048.0 * scale) - (logoSize / 2.0),
                        top: (576.0 * scale) - (logoSize / 2.0),
                        child: GestureDetector(
                          onTap: widget.onTapMaqueteColetiva,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: _AlphaLumenCentralLogo(size: logoSize),
                          ),
                        ),
                      ),

                      // E. Marcadores dos Estandes (01 a 12)
                      ...widget.stands.map((stand) {
                        final pos = _standCanvasPositions[stand.number] ??
                            const StandPosition(2048, 576);

                        final double standW = stand.isBancadaLivre
                            ? bancadaLivreW
                            : baseTableW;

                        final double left = (pos.x * scale) - (standW / 2.0);
                        final double top = (pos.y * scale) - (standW * 0.33);

                        return Positioned(
                          left: left,
                          top: top,
                          child: StandMarker(
                            stand: stand,
                            isSelected: widget.selectedStand?.id == stand.id,
                            width: standW,
                            onTap: () => widget.onSelectStand(stand),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // 2. PAINEL DE DETALHES FIXO (Sobreposto à direita quando uma fase é selecionada)
            if (widget.selectedStand != null)
              Positioned(
                top: 16,
                right: 16,
                bottom: 16,
                child: Align(
                  alignment: Alignment.topRight,
                  child: SingleChildScrollView(
                    child: StandInfoCard(
                      stand: widget.selectedStand!,
                      onStartMission: () =>
                          widget.onStartMission(widget.selectedStand!),
                      onClose: widget.onCloseCard,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Logo/Plataforma Central do Instituto Alpha Lumen adaptada para o cenário panorâmico.
class _AlphaLumenCentralLogo extends StatelessWidget {
  final double size;

  const _AlphaLumenCentralLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.035),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFF0B634B),
              Color(0xFF04382B),
              Color(0xFF021B15),
            ],
            stops: [0.0, 0.70, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFF10B981),
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.40),
              blurRadius: 24,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.90,
              height: size * 0.90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF34D399).withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: size * 0.10,
                horizontal: size * 0.08,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: size * 0.34,
                    height: size * 0.34,
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  SizedBox(height: size * 0.04),
                  Text(
                    'INSTITUTO ALPHA LUMEN',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: (size * 0.070).clamp(9.0, 13.0),
                      letterSpacing: 0.6,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'EletroLab',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color(0xFF34D399),
                      fontWeight: FontWeight.w700,
                      fontSize: (size * 0.062).clamp(8.0, 11.0),
                      letterSpacing: 0.4,
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter que desenha a linha de conexões entre os 12 estandes na quadra panorâmica.
class HorizontalProgressionPathPainter extends CustomPainter {
  final List<StandData> stands;
  final double scale;
  final Map<int, StandPosition> positions;
  final double centerLogoX;
  final double centerLogoY;
  final double centerLogoRadius;

  HorizontalProgressionPathPainter({
    required this.stands,
    required this.scale,
    required this.positions,
    required this.centerLogoX,
    required this.centerLogoY,
    required this.centerLogoRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stands.length < 2) return;

    final center = Offset(centerLogoX, centerLogoY);

    // Recorta o caminho para não sobrepor o circulo do logo central
    canvas.save();
    final clipPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(
        Rect.fromCircle(center: center, radius: centerLogoRadius + 4),
      )
      ..fillType = PathFillType.evenOdd;
    canvas.clipPath(clipPath);

    final glowPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    final pathPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final firstPos = positions[stands.first.number] ?? const StandPosition(0, 0);
    path.moveTo(firstPos.x * scale, firstPos.y * scale);

    for (int i = 0; i < stands.length - 1; i++) {
      final pos1 = positions[stands[i].number] ?? const StandPosition(0, 0);
      final pos2 = positions[stands[i + 1].number] ?? const StandPosition(0, 0);

      final p1 = Offset(pos1.x * scale, pos1.y * scale);
      final p2 = Offset(pos2.x * scale, pos2.y * scale);

      final controlPoint1 = Offset((p1.dx + p2.dx) / 2, p1.dy);
      final controlPoint2 = Offset((p1.dx + p2.dx) / 2, p2.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, pathPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HorizontalProgressionPathPainter oldDelegate) {
    return oldDelegate.scale != scale;
  }
}
