import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/sandbox_state.dart';
import '../../../widgets/glass_container.dart';
import '../utils/sandbox_smart_inspector.dart';

class SandboxInspectorDialog extends StatelessWidget {
  final SandboxState state;
  final bool isEn;
  final bool isDark;
  final Function(String componentId)? onSelectComponent;

  const SandboxInspectorDialog({
    super.key,
    required this.state,
    required this.isEn,
    required this.isDark,
    this.onSelectComponent,
  });

  @override
  Widget build(BuildContext context) {
    final issues = SandboxSmartInspector.analyzeCircuit(state);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: GlassContainer(
        borderRadius: 20,
        opacity: isDark ? 0.85 : 0.95,
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
                      color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00F5D4), width: 1.5),
                    ),
                    child: const Icon(Icons.saved_search_rounded, color: Color(0xFF00F5D4), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'PROF. VOLTS SMART INSPECTOR' : 'INSPETOR INTELIGENTE PROF. VOLTS',
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF00F5D4) : Colors.black87,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          isEn ? 'Real-time Circuit Diagnostics' : 'Diagnóstico de Falhas em Tempo Real',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
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

              const Divider(height: 1, color: Colors.white24),
              const SizedBox(height: 16),

              // Lista de Diagnósticos
              Expanded(
                child: ListView.separated(
                  itemCount: issues.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    return _buildIssueCard(context, issue);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Botão Fechar
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00F5D4),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isEn ? 'CLOSE INSPECTOR' : 'FECHAR INSPETOR',
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueCard(BuildContext context, CircuitDiagnosticIssue issue) {
    Color cardColor;
    Color borderColor;
    IconData iconData;

    switch (issue.severity) {
      case DiagnosticSeverity.critical:
        cardColor = const Color(0xFFFF3B7F).withValues(alpha: 0.12);
        borderColor = const Color(0xFFFF3B7F);
        iconData = Icons.dangerous_rounded;
        break;
      case DiagnosticSeverity.warning:
        cardColor = const Color(0xFFFFB300).withValues(alpha: 0.12);
        borderColor = const Color(0xFFFFB300);
        iconData = Icons.warning_amber_rounded;
        break;
      case DiagnosticSeverity.info:
        cardColor = const Color(0xFF29B6F6).withValues(alpha: 0.12);
        borderColor = const Color(0xFF29B6F6);
        iconData = Icons.info_outline_rounded;
        break;
      case DiagnosticSeverity.success:
        cardColor = const Color(0xFF00FF9D).withValues(alpha: 0.12);
        borderColor = const Color(0xFF00FF9D);
        iconData = Icons.check_circle_outline_rounded;
        break;
    }

    final title = isEn ? issue.titleEn : issue.titlePt;
    final description = isEn ? issue.descriptionEn : issue.descriptionPt;
    final recommendation = isEn ? issue.recommendationEn : issue.recommendationPt;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: borderColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                  ),
                ),
                if (recommendation != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black38 : Colors.white70,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, size: 14, color: Color(0xFFFFD54F)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            recommendation,
                            style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (issue.componentId != null && onSelectComponent != null) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: isEn ? 'Select Component' : 'Selecionar Componente',
              icon: const Icon(Icons.my_location_rounded, size: 18, color: Color(0xFF00F5D4)),
              onPressed: () {
                onSelectComponent!(issue.componentId!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}
