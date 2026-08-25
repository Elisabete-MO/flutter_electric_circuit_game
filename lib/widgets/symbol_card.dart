import 'package:flutter/material.dart';
import 'package:eletrolab/app/theme.dart';

import '../models/first_step_component.dart';
import 'circuit_symbol_painter.dart';
import 'component_physical_painter.dart';

/// Cartão de componente elétrico inspirado no grid de 8 seções das imagens de referência 1 e 2.
/// Exibe o objeto físico real na metade superior e o símbolo esquemático na metade inferior.
class SymbolCard extends StatelessWidget {
  const SymbolCard({
    super.key,
    required this.component,
    required this.onTap,
    this.onToggleState,
    this.isSelected = false,
    this.showLabels = true,
  });

  final FirstStepComponent component;
  final VoidCallback onTap;
  final VoidCallback? onToggleState;
  final bool isSelected;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isSelected
        ? (isDark ? EletroLabColors.borderDarkColors[0] : EletroLabColors.borderLightColors[0])
        : (isDark ? EletroLabColors.borderDarkColors[1] : EletroLabColors.borderLightColors[1]);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isSelected ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor,
          width: isSelected ? 2.5 : 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
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
                    if (showLabels) ...[
                      Text(
                        component.namePt,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (component.nameEn.isNotEmpty &&
                          component.nameEn != component.namePt)
                        Text(
                          component.nameEn,
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
                    ] else
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
                          type: component.type,
                          isActive: component.isActive,
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
              color: isSelected
                  ? theme.colorScheme.primary
                  : (component.isActive
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
                        type: component.type,
                        isActive: component.isActive,
                        color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black87,
                        activeColor: const Color(0xFFFFB300),
                        strokeWidth: 2.2,
                      ),
                      child: const SizedBox.expand(),
                    ),

                    // Botão interativo para alternar estado (ex: abrir/fechar chave, ligar LED)
                    if (component.supportsStateToggle && onToggleState != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: onToggleState,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: component.isActive
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: component.isActive
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    component.isActive
                                        ? Icons.power_rounded
                                        : Icons.power_off_rounded,
                                    size: 14,
                                    color: component.isActive
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    component.isActive ? 'LIGADO' : 'DESLIGADO',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: component.isActive
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
    );
  }
}
