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
  late final AnimationController _hoverController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _glowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeOutCubic,
      ),
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
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
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
          final hoverValue = _glowAnimation.value;
          final scale = 1 + (0.02 * hoverValue);

          return Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            transform: Matrix4.diagonal3Values(scale, scale, 1),
            transformAlignment: Alignment.center,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: CyberHudPainter(
                  accentColor: widget.accentColor,
                  isDark: isDark,
                  hoverValue: hoverValue,
                ),
                child: ClipPath(
                  clipper: CyberHudClipper(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      splashColor:
                          widget.accentColor.withValues(alpha: 0.15),
                      highlightColor:
                          widget.accentColor.withValues(alpha: 0.05),
                      child: Padding(
                        padding: widget.padding,
                        child: widget.child,
                      ),
                    ),
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
  bool shouldReclip(covariant CyberHudClipper oldClipper) => false;
}

/// Função utilitária para obter o Path da silhueta do Cyber HUD.
Path _getCyberPath(Size size) {
  final width = size.width;
  final height = size.height;
  final path = Path();

  const topLeftChamfer = 10.0;
  const topRightChamfer = 24.0;
  const bottomLeftChamfer = 24.0;
  const bottomRightChamfer = 10.0;

  path.moveTo(topLeftChamfer, 0);
  path.lineTo(width - topRightChamfer, 0);
  path.lineTo(width, topRightChamfer);
  path.lineTo(width, height - bottomRightChamfer);
  path.lineTo(width - bottomRightChamfer, height);
  path.lineTo(bottomLeftChamfer, height);
  path.lineTo(0, height - bottomLeftChamfer);
  path.lineTo(0, topLeftChamfer);
  path.close();

  return path;
}

/// CustomPainter para pintar o fundo, grade de pontos, bordas neon
/// com glow e detalhes decorativos.
class CyberHudPainter extends CustomPainter {
  const CyberHudPainter({
    required this.accentColor,
    required this.isDark,
    required this.hoverValue,
  });

  final Color accentColor;
  final bool isDark;
  final double hoverValue;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final path = _getCyberPath(size);

    // Fundo do cartão. A opacidade maior substitui o BackdropFilter,
    // oferecendo melhor desempenho no mobile.
    final backgroundColor = isDark
        ? const Color(0xFF1B0E3C).withValues(
            alpha: 0.65 + (0.15 * hoverValue),
          )
        : Colors.white.withValues(
            alpha: 0.70 + (0.10 * hoverValue),
          );

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.3 : 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    // Offset the shadow slightly down
    canvas.save();
    canvas.translate(0, 4);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    canvas.drawPath(path, backgroundPaint);

    // Grade tecnológica de pontos.
    final gridColor = accentColor.withValues(
      alpha: isDark
          ? 0.03 + (0.05 * hoverValue)
          : 0.02 + (0.03 * hoverValue),
    );

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const spacing = 14.0;

    for (double x = spacing; x < width; x += spacing) {
      for (double y = spacing; y < height; y += spacing) {
        final point = Offset(x, y);

        if (path.contains(point)) {
          canvas.drawPoints(
            PointMode.points,
            [point],
            gridPaint,
          );
        }
      }
    }
    if (isDark) {
      // Brilho neon difuso (espalhado)
      final glowPaintDiffuse = Paint()
        ..color = accentColor.withValues(
          alpha: 0.2 + (0.25 * hoverValue),
        )
        ..strokeWidth = 6.0 + (4.0 * hoverValue)
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          12.0 + (6.0 * hoverValue),
        );
      canvas.drawPath(path, glowPaintDiffuse);

      // Brilho neon intenso (próximo à linha)
      final glowPaintIntense = Paint()
        ..color = accentColor.withValues(
          alpha: 0.45 + (0.35 * hoverValue),
        )
        ..strokeWidth = 3.0 + (2.0 * hoverValue)
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          6.0 + (4.0 * hoverValue),
        );
      canvas.drawPath(path, glowPaintIntense);
    }

    // Borda principal.
    final borderPaint = Paint()
      ..color = accentColor.withValues(
        alpha: 0.7 + (0.3 * hoverValue),
      )
      ..strokeWidth = 3.0 + (1.0 * hoverValue)
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, borderPaint);

    // Linhas decorativas.
    final techPaint = Paint()
      ..color = accentColor.withValues(
        alpha: 0.6 + (0.4 * hoverValue),
      )
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final topRightDetailPath = Path()
      ..moveTo(width - 32, 3)
      ..lineTo(width - 3, 32);

    canvas.drawPath(topRightDetailPath, techPaint);

    final bottomLeftDetailPath = Path()
      ..moveTo(3, height - 32)
      ..lineTo(32, height - 3);

    canvas.drawPath(bottomLeftDetailPath, techPaint);

    // Pequena aba técnica no topo esquerdo.
    final tabPath = Path()
      ..moveTo(25, 0)
      ..lineTo(45, 0)
      ..lineTo(49, 4)
      ..lineTo(29, 4)
      ..close();

    final tabPaint = Paint()
      ..color = accentColor.withValues(
        alpha: 0.3 + (0.5 * hoverValue),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(tabPath, tabPaint);

    // Mini pontos técnicos.
    final dotPaint = Paint()
      ..color = accentColor.withValues(
        alpha: 0.5 + (0.5 * hoverValue),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(8, 25), 1.5, dotPaint);
    canvas.drawCircle(const Offset(12, 25), 1.5, dotPaint);
    canvas.drawCircle(Offset(width - 8, height - 25), 1.5, dotPaint);
    canvas.drawCircle(Offset(width - 12, height - 25), 1.5, dotPaint);

    // Marcadores angulares.
    final cornerBracketPaint = Paint()
      ..color = accentColor.withValues(
        alpha: 0.7 + (0.3 * hoverValue),
      )
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final topLeftCornerPath = Path()
      ..moveTo(0, 22)
      ..lineTo(0, 10)
      ..lineTo(10, 0)
      ..lineTo(22, 0);

    canvas.drawPath(topLeftCornerPath, cornerBracketPaint);

    final bottomRightCornerPath = Path()
      ..moveTo(width - 22, height)
      ..lineTo(width - 10, height)
      ..lineTo(width, height - 10)
      ..lineTo(width, height - 22);

    canvas.drawPath(bottomRightCornerPath, cornerBracketPaint);
  }

  @override
  bool shouldRepaint(covariant CyberHudPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hoverValue != hoverValue;
  }
}