import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui_scale.dart';
import '../../../models/first_step_component.dart';
import '../../../widgets/success_confetti_overlay.dart';
import '../../../widgets/workbench_components.dart';
import '../../../widgets/workbench_sidebar_cards.dart';
import '../../../widgets/workbench_table_frame.dart';
import '../widgets/first_steps_widgets.dart';

/// Módulo 1 do Estande 01 — Vitrine Interativa de Componentes e Símbolos Esquemáticos.
class FirstStepsShowcaseTab extends StatefulWidget {
  final VoidCallback onModuleComplete;

  const FirstStepsShowcaseTab({
    super.key,
    required this.onModuleComplete,
  });

  @override
  State<FirstStepsShowcaseTab> createState() => _FirstStepsShowcaseTabState();
}

class _FirstStepsShowcaseTabState extends State<FirstStepsShowcaseTab> {
  late List<FirstStepComponent> _components;
  int _selectedIndex = 0;
  bool _usePhysicalStyle = true;
  final Set<String> _inspectedIds = {};

  @override
  void initState() {
    super.initState();
    _components = List.from(FirstStepComponent.defaultList);
    if (_components.isNotEmpty) {
      _inspectedIds.add(_components[0].id);
    }
  }

  void _selectComponent(int index) {
    setState(() {
      _selectedIndex = index;
      _inspectedIds.add(_components[index].id);
    });
  }

  void _toggleComponentActive(int index) {
    setState(() {
      final comp = _components[index];
      _components[index] = comp.copyWith(isActive: !comp.isActive);
    });
  }

  void _onCompleteShowcase() {
    showSuccessConfetti(context);
    widget.onModuleComplete();
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final selectedComp = _components[_selectedIndex];

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
                  leftHeaderWidget: FirstStepsStatusCard(
                    totalCount: _components.length,
                    inspectedCount: _inspectedIds.length,
                    title: 'Vitrine de Componentes',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Faixa de Título com Alto Contraste
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: scale.spacing(14, min: 10, max: 20),
                            vertical: scale.spacing(6, min: 4, max: 10),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _usePhysicalStyle
                                  ? const Color(0xFF0284C7).withValues(alpha: 0.5)
                                  : const Color(0xFF00E5FF).withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            _usePhysicalStyle
                                ? 'Vitrine Realista dos Componentes — Toque em um item para inspecionar'
                                : 'Diagrama Esquemático Universal (Norma IEC/ABNT) — Toque para inspecionar',
                            style: GoogleFonts.rajdhani(
                              color: _usePhysicalStyle
                                  ? Colors.white
                                  : const Color(0xFF00E5FF),
                              fontWeight: FontWeight.bold,
                              fontSize: scale.font(14.5, min: 12.5, max: 18),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Grade de Componentes
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount =
                                  constraints.maxWidth >= 700 ? 4 : 2;
                              final spacing = scale.spacing(12, min: 8, max: 18);

                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: _components.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                  childAspectRatio: 1.05,
                                ),
                                itemBuilder: (context, index) {
                                  final comp = _components[index];
                                  final isSelected = index == _selectedIndex;

                                  return FirstStepsComponentTile(
                                    component: comp,
                                    isSelected: isSelected,
                                    usePhysicalStyle: _usePhysicalStyle,
                                    onTap: () => _selectComponent(index),
                                    onToggleActive: () =>
                                        _toggleComponentActive(index),
                                  );
                                },
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
            teamTitle: 'Guia de Componentes',
            showTeamHeader: false,
            buttonColor: const Color(0xFF059669),
            buttonLabel: 'AVANÇAR PARA TERMINAIS ➔',
            toolboxItems: [
              WorkbenchMissionObjectiveCard(
                missionNumber: 1,
                title: 'Catálogo de Componentes',
                description:
                    'Explore os 8 componentes essenciais da eletricidade. Alterne entre os modos Físico e Esquemático no topo da bancada.',
                voltsTip:
                    'Observe bem os símbolos esquemáticos! Eles são a linguagem universal usada por engenheiros e técnicos para projetar qualquer circuito.',
              ),
              const SizedBox(height: 12),
              FirstStepsComponentDetailCard(
                component: selectedComp,
                usePhysicalStyle: _usePhysicalStyle,
                onToggleState: selectedComp.supportsStateToggle
                    ? () => _toggleComponentActive(_selectedIndex)
                    : null,
              ),
            ],
            onEnergizePressed: _onCompleteShowcase,
            isLoading: false,
          ),
        ),
      ],
    );
  }
}
