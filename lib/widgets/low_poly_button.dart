import 'package:flutter/material.dart';
import '../core/ui_scale.dart';

/// Variantes de cores temáticas para o [LowPolyButton].
enum LowPolyButtonVariant {
  /// Verde esmeralda vibrante (ação principal / sucesso).
  primary,

  /// Âmbar / Dourado energético (tutoriais e destaques).
  accent,

  /// Ciano neônio futurista (bancada livre, 3D lab, tecnologia).
  cyan,

  /// Tom escuro fosco com borda sutil (ações secundárias / fechar).
  dark,
}

/// Botão estilizado no padrão visual **Low-Poly 3D**, apresentando cantos
/// chanfrados angulares (*beveled edges*), extrusão sólida em relevo 3D
/// e efeito mecânico tátil de compressão (*push-down*) ao ser clicado ou tocado.
class LowPolyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LowPolyButtonVariant variant;
  final double? width;
  final double height;
  final double bevelRadius;
  final double depth;
  final double fontSize;
  final bool isFullWidth;

  const LowPolyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = LowPolyButtonVariant.primary,
    this.width,
    this.height = 48.0,
    this.bevelRadius = 8.0,
    this.depth = 4.0,
    this.fontSize = 15.0,
    this.isFullWidth = false,
  });

  @override
  State<LowPolyButton> createState() => _LowPolyButtonState();
}

class _LowPolyButtonState extends State<LowPolyButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final isEnabled = widget.onPressed != null;

    final double effectiveHeight = scale.size(widget.height, min: 40.0, max: 64.0);
    final double effectiveDepth = scale.size(widget.depth, min: 3.0, max: 6.0);
    final double effectiveBevel = scale.size(widget.bevelRadius, min: 6.0, max: 12.0);
    final double effectiveFontSize = scale.font(widget.fontSize, min: 13.0, max: 20.0);

    // Cores por variante
    late final Color topFaceColor;
    late final Color bottomBaseColor;
    late final Color borderColor;
    late final Color textColor;

    switch (widget.variant) {
      case LowPolyButtonVariant.primary:
        topFaceColor = isEnabled
            ? (_isHovered ? const Color(0xFF15D898) : const Color(0xFF10B981))
            : const Color(0xFF1E3A32);
        bottomBaseColor = isEnabled ? const Color(0xFF065F46) : const Color(0xFF0E221D);
        borderColor = isEnabled ? const Color(0xFF34D399) : const Color(0xFF2D5A4E);
        textColor = isEnabled ? const Color(0xFF021B14) : Colors.white38;
        break;

      case LowPolyButtonVariant.accent:
        topFaceColor = isEnabled
            ? (_isHovered ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B))
            : const Color(0xFF3A301E);
        bottomBaseColor = isEnabled ? const Color(0xFFB45309) : const Color(0xFF221C0E);
        borderColor = isEnabled ? const Color(0xFFFDE68A) : const Color(0xFF5A492D);
        textColor = isEnabled ? const Color(0xFF1F1202) : Colors.white38;
        break;

      case LowPolyButtonVariant.cyan:
        topFaceColor = isEnabled
            ? (_isHovered ? const Color(0xFF38BDF8) : const Color(0xFF00E5FF))
            : const Color(0xFF1E333A);
        bottomBaseColor = isEnabled ? const Color(0xFF0284C7) : const Color(0xFF0E1F24);
        borderColor = isEnabled ? const Color(0xFFBAE6FD) : const Color(0xFF2D4E5A);
        textColor = isEnabled ? const Color(0xFF021921) : Colors.white38;
        break;

      case LowPolyButtonVariant.dark:
        topFaceColor = isEnabled
            ? (_isHovered ? const Color(0xFF133E32) : const Color(0xFF082B22))
            : const Color(0xFF0F1715);
        bottomBaseColor = isEnabled ? const Color(0xFF021612) : const Color(0xFF070B0A);
        borderColor = isEnabled ? const Color(0xFF10B981).withValues(alpha: 0.5) : Colors.white12;
        textColor = isEnabled ? Colors.white : Colors.white38;
        break;
    }

    final double currentOffset = (_isPressed && isEnabled) ? effectiveDepth : 0.0;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isEnabled && mounted) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (mounted) {
          setState(() {
            _isHovered = false;
            _isPressed = false;
          });
        }
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (isEnabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (isEnabled) {
            setState(() => _isPressed = false);
            widget.onPressed?.call();
          }
        },
        onTapCancel: () {
          if (mounted) setState(() => _isPressed = false);
        },
        child: SizedBox(
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: effectiveHeight + effectiveDepth,
          child: Stack(
            children: [
              // 1. Base Inferior 3D Fixa (extrusão sólida)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: effectiveHeight,
                child: Material(
                  color: bottomBaseColor,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(effectiveBevel),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),

              // 2. Face Superior Dinâmica (translada no clique simulando botão mecânico)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 60),
                curve: Curves.easeOutQuad,
                left: 0,
                right: 0,
                top: currentOffset,
                height: effectiveHeight,
                child: Material(
                  color: topFaceColor,
                  elevation: _isPressed ? 0 : 2,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(effectiveBevel),
                    side: BorderSide(
                      color: borderColor,
                      width: scale.size(1.4, min: 1.0, max: 2.0),
                    ),
                  ),
                  child: InkWell(
                    splashColor: Colors.white24,
                    highlightColor: Colors.transparent,
                    customBorder: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(effectiveBevel),
                    ),
                    onTap: widget.onPressed,
                    child: Center(
                      child: Padding(
                        padding: scale.insetsSymmetric(horizontal: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: scale.icon(effectiveFontSize * 1.2),
                                color: textColor,
                              ),
                              SizedBox(width: scale.spacing(8)),
                            ],
                            Text(
                              widget.label,
                              style: TextStyle(
                                color: textColor,
                                fontSize: effectiveFontSize,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
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
      ),
    );
  }
}
