import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui_scale.dart';
import '../../../models/first_step_component.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';

/// Widget dedicado para exibição das imagens realistas de assets/components/
class FirstStepPhysicalView extends StatelessWidget {
  final ComponentType type;
  final bool isActive;
  final double size;

  const FirstStepPhysicalView({
    super.key,
    required this.type,
    this.isActive = false,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = type.getAssetPath(isActive);
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return CustomPaint(
            size: Size(size, size),
            painter: ComponentPhysicalPainter(
              type: type,
              isActive: isActive,
              isDarkMode: false,
            ),
          );
        },
      );
    }

    return CustomPaint(
      size: Size(size, size),
      painter: ComponentPhysicalPainter(
        type: type,
        isActive: isActive,
        isDarkMode: false,
      ),
    );
  }
}

/// Card de cabeçalho da bancada com contadores e status de exploração.
class FirstStepsStatusCard extends StatelessWidget {
  final int totalCount;
  final int inspectedCount;
  final String title;

  const FirstStepsStatusCard({
    super.key,
    required this.totalCount,
    required this.inspectedCount,
    this.title = 'Vitrine de Componentes',
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final isComplete = inspectedCount >= totalCount && totalCount > 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(12, min: 8, max: 20),
        vertical: scale.spacing(6, min: 4, max: 12),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(scale.size(10, min: 6, max: 16)),
        border: Border.all(
          color: isComplete ? const Color(0xFF10B981) : const Color(0xFF0284C7),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle_rounded : Icons.explore_rounded,
            color: isComplete ? const Color(0xFF10B981) : const Color(0xFF00E5FF),
            size: scale.icon(16, min: 14, max: 22),
          ),
          SizedBox(width: scale.spacing(6, min: 4, max: 10)),
          Flexible(
            child: Text(
              '$inspectedCount / $totalCount explorados',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontSize: scale.font(12, min: 10.5, max: 16),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de exibição de um componente na bancada (modo Físico ou Esquemático).
class FirstStepsComponentTile extends StatelessWidget {
  final FirstStepComponent component;
  final bool isSelected;
  final bool usePhysicalStyle;
  final VoidCallback onTap;
  final VoidCallback? onToggleActive;
  final bool hideLabel;
  final String? badgeText;

  const FirstStepsComponentTile({
    super.key,
    required this.component,
    required this.isSelected,
    required this.usePhysicalStyle,
    required this.onTap,
    this.onToggleActive,
    this.hideLabel = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    final bgColor = isSelected
        ? (usePhysicalStyle
            ? const Color(0xFFE0F2FE)
            : const Color(0xFF0C4A6E).withValues(alpha: 0.85))
        : (usePhysicalStyle
            ? Colors.white.withValues(alpha: 0.96)
            : const Color(0xFF1E293B).withValues(alpha: 0.92));

    final borderColor = isSelected
        ? const Color(0xFF0284C7)
        : (usePhysicalStyle
            ? const Color(0xFFCBD5E1)
            : const Color(0xFF334155));

    final textColor = usePhysicalStyle
        ? const Color(0xFF0F172A)
        : Colors.white;

    final paintSize = scale.size(76, min: 54, max: 110);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(scale.spacing(10, min: 6, max: 16)),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : borderColor,
            width: isSelected ? 2.4 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.45),
                    blurRadius: scale.size(12, min: 8, max: 20),
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: scale.size(6, min: 3, max: 10),
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Área de renderização visual (assets/components ou símbolo esquemático)
            Expanded(
              child: Center(
                child: usePhysicalStyle
                    ? FirstStepPhysicalView(
                        type: component.type,
                        isActive: component.isActive,
                        size: paintSize,
                      )
                    : CustomPaint(
                        size: Size(paintSize, paintSize),
                        painter: CircuitSymbolPainter(
                          type: component.type,
                          isActive: component.isActive,
                          color: usePhysicalStyle
                              ? const Color(0xFF0F172A)
                              : (isSelected
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFF38BDF8)),
                          strokeWidth: 2.4,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            // Rótulo ou identificador da opção (no Quiz)
            if (!hideLabel) ...[
              Text(
                component.namePt,
                style: GoogleFonts.rajdhani(
                  color: textColor,
                  fontSize: scale.font(14.5, min: 12.5, max: 20),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              if (component.supportsStateToggle)
                InkWell(
                  onTap: onToggleActive,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: component.isActive
                          ? const Color(0xFF10B981).withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: component.isActive
                            ? const Color(0xFF10B981)
                            : Colors.grey.withValues(alpha: 0.4),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      component.isActive ? 'LIGADO' : 'DESLIGADO',
                      style: GoogleFonts.rajdhani(
                        color: component.isActive
                            ? const Color(0xFF10B981)
                            : (usePhysicalStyle ? Colors.black54 : Colors.white60),
                        fontSize: scale.font(10.5, min: 9.5, max: 14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                Text(
                  usePhysicalStyle ? 'Físico' : 'Esquemático',
                  style: GoogleFonts.outfit(
                    color: usePhysicalStyle ? Colors.black45 : Colors.white38,
                    fontSize: scale.font(10.5, min: 9, max: 14),
                  ),
                ),
            ] else ...[
              // No modo quiz, exibe apenas a identificação da opção para não entregar o nome
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
                      : (usePhysicalStyle
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFF0F172A)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00E5FF)
                        : (usePhysicalStyle
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF334155)),
                  ),
                ),
                child: Text(
                  badgeText ?? '?',
                  style: GoogleFonts.rajdhani(
                    color: isSelected
                        ? (usePhysicalStyle ? const Color(0xFF0284C7) : const Color(0xFF00E5FF))
                        : (usePhysicalStyle ? const Color(0xFF475569) : Colors.white70),
                    fontSize: scale.font(13, min: 11, max: 17),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Painel lateral de detalhes técnicos e pedagógicos do componente selecionado.
class FirstStepsComponentDetailCard extends StatelessWidget {
  final FirstStepComponent component;
  final bool usePhysicalStyle;
  final VoidCallback? onToggleState;

  const FirstStepsComponentDetailCard({
    super.key,
    required this.component,
    required this.usePhysicalStyle,
    this.onToggleState,
  });

  String _getCategoryName(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
      case ComponentType.powerSupply:
        return 'FONTE DE ENERGIA';
      case ComponentType.bulb:
      case ComponentType.motor:
      case ComponentType.buzzer:
        return 'CARGA / ATUADOR';
      case ComponentType.switchComponent:
        return 'DISPOSITIVO DE CONTROLE';
      case ComponentType.resistor:
      case ComponentType.potentiometer:
        return 'LIMITADOR DE CORRENTE';
      case ComponentType.diode:
      case ComponentType.led:
        return 'SEMICONDUTOR POLARIZADO';
      case ComponentType.connectingWire:
        return 'CONDUTOR ELÉTRICO';
      case ComponentType.capacitor:
        return 'ARMAZENADOR DE CARGA';
      case ComponentType.fuse:
        return 'PROTEÇÃO';
    }
  }

  List<String> _getTerminals(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
        return ['Polo Positivo (+)', 'Polo Negativo (-)'];
      case ComponentType.bulb:
        return ['Terminal Central (Base)', 'Rosca Metálica'];
      case ComponentType.switchComponent:
        return ['Contato 1 (Entrada)', 'Contato 2 (Saída)'];
      case ComponentType.resistor:
        return ['Terminal A (Bidirecional)', 'Terminal B (Bidirecional)'];
      case ComponentType.diode:
        return ['Ânodo (+)', 'Cátodo (-)'];
      case ComponentType.led:
        return ['Ânodo (+) Terminal Longo', 'Cátodo (-) Terminal Curto'];
      case ComponentType.motor:
        return ['Borne Positivo (+)', 'Borne Negativo (-)'];
      case ComponentType.connectingWire:
        return ['Extremidade A', 'Extremidade B'];
      default:
        return ['Terminal 1', 'Terminal 2'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final category = _getCategoryName(component.type);
    final terminals = _getTerminals(component.type);

    return Container(
      padding: EdgeInsets.all(scale.spacing(14, min: 10, max: 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
        border: Border.all(
          color: const Color(0xFF0284C7).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com Ícone e Categoria
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: const Color(0xFF00E5FF),
                  size: scale.icon(20, min: 16, max: 28),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.namePt.toUpperCase(),
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: scale.font(18, min: 15, max: 24),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '(${component.nameEn})',
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: scale.font(12, min: 10, max: 16),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge de Categoria
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF0284C7), width: 1),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF00E5FF),
                    fontSize: scale.font(10, min: 8.5, max: 13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Preview Ampliado do Componente (com imagem de assets/components)
          Container(
            width: double.infinity,
            height: scale.size(90, min: 70, max: 120),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FirstStepPhysicalView(
                      type: component.type,
                      isActive: component.isActive,
                      size: scale.size(50, min: 40, max: 64),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Visual Físico',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: scale.font(10, min: 8.5, max: 13),
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 50, color: const Color(0xFF334155)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(45, 45),
                      painter: CircuitSymbolPainter(
                        type: component.type,
                        isActive: component.isActive,
                        color: const Color(0xFF00E5FF),
                        strokeWidth: 2.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Símbolo IEC',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF00E5FF),
                        fontSize: scale.font(10, min: 8.5, max: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Função no circuito
          Text(
            'Função no Circuito:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF00E5FF),
              fontSize: scale.font(14, min: 12, max: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            component.description,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: scale.font(12.5, min: 11, max: 17),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Terminais e Conexões
          Text(
            'Terminais e Conexão:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF10B981),
              fontSize: scale.font(14, min: 12, max: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: terminals.map((t) {
              final isPositive = t.contains('+');
              final isNegative = t.contains('-');
              final chipColor = isPositive
                  ? const Color(0xFFEF4444)
                  : (isNegative ? const Color(0xFF0284C7) : const Color(0xFF10B981));

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: chipColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  t,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: scale.font(11, min: 9.5, max: 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Símbolo Esquemático
          Text(
            'Representação no Diagrama:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFF59E0B),
              fontSize: scale.font(14, min: 12, max: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            component.symbolDescription,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: scale.font(12, min: 10.5, max: 16),
              height: 1.35,
            ),
          ),

          if (component.supportsStateToggle && onToggleState != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: component.isActive
                      ? const Color(0xFF059669)
                      : const Color(0xFF334155),
                  padding: EdgeInsets.symmetric(
                    vertical: scale.spacing(10, min: 8, max: 16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onToggleState,
                icon: Icon(
                  component.isActive ? Icons.power_rounded : Icons.power_off_rounded,
                  color: Colors.white,
                  size: scale.icon(18, min: 14, max: 24),
                ),
                label: Text(
                  component.isActive ? 'TESTAR: DESATIVAR' : 'TESTAR: ATIVAR',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: scale.font(13, min: 11, max: 17),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
