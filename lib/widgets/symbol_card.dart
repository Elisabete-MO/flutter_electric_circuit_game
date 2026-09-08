import 'package:flutter/material.dart';
import 'package:eletrolab/app/theme.dart';

import '../core/ui_scale.dart';
import '../models/first_step_component.dart';
import 'circuit_symbol_painter.dart';
import 'component_physical_painter.dart';

/// Cartão de componente elétrico inspirado no grid de 8 seções das imagens de referência 1 e 2.
/// Exibe o objeto físico real na metade superior e o símbolo esquemático na metade inferior.
class SymbolCard extends StatefulWidget {
  const SymbolCard({
    super.key,
    required this.component,
    this.onTap,
    this.onToggleState,
    this.isSelected = false,
    this.showLabels = true,
    this.isCorrectlyAnswered = false,
    this.useRealisticAssets = false,
  });

  final FirstStepComponent component;
  final VoidCallback? onTap;
  final VoidCallback? onToggleState;
  final bool isSelected;
  final bool showLabels;
  final bool isCorrectlyAnswered;
  final bool useRealisticAssets;

  @override
  State<SymbolCard> createState() => _SymbolCardState();
}

class _SymbolCardState extends State<SymbolCard> {
  bool _isHovered = false;

  double _getComponentScale(ComponentType type) {
    switch (type) {
      case ComponentType.resistor:
        return 1.65;
      case ComponentType.diode:
        return 1.55;
      case ComponentType.motor:
        return 1.35;
      case ComponentType.connectingWire:
        return 1.15;
      case ComponentType.led:
        return 1.05;
      case ComponentType.bulb:
        return 1.00; // 1.00 para não sobrepor o texto do nome da lâmpada
      case ComponentType.switchComponent:
        return 1.15;
      case ComponentType.battery:
        return 1.05;
      default:
        return 1.10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scale = context.uiScale;

    final borderColor = widget.isCorrectlyAnswered
        ? (isDark ? const Color(0xFF00E676) : const Color(0xFF2E7D32))
        : widget.isSelected
            ? (isDark ? EletroLabColors.borderDarkColors[0] : EletroLabColors.borderLightColors[0])
            : _isHovered
                ? theme.colorScheme.primary
                : (isDark ? EletroLabColors.borderDarkColors[1] : EletroLabColors.borderLightColors[1]);

    final activeGlowColor = widget.component.type == ComponentType.bulb
        ? const Color(0xFFFFB300)
        : (widget.component.type == ComponentType.led
            ? const Color(0xFF00E676)
            : theme.colorScheme.primary);

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
            borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
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
                // PARTE SUPERIOR: Objeto físico real + Nome (Flex maior para dar destaque aos objetos 3D)
                Expanded(
                  flex: 70,
                  child: Container(
                    color: isDark
                        ? const Color(0xFF1E2638)
                        : const Color(0xFFF8FAFC),
                    padding: EdgeInsets.symmetric(
                      horizontal: scale.spacing(8, min: 6, max: 14),
                      vertical: scale.spacing(6, min: 4, max: 10),
                    ),
                    child: Column(
                      children: [
                        if (widget.showLabels) ...[
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.component.namePt,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: scale.font(16, min: 13, max: 24),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(height: scale.spacing(4, min: 2, max: 8)),
                        ] else if (widget.isCorrectlyAnswered)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: const Color(0xFF00E676),
                                  size: scale.icon(16, min: 13, max: 24),
                                ),
                                SizedBox(width: scale.spacing(4, min: 2, max: 8)),
                                Text(
                                  widget.component.namePt,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: scale.font(16, min: 13, max: 24),
                                    color: const Color(0xFF00E676),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 2),
                            child: Text(
                              '?',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: scale.font(16, min: 13, max: 24),
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Center(
                            child: widget.useRealisticAssets &&
                                    widget.component.type.getAssetPath(widget.component.isActive) != null
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Sombra de pedestal 3D sob o objeto realista
                                      Positioned(
                                        bottom: 4,
                                        child: Container(
                                          width: scale.size(80, min: 60, max: 130),
                                          height: scale.size(14, min: 10, max: 22),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            boxShadow: [
                                              BoxShadow(
                                                color: widget.component.isActive
                                                    ? activeGlowColor.withValues(alpha: 0.45)
                                                    : Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                                                blurRadius: widget.component.isActive ? 16 : 8,
                                                spreadRadius: widget.component.isActive ? 4 : 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Imagem com Escala Personalizada Inteligente
                                      Transform.scale(
                                        scale: _getComponentScale(widget.component.type),
                                        child: Image.asset(
                                          widget.component.type.getAssetPath(widget.component.isActive)!,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) => CustomPaint(
                                            painter: ComponentPhysicalPainter(
                                              type: widget.component.type,
                                              isActive: widget.component.isActive,
                                              isDarkMode: isDark,
                                            ),
                                            child: const SizedBox.expand(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : CustomPaint(
                                    painter: ComponentPhysicalPainter(
                                      type: widget.component.type,
                                      isActive: widget.component.isActive,
                                      isDarkMode: isDark,
                                    ),
                                    child: const SizedBox.expand(),
                                  ),
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
                  flex: 30,
                  child: Container(
                    color: isDark
                        ? const Color(0xFF161C28)
                        : const Color(0xFFFFFFFF),
                    padding: EdgeInsets.symmetric(
                      horizontal: scale.spacing(14, min: 10, max: 22),
                      vertical: scale.spacing(4, min: 2, max: 8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          painter: CircuitSymbolPainter(
                            type: widget.component.type,
                            isActive: widget.component.isActive,
                            color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black87,
                            activeColor: const Color(0xFFFFB300),
                            strokeWidth: scale.size(2.2, min: 1.6, max: 3.5),
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
                                borderRadius: BorderRadius.circular(scale.size(12, min: 8, max: 18)),
                                onTap: widget.onToggleState,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: scale.spacing(8, min: 6, max: 14),
                                    vertical: scale.spacing(4, min: 2, max: 8),
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.component.isActive
                                        ? theme.colorScheme.primaryContainer
                                        : theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(scale.size(12, min: 8, max: 18)),
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
                                        size: scale.icon(14, min: 11, max: 20),
                                        color: widget.component.isActive
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                      SizedBox(width: scale.spacing(4, min: 2, max: 8)),
                                      Text(
                                        widget.component.isActive ? 'LIGADO' : 'DESLIGADO',
                                        style: TextStyle(
                                          fontSize: scale.font(9, min: 8, max: 14),
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

