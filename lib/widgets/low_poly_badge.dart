import 'package:flutter/material.dart';
import '../core/ui_scale.dart';

/// Variantes de estilo para [LowPolyBadge].
enum LowPolyBadgeVariant {
  /// Âmbar / Dourado (Tutorial / Destaque)
  amber,

  /// Ciano vibrante (3D Lab / Especial)
  cyan,

  /// Verde esmeralda (Concluído / Normal)
  emerald,

  /// Escuro fosco (Neutro / ID)
  dark,
}

/// Tag / Badge facetada com cantos chanfrados no estilo visual Low-Poly.
class LowPolyBadge extends StatelessWidget {
  final String label;
  final LowPolyBadgeVariant variant;
  final double fontSize;
  final double bevelRadius;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;

  const LowPolyBadge({
    super.key,
    required this.label,
    this.variant = LowPolyBadgeVariant.dark,
    this.fontSize = 11.0,
    this.bevelRadius = 4.0,
    this.padding,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final double effectiveBevel = scale.size(bevelRadius, min: 3.0, max: 8.0);
    final double effectiveFontSize = scale.font(fontSize, min: 9.0, max: 16.0);

    late final Color bgColor;
    late final Color borderColor;
    late final Color textColor;

    switch (variant) {
      case LowPolyBadgeVariant.amber:
        bgColor = const Color(0xFFB45309);
        borderColor = const Color(0xFFFDE68A);
        textColor = Colors.white;
        break;
      case LowPolyBadgeVariant.cyan:
        bgColor = const Color(0xFF0369A1);
        borderColor = const Color(0xFF7DD3FC);
        textColor = Colors.white;
        break;
      case LowPolyBadgeVariant.emerald:
        bgColor = const Color(0xFF047857);
        borderColor = const Color(0xFF6EE7B7);
        textColor = Colors.white;
        break;
      case LowPolyBadgeVariant.dark:
        bgColor = const Color(0xFF021B14).withValues(alpha: 0.92);
        borderColor = const Color(0xFF10B981).withValues(alpha: 0.85);
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: padding ??
          scale.insetsSymmetric(
            horizontal: 8,
            vertical: 4,
          ),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBevel),
          side: BorderSide(
            color: borderColor,
            width: scale.size(1.0, min: 0.8, max: 1.5),
          ),
        ),
        shadows: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: scale.icon(effectiveFontSize * 1.1),
              color: textColor,
            ),
            SizedBox(width: scale.spacing(4)),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: effectiveFontSize,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
