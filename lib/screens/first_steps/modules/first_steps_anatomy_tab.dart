import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui_scale.dart';
import '../../../models/first_step_component.dart';
import '../../../widgets/circuit_symbol_painter.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';

/// Módulo 2 do Estande 01 — Anatomia dos Terminais, Nós e Polaridade.
class FirstStepsAnatomyTab extends StatefulWidget {
  final VoidCallback onModuleComplete;

  const FirstStepsAnatomyTab({
    super.key,
    required this.onModuleComplete,
  });

  @override
  State<FirstStepsAnatomyTab> createState() => _FirstStepsAnatomyTabState();
}

class _FirstStepsAnatomyTabState extends State<FirstStepsAnatomyTab> {
  bool _usePhysicalStyle = true;
  int _selectedCategoryIndex = 0; // 0: Polarizados, 1: Bidirecionais

  void _onCompleteAnatomy() {
    showSuccessConfetti(context);
    widget.onModuleComplete();
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Row(
      children: [
        // Coluna Esquerda (7 flex) — Bancada de Trabalho
        Expanded(
          flex: 7,
          child: Column(
            children: [
              Expanded(
                child: WorkbenchTableFrame(
                  usePhysicalStyle: _usePhysicalStyle,
                  onStyleChanged: (val) =>
                      setState(() => _usePhysicalStyle = val),
                  leftHeaderWidget: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: scale.spacing(10, min: 6, max: 16),
                      vertical: scale.spacing(5, min: 3, max: 10),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                      borderRadius:
                          BorderRadius.circular(scale.size(10, min: 6, max: 16)),
                      border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cable_rounded,
                            color: Color(0xFF10B981), size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Terminais e Nós',
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: scale.font(12, min: 10.5, max: 16),
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Seletor de Categoria
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildCategoryTab(
                              index: 0,
                              label: '1. Componentes Polarizados (+ / -)',
                              icon: Icons.battery_charging_full_rounded,
                            ),
                            _buildCategoryTab(
                              index: 1,
                              label: '2. Componentes Bidirecionais (A / B)',
                              icon: Icons.sync_alt_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _selectedCategoryIndex == 0
                              ? _buildPolarizedSection()
                              : _buildBidirectionalSection(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Coluna Direita (3 flex) — Painel Lateral
        Expanded(
          flex: 3,
          child: WorkbenchSidePanel(
            teamTitle: 'Análise de Conexões',
            showTeamHeader: false,
            buttonColor: const Color(0xFF059669),
            toolboxItems: [
              WorkbenchMissionObjectiveCard(
                missionNumber: 2,
                title: 'Terminais e Polaridade',
                description:
                    'Compreenda a diferença entre componentes polarizados (que exigem sentido correto da corrente) e bidirecionais (reversíveis).',
                voltsTip:
                    'Lembre-se: em componentes polarizados como o LED, se você inverter os polos (+) e (-), o componente não funcionará ou poderá ser danificado!',
              ),
              const SizedBox(height: 12),
              _buildRulesCard(),
            ],
            onEnergizePressed: _onCompleteAnatomy,
            isLoading: false,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final scale = context.uiScale;
    final isSelected = _selectedCategoryIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedCategoryIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: scale.spacing(14, min: 10, max: 20),
          vertical: scale.spacing(8, min: 6, max: 12),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0284C7)
              : (_usePhysicalStyle ? Colors.white : const Color(0xFF1E293B)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00E5FF)
                : (_usePhysicalStyle
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF334155)),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF0284C7),
              size: scale.icon(18, min: 14, max: 24),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: isSelected
                    ? Colors.white
                    : (_usePhysicalStyle
                        ? const Color(0xFF0F172A)
                        : Colors.white70),
                fontWeight: FontWeight.bold,
                fontSize: scale.font(14, min: 12, max: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolarizedSection() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildAnatomyCard(
            title: 'Bateria / Pilha (Fonte de Tensão)',
            type: ComponentType.battery,
            terminalLeft: 'Polo Positivo (+)',
            terminalRight: 'Polo Negativo (-)',
            colorLeft: const Color(0xFFEF4444),
            colorRight: const Color(0xFF1E293B),
            description:
                'O polo positivo (+) tem maior potencial elétrico. A corrente convencional sai do polo positivo e retorna pelo polo negativo (-).',
          ),
          const SizedBox(height: 12),
          _buildAnatomyCard(
            title: 'LED (Diodo Emissor de Luz)',
            type: ComponentType.led,
            terminalLeft: 'Ânodo (+) Terminal Longo',
            terminalRight: 'Cátodo (-) Terminal Curto',
            colorLeft: const Color(0xFFEF4444),
            colorRight: const Color(0xFF0284C7),
            description:
                'O LED só conduz corrente do Ânodo para o Cátodo. Se for ligado invertido, o circuito permanecerá em estado aberto e apagado.',
          ),
        ],
      ),
    );
  }

  Widget _buildBidirectionalSection() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildAnatomyCard(
            title: 'Lâmpada Incandescente (Carga)',
            type: ComponentType.bulb,
            terminalLeft: 'Terminal A (Base)',
            terminalRight: 'Terminal B (Rosca)',
            colorLeft: const Color(0xFFF59E0B),
            colorRight: const Color(0xFFF59E0B),
            description:
                'A lâmpada incandescente não tem polaridade! A corrente pode fluir em qualquer direção através do filamento de tungstênio.',
          ),
          const SizedBox(height: 12),
          _buildAnatomyCard(
            title: 'Resistor (Limitador de Corrente)',
            type: ComponentType.resistor,
            terminalLeft: 'Terminal 1',
            terminalRight: 'Terminal 2',
            colorLeft: const Color(0xFF10B981),
            colorRight: const Color(0xFF10B981),
            description:
                'O resistor é perfeitamente simétrico e reversível. A oposição à corrente é idêntica em ambos os sentidos.',
          ),
        ],
      ),
    );
  }

  Widget _buildAnatomyCard({
    required String title,
    required ComponentType type,
    required String terminalLeft,
    required String terminalRight,
    required Color colorLeft,
    required Color colorRight,
    required String description,
  }) {
    final scale = context.uiScale;

    return Container(
      padding: EdgeInsets.all(scale.spacing(14, min: 10, max: 20)),
      decoration: BoxDecoration(
        color: _usePhysicalStyle
            ? Colors.white
            : const Color(0xFF1E293B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _usePhysicalStyle
              ? const Color(0xFFCBD5E1)
              : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.rajdhani(
              color: _usePhysicalStyle
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF00E5FF),
              fontWeight: FontWeight.bold,
              fontSize: scale.font(16, min: 13, max: 20),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Visualizador do Componente
              Container(
                width: scale.size(80, min: 60, max: 110),
                height: scale.size(80, min: 60, max: 110),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _usePhysicalStyle
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _usePhysicalStyle
                      ? CustomPaint(
                          size: const Size(55, 55),
                          painter: ComponentPhysicalPainter(
                            type: type,
                            isActive: true,
                            isDarkMode: !_usePhysicalStyle,
                          ),
                        )
                      : CustomPaint(
                          size: const Size(55, 55),
                          painter: CircuitSymbolPainter(
                            type: type,
                            isActive: true,
                            color: _usePhysicalStyle
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF00E5FF),
                            strokeWidth: 2.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // Terminais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildTerminalBadge(terminalLeft, colorLeft),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 16, color: Colors.grey),
                        _buildTerminalBadge(terminalRight, colorRight),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.outfit(
                        color: _usePhysicalStyle
                            ? const Color(0xFF475569)
                            : Colors.white70,
                        fontSize: scale.font(12.5, min: 11, max: 16),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalBadge(String label, Color color) {
    final scale = context.uiScale;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
          color: color,
          fontSize: scale.font(12, min: 10, max: 15),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRulesCard() {
    final scale = context.uiScale;
    return Container(
      padding: EdgeInsets.all(scale.spacing(14, min: 10, max: 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                'Regras de Ouro:',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: scale.font(16, min: 13, max: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Nunca conecte o polo (+) diretamente ao (-) da bateria sem uma carga (isso causaria um curto-circuito perigoso!).\n'
            '• A corrente sempre precisa de um caminho fechado (loop) para fluir.',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: scale.font(13, min: 11, max: 17),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
