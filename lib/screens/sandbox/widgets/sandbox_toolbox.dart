import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui_scale.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/first_step_component.dart';
import '../../../models/sandbox_component.dart';
import '../../../widgets/component_physical_painter.dart';
import '../../../widgets/circuit_symbol_painter.dart';

/// Card Lateral Branco Padronizado da Bancada Livre com Categorias e Modelos Low-Poly 3D
class SandboxToolboxWidget extends StatefulWidget {
  final bool isHorizontal;
  final bool isDark;
  final bool isDiagramMode;
  final String Function(ComponentType, AppLocalizations) getComponentName;

  const SandboxToolboxWidget({
    super.key,
    this.isHorizontal = false,
    required this.isDark,
    required this.isDiagramMode,
    required this.getComponentName,
  });

  @override
  State<SandboxToolboxWidget> createState() => _SandboxToolboxWidgetState();
}

class _SandboxToolboxWidgetState extends State<SandboxToolboxWidget> {
  SandboxCategory? _selectedCategory; // null = Todas as categorias

  List<SandboxPaletteItem> get _filteredItems {
    if (_selectedCategory == null) return allSandboxPaletteItems;
    return allSandboxPaletteItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scale = context.uiScale;

    // Card Branco com acabamento dos estandes da Feira
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: scale.size(12, min: 8, max: 20),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Cabeçalho do Card Lateral
          Container(
            padding: scale.insetsSymmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: const Icon(
                    Icons.category_rounded,
                    color: Color(0xFF059669),
                    size: 16,
                  ),
                ),
                SizedBox(width: scale.spacing(8)),
                Expanded(
                  child: Text(
                    'PALETA DE COMPONENTES',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.w800,
                      fontSize: scale.font(14, min: 12, max: 18),
                      letterSpacing: 0.8,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_filteredItems.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Barra de Categorias (Filtros com ícones)
          Container(
            height: scale.size(38, min: 32, max: 44),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('Todos', null, Icons.apps_rounded, scale),
                _buildCategoryChip('Fontes', SandboxCategory.sources, Icons.bolt_rounded, scale),
                _buildCategoryChip('Cargas', SandboxCategory.loads, Icons.lightbulb_rounded, scale),
                _buildCategoryChip('Chaves', SandboxCategory.switches, Icons.toggle_on_rounded, scale),
                _buildCategoryChip('Passivos', SandboxCategory.passives, Icons.shield_rounded, scale),
                _buildCategoryChip('Sensores', SandboxCategory.sensors, Icons.sensors_rounded, scale),
                _buildCategoryChip('Ferramentas', SandboxCategory.tools, Icons.build_rounded, scale),
              ],
            ),
          ),

          // 3. Grid de Componentes Arrastáveis
          Expanded(
            child: Padding(
              padding: scale.insetsAll(8),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.isHorizontal ? 4 : 2,
                  crossAxisSpacing: scale.spacing(6, min: 4, max: 10),
                  mainAxisSpacing: scale.spacing(6, min: 4, max: 10),
                  childAspectRatio: 0.95,
                ),
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return _buildToolboxItem(context, item, l10n);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    SandboxCategory? category,
    IconData icon,
    UiScale scale,
  ) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF047857) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? const Color(0xFF047857) : const Color(0xFFCBD5E1),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolboxItem(
    BuildContext context,
    SandboxPaletteItem item,
    AppLocalizations l10n,
  ) {
    final type = item.type;
    final scale = context.uiScale;
    final assetPath = type.getLowPolyAssetPath(false) ?? item.iconAsset;

    Widget cardContent = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Miniatura do Componente (Low-Poly ou Símbolo)
          Expanded(
            child: Center(
              child: widget.isDiagramMode
                  ? CustomPaint(
                      size: const Size(40, 40),
                      painter: CircuitSymbolPainter(
                        type: type,
                        isActive: false,
                        color: const Color(0xFF0F172A),
                        activeColor: const Color(0xFF059669),
                        strokeWidth: 2.0,
                      ),
                    )
                  : Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => CustomPaint(
                        size: const Size(36, 36),
                        painter: ComponentPhysicalPainter(
                          type: type,
                          isActive: false,
                          isDarkMode: false,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          // Nome do Componente
          Text(
            item.name,
            style: GoogleFonts.outfit(
              fontSize: scale.font(10.5, min: 9.0, max: 13.0),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return Draggable<ComponentType>(
      data: type,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: scale.size(70, min: 55, max: 90),
          height: scale.size(70, min: 55, max: 90),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.bolt,
              color: Color(0xFF10B981),
              size: 40,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: cardContent,
      ),
      child: Tooltip(
        message: '${item.name}\n${item.description}',
        waitDuration: const Duration(milliseconds: 400),
        child: cardContent,
      ),
    );
  }
}
