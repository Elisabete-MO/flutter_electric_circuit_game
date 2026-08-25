import 'package:flutter/material.dart';
import 'package:eletrolab/app/theme.dart';

import '../models/first_step_component.dart';
import 'circuit_symbol_painter.dart';
import 'component_physical_painter.dart';

/// Cartão de componente elétrico inspirado no grid de 8 seções das imagens de referência 1 e 2.
/// Exibe o objeto físico real na metade superior e o símbolo esquemático na metade inferior.
class SymbolCard extends StatefulWidget {
  const SymbolCard({
    super.key,
    required this.component,
    required this.onTap,
    this.onToggleState,
    this.isSelected = false,
    this.showLabels = true,
    this.isCorrectlyAnswered = false,
  });

  final FirstStepComponent component;
  final VoidCallback onTap;
  final VoidCallback? onToggleState;
  final bool isSelected;
  final bool showLabels;
  final bool isCorrectlyAnswered;

  @override
  State<SymbolCard> createState() => _SymbolCardState();
}

class _SymbolCardState extends State<SymbolCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = widget.isCorrectlyAnswered
        ? (isDark ? const Color(0xFF00E676) : const Color(0xFF2E7D32))
        : widget.isSelected
            ? (isDark ? EletroLabColors.borderDarkColors[0] : EletroLabColors.borderLightColors[0])
            : _isHovered
                ? theme.colorScheme.primary
                : (isDark ? EletroLabColors.borderDarkColors[1] : EletroLabColors.borderLightColors[1]);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.diagonal3Values(_isHovered ? 1.025 : 1.0, _isHovered ? 1.025 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _isHovered ? 6 : (widget.isSelected ? 4 : 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: borderColor,
              width: widget.isSelected || widget.isCorrectlyAnswered
                  ? 2.5
                  : (_isHovered ? 1.8 : 1.2),
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PARTE SUPERIOR: Objeto físico real + Nome
                Expanded(
                  flex: 5,
                  child: Container(
                    color: isDark
                        ? const Color(0xFF1E2638)
                        : const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        if (widget.showLabels) ...[
                          Text(
                            widget.component.namePt,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.component.nameEn.isNotEmpty &&
                              widget.component.nameEn != widget.component.namePt)
                            Text(
                              widget.component.nameEn,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.75),
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                        ] else if (widget.isCorrectlyAnswered)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 4),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF00E676),
                              size: 22,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: Text(
                              '?',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        Expanded(
                          child: CustomPaint(
                            painter: ComponentPhysicalPainter(
                              type: widget.component.type,
                              isActive: widget.component.isActive,
                              isDarkMode: isDark,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // DIVISOR HORIZONTAL NÍTIDO (Estilo imagem 2 - linha vermelha/azul)
                Container(
                  height: 2,
                  color: widget.isCorrectlyAnswered
                      ? const Color(0xFF00E676)
                      : widget.isSelected
                          ? theme.colorScheme.primary
                          : (widget.component.isActive
                              ? const Color(0xFFFFB300)
                              : (isDark ? Colors.grey[700] : const Color(0xFFB0BEC5))),
                ),

                // PARTE INFERIOR: Símbolo Esquemático Elétrico
                Expanded(
                  flex: 4,
                  child: Container(
                    color: isDark
                        ? const Color(0xFF161C28)
                        : const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          painter: CircuitSymbolPainter(
                            type: widget.component.type,
                            isActive: widget.component.isActive,
                            color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black87,
                            activeColor: const Color(0xFFFFB300),
                            strokeWidth: 2.2,
                          ),
                          child: const SizedBox.expand(),
                        ),

                        // Botão interativo para alternar estado (ex: abrir/fechar chave, ligar LED)
                        if (widget.component.supportsStateToggle && widget.onToggleState != null)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: widget.onToggleState,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.component.isActive
                                        ? theme.colorScheme.primaryContainer
                                        : theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: widget.component.isActive
                                          ? theme.colorScheme.primary
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        widget.component.isActive
                                            ? Icons.power_rounded
                                            : Icons.power_off_rounded,
                                        size: 14,
                                        color: widget.component.isActive
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.component.isActive ? 'LIGADO' : 'DESLIGADO',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: widget.component.isActive
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
