import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'activity_controller.dart';
import 'diagram_game.dart';
import 'mvp_contract.dart';

class DiagramWorkspace extends StatefulWidget {
  const DiagramWorkspace({
    super.key,
    required this.controller,
    required this.diagramGame,
  });

  final ActivityController controller;
  final CircuitDiagramGame diagramGame;

  @override
  State<DiagramWorkspace> createState() => _DiagramWorkspaceState();
}

class _DiagramWorkspaceState extends State<DiagramWorkspace> {
  SlotId? _candidateSlot;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final path in mvpAssetPaths.values) {
      if (path.endsWith('.svg')) {
        vg.loadPicture(SvgAssetLoader(path), context);
      }
    }
  }

  void _setCandidate(SlotId? slot) {
    if (_candidateSlot == slot) {
      return;
    }
    setState(() => _candidateSlot = slot);
    widget.diagramGame.setCandidateSlot(slot);
  }

  @override
  void dispose() {
    widget.diagramGame.setCandidateSlot(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.controller.validationStatus == ValidationStatus.correct;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 0 
            ? constraints.maxHeight 
            : 380.0;
        final canvasHeight = (contentHeight - 96.0).clamp(180.0, double.infinity);
        
        final layout = DiagramLayout.fromSize(
          Vector2(constraints.maxWidth, canvasHeight),
        );

        final batterySlot = layout.slots[SlotId.battery]!;

        return Column(
          children: [
            Expanded(
              child: CustomPaint(
                painter: const _DotGridPainter(),
                child: Stack(
                  children: [
                    Positioned.fill(child: GameWidget(game: widget.diagramGame)),
                    for (final entry in layout.slots.entries)
                      _DiagramDropTarget(
                        slot: entry.key,
                        layout: entry.value,
                        controller: widget.controller,
                        onCandidateChanged: _setCandidate,
                      ),
                    
                    // Battery Labels (+, -, 6 V)
                    Positioned(
                      left: batterySlot.snapCenter.x - 45,
                      top: batterySlot.snapCenter.y - 12,
                      child: const Text(
                        '6 V',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    Positioned(
                      left: batterySlot.snapCenter.x - 10,
                      top: batterySlot.snapCenter.y - 52,
                      child: const Text(
                        '+',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    Positioned(
                      left: batterySlot.snapCenter.x - 8,
                      top: batterySlot.snapCenter.y + 35,
                      child: const Text(
                        '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Container(
              height: 84,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              alignment: Alignment.center,
              child: isCorrect
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF10B981),
                          size: 26,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Diagrama equivalente',
                          style: TextStyle(
                            color: Color(0xFF047857),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  : SymbolLibrary(controller: widget.controller),
            ),
          ],
        );
      },
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    const step = 16.0;
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DiagramDropTarget extends StatelessWidget {
  const _DiagramDropTarget({
    required this.slot,
    required this.layout,
    required this.controller,
    required this.onCandidateChanged,
  });

  final SlotId slot;
  final DiagramSlotLayout layout;
  final ActivityController controller;
  final ValueChanged<SlotId?> onCandidateChanged;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: layout.snapCenter.x - layout.dropSize.x / 2,
      top: layout.snapCenter.y - layout.dropSize.y / 2,
      width: layout.dropSize.x,
      height: layout.dropSize.y,
      child: DragTarget<SymbolType>(
        onWillAcceptWithDetails: (_) {
          onCandidateChanged(slot);
          return true;
        },
        onLeave: (_) => onCandidateChanged(null),
        onAcceptWithDetails: (details) {
          onCandidateChanged(null);
          controller.moveSymbol(details.data, slot);
        },
        builder: (context, candidateData, rejectedData) {
          final symbol = controller.slotOccupancy[slot];
          if (symbol == null) {
            return const SizedBox.expand();
          }
          final rotationDeg = controller.slotRotations[slot] ?? 0;
          return GestureDetector(
            onTap: () => controller.selectSlot(slot),
            child: Center(
              child: AnimatedRotation(
                turns: rotationDeg / 360.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('${slot.name}_${symbol.name}'),
                  tween: Tween<double>(begin: 0.75, end: 1.0),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: _DraggableSymbol(
                    symbolType: symbol,
                    size: layout.visualSize,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SymbolLibrary extends StatelessWidget {
  const SymbolLibrary({super.key, required this.controller});

  final ActivityController controller;

  @override
  Widget build(BuildContext context) {
    final symbols = [
      SymbolType.battery,
      SymbolType.switchSpst,
      SymbolType.lamp,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final symbol in symbols)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _SymbolCard(
                symbol: symbol,
                isPlaced: controller.slotForSymbol(symbol) != null,
              ),
            ),
          ),
      ],
    );
  }
}

class _SymbolCard extends StatelessWidget {
  const _SymbolCard({required this.symbol, required this.isPlaced});

  final SymbolType symbol;
  final bool isPlaced;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 68,
      decoration: BoxDecoration(
        color: isPlaced ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlaced ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: isPlaced
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: isPlaced
            ? Opacity(
                opacity: 0.20,
                child: _TechnicalSymbol(
                  symbolType: symbol,
                  size: Vector2(50, 32),
                ),
              )
            : _DraggableSymbol(
                symbolType: symbol,
                size: Vector2(50, 32),
              ),
      ),
    );
  }
}

class _DraggableSymbol extends StatelessWidget {
  const _DraggableSymbol({required this.symbolType, required this.size});

  final SymbolType symbolType;
  final Vector2 size;

  @override
  Widget build(BuildContext context) {
    final symbol = _TechnicalSymbol(symbolType: symbolType, size: size);
    return Draggable<SymbolType>(
      data: symbolType,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.85, child: symbol),
      ),
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: symbol,
      ),
      child: symbol,
    );
  }
}

class _TechnicalSymbol extends StatelessWidget {
  const _TechnicalSymbol({required this.symbolType, required this.size});

  final SymbolType symbolType;
  final Vector2 size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.x,
      height: size.y,
      child: SvgPicture.asset(_symbolAssetPath(symbolType)),
    );
  }
}

String _symbolAssetPath(SymbolType symbolType) {
  return switch (symbolType) {
    SymbolType.battery => mvpAssetPaths[MvpAsset.batterySymbol]!,
    SymbolType.switchSpst => mvpAssetPaths[MvpAsset.switchSymbol]!,
    SymbolType.lamp => mvpAssetPaths[MvpAsset.lampSymbol]!,
  };
}
