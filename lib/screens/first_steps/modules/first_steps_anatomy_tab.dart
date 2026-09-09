import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/first_steps_widgets.dart';

import '../../../core/ui_scale.dart';
import '../../../models/first_step_component.dart';
import '../../../widgets/circuit_symbol_painter.dart';
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
  String? _highlightedTerminal;

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
                        const SizedBox(height: 12),
                        // Grid 2x2 com os 4 componentes da categoria selecionada
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount =
                                  constraints.maxWidth >= 700 ? 2 : 1;
                              final spacing = scale.spacing(12, min: 8, max: 16);

                              return GridView.count(
                                physics: const BouncingScrollPhysics(),
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                                childAspectRatio: constraints.maxWidth >= 700
                                    ? 1.55
                                    : 2.1,
                                children: _selectedCategoryIndex == 0
                                    ? _buildPolarizedCards()
                                    : _buildBidirectionalCards(),
                              );
                            },
                          ),
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
            buttonLabel: 'AVANÇAR PARA O QUIZ ➔',
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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

  List<Widget> _buildPolarizedCards() {
    return [
      _buildAnatomyCard(
        title: 'Bateria (Fonte DC)',
        type: ComponentType.battery,
        terminalLeft: 'Polo Positivo (+)',
        terminalRight: 'Polo Negativo (-)',
        colorLeft: const Color(0xFFEF4444),
        colorRight: const Color(0xFF0284C7),
        description:
            'Polo (+) com potencial mais alto. A corrente convencional sai pelo (+) e retorna pelo (-).',
      ),
      _buildAnatomyCard(
        title: 'LED (Emissor de Luz)',
        type: ComponentType.led,
        terminalLeft: 'Ânodo (+) Longo',
        terminalRight: 'Cátodo (-) Curto',
        colorLeft: const Color(0xFFEF4444),
        colorRight: const Color(0xFF0284C7),
        description:
            'Só acende quando a corrente entra pelo Ânodo (+) e sai pelo Cátodo (-).',
      ),
      _buildAnatomyCard(
        title: 'Diodo Retificador',
        type: ComponentType.diode,
        terminalLeft: 'Ânodo (Entrada)',
        terminalRight: 'Cátodo (Barra)',
        colorLeft: const Color(0xFFEF4444),
        colorRight: const Color(0xFF0284C7),
        description:
            'Funciona como uma válvula de sentido único, bloqueando correntes reversas.',
      ),
      _buildAnatomyCard(
        title: 'Motor Elétrico DC',
        type: ComponentType.motor,
        terminalLeft: 'Borne (+)',
        terminalRight: 'Borne (-)',
        colorLeft: const Color(0xFFEF4444),
        colorRight: const Color(0xFF0284C7),
        description:
            'Inverter os polos inverte o sentido de rotação mecânica do eixo.',
      ),
    ];
  }

  List<Widget> _buildBidirectionalCards() {
    return [
      _buildAnatomyCard(
        title: 'Lâmpada Incandescente',
        type: ComponentType.bulb,
        terminalLeft: 'Terminal A (Base)',
        terminalRight: 'Terminal B (Rosca)',
        colorLeft: const Color(0xFFF59E0B),
        colorRight: const Color(0xFFF59E0B),
        description:
            'Sem polaridade: a corrente pode fluir em qualquer sentido pelo filamento.',
      ),
      _buildAnatomyCard(
        title: 'Resistor Linear',
        type: ComponentType.resistor,
        terminalLeft: 'Terminal 1',
        terminalRight: 'Terminal 2',
        colorLeft: const Color(0xFF10B981),
        colorRight: const Color(0xFF10B981),
        description:
            'Totalmente reversível: oferece a mesma oposição à corrente em ambos os lados.',
      ),
      _buildAnatomyCard(
        title: 'Interruptor / Chave',
        type: ComponentType.switchComponent,
        terminalLeft: 'Contato 1',
        terminalRight: 'Contato 2',
        colorLeft: const Color(0xFF10B981),
        colorRight: const Color(0xFF10B981),
        description:
            'Abre ou fecha o trecho condutor independentemente de qual terminal recebe a tensão.',
      ),
      _buildAnatomyCard(
        title: 'Fio de Conexão',
        type: ComponentType.connectingWire,
        terminalLeft: 'Extremidade A',
        terminalRight: 'Extremidade B',
        colorLeft: const Color(0xFF10B981),
        colorRight: const Color(0xFF10B981),
        description:
            'Condutor ideal de resistência nula, transporta elétrons nos dois sentidos.',
      ),
    ];
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
      padding: EdgeInsets.all(scale.spacing(12, min: 8, max: 16)),
      decoration: BoxDecoration(
        color: _usePhysicalStyle
            ? Colors.white
            : const Color(0xFF1E293B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _usePhysicalStyle
              ? const Color(0xFFCBD5E1)
              : const Color(0xFF334155),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título do componente
          Text(
            title,
            style: GoogleFonts.rajdhani(
              color: _usePhysicalStyle
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF00E5FF),
              fontWeight: FontWeight.bold,
              fontSize: scale.font(15, min: 13, max: 19),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Visualizador do Componente
                Container(
                  width: scale.size(68, min: 50, max: 88),
                  height: scale.size(68, min: 50, max: 88),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _usePhysicalStyle
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _usePhysicalStyle
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF334155),
                    ),
                  ),
                  child: Center(
                    child: _usePhysicalStyle
                        ? FirstStepPhysicalView(
                            type: type,
                            isActive: true,
                            size: 48,
                          )
                        : CustomPaint(
                            size: const Size(48, 48),
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
                const SizedBox(width: 10),
                // Terminais e descrição
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badges dos terminais
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildTerminalBadge(
                            terminalLeft,
                            colorLeft,
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: scale.icon(14, min: 12, max: 18),
                            color: _usePhysicalStyle
                                ? Colors.black45
                                : Colors.white54,
                          ),
                          _buildTerminalBadge(
                            terminalRight,
                            colorRight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: GoogleFonts.outfit(
                          color: _usePhysicalStyle
                              ? const Color(0xFF475569)
                              : Colors.white70,
                          fontSize: scale.font(11.5, min: 10, max: 15),
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalBadge(String label, Color color) {
    final scale = context.uiScale;
    final isHighlighted = _highlightedTerminal == label;

    return InkWell(
      onTap: () {
        setState(() {
          _highlightedTerminal = isHighlighted ? null : label;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isHighlighted ? 0.35 : 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color,
            width: isHighlighted ? 1.8 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            color: _usePhysicalStyle ? color : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: scale.font(11, min: 9.5, max: 14),
          ),
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
              const Icon(Icons.lightbulb_rounded, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                'Regras de Ouro:',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: scale.font(15, min: 13, max: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRuleItem(
            '• Nunca conecte o polo (+) diretamente ao (-) da bateria sem uma carga (isso causaria um curto-circuito perigoso).',
          ),
          const SizedBox(height: 4),
          _buildRuleItem(
            '• A corrente sempre precisa de um caminho fechado (loop) para fluir.',
          ),
          const SizedBox(height: 4),
          _buildRuleItem(
            '• Componentes polarizados só funcionam quando inseridos na orientação correta.',
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    final scale = context.uiScale;
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: Colors.white70,
        fontSize: scale.font(12, min: 10.5, max: 16),
        height: 1.35,
      ),
    );
  }
}
