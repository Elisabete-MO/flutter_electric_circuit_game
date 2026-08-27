import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/first_step_component.dart';
import '../../../models/sandbox_component.dart';
import '../../../models/sandbox_state.dart';
import '../../../models/sandbox_wire.dart';
import '../../../widgets/glass_container.dart';

class SandboxChallengesDialog extends StatefulWidget {
  final SandboxState currentState;
  final bool isEn;
  final bool isDark;
  final Function(List<SandboxComponent> components, List<SandboxWire> wires) onLoadCircuit;

  const SandboxChallengesDialog({
    super.key,
    required this.currentState,
    required this.isEn,
    required this.isDark,
    required this.onLoadCircuit,
  });

  @override
  State<SandboxChallengesDialog> createState() => _SandboxChallengesDialogState();
}

class _SandboxChallengesDialogState extends State<SandboxChallengesDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _importController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _importController.dispose();
    super.dispose();
  }

  void _loadPreset(int index) {
    List<SandboxComponent> components = [];
    List<SandboxWire> wires = [];

    if (index == 0) {
      // Desafio 1: O LED Misterioso
      components = [
        SandboxComponent(id: 'c_bat', type: ComponentType.battery, gridX: 2, gridY: 2, value: 9.0),
        SandboxComponent(id: 'c_led', type: ComponentType.led, gridX: 6, gridY: 2, value: 2.0),
        SandboxComponent(id: 'c_sw', type: ComponentType.switchComponent, gridX: 4, gridY: 4, isActive: false),
      ];
      wires = [
        const SandboxWire(id: 'w1', fromComponentId: 'c_bat', fromTerminal: 'B', toComponentId: 'c_led', toTerminal: 'A'),
        const SandboxWire(id: 'w2', fromComponentId: 'c_led', fromTerminal: 'B', toComponentId: 'c_sw', toTerminal: 'A'),
        const SandboxWire(id: 'w3', fromComponentId: 'c_sw', fromTerminal: 'B', toComponentId: 'c_bat', toTerminal: 'A'),
      ];
    } else if (index == 1) {
      // Desafio 2: Proteção de Fusível
      components = [
        SandboxComponent(id: 'c_ps', type: ComponentType.powerSupply, gridX: 2, gridY: 2, value: 24.0),
        SandboxComponent(id: 'c_pot', type: ComponentType.potentiometer, gridX: 5, gridY: 2, value: 1.0),
        SandboxComponent(id: 'c_fuse', type: ComponentType.fuse, gridX: 8, gridY: 2, value: 2.0),
        SandboxComponent(id: 'c_mot', type: ComponentType.motor, gridX: 5, gridY: 5, value: 15.0),
      ];
      wires = [
        const SandboxWire(id: 'w1', fromComponentId: 'c_ps', fromTerminal: 'B', toComponentId: 'c_pot', toTerminal: 'A'),
        const SandboxWire(id: 'w2', fromComponentId: 'c_pot', fromTerminal: 'B', toComponentId: 'c_fuse', toTerminal: 'A'),
        const SandboxWire(id: 'w3', fromComponentId: 'c_fuse', fromTerminal: 'B', toComponentId: 'c_mot', toTerminal: 'A'),
        const SandboxWire(id: 'w4', fromComponentId: 'c_mot', fromTerminal: 'B', toComponentId: 'c_ps', toTerminal: 'A'),
      ];
    } else if (index == 2) {
      // Desafio 3: O Curto Misterioso
      components = [
        SandboxComponent(id: 'c_bat', type: ComponentType.battery, gridX: 2, gridY: 3, value: 9.0),
        SandboxComponent(id: 'c_bulb', type: ComponentType.bulb, gridX: 6, gridY: 3, value: 5.0),
      ];
      wires = [
        const SandboxWire(id: 'w1', fromComponentId: 'c_bat', fromTerminal: 'B', toComponentId: 'c_bulb', toTerminal: 'A'),
        const SandboxWire(id: 'w2', fromComponentId: 'c_bulb', fromTerminal: 'B', toComponentId: 'c_bat', toTerminal: 'A'),
        const SandboxWire(id: 'w_short', fromComponentId: 'c_bat', fromTerminal: 'B', toComponentId: 'c_bat', toTerminal: 'A'), // Fio em curto
      ];
    }

    widget.onLoadCircuit(components, wires);
    Navigator.of(context).pop();
  }

  String _exportCurrentCircuit() {
    final Map<String, dynamic> data = {
      'components': widget.currentState.components.map((c) => {
        'id': c.id,
        'type': c.type.name,
        'gridX': c.gridX,
        'gridY': c.gridY,
        'value': c.value,
        'isActive': c.isActive,
      }).toList(),
      'wires': widget.currentState.wires.map((w) => {
        'id': w.id,
        'fromComponentId': w.fromComponentId,
        'fromTerminal': w.fromTerminal,
        'toComponentId': w.toComponentId,
        'toTerminal': w.toTerminal,
      }).toList(),
    };
    return base64Encode(utf8.encode(jsonEncode(data)));
  }

  void _importCircuit(String code) {
    try {
      final decodedJson = utf8.decode(base64Decode(code.trim()));
      final Map<String, dynamic> data = jsonDecode(decodedJson);

      final List<SandboxComponent> components = (data['components'] as List).map((item) {
        return SandboxComponent(
          id: item['id'],
          type: ComponentType.values.firstWhere((e) => e.name == item['type']),
          gridX: item['gridX'],
          gridY: item['gridY'],
          value: (item['value'] as num).toDouble(),
          isActive: item['isActive'] ?? false,
        );
      }).toList();

      final List<SandboxWire> wires = (data['wires'] as List).map((item) {
        return SandboxWire(
          id: item['id'],
          fromComponentId: item['fromComponentId'],
          fromTerminal: item['fromTerminal'],
          toComponentId: item['toComponentId'],
          toTerminal: item['toTerminal'],
        );
      }).toList();

      widget.onLoadCircuit(components, wires);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEn ? 'Circuit imported successfully!' : 'Circuito carregado com sucesso!'),
          backgroundColor: const Color(0xFF00FF9D),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEn ? 'Invalid circuit code!' : 'Código de circuito inválido!'),
          backgroundColor: const Color(0xFFFF3B7F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: GlassContainer(
        borderRadius: 20,
        opacity: widget.isDark ? 0.85 : 0.95,
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 620),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                    ),
                    child: const Icon(Icons.psychology_rounded, color: Color(0xFFFFB300), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEn ? 'TROUBLESHOOTING & CIRCUIT SHARING' : 'DESAFIOS DE DIAGNÓSTICO & UGC',
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? const Color(0xFFFFB300) : Colors.black87,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          widget.isEn ? 'Solve faulty circuits or share yours' : 'Encontre defeitos ou compartilhe circuitos',
                          style: TextStyle(fontSize: 11, color: widget.isDark ? Colors.grey[400] : Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Abas
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFFFB300),
                labelColor: const Color(0xFFFFB300),
                unselectedLabelColor: widget.isDark ? Colors.grey[400] : Colors.grey[700],
                tabs: [
                  Tab(text: widget.isEn ? 'Troubleshooting Presets' : 'Desafios Prontos'),
                  Tab(text: widget.isEn ? 'Import / Export Code' : 'Importar / Exportar'),
                ],
              ),
              const SizedBox(height: 16),

              // Conteúdo das Abas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Aba 1: Presets
                    ListView(
                      children: [
                        _buildPresetCard(
                          0,
                          widget.isEn ? 'Preset 1: The Mysterious LED' : 'Desafio 1: O LED Misterioso',
                          widget.isEn ? 'The LED is connected to a 9V battery without resistor. Fix it before turning simulation ON!' : 'O LED está ligado a uma bateria 9V sem resistor. Corrija o circuito antes de queimar o LED!',
                          Icons.lightbulb_rounded,
                        ),
                        const SizedBox(height: 10),
                        _buildPresetCard(
                          1,
                          widget.isEn ? 'Preset 2: Fuse Protection' : 'Desafio 2: Proteção de Fusível',
                          widget.isEn ? 'Adjust the potentiometer knob so the motor spins safely without blowing the 2A fuse.' : 'Ajuste o potenciômetro para o motor girar sem acionar o disjuntor do fusível de 2A.',
                          Icons.shield_rounded,
                        ),
                        const SizedBox(height: 10),
                        _buildPresetCard(
                          2,
                          widget.isEn ? 'Preset 3: The Short Circuit Bug' : 'Desafio 3: O Curto Misterioso',
                          widget.isEn ? 'The power supply trips due to a hidden short circuit wire. Find and delete it!' : 'A fonte está desarmando por curto-circuito. Use o inspetor e elimine o fio em curto.',
                          Icons.flash_off_rounded,
                        ),
                      ],
                    ),

                    // Aba 2: Import / Export
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.isEn ? 'Export Current Circuit:' : 'Exportar Circuito Atual:',
                            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: () {
                              final code = _exportCurrentCircuit();
                              Clipboard.setData(ClipboardData(text: code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(widget.isEn ? 'Circuit code copied to clipboard!' : 'Código do circuito copiado!'),
                                  backgroundColor: const Color(0xFF00F5D4),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: Text(widget.isEn ? 'Copy Circuit Code' : 'Copiar Código do Circuito'),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            widget.isEn ? 'Import Circuit from Code:' : 'Importar Circuito via Código:',
                            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _importController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: widget.isEn ? 'Paste circuit code here...' : 'Cole o código do circuito aqui...',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.all(10),
                            ),
                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: () {
                              _importCircuit(_importController.text);
                            },
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: Text(widget.isEn ? 'Load Circuit' : 'Carregar Circuito'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB300),
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetCard(int index, String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.isDark ? Colors.white24 : Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFB300), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 11, color: widget.isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _loadPreset(index),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB300),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            child: Text(widget.isEn ? 'START' : 'INICIAR', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
