import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/first_step_component.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/prof_volts_speech.dart';
import '../../widgets/prof_volts_feedback_dialog.dart';
import '../../widgets/symbol_card.dart';

/// Fase 3: Associação de componentes físicos a símbolos esquemáticos com distratores.
class FirstBenchPhase3 extends StatefulWidget {
  final VoidCallback onPhaseComplete;

  const FirstBenchPhase3({
    super.key,
    required this.onPhaseComplete,
  });

  @override
  State<FirstBenchPhase3> createState() => _FirstBenchPhase3State();
}

class _FirstBenchPhase3State extends State<FirstBenchPhase3> {
  bool _isDiagramMode = false;

  // Slots do circuito físico: Bateria, Interruptor, Resistor, LED
  final Map<String, ComponentType?> _slots = {
    'slot_battery': null,
    'slot_switch': null,
    'slot_resistor': null,
    'slot_led': null,
  };

  // 4 símbolos corretos + 2 distratores (Lâmpada, Diodo)
  late List<FirstStepComponent> _availableSymbols;

  @override
  void initState() {
    super.initState();
    _initSymbols();
  }

  void _initSymbols() {
    final list = [
      FirstStepComponent.defaultList.firstWhere((c) => c.type == ComponentType.battery),
      FirstStepComponent.defaultList.firstWhere((c) => c.type == ComponentType.switchComponent),
      FirstStepComponent.defaultList.firstWhere((c) => c.type == ComponentType.resistor),
      FirstStepComponent.defaultList.firstWhere((c) => c.type == ComponentType.led),
      FirstStepComponent.defaultList.firstWhere((c) => c.type == ComponentType.bulb), // Distrator 1
      FirstStepComponent.defaultList.firstWhere((c) => c.type == ComponentType.diode), // Distrator 2
    ];
    list.shuffle();
    _availableSymbols = list;
  }

  void _onAssignSymbolToSlot(String slotKey, ComponentType type) {
    setState(() {
      _slots[slotKey] = type;
    });
  }

  void _onRemoveSymbolFromSlot(String slotKey) {
    setState(() {
      _slots[slotKey] = null;
    });
  }

  void _checkSolution() {
    final isBatteryCorrect = _slots['slot_battery'] == ComponentType.battery;
    final isSwitchCorrect = _slots['slot_switch'] == ComponentType.switchComponent;
    final isResistorCorrect = _slots['slot_resistor'] == ComponentType.resistor;
    final isLedCorrect = _slots['slot_led'] == ComponentType.led;

    final isAllCorrect = isBatteryCorrect && isSwitchCorrect && isResistorCorrect && isLedCorrect;

    String feedback;
    if (isAllCorrect) {
      feedback =
          'Excelente! Todos os 4 símbolos foram associados corretamente aos seus componentes físicos e polaridades!';
    } else {
      final errors = <String>[];
      if (!isBatteryCorrect) errors.add('Fonte/Bateria');
      if (!isSwitchCorrect) errors.add('Interruptor');
      if (!isResistorCorrect) errors.add('Resistor');
      if (!isLedCorrect) errors.add('LED');

      feedback =
          'Atenção! Os seguintes pontos precisam de correção: ${errors.join(", ")}. Verifique se não utilizou lâmpada ou diodo comum por engano!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfVoltsFeedbackDialog(
        isCorrect: isAllCorrect,
        message: feedback,
        onAction: () {
          Navigator.of(context).pop();
          if (isAllCorrect) {
            widget.onPhaseComplete();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAllFilled = _slots.values.every((val) => val != null);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balão Orientativo Prof. Volts
              const ProfVoltsSpeech(
                text: 'FASE 3: Associe cada componente físico ao seu símbolo esquemático correto! Cuidado com os símbolos distratores.',
              ),
              const SizedBox(height: 16),

              // Alternador entre Modo Físico e Modo Esquemático
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bancada de Mapeamento',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00FF9D),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isDiagramMode = !_isDiagramMode;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00FF9D)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isDiagramMode ? Icons.schema_rounded : Icons.view_in_ar_rounded,
                            size: 18,
                            color: const Color(0xFF00FF9D),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isDiagramMode ? 'Modo Diagrama' : 'Modo Físico',
                            style: TextStyle(
                              fontFamily: GoogleFonts.rajdhani().fontFamily,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00FF9D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Área de Encaixe dos 4 Slots do Circuito
              GlassContainer(
                borderRadius: 20,
                accentColor: const Color(0xFF00FF9D),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSlot('slot_battery', 'Bateria (+)'),
                        _buildSlot('slot_switch', 'Interruptor'),
                        _buildSlot('slot_resistor', 'Resistor'),
                        _buildSlot('slot_led', 'LED (-)'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isAllFilled ? _checkSolution : null,
                        icon: const Icon(Icons.verified_rounded),
                        label: Text(
                          'VERIFICAR ASSOCIAÇÕES',
                          style: TextStyle(
                            fontFamily: GoogleFonts.rajdhani().fontFamily,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF9D),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Catálogo de Símbolos Embaralhados
              Text(
                'Símbolos Disponíveis (Toque ou Arraste para o Slot desejado):',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableSymbols.map((symbol) {
                  final isAssigned = _slots.containsValue(symbol.type);

                  return SizedBox(
                    width: 140,
                    height: 160,
                    child: Opacity(
                      opacity: isAssigned ? 0.4 : 1.0,
                      child: SymbolCard(
                        component: symbol,
                        showLabels: true,
                        useRealisticAssets: !_isDiagramMode,
                        onTap: isAssigned
                            ? null
                            : () {
                                _showAssignDialog(symbol);
                              },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(String slotKey, String title) {
    final assignedType = _slots[slotKey];
    final hasItem = assignedType != null;

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: GoogleFonts.rajdhani().fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        DragTarget<ComponentType>(
          onAcceptWithDetails: (details) {
            _onAssignSymbolToSlot(slotKey, details.data);
          },
          builder: (context, candidateData, rejectedData) {
            return InkWell(
              onTap: hasItem ? () => _onRemoveSymbolFromSlot(slotKey) : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty
                      ? const Color(0xFF00FF9D).withValues(alpha: 0.2)
                      : (hasItem ? const Color(0xFF0F172A) : const Color(0xFF091322)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasItem ? const Color(0xFF00FF9D) : const Color(0xFF334155),
                    width: hasItem ? 2.0 : 1.0,
                  ),
                ),
                child: hasItem
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getIconForType(assignedType),
                            color: const Color(0xFF00FF9D),
                            size: 36,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getNameForType(assignedType),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Toque p/ remover',
                            style: TextStyle(fontSize: 9, color: Colors.white38),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline_rounded, color: Colors.white38, size: 28),
                          SizedBox(height: 4),
                          Text(
                            'Slot Vazio',
                            style: TextStyle(fontSize: 11, color: Colors.white38),
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAssignDialog(FirstStepComponent symbol) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Associar Símbolo (${symbol.namePt}) a um Slot:',
                style: TextStyle(
                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.battery_charging_full_rounded, color: Colors.amber),
                title: const Text('Slot Bateria', style: TextStyle(color: Colors.white)),
                onTap: () {
                  _onAssignSymbolToSlot('slot_battery', symbol.type);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.toggle_on_rounded, color: Colors.green),
                title: const Text('Slot Interruptor', style: TextStyle(color: Colors.white)),
                onTap: () {
                  _onAssignSymbolToSlot('slot_switch', symbol.type);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.align_horizontal_center_rounded, color: Colors.blueAccent),
                title: const Text('Slot Resistor', style: TextStyle(color: Colors.white)),
                onTap: () {
                  _onAssignSymbolToSlot('slot_resistor', symbol.type);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lightbulb_outline_rounded, color: Colors.amberAccent),
                title: const Text('Slot LED', style: TextStyle(color: Colors.white)),
                onTap: () {
                  _onAssignSymbolToSlot('slot_led', symbol.type);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForType(ComponentType type) {
    return switch (type) {
      ComponentType.battery => Icons.battery_charging_full_rounded,
      ComponentType.switchComponent => Icons.toggle_on_rounded,
      ComponentType.resistor => Icons.align_horizontal_center_rounded,
      ComponentType.led => Icons.lightbulb_outline_rounded,
      ComponentType.bulb => Icons.lightbulb_rounded,
      ComponentType.diode => Icons.arrow_forward_rounded,
      _ => Icons.widgets_rounded,
    };
  }

  String _getNameForType(ComponentType type) {
    return switch (type) {
      ComponentType.battery => 'Bateria',
      ComponentType.switchComponent => 'Interruptor',
      ComponentType.resistor => 'Resistor',
      ComponentType.led => 'LED',
      ComponentType.bulb => 'Lâmpada',
      ComponentType.diode => 'Diodo',
      _ => 'Outro',
    };
  }
}
