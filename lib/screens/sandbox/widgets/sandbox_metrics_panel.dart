import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/first_step_component.dart';
import '../../../models/sandbox_component.dart';
import '../../../models/sandbox_wire.dart';
import '../../../state/sandbox_controller.dart';
import '../../../widgets/glass_container.dart';

class SandboxMetricsPanelWidget extends ConsumerWidget {
  final SandboxComponent component;
  final List<SandboxWire> wires;
  final List<SandboxComponent> allComponents;
  final bool isEn;
  final bool isDark;
  final String Function(ComponentType, AppLocalizations) getComponentName;
  final VoidCallback onDeselect;

  const SandboxMetricsPanelWidget({
    super.key,
    required this.component,
    required this.wires,
    required this.allComponents,
    required this.isEn,
    required this.isDark,
    required this.getComponentName,
    required this.onDeselect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sandboxState = ref.watch(sandboxControllerProvider);
    final controller = ref.read(sandboxControllerProvider.notifier);
    final isSwitch = component.type == ComponentType.switchComponent;
    final hasValueSlider = component.type == ComponentType.battery || component.type == ComponentType.resistor;

    final connectedWires = wires.where((w) {
      return w.fromComponentId == component.id || w.toComponentId == component.id;
    }).toList();

    String getWireDescription(SandboxWire wire) {
      final isFromMe = wire.fromComponentId == component.id;
      final myTerm = isFromMe ? wire.fromTerminal : wire.toTerminal;
      final otherId = isFromMe ? wire.toComponentId : wire.fromComponentId;
      final otherTerm = isFromMe ? wire.toTerminal : wire.fromTerminal;

      final otherCompList = allComponents.where((c) => c.id == otherId).toList();
      if (otherCompList.isEmpty) return 'Terminal $myTerm';
      final otherComp = otherCompList.first;

      String compName = '';
      if (isEn) {
        if (otherComp.type == ComponentType.battery) compName = 'Battery';
        if (otherComp.type == ComponentType.resistor) compName = 'Resistor';
        if (otherComp.type == ComponentType.bulb) compName = 'Bulb';
        if (otherComp.type == ComponentType.switchComponent) compName = 'Switch';
        if (otherComp.type == ComponentType.motor) compName = 'Motor';
        if (otherComp.type == ComponentType.led) compName = 'LED';
        if (otherComp.type == ComponentType.diode) compName = 'Diode';
      } else {
        if (otherComp.type == ComponentType.battery) compName = 'Bateria';
        if (otherComp.type == ComponentType.resistor) compName = 'Resistor';
        if (otherComp.type == ComponentType.bulb) compName = 'Lâmpada';
        if (otherComp.type == ComponentType.switchComponent) compName = 'Interruptor';
        if (otherComp.type == ComponentType.motor) compName = 'Motor';
        if (otherComp.type == ComponentType.led) compName = 'LED';
        if (otherComp.type == ComponentType.diode) compName = 'Diodo';
      }

      return 'Term. $myTerm ↔ $compName ($otherTerm)';
    }

    String valueLabel = '';
    String unit = '';
    double minVal = 1.0;
    double maxVal = 100.0;
    if (component.type == ComponentType.battery) {
      valueLabel = isEn ? 'Voltage' : 'Tensão';
      unit = 'V';
      minVal = 1.5;
      maxVal = 24.0;
    } else if (component.type == ComponentType.resistor) {
      valueLabel = isEn ? 'Resistance' : 'Resistência';
      unit = 'Ω';
      minVal = 1.0;
      maxVal = 100.0;
    }

    return GlassContainer(
      borderRadius: 16,
      opacity: isDark ? 0.35 : 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título do Componente
          Text(
            getComponentName(component.type, AppLocalizations.of(context)!).toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? const Color(0xFF00F5D4) : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Se for interruptor, controle liga/desliga
          if (isSwitch) ...[
            Text(
              isEn ? 'Switch State:' : 'Estado do interruptor:',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              onPressed: () {
                controller.toggleComponentActive(component.id);
              },
              icon: Icon(component.isActive ? Icons.power_rounded : Icons.power_off_rounded, size: 16),
              label: Text(component.isActive ? (isEn ? 'OPENED' : 'ABERTO') : (isEn ? 'CLOSED' : 'FECHADO')),
              style: ElevatedButton.styleFrom(
                backgroundColor: component.isActive
                    ? const Color(0xFF00FF9D).withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
                foregroundColor: component.isActive ? const Color(0xFF00FF9D) : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Slider de Valor (Battery / Resistor)
          if (hasValueSlider) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  valueLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${component.value.toStringAsFixed(1)}$unit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF00F5D4) : Colors.black87,
                  ),
                ),
              ],
            ),
            Slider(
              value: component.value.clamp(minVal, maxVal),
              min: minVal,
              max: maxVal,
              divisions: maxVal > 50 ? 50 : 15,
              activeColor: const Color(0xFF00F5D4),
              onChanged: (val) {
                controller.updateComponentValue(component.id, val);
              },
            ),
            const SizedBox(height: 16),
          ],

          // Detalhes Elétricos em Tempo Real
          _buildElectricityDetails(context, ref, component, isEn, isDark),

          if (connectedWires.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              isEn ? 'Connected Wires:' : 'Fios Conectados:',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              child: SingleChildScrollView(
                child: Column(
                  children: connectedWires.map((wire) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              getWireDescription(wire),
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFFF3B7F)),
                            onPressed: () {
                              controller.removeWire(wire.id);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
          const Spacer(),

          // Botões de Ação
          if (sandboxState.burnedComponentIds.contains(component.id)) ...[
            FilledButton.icon(
              onPressed: () {
                controller.replaceBurnedComponent(component.id);
              },
              icon: const Icon(Icons.build_rounded, size: 16),
              label: Text(isEn ? 'Replace Component' : 'Substituir Componente'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00FF9D),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: () {
              controller.rotateComponent(component.id);
            },
            icon: const Icon(Icons.rotate_right_rounded, size: 16),
            label: Text(isEn ? 'Rotate 90°' : 'Rotacionar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              controller.removeComponent(component.id);
              onDeselect();
            },
            icon: const Icon(Icons.delete_forever_rounded, size: 16),
            label: Text(isEn ? 'Delete' : 'Excluir'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B7F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectricityDetails(BuildContext context, WidgetRef ref, SandboxComponent component, bool isEn, bool isDark) {
    final state = ref.watch(sandboxControllerProvider);
    if (!state.isSimulating) return Container();

    final active = state.simulationValues['active_${component.id}'] == 1.0;
    if (!active) {
      return Text(
        isEn ? 'No current flow.' : 'Sem passagem de corrente.',
        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    final current = state.simulationValues['current_${component.id}'] ?? 0.0;
    final vDrop = state.simulationValues['voltage_drop_${component.id}'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white60,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Live Metrics:' : 'Métricas Elétricas:',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            '${isEn ? 'Current:' : 'Corrente:'} ${current.toStringAsFixed(2)} A',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          if (component.type != ComponentType.battery)
            Text(
              '${isEn ? 'V Drop:' : 'Queda V:'} ${vDrop.toStringAsFixed(2)} V',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
