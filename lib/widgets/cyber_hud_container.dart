import 'dart:ui';
import 'package:flutter/material.dart';

/// Um container com design de Moldura Cyber HUD (ficção científica)
/// inspirado em GUIs de jogos futuristas, com cantos chanfrados,
/// linhas neon brilhantes, grade de pontos interna e animação de hover.
class CyberHudContainer extends StatefulWidget {
  const CyberHudContainer({
    super.key,
    required this.child,
    this.accentColor = const Color(0xFF00E5FF),
    this.onTap,
    this.onHoverChanged,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.width,
    this.height,
  });

  final Widget child;
  final Color accentColor;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHoverChanged;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  @override
  State<CyberHudContainer> createState() => _CyberHudContainerState();
}

class _CyberHudContainerState extends State<CyberHudContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        _hoverController.forward();
        widget.onHoverChanged?.call(true);
      },
      onExit: (_) {
        _hoverController.reverse();
        widget.onHoverChanged?.call(false);
      },
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          final hoverVal = _glowAnimation.value;
          final scale = 1.0 + (0.02 * hoverVal); // Micro-escala no hover

          return Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            transform: Matrix4.diagonal3Values(scale, scale, 1.0),
            transformAlignment: Alignment.center,
            child: CustomPaint(
              painter: CyberHudPainter(
                accentColor: widget.accentColor,
                isDark: isDark,
                hoverValue: hoverVal,
              ),
              child: ClipPath(
                clipper: CyberHudClipper(),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    splashColor: widget.accentColor.withValues(alpha: 0.15),
                    highlightColor: widget.accentColor.withValues(alpha: 0.05),
                    child: Padding(
                      padding: widget.padding,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Clipper para recortar o conteúdo exatamente na forma chanfrada do Cyber HUD.
class CyberHudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return _getCyberPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Função utilitária para obter o Path da silhueta do Cyber HUD.
Path _getCyberPath(Size size) {
  final w = size.width;
  final h = size.height;
  final path = Path();

  // Dimensões dos chanfros
  const cTopLeft = 10.0;
  const cTopRight = 24.0;
  const cBottomLeft = 24.0;
  const cBottomRight = 10.0;

  // Início no canto superior esquerdo (após chanfro)
  path.moveTo(cTopLeft, 0);
  path.lineTo(w - cTopRight, 0); // Linha topo
  path.lineTo(w, cTopRight);     // Chanfro superior direito
  path.lineTo(w, h - cBottomRight); // Linha direita
  path.lineTo(w - cBottomRight, h); // Chanfro inferior direito
  path.lineTo(cBottomLeft, h);      // Linha base
  path.lineTo(0, h - cBottomLeft);  // Chanfro inferior esquerdo
  path.lineTo(0, cTopLeft);         // Linha esquerda
  path.close();

  return path;
}

/// CustomPainter para pintar o fundo, grade de pontos, bordas neon com glow e detalhes decorativos.
class CyberHudPainter extends CustomPainter {
  CyberHudPainter({
    required this.accentColor,
    required this.isDark,
    required this.hoverValue,
  });

  final Color accentColor;
  final bool isDark;
  final double hoverValue;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = _getCyberPath(size);

    // 1. Pintar Fundo Glassmorphic do Cartão
    final bgColor = isDark 
        ? const Color(0xFF1B0E3C).withValues(alpha: 0.75 + (0.15 * hoverValue))
        : Colors.white.withValues(alpha: 0.85 + (0.10 * hoverValue));

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    // 2. Pintar Grade Tecnológica de Pontos Internos (Micro-grid)
    final gridColor = accentColor.withValues(alpha: isDark ? 0.03 + (0.05 * hoverValue) : 0.02 + (0.03 * hoverValue));
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const spacing = 14.0;
    for (double x = spacing; x < w; x += spacing) {
      for (double y = spacing; y < h; y += spacing) {
        // Apenas desenha se o ponto estiver contido na forma geométrica recortada
        if (path.contains(Offset(x, y))) {
          canvas.drawPoints(PointMode.points, [Offset(x, y)], gridPaint);
        }
      }
    }

    // 3. Pintar Sombra de Brilho Neon (Glow) sob a borda
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.15 + (0.20 * hoverValue))
      ..strokeWidth = 2.0 + (2.0 * hoverValue)
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0 + (3.0 * hoverValue));
    canvas.drawPath(path, glowPaint);

    // 4. Borda Principal
    final borderPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.4 + (0.5 * hoverValue))
      ..strokeWidth = 1.2 + (0.6 * hoverValue)
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // 5. Adicionar Linhas Decorativas de Alta Tecnologia (Tech Brackets / Accent Lines)
    // Linha paralela decorativa no chanfro superior direito
    final techPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6 + (0.4 * hoverValue))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Detalhe: Suporte superior direito (canto chanfrado de 24px)
    final capPath = Path();
    capPath.moveTo(w - 32, 3);
    capPath.lineTo(w - 3, 32);
    canvas.drawPath(capPath, techPaint);

    // Detalhe: Canto inferior esquerdo (canto chanfrado de 24px)
    final baseDetailPath = Path();
    baseDetailPath.moveTo(3, h - 32);
    baseDetailPath.lineTo(32, h - 3);
    canvas.drawPath(baseDetailPath, techPaint);

    // Detalhe: Pequena aba técnica no topo esquerdo
    final tabPath = Path();
    tabPath.moveTo(25, 0);
    tabPath.lineTo(45, 0);
    tabPath.lineTo(49, 4);
    tabPath.lineTo(29, 4);
    tabPath.close();
    
    final tabPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3 + (0.5 * hoverValue))
      ..style = PaintingStyle.fill;
    canvas.drawPath(tabPath, tabPaint);

    // Desenhar mini-pontos técnicos nos cantos opostos
    final dotPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.5 + (0.5 * hoverValue))
      ..style = PaintingStyle.fill;

    // Dots no topo esquerdo e rodapé direito
    canvas.drawCircle(Offset(8, 25), 1.5, dotPaint);
    canvas.drawCircle(Offset(12, 25), 1.5, dotPaint);
    canvas.drawCircle(Offset(w - 8, h - 25), 1.5, dotPaint);
    canvas.drawCircle(Offset(w - 12, h - 25), 1.5, dotPaint);

    // Marcadores angulares extras (Tech corners)
    final cornerBracket = Paint()
      ..color = accentColor.withValues(alpha: 0.7 + (0.3 * hoverValue))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Canto Superior Esquerdo Bracket L-shape
    final cornerPath1 = Path();
    cornerPath1.moveTo(0, 22);
    cornerPath1.lineTo(0, 10);
    cornerPath1.lineTo(10, 0);
    cornerPath1.lineTo(22, 0);
    canvas.drawPath(cornerPath1, cornerBracket);

    // Canto Inferior Direito Bracket L-shape
    final cornerPath2 = Path();
    cornerPath2.moveTo(w - 22, h);
    cornerPath2.lineTo(w - 10, h);
    cornerPath2.lineTo(w, h - 10);
    cornerPath2.lineTo(w, h - 22);
    canvas.drawPath(cornerPath2, cornerBracket);
  }

  @override
  bool shouldRepaint(covariant CyberHudPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hoverValue != hoverValue;
  }
}
