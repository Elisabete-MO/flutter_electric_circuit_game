import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui_scale.dart';
import '../../../models/first_step_component.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';

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

  const FirstStepsComponentTile({
    super.key,
    required this.component,
    required this.isSelected,
    required this.usePhysicalStyle,
    required this.onTap,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isSelected
        ? (usePhysicalStyle
            ? const Color(0xFFE0F2FE)
            : const Color(0xFF0C4A6E).withValues(alpha: 0.75))
        : (usePhysicalStyle
            ? Colors.white.withValues(alpha: 0.95)
            : const Color(0xFF1E293B).withValues(alpha: 0.90));

    final borderColor = isSelected
        ? const Color(0xFF0284C7)
        : (usePhysicalStyle
            ? const Color(0xFFCBD5E1)
            : const Color(0xFF334155));

    final textColor = usePhysicalStyle
        ? const Color(0xFF0F172A)
        : Colors.white;

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
            color: borderColor,
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                    blurRadius: scale.size(10, min: 6, max: 18),
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: scale.size(6, min: 3, max: 10),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Área de renderização visual
            Expanded(
              child: Center(
                child: usePhysicalStyle
                    ? CustomPaint(
                        size: Size(
                          scale.size(65, min: 45, max: 95),
                          scale.size(65, min: 45, max: 95),
                        ),
                        painter: ComponentPhysicalPainter(
                          type: component.type,
                          isActive: component.isActive,
                          isDarkMode: !usePhysicalStyle && isDark,
                        ),
                      )
                    : CustomPaint(
                        size: Size(
                          scale.size(65, min: 45, max: 95),
                          scale.size(65, min: 45, max: 95),
                        ),
                        painter: CircuitSymbolPainter(
                          type: component.type,
                          isActive: component.isActive,
                          color: usePhysicalStyle
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF00E5FF),
                          strokeWidth: 2.2,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            // Nome do Componente
            Text(
              component.namePt,
              style: GoogleFonts.rajdhani(
                color: textColor,
                fontSize: scale.font(14, min: 12, max: 19),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            // Botão de alternar estado se suportar (Lâmpada / Chave / LED)
            if (component.supportsStateToggle)
              InkWell(
                onTap: onToggleActive,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: component.isActive
                        ? const Color(0xFF10B981).withValues(alpha: 0.18)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: component.isActive
                          ? const Color(0xFF10B981)
                          : Colors.grey.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    component.isActive ? 'LIGADO' : 'DESLIGADO',
                    style: GoogleFonts.rajdhani(
                      color: component.isActive
                          ? const Color(0xFF10B981)
                          : (usePhysicalStyle ? Colors.black54 : Colors.white60),
                      fontSize: scale.font(10, min: 9, max: 14),
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

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Container(
      padding: EdgeInsets.all(scale.spacing(14, min: 10, max: 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            ],
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
              fontSize: scale.font(13, min: 11, max: 17),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          // Símbolo Esquemático
          Text(
            'Representação no Diagrama:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF10B981),
              fontSize: scale.font(14, min: 12, max: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            component.symbolDescription,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: scale.font(12.5, min: 10.5, max: 16.5),
              height: 1.35,
            ),
          ),
          if (component.supportsStateToggle && onToggleState != null) ...[
            const SizedBox(height: 14),
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
