import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/ui_scale.dart';

/// Componentes Padronizados da Bancada de Simulação do EletroLab

/// 1. Cabeçalho de Navegação e Stepper das Missões
class WorkbenchHeaderStepper extends StatelessWidget {
  final int totalMissions;
  final int currentMissionIndex;
  final String missionTitle;
  final String missionObjective;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const WorkbenchHeaderStepper({
    super.key,
    required this.totalMissions,
    required this.currentMissionIndex,
    required this.missionTitle,
    required this.missionObjective,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(16, min: 10, max: 24),
        vertical: scale.spacing(8, min: 6, max: 14),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: scale.size(8, min: 4, max: 14),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: const Color(0xFF334155), size: scale.icon(24, min: 20, max: 32)),
            onPressed: onPrevious,
            tooltip: 'Missão Anterior',
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalMissions, (index) {
                final isCurrent = index == currentMissionIndex;
                final isCompleted = index < currentMissionIndex;
                final barWidth = isCurrent
                    ? scale.size(32, min: 24, max: 48)
                    : scale.size(12, min: 10, max: 20);
                final barHeight = scale.size(12, min: 10, max: 20);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: scale.spacing(4, min: 2, max: 8)),
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF0284C7)
                        : isCompleted
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(barHeight / 2),
                  ),
                  child: isCompleted
                      ? Icon(Icons.check, size: scale.icon(10, min: 8, max: 16), color: Colors.white)
                      : null,
                );
              }),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: const Color(0xFF334155), size: scale.icon(24, min: 20, max: 32)),
            onPressed: onNext,
            tooltip: 'Próxima Missão',
          ),
        ],
      ),
    );
  }
}

/// 2. Header do Título e Objetivo da Missão
class WorkbenchMissionHeader extends StatelessWidget {
  final String title;
  final String objective;

  const WorkbenchMissionHeader({
    super.key,
    required this.title,
    required this.objective,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.rajdhani(
            fontSize: scale.font(20, min: 16, max: 30),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          objective,
          style: GoogleFonts.outfit(
            color: const Color(0xFF475569),
            fontSize: scale.font(13.5, min: 11.5, max: 20.0),
          ),
        ),
      ],
    );
  }
}

/// 3. Socket / Slot Quadrado Neon Arrastável (`DragTarget` Universal)
class WorkbenchSlotSocket<T extends Object> extends StatelessWidget {
  final T expectedData;
  final bool isConnected;
  final ValueSetter<T> onAccept;
  final VoidCallback onTap;
  final String idleText;
  final String hoverText;
  final String connectedText;
  final IconData idleIcon;
  final Color activeColor;

  const WorkbenchSlotSocket({
    super.key,
    required this.expectedData,
    required this.isConnected,
    required this.onAccept,
    required this.onTap,
    required this.idleText,
    this.hoverText = '🎯 Solte Aqui para Encaixar!',
    required this.connectedText,
    this.idleIcon = Icons.add_box_rounded,
    this.activeColor = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return DragTarget<T>(
      onWillAcceptWithDetails: (details) => details.data == expectedData,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: scale.spacing(20, min: 14, max: 32),
              vertical: scale.spacing(12, min: 8, max: 20),
            ),
            decoration: BoxDecoration(
              color: isConnected
                  ? const Color(0xFF064E3B)
                  : isHovering
                      ? activeColor.withValues(alpha: 0.25)
                      : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
              border: Border.all(
                color: isConnected
                    ? activeColor
                    : isHovering
                        ? activeColor
                        : Colors.amber,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isConnected ? activeColor : Colors.amber).withValues(alpha: 0.3),
                  blurRadius: scale.size(10, min: 6, max: 18),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConnected
                      ? Icons.check_circle_rounded
                      : isHovering
                          ? Icons.move_to_inbox_rounded
                          : idleIcon,
                  color: isConnected ? activeColor : Colors.amber,
                  size: scale.icon(22, min: 18, max: 32),
                ),
                SizedBox(width: scale.spacing(10, min: 6, max: 16)),
                Text(
                  isConnected
                      ? connectedText
                      : isHovering
                          ? hoverText
                          : idleText,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: scale.font(15, min: 13, max: 22),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 4. Card da Gaveta de Ferramentas Arrastáveis (`Draggable`)
class WorkbenchToolboxItem<T extends Object> extends StatelessWidget {
  final T data;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? customVectorWidget;
  final Color color;

  const WorkbenchToolboxItem({
    super.key,
    required this.data,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.customVectorWidget,
    this.color = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Draggable<T>(
      data: data,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: scale.spacing(14, min: 10, max: 22),
            vertical: scale.spacing(10, min: 8, max: 16),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF059669),
            borderRadius: BorderRadius.circular(scale.size(12, min: 8, max: 18)),
            boxShadow: const [BoxShadow(color: Color(0xFF10B981), blurRadius: 12)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              customVectorWidget ?? Icon(icon, color: Colors.white, size: scale.icon(20, min: 16, max: 28)),
              SizedBox(width: scale.spacing(8, min: 5, max: 14)),
              Text(
                title,
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: scale.font(13, min: 11, max: 18),
                ),
              ),
            ],
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: scale.spacing(8, min: 5, max: 14)),
        padding: EdgeInsets.all(scale.spacing(10, min: 7, max: 16)),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(scale.size(12, min: 8, max: 18)),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(scale.spacing(6, min: 4, max: 10)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.2),
              ),
              child: customVectorWidget ?? Icon(icon, color: color, size: scale.icon(20, min: 16, max: 28)),
            ),
            SizedBox(width: scale.spacing(10, min: 6, max: 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: scale.font(13, min: 11, max: 18),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: scale.font(11, min: 9.5, max: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4b. Card de Componentes com Símbolo e Rótulo
class WorkbenchSymbolToolboxTile<T extends Object> extends StatelessWidget {
  final T data;
  final Widget symbolWidget;
  final String? label;
  final String? tooltip;
  final Color color;

  const WorkbenchSymbolToolboxTile({
    super.key,
    required this.data,
    required this.symbolWidget,
    this.label,
    this.tooltip,
    this.color = const Color(0xFF0284C7),
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final tileSize = scale.size(84, min: 64, max: 130);

    final tileContent = Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scale.size(14, min: 10, max: 22)),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: scale.size(6, min: 4, max: 12),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 2),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: tileSize * 0.85,
                    height: tileSize * 0.85,
                    child: Center(child: symbolWidget),
                  ),
                ),
              ),
            ),
          ),
          if (label != null || tooltip != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4, right: 4),
              child: Text(
                label ?? tooltip ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF334155),
                  fontSize: scale.font(10.5, min: 9.0, max: 15.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );

    return Draggable<T>(
      data: data,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: tileSize * 1.05,
          height: tileSize * 1.05,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: scale.size(14, min: 8, max: 22),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(child: symbolWidget),
        ),
      ),
      child: tooltip != null
          ? Tooltip(
              message: tooltip!,
              child: tileContent,
            )
          : tileContent,
    );
  }
}

/// 5. Painel Lateral Unificado da Bancada
class WorkbenchSidePanel extends StatelessWidget {
  final String teamTitle;
  final List<Widget> toolboxItems;
  final VoidCallback onEnergizePressed;
  final bool isLoading;
  final Color? buttonColor;
  final String? buttonLabel;
  final bool showTeamHeader;

  const WorkbenchSidePanel({
    super.key,
    required this.teamTitle,
    required this.toolboxItems,
    required this.onEnergizePressed,
    this.isLoading = false,
    this.buttonColor,
    this.buttonLabel,
    this.showTeamHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Container(
      padding: EdgeInsets.all(scale.spacing(16, min: 12, max: 28)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(scale.size(20, min: 14, max: 32)),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: scale.size(12, min: 8, max: 20),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTeamHeader) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: scale.spacing(12, min: 8, max: 20),
                vertical: scale.spacing(10, min: 6, max: 16),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(scale.size(12, min: 8, max: 18)),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.widgets_rounded, color: const Color(0xFF0284C7), size: scale.icon(20, min: 16, max: 28)),
                  SizedBox(width: scale.spacing(8, min: 5, max: 14)),
                  Expanded(
                    child: Text(
                      teamTitle,
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: scale.font(15, min: 13, max: 22),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: scale.spacing(12, min: 8, max: 18)),
          ],
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: toolboxItems,
              ),
            ),
          ),
          SizedBox(height: scale.spacing(12, min: 8, max: 18)),
          SizedBox(
            width: double.infinity,
            height: scale.size(48, min: 40, max: 68),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor ?? const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(scale.size(12, min: 8, max: 18)),
                ),
                elevation: 3,
              ),
              icon: isLoading
                  ? SizedBox(
                      width: scale.size(18, min: 14, max: 26),
                      height: scale.size(18, min: 14, max: 26),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.play_arrow_rounded, color: Colors.white, size: scale.icon(22, min: 18, max: 32)),
              label: Text(
                isLoading
                    ? 'SIMULANDO...'
                    : (buttonLabel ?? 'ENERGIZAR E VALIDAR BANCADA'),
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: scale.font(14, min: 12, max: 22),
                ),
              ),
              onPressed: isLoading ? null : onEnergizePressed,
            ),
          ),
        ],
      ),
    );
  }
}

