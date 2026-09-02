import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF06231E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70),
            onPressed: onPrevious,
            tooltip: 'Missão Anterior',
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalMissions, (index) {
                final isCurrent = index == currentMissionIndex;
                final isCompleted = index < currentMissionIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isCurrent ? 32 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF10B981)
                        : isCompleted
                            ? const Color(0xFF059669)
                            : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
                );
              }),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.rajdhani(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF10B981),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          objective,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
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
    return DragTarget<T>(
      onWillAcceptWithDetails: (details) => details.data == expectedData,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isConnected
                  ? const Color(0xFF064E3B)
                  : isHovering
                      ? activeColor.withValues(alpha: 0.25)
                      : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
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
                  blurRadius: 10,
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
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  isConnected
                      ? connectedText
                      : isHovering
                          ? hoverText
                          : idleText,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
    return Draggable<T>(
      data: data,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF059669),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Color(0xFF10B981), blurRadius: 12)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              customVectorWidget ?? Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.2),
              ),
              child: customVectorWidget ?? Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
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

/// 5. Painel Lateral Unificado com Gaveta de Ferramentas e Botão de Energizar
class WorkbenchSidePanel extends StatelessWidget {
  final String teamTitle;
  final List<Widget> toolboxItems;
  final VoidCallback onEnergizePressed;

  const WorkbenchSidePanel({
    super.key,
    required this.teamTitle,
    required this.toolboxItems,
    required this.onEnergizePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF082B24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_input_component_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  teamTitle,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          Text(
            'Gaveta de Componentes Arrastáveis:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF10B981),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: toolboxItems,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: Text(
                'ENERGIZAR E VALIDAR BANCADA',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              onPressed: onEnergizePressed,
            ),
          ),
        ],
      ),
    );
  }
}
