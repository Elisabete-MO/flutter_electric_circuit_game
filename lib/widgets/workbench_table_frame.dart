import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.only(top: 54, bottom: 50, left: 16, right: 16),
                child: child,
              ),
            ),

            // 3. Barra Superior Flutuante (Cards de Status, Seletor e Telemetria)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Canto Esquerdo: Card de Status
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: leftHeaderWidget ?? const SizedBox.shrink(),
                    ),
                  ),

                  // Centro: Seletor de Modo (Esquemático vs Físico 3D)
                  if (showModeSelector)
                    _buildVisualModeSelector()
                  else
                    const SizedBox.shrink(),

                  // Canto Direito: Card de Telemetria
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: rightHeaderWidget ?? const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Rodapé Flutuante (ex: Undo / Redo Pill)
            if (bottomWidget != null)
              Positioned(
                bottom: 12,
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

  Widget _buildVisualModeSelector() {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: !usePhysicalStyle
                    ? const Color(0xFF0284C7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
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
                    size: 15,
                    color: !usePhysicalStyle
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Esquemático',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: !usePhysicalStyle
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: usePhysicalStyle
                    ? const Color(0xFF0284C7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
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
                    size: 15,
                    color: usePhysicalStyle
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Físico 3D',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: usePhysicalStyle
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
