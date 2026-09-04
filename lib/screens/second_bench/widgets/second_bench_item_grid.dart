import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../second_bench_tokens.dart';

/// Item genérico da biblioteca para exibição na grade do painel lateral.
class SecondBenchGridItemData<T extends Object> {
  final String id;
  final T value;
  final String label;
  final String? assetPath;
  final Widget? customPainterWidget;
  final bool isSelected;
  final bool isDisabled;
  final String? badgeText;
  final Color? badgeColor;

  const SecondBenchGridItemData({
    required this.id,
    required this.value,
    required this.label,
    this.assetPath,
    this.customPainterWidget,
    this.isSelected = false,
    this.isDisabled = false,
    this.badgeText,
    this.badgeColor,
  });
}

/// Componente padronizado de grade de 2 colunas para o painel lateral das Fases 3 e 4.
class SecondBenchItemGrid<T extends Object> extends StatelessWidget {
  final List<SecondBenchGridItemData<T>> items;
  final ValueChanged<SecondBenchGridItemData<T>>? onItemTap;
  final double assetHeight;
  final bool enableDrag;

  const SecondBenchItemGrid({
    super.key,
    required this.items,
    this.onItemTap,
    this.assetHeight = 58.0, // Escala perceptual aumentada para legibilidade
    this.enableDrag = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGridCard(context, item);
      },
    );
  }

  Widget _buildGridCard(BuildContext context, SecondBenchGridItemData<T> item) {
    Widget cardChild = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.isDisabled ? null : () => onItemTap?.call(item),
        borderRadius: BorderRadius.circular(SecondBenchLayoutTokens.itemCardRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: item.isSelected
                ? const Color(0xFFE2F3EC)
                : (item.isDisabled
                    ? const Color(0xFFEFEBE1)
                    : const Color(0xFFFFFDF7)),
            borderRadius: BorderRadius.circular(SecondBenchLayoutTokens.itemCardRadius),
            border: Border.all(
              color: item.isSelected
                  ? SecondBenchLayoutTokens.primaryGreen
                  : (item.isDisabled
                      ? const Color(0xFFD6CFC0)
                      : const Color(0xFFC8BFA8)),
              width: item.isSelected ? 2.0 : 1.2,
            ),
            boxShadow: item.isSelected
                ? [
                    BoxShadow(
                      color: SecondBenchLayoutTokens.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Asset da Peça / Símbolo em destaque centralizado com escala perceptiva aumentada
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxHeight: assetHeight),
                        child: item.assetPath != null
                            ? Image.asset(
                                item.assetPath!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    item.customPainterWidget ??
                                    const Icon(
                                      Icons.electrical_services_rounded,
                                      size: 36,
                                      color: SecondBenchLayoutTokens.darkGreen,
                                    ),
                              )
                            : (item.customPainterWidget ??
                                const Icon(
                                  Icons.electrical_services_rounded,
                                  size: 36,
                                  color: SecondBenchLayoutTokens.darkGreen,
                                )),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 2. Nome claro e legível abaixo da imagem
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: SecondBenchLayoutTokens.touchTargetMinSize - 20,
                    ),
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: item.isDisabled
                            ? Colors.black38
                            : SecondBenchLayoutTokens.textDark,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Badge opcional (ex: "680 Ω" ou "Invertido")
              if (item.badgeText != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.badgeColor ?? SecondBenchLayoutTokens.primaryGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.badgeText!,
                      style: TextStyle(
                        fontFamily: GoogleFonts.rajdhani().fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (enableDrag && !item.isDisabled) {
      return Draggable<T>(
        data: item.value,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SecondBenchLayoutTokens.accentGreen, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: item.assetPath != null
                ? Image.asset(item.assetPath!, fit: BoxFit.contain)
                : (item.customPainterWidget ?? Container()),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: cardChild,
        ),
        child: cardChild,
      );
    }

    return cardChild;
  }
}
