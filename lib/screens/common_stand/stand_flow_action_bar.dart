import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'stand_flow_tokens.dart';

/// Barra inferior reutilizável e padronizada de ações das missões.
class StandFlowActionBar extends StatelessWidget {
  final Widget? leftContent;
  final String? statusText;
  final String? progressText;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool canUndo;
  final bool canRedo;
  final bool? usePhysicalStyle;
  final ValueChanged<bool>? onToggleStyle;
  final List<Widget> extraActions;
  final Widget? primaryAction;

  const StandFlowActionBar({
    super.key,
    this.leftContent,
    this.statusText,
    this.progressText,
    this.onUndo,
    this.onRedo,
    this.canUndo = false,
    this.canRedo = false,
    this.usePhysicalStyle,
    this.onToggleStyle,
    this.extraActions = const [],
    this.primaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: StandFlowTokens.actionBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StandFlowTokens.primaryGreen.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;

          return Row(
            children: [
              // 1. Lado Esquerdo: Mensagem de status / instrução
              Expanded(
                child: leftContent ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (statusText != null) ...[
                          const Icon(
                            Icons.info_outline_rounded,
                            color: StandFlowTokens.accentGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              statusText!,
                              style: TextStyle(
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
              ),

              // 2. Lado Direito: Ações (Undo, Redo, Toggle de Estilo, Botões Extras e Botão Primário)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onUndo != null)
                    IconButton(
                      icon: const Icon(Icons.undo_rounded, size: 20),
                      tooltip: 'Desfazer',
                      color: canUndo ? Colors.white : Colors.white24,
                      onPressed: canUndo ? onUndo : null,
                    ),
                  if (onRedo != null)
                    IconButton(
                      icon: const Icon(Icons.redo_rounded, size: 20),
                      tooltip: 'Refazer',
                      color: canRedo ? Colors.white : Colors.white24,
                      onPressed: canRedo ? onRedo : null,
                    ),

                  if (usePhysicalStyle != null && onToggleStyle != null && !isNarrow) ...[
                    const SizedBox(width: 6),
                    _buildStyleToggle(),
                  ],

                  ...extraActions,

                  if (primaryAction != null) ...[
                    const SizedBox(width: 10),
                    primaryAction!,
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStyleToggle() {
    final isPhysical = usePhysicalStyle ?? true;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF03241B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: StandFlowTokens.primaryGreen.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('Físico', isPhysical, () => onToggleStyle?.call(true)),
          _buildToggleOption('Esquema', !isPhysical, () => onToggleStyle?.call(false)),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? StandFlowTokens.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: GoogleFonts.rajdhani().fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }
}
