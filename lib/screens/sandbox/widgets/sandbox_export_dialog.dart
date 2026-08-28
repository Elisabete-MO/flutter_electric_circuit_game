import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/first_step_component.dart';
import '../../../models/sandbox_state.dart';
import '../../../widgets/glass_container.dart';

class SandboxExportDialog extends StatelessWidget {
  final SandboxState state;
  final bool isEn;
  final bool isDark;

  const SandboxExportDialog({
    super.key,
    required this.state,
    required this.isEn,
    required this.isDark,
  });

  Map<ComponentType, int> _getComponentCounts() {
    final counts = <ComponentType, int>{};
    for (final c in state.components) {
      counts[c.type] = (counts[c.type] ?? 0) + 1;
    }
    return counts;
  }

  double _calculateTotalPower() {
    double totalPower = 0.0;
    for (final c in state.components) {
      if (c.type != ComponentType.battery && c.type != ComponentType.powerSupply) {
        totalPower += state.simulationValues['power_${c.id}'] ?? 0.0;
      }
    }
    return totalPower;
  }

  double _getSystemVoltage() {
    final powerSources = state.components.where((c) => c.type == ComponentType.battery || c.type == ComponentType.powerSupply).toList();
    if (powerSources.isEmpty) return 0.0;
    return powerSources.fold(0.0, (sum, src) => sum + src.value);
  }

  String _generateMarkdownReport() {
    final buffer = StringBuffer();
    buffer.writeln('# ⚡ ${isEn ? 'EletroLab - Technical Circuit Report (BOM)' : 'EletroLab - Relatório Técnico de Laboratório (BOM)'}');
    buffer.writeln('**${isEn ? 'Date' : 'Data'}:** ${DateTime.now().toLocal().toString().split('.')[0]}');
    buffer.writeln('**${isEn ? 'Simulation Status' : 'Status da Simulação'}:** ${state.isSimulating ? (isEn ? 'ACTIVE (CLOSED LOOP)' : 'ATIVA (CIRCUITO FECHADO)') : (isEn ? 'INACTIVE' : 'INATIVA')}');
    buffer.writeln();

    buffer.writeln('## 📊 ${isEn ? 'Electrical Summary' : 'Resumo de Grandezas Elétricas'}');
    final vSys = _getSystemVoltage();
    final pTotal = _calculateTotalPower();
    buffer.writeln('- **${isEn ? 'Total Supply Voltage' : 'Tensão Total da Fonte'}:** ${vSys.toStringAsFixed(1)} V');
    buffer.writeln('- **${isEn ? 'Total Power Consumption' : 'Potência Total Consumida'}:** ${pTotal.toStringAsFixed(2)} W');
    buffer.writeln('- **${isEn ? 'Total Active Components' : 'Total de Componentes'}:** ${state.components.length}');
    buffer.writeln('- **${isEn ? 'Total Wires Connected' : 'Total de Conexões (Fios)'}:** ${state.wires.length}');
    buffer.writeln();

    buffer.writeln('## 📦 ${isEn ? 'Bill of Materials (BOM)' : 'Lista de Componentes (BOM)'}');
    buffer.writeln('| ${isEn ? 'Item' : 'Item'} | ${isEn ? 'Type' : 'Tipo'} | ${isEn ? 'Quantity' : 'Quantidade'} | ${isEn ? 'Value / Spec' : 'Valor Nominal'} | ${isEn ? 'Power Dissipated' : 'Potência Dissipada'} |');
    buffer.writeln('| :--- | :--- | :--- | :--- | :--- |');

    int index = 1;
    for (final comp in state.components) {
      final power = state.simulationValues['power_${comp.id}'] ?? 0.0;
      String spec = '${comp.value.toStringAsFixed(1)} ${_getUnit(comp.type)}';
      if (comp.type == ComponentType.switchComponent) {
        spec = comp.isActive ? (isEn ? 'CLOSED (ON)' : 'FECHADO (ON)') : (isEn ? 'OPEN (OFF)' : 'ABERTO (OFF)');
      }
      buffer.writeln('| $index | ${comp.type.name.toUpperCase()} | 1 | $spec | ${power.toStringAsFixed(2)} W |');
      index++;
    }

    return buffer.toString();
  }

  String _getUnit(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
      case ComponentType.powerSupply:
        return 'V';
      case ComponentType.resistor:
      case ComponentType.potentiometer:
        return 'Ω';
      case ComponentType.fuse:
        return 'A';
      case ComponentType.capacitor:
        return 'µF';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final counts = _getComponentCounts();
    final vSys = _getSystemVoltage();
    final pTotal = _calculateTotalPower();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: GlassContainer(
        borderRadius: 20,
        opacity: isDark ? 0.88 : 0.95,
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
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
                      color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00FF9D), width: 1.5),
                    ),
                    child: const Icon(Icons.assignment_rounded, color: Color(0xFF00FF9D), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'TECHNICAL REPORT & BOM (BILL OF MATERIALS)' : 'RELATÓRIO TÉCNICO & BOM DO CIRCUITO',
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF00FF9D) : Colors.black87,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          isEn ? 'Laboratory specification & electrical metrics summary' : 'Especificação de laboratório e resumo de métricas',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[700]),
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
              const SizedBox(height: 16),

              // Métricas Principais em Cards
              Row(
                children: [
                  _buildMetricCard(isEn ? 'SUPPLY VOLTAGE' : 'TENSÃO TOTAL', '${vSys.toStringAsFixed(1)} V', const Color(0xFF00F5D4)),
                  const SizedBox(width: 8),
                  _buildMetricCard(isEn ? 'POWER CONSUMPTION' : 'POTÊNCIA TOTAL', '${pTotal.toStringAsFixed(2)} W', const Color(0xFFFFB300)),
                  const SizedBox(width: 8),
                  _buildMetricCard(isEn ? 'COMPONENTS' : 'COMPONENTES', '${state.components.length}', const Color(0xFFFF3B7F)),
                ],
              ),
              const SizedBox(height: 16),

              const Divider(height: 1, color: Colors.white24),
              const SizedBox(height: 12),

              // Tabela de Componentes (BOM)
              Text(
                isEn ? 'BILL OF MATERIALS (BOM):' : 'LISTA DE MATERIAIS & POTÊNCIA (BOM):',
                style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                      width: 1.0,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2.5),
                      1: FlexColumnWidth(1.2),
                      2: FlexColumnWidth(2.0),
                      3: FlexColumnWidth(2.0),
                    },
                    children: [
                      // Cabeçalho da Tabela
                      TableRow(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        ),
                        children: [
                          _buildTableCell(isEn ? 'Type' : 'Tipo', isHeader: true),
                          _buildTableCell(isEn ? 'Qty' : 'Qtd', isHeader: true),
                          _buildTableCell(isEn ? 'Nominal Value' : 'Valor Nominal', isHeader: true),
                          _buildTableCell(isEn ? 'Power Dissipated' : 'Potência (W)', isHeader: true),
                        ],
                      ),
                      // Linhas dos Componentes
                      ...counts.entries.map((entry) {
                        final type = entry.key;
                        final qty = entry.value;
                        final sampleComp = state.components.firstWhere((c) => c.type == type);
                        final totalCompPower = state.components.where((c) => c.type == type).fold(0.0, (sum, c) => sum + (state.simulationValues['power_${c.id}'] ?? 0.0));

                        String spec = '${sampleComp.value.toStringAsFixed(1)} ${_getUnit(type)}';
                        if (type == ComponentType.switchComponent) {
                          spec = sampleComp.isActive ? (isEn ? 'CLOSED' : 'FECHADO') : (isEn ? 'OPEN' : 'ABERTO');
                        }

                        return TableRow(
                          children: [
                            _buildTableCell(type.name.toUpperCase()),
                            _buildTableCell('$qty'),
                            _buildTableCell(spec),
                            _buildTableCell('${totalCompPower.toStringAsFixed(2)} W'),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Ações: Copiar Relatório Markdown & Fechar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final report = _generateMarkdownReport();
                        Clipboard.setData(ClipboardData(text: report));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEn ? 'Report copied to clipboard in Markdown format!' : 'Relatório copiado em formato Markdown!'),
                            backgroundColor: const Color(0xFF00FF9D),
                          ),
                        );
                      },
                      icon: const Icon(Icons.content_copy_rounded, size: 18),
                      label: Text(isEn ? 'COPY MARKDOWN REPORT' : 'COPIAR RELATÓRIO MARKDOWN'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: const Color(0xFF00FF9D),
                        side: const BorderSide(color: Color(0xFF00FF9D)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? Colors.white24 : Colors.grey[300],
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(isEn ? 'CLOSE' : 'FECHAR'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.2),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.rajdhani(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.shareTechMono(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.rajdhani(
          fontSize: isHeader ? 11 : 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isDark ? Colors.white : Colors.black87,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}
