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
    return LayoutBuilder(
      builder: (context, constraints) {
        const diagramHeight = 230.0;
        final layout = DiagramLayout.fromSize(
          Vector2(constraints.maxWidth, diagramHeight),
        );
        return SizedBox(
          height: diagramHeight,
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
            ],
          ),
        );
      },
    );
  }
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
          return Center(
            child: _DraggableSymbol(
              symbolType: symbol,
              size: layout.visualSize,
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
    return Row(
      children: [
        for (final symbol in SymbolType.values)
          Expanded(
            child: Center(
              child: controller.slotForSymbol(symbol) == null
                  ? _DraggableSymbol(symbolType: symbol, size: Vector2(92, 48))
                  : const SizedBox(width: 92, height: 48),
            ),
          ),
      ],
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
        child: Opacity(opacity: 0.82, child: symbol),
      ),
      childWhenDragging: SizedBox(width: size.x, height: size.y),
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
