import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/ui_scale.dart';

/// Moldura Padronizada da Mesa de Laboratório (EletroLab)
/// Utiliza o asset `mesa_eletrolab_vista_superior.png` como fundo vetorial/fotográfico
/// com seletores, cartões de status e controles flutuantes integrados.
class WorkbenchTableFrame extends StatelessWidget {
  final Widget child;
  final bool usePhysicalStyle;
  final ValueSetter<bool> onStyleChanged;
  final Widget? leftHeaderWidget;
  final Widget? rightHeaderWidget;
  final Widget? bottomWidget;
  final bool showModeSelector;

  const WorkbenchTableFrame({
    super.key,
    required this.child,
    required this.usePhysicalStyle,
    required this.onStyleChanged,
    this.leftHeaderWidget,
    this.rightHeaderWidget,
    this.bottomWidget,
    this.showModeSelector = true,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scale.size(20, min: 14, max: 32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: scale.size(18, min: 10, max: 28),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(scale.size(20, min: 14, max: 32)),
        child: Stack(
          children: [
            // 1. Imagem de Fundo da Mesa Vista Superior
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgrounds/mesa_eletrolab_vista_superior.png',
                fit: BoxFit.fill,
              ),
            ),

            // 2. Área Central do Circuito Eletrônico
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  top: scale.spacing(54, min: 40, max: 80),
                  bottom: scale.spacing(50, min: 36, max: 76),
                  left: scale.spacing(16, min: 10, max: 28),
                  right: scale.spacing(16, min: 10, max: 28),
                ),
                child: child,
              ),
            ),

            // 3. Barra Superior Flutuante (Cards de Status, Seletor e Telemetria)
            Positioned(
              top: scale.spacing(12, min: 8, max: 20),
              left: scale.spacing(16, min: 10, max: 28),
              right: scale.spacing(16, min: 10, max: 28),
              child: LayoutBuilder(
                builder: (context, headerConstraints) {
                  final headerW = headerConstraints.maxWidth;
                  final isCompact = headerW < 540;
                  final isUltraCompact = headerW < 400;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Canto Esquerdo: Card de Status
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: leftHeaderWidget != null
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: leftHeaderWidget!,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),

                      // Centro: Seletor de Modo (Esquemático vs Físico 3D)
                      if (showModeSelector)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildVisualModeSelector(
                            context,
                            isCompact: isCompact,
                            isUltraCompact: isUltraCompact,
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      // Canto Direito: Card de Telemetria
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: rightHeaderWidget != null
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: rightHeaderWidget!,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 4. Rodapé Flutuante (ex: Undo / Redo Pill)
            if (bottomWidget != null)
              Positioned(
                bottom: scale.spacing(12, min: 8, max: 20),
                left: 0,
                right: 0,
                child: Center(
                  child: bottomWidget!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualModeSelector(
    BuildContext context, {
    bool isCompact = false,
    bool isUltraCompact = false,
  }) {
    final scale = context.uiScale;

    return Container(
      height: scale.size(36, min: 30, max: 54),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(scale.size(20, min: 16, max: 30)),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: scale.size(8, min: 4, max: 14),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opção 1: Esquemático
          GestureDetector(
            onTap: () => onStyleChanged(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isUltraCompact
                    ? 8
                    : (isCompact ? 10 : scale.spacing(14, min: 10, max: 24)),
                vertical: scale.spacing(4, min: 2, max: 8),
              ),
              decoration: BoxDecoration(
                color: !usePhysicalStyle
                    ? const Color(0xFF0284C7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
                boxShadow: !usePhysicalStyle
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.architecture_rounded,
                    size: scale.icon(15, min: 13, max: 22),
                    color: !usePhysicalStyle
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  if (!isUltraCompact) ...[
                    SizedBox(width: scale.spacing(5, min: 3, max: 8)),
                    Text(
                      isCompact ? 'Esq.' : 'Esquemático',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: scale.font(12.5, min: 11, max: 18),
                        color: !usePhysicalStyle
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 3),
          // Opção 2: Físico 3D
          GestureDetector(
            onTap: () => onStyleChanged(true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isUltraCompact
                    ? 8
                    : (isCompact ? 10 : scale.spacing(14, min: 10, max: 24)),
                vertical: scale.spacing(4, min: 2, max: 8),
              ),
              decoration: BoxDecoration(
                color: usePhysicalStyle
                    ? const Color(0xFF0284C7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
                boxShadow: usePhysicalStyle
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.electrical_services_rounded,
                    size: scale.icon(15, min: 13, max: 22),
                    color: usePhysicalStyle
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  if (!isUltraCompact) ...[
                    SizedBox(width: scale.spacing(5, min: 3, max: 8)),
                    Text(
                      isCompact ? 'Físico' : 'Físico 3D',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: scale.font(12.5, min: 11, max: 18),
                        color: usePhysicalStyle
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Layout Responsivo Universal para Bancadas do EletroLab (Bancada + Painel Lateral).
///
/// Garante que:
/// - Em telas largas (Desktop/Notebooks), a bancada ocupe o espaço nobre e o painel
///   lateral tenha uma largura proporcional e equilibrada (270-340px), evitando que
///   os cards fiquem "recuados demais" ou esvaziados à direita.
/// - Em telas intermediárias (Tablets/Telas menores), o painel lateral preserve sua
///   legibilidade mínima sem esmagar o conteúdo dos cards.
/// - Em telas compactas (< 720px), faz o reflow responsivo vertical com rolagem suave,
///   impedindo qualquer overflow horizontal.
class WorkbenchResponsiveLayout extends StatelessWidget {
  final Widget workbench;
  final Widget sidePanel;
  final double spacing;

  const WorkbenchResponsiveLayout({
    super.key,
    required this.workbench,
    required this.sidePanel,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Modo Vertical / Empilhado para telas estreitas (portrait ou mobile < 720px)
        if (w < 720) {
          final benchHeight = h > 0
              ? (h * 0.58).clamp(scale.size(320, min: 280, max: 480), scale.size(500, min: 380, max: 640))
              : scale.size(340, min: 300, max: 480);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: benchHeight,
                  child: workbench,
                ),
                SizedBox(height: scale.spacing(spacing, min: 10, max: 24)),
                sidePanel,
              ],
            ),
          );
        }

        // Modo Horizontal com Proporção Otimizada
        // Painel lateral com largura calibrada pelo UiScale (270px a 340px em 1080p, escalando em 2K/4K)
        final sidePanelWidth = scale.cardWidth(
          300.0,
          maxPercent: 0.32,
          min: 270.0,
          max: scale.size(360.0, min: 300.0, max: 540.0),
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: workbench),
            SizedBox(width: scale.spacing(spacing, min: 10, max: 24)),
            SizedBox(
              width: sidePanelWidth,
              child: sidePanel,
            ),
          ],
        );
      },
    );
  }
}

