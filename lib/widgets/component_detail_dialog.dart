import 'package:flutter/material.dart';

import '../core/ui_scale.dart';
import '../l10n/app_localizations.dart';
import '../models/first_step_component.dart';
import 'circuit_symbol_painter.dart';
import 'component_physical_painter.dart';

/// Modal dialog com detalhes explicativos do componente selecionado.
class ComponentDetailDialog extends StatefulWidget {
  const ComponentDetailDialog({
    super.key,
    required this.initialComponent,
    this.useRealisticAssets = false,
  });

  final FirstStepComponent initialComponent;
  final bool useRealisticAssets;

  @override
  State<ComponentDetailDialog> createState() => _ComponentDetailDialogState();
}

class _ComponentDetailDialogState extends State<ComponentDetailDialog> {
  late FirstStepComponent _component;

  @override
  void initState() {
    super.initState();
    _component = widget.initialComponent;
  }

  void _toggleState() {
    if (_component.supportsStateToggle) {
      setState(() {
        _component = _component.copyWith(isActive: !_component.isActive);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isEn = l10n.localeName == 'en';
    final scale = context.uiScale;

    final displayName = isEn ? _component.nameEn : _component.namePt;
    final subtitleName = isEn ? _component.namePt : _component.nameEn;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(scale.size(24))),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: scale.dialogWidth(500)),
        child: SingleChildScrollView(
          child: Padding(
            padding: scale.insetsAll(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header com título e botão fechar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: scale.font(22),
                            ),
                          ),
                          if (subtitleName.isNotEmpty && subtitleName != displayName)
                            Text(
                              subtitleName,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: scale.font(12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: scale.icon(22)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: scale.spacing(20)),

                // Visualização comparativa lado a lado (Físico vs. Esquemático)
                Container(
                  height: scale.size(150),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2638)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(scale.size(16)),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Lado 1: Físico
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.compPhysical,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                                fontSize: scale.font(11),
                              ),
                            ),
                            SizedBox(height: scale.spacing(8)),
                            SizedBox(
                              height: scale.size(80),
                              child: widget.useRealisticAssets &&
                                      _component.type.getAssetPath(_component.isActive) != null
                                  ? Image.asset(
                                      _component.type.getAssetPath(_component.isActive)!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => CustomPaint(
                                        painter: ComponentPhysicalPainter(
                                          type: _component.type,
                                          isActive: _component.isActive,
                                          isDarkMode: isDark,
                                        ),
                                        child: const SizedBox.expand(),
                                      ),
                                    )
                                  : CustomPaint(
                                      painter: ComponentPhysicalPainter(
                                        type: _component.type,
                                        isActive: _component.isActive,
                                        isDarkMode: isDark,
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      ),
                      // Lado 2: Símbolo Esquemático
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.compSchematic,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.tertiary,
                                fontSize: scale.font(11),
                              ),
                            ),
                            SizedBox(height: scale.spacing(8)),
                            SizedBox(
                              height: scale.size(80),
                              child: CustomPaint(
                                painter: CircuitSymbolPainter(
                                  type: _component.type,
                                  isActive: _component.isActive,
                                  color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black87,
                                  activeColor: const Color(0xFFFFB300),
                                  strokeWidth: 2.5,
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scale.spacing(20)),

                // Descrição pedagógica
                Text(
                  l10n.compFunction,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: scale.font(14),
                  ),
                ),
                SizedBox(height: scale.spacing(4)),
                Text(
                  _component.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: scale.font(13.5),
                  ),
                ),
                SizedBox(height: scale.spacing(16)),

                Text(
                  l10n.compSymbolMeaning,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: scale.font(14),
                  ),
                ),
                SizedBox(height: scale.spacing(4)),
                Text(
                  _component.symbolDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: scale.font(13.5),
                  ),
                ),
                SizedBox(height: scale.spacing(24)),

                // Ação de Testar Estado / Fechar
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: scale.spacing(12),
                  runSpacing: scale.spacing(12),
                  children: [
                    if (_component.supportsStateToggle)
                      OutlinedButton.icon(
                        onPressed: _toggleState,
                        icon: Icon(
                          _component.isActive
                              ? Icons.power_rounded
                              : Icons.power_off_rounded,
                          size: scale.icon(18),
                        ),
                        label: Text(
                          _component.isActive
                              ? l10n.compDeactivateState
                              : l10n.compActivateState,
                          style: TextStyle(fontSize: scale.font(13)),
                        ),
                      ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.compUnderstood,
                        style: TextStyle(fontSize: scale.font(13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
