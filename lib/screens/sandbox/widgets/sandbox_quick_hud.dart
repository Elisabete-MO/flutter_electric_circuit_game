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

class SandboxMultiSelectionHudWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onRotate;
  final VoidCallback onDelete;
  final VoidCallback onDeselect;
  final bool isDark;

  const SandboxMultiSelectionHudWidget({
    super.key,
    required this.selectedCount,
    required this.onRotate,
    required this.onDelete,
    required this.onDeselect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? const Color(0xFF00F5D4) : const Color(0xFF00875A);
    final bgColor = isDark
        ? const Color(0xFF141E33).withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.select_all_rounded, size: 14, color: borderColor),
                  const SizedBox(width: 4),
                  Text(
                    '$selectedCount selecionados',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: onRotate,
              tooltip: 'Rotacionar Todos (R)',
              icon: Icon(Icons.rotate_right_rounded, size: 16, color: borderColor),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: onDelete,
              tooltip: 'Excluir Todos (Delete/Backspace)',
              icon: const Icon(Icons.delete_forever_rounded, size: 16, color: Color(0xFFFF3B7F)),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: onDeselect,
              tooltip: 'Desmarcar (Esc)',
              icon: Icon(Icons.close_rounded, size: 16, color: isDark ? Colors.white54 : Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

class SandboxWireHudWidget extends StatelessWidget {
  final Offset position;
  final VoidCallback onDelete;
  final bool isDark;

  const SandboxWireHudWidget({
    super.key,
    required this.position,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (position.dx - 45).clamp(0.0, double.infinity),
      top: (position.dy - 38).clamp(0.0, double.infinity),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141E33).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFF3B7F), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3B7F).withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cable_rounded, size: 13, color: Color(0xFF00F5D4)),
              const SizedBox(width: 4),
              Text(
                'Fio',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                icon: const Icon(Icons.delete_forever_rounded, size: 15, color: Color(0xFFFF3B7F)),
                tooltip: 'Remover Fio (Delete/Backspace)',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

