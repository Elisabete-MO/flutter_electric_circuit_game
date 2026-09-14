import 'package:flutter/material.dart';

/// Widget reutilizável para itens arrastáveis no EletroLab.
///
/// Garante que o card arrastado acompanhe o cursor/dedo perfeitamente,
/// usando [pointerDragAnchorStrategy], [rootOverlay: true] e espelhando
/// as dimensões exatas do card de origem no feedback.
class DraggableCard<T extends Object> extends StatelessWidget {
  final T data;
  final Widget child;
  final Widget? feedbackChild;
  final bool enabled;
  final double minTouchTargetSize;
  final double draggingOpacity;

  const DraggableCard({
    super.key,
    required this.data,
    required this.child,
    this.feedbackChild,
    this.enabled = true,
    this.minTouchTargetSize = 44.0,
    this.draggingOpacity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : null;
        final cardHeight =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : null;

        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minTouchTargetSize,
            minHeight: minTouchTargetSize,
          ),
          child: Draggable<T>(
            data: data,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            rootOverlay: true,
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: feedbackChild ?? child,
              ),
            ),
            childWhenDragging: Opacity(opacity: draggingOpacity, child: child),
            child: child,
          ),
        );
      },
    );
  }
}
