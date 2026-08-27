import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/first_step_component.dart';
import '../../../models/sandbox_component.dart';

class SandboxQuickHudWidget extends StatelessWidget {
  final SandboxComponent selectedComponent;
  final double cellSize;
  final double width;
  final bool isDark;
  final VoidCallback onRotate;
  final VoidCallback? onToggleActive;
  final VoidCallback onDelete;

  const SandboxQuickHudWidget({
    super.key,
    required this.selectedComponent,
    required this.cellSize,
    required this.width,
    required this.isDark,
    required this.onRotate,
    this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (selectedComponent.gridX * cellSize).clamp(0.0, math.max(0.0, width - 140)),
      top: math.max(0.0, (selectedComponent.gridY * cellSize) - 36),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141E33).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00F5D4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5D4).withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                icon: const Icon(Icons.rotate_right_rounded, size: 15, color: Color(0xFF00F5D4)),
                tooltip: 'Rotacionar (R)',
                onPressed: onRotate,
              ),
              if (selectedComponent.type == ComponentType.switchComponent && onToggleActive != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  icon: Icon(
                    selectedComponent.isActive ? Icons.power_rounded : Icons.power_off_rounded,
                    size: 15,
                    color: selectedComponent.isActive ? const Color(0xFF00FF9D) : Colors.grey,
                  ),
                  tooltip: 'Alternar Interruptor (Espaço)',
                  onPressed: onToggleActive,
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                icon: const Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFFF3B7F)),
                tooltip: 'Excluir (Del)',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
