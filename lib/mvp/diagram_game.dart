import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_svg/flame_svg.dart';

import 'activity_controller.dart';
import 'mvp_contract.dart';

class CircuitDiagramGame extends FlameGame {
  CircuitDiagramGame({required this.controller});

  final ActivityController controller;
  late final _DiagramWires _wires;
  late final Map<SlotId, _DiagramSlot> _slots;
  bool _isDiagramLoaded = false;

  @override
  Color backgroundColor() => const Color(0xFFF3F7FA);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    assets.prefix = '';

    _wires = _DiagramWires();
    _slots = {
      for (final slot in SlotId.values) slot: _DiagramSlot(slotId: slot),
    };
    await add(_wires);
    await addAll(_slots.values);

    _isDiagramLoaded = true;
    _layoutDiagram();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_isDiagramLoaded) {
      _layoutDiagram();
    }
  }

  void _layoutDiagram() {
    final layout = _DiagramLayout.fromSize(size);
    for (final entry in layout.slots.entries) {
      _slots[entry.key]!.setLayout(entry.value);
    }
    _wires
      ..size = size
      ..setLayout(layout);
  }
}

class SymbolLibraryGame extends FlameGame {
  late final List<_LibrarySymbol> _symbols;
  bool _isLibraryLoaded = false;

  @override
  Color backgroundColor() => const Color(0xFFF3F7FA);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    assets.prefix = '';

    _symbols = [
      _LibrarySymbol(
        symbolType: SymbolType.battery,
        svg: await loadSvg(mvpAssetPaths[MvpAsset.batterySymbol]!),
      ),
      _LibrarySymbol(
        symbolType: SymbolType.switchSpst,
        svg: await loadSvg(mvpAssetPaths[MvpAsset.switchSymbol]!),
      ),
      _LibrarySymbol(
        symbolType: SymbolType.lamp,
        svg: await loadSvg(mvpAssetPaths[MvpAsset.lampSymbol]!),
      ),
    ];
    await addAll(_symbols);

    _isLibraryLoaded = true;
    _layoutLibrary();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_isLibraryLoaded) {
      _layoutLibrary();
    }
  }

  void _layoutLibrary() {
    final symbolSize = Vector2((size.x / 4).clamp(72, 108).toDouble(), 48);
    for (var index = 0; index < _symbols.length; index++) {
      _symbols[index]
        ..size = symbolSize
        ..position = Vector2(size.x * (0.2 + index * 0.3), size.y * 0.5)
        ..homePosition = _symbols[index].position.clone();
    }
  }
}

class _DiagramLayout {
  _DiagramLayout({required this.slots});

  final Map<SlotId, _SlotLayout> slots;

  factory _DiagramLayout.fromSize(Vector2 size) {
    return _DiagramLayout(
      slots: {
        SlotId.battery: _SlotLayout(
          snapCenter: Vector2(size.x * 0.25, size.y * 0.28),
          visualSize: Vector2(92, 48),
        ),
        SlotId.switchSpst: _SlotLayout(
          snapCenter: Vector2(size.x * 0.72, size.y * 0.28),
          visualSize: Vector2(100, 48),
        ),
        SlotId.lamp: _SlotLayout(
          snapCenter: Vector2(size.x * 0.50, size.y * 0.70),
          visualSize: Vector2(92, 48),
        ),
      },
    );
  }
}

class _SlotLayout {
  const _SlotLayout({required this.snapCenter, required this.visualSize});

  final Vector2 snapCenter;
  final Vector2 visualSize;

  Vector2 get dropSize => visualSize + Vector2(36, 28);
}

class _DiagramSlot extends PositionComponent {
  _DiagramSlot({required this.slotId}) : super(anchor: Anchor.center);

  final SlotId slotId;
  late Vector2 snapCenter;
  late Vector2 dropSize;
  final Paint _slotPaint = Paint()
    ..color = const Color(0xFF7B8A97)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  Rect get dropHitbox => Rect.fromCenter(
    center: Offset(snapCenter.x, snapCenter.y),
    width: dropSize.x,
    height: dropSize.y,
  );

  void setLayout(_SlotLayout layout) {
    snapCenter = layout.snapCenter;
    dropSize = layout.dropSize;
    position = snapCenter;
    size = layout.visualSize;
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    const dashLength = 6.0;
    const gapLength = 4.0;

    for (var x = 0.0; x < rect.width; x += dashLength + gapLength) {
      canvas.drawLine(
        Offset(x, 0),
        Offset((x + dashLength).clamp(0, rect.width).toDouble(), 0),
        _slotPaint,
      );
      canvas.drawLine(
        Offset(x, rect.height),
        Offset((x + dashLength).clamp(0, rect.width).toDouble(), rect.height),
        _slotPaint,
      );
    }
    for (var y = 0.0; y < rect.height; y += dashLength + gapLength) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, (y + dashLength).clamp(0, rect.height).toDouble()),
        _slotPaint,
      );
      canvas.drawLine(
        Offset(rect.width, y),
        Offset(rect.width, (y + dashLength).clamp(0, rect.height).toDouble()),
        _slotPaint,
      );
    }
  }
}

class _DiagramWires extends PositionComponent {
  final Paint _wirePaint = Paint()
    ..color = const Color(0xFF243746)
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  Path _path = Path();

  void setLayout(_DiagramLayout layout) {
    final battery = layout.slots[SlotId.battery]!;
    final switchSpst = layout.slots[SlotId.switchSpst]!;
    final lamp = layout.slots[SlotId.lamp]!;
    final batteryRight =
        battery.snapCenter + Vector2(battery.visualSize.x / 2, 0);
    final batteryLeft =
        battery.snapCenter - Vector2(battery.visualSize.x / 2, 0);
    final switchLeft =
        switchSpst.snapCenter - Vector2(switchSpst.visualSize.x / 2, 0);
    final switchRight =
        switchSpst.snapCenter + Vector2(switchSpst.visualSize.x / 2, 0);
    final lampLeft = lamp.snapCenter - Vector2(lamp.visualSize.x / 2, 0);
    final lampRight = lamp.snapCenter + Vector2(lamp.visualSize.x / 2, 0);
    final leftX = 16.0;
    final rightX = size.x - 16;

    _path = Path()
      ..moveTo(batteryRight.x, batteryRight.y)
      ..lineTo(switchLeft.x, switchLeft.y)
      ..moveTo(switchRight.x, switchRight.y)
      ..lineTo(rightX, switchRight.y)
      ..lineTo(rightX, lampRight.y)
      ..lineTo(lampRight.x, lampRight.y)
      ..moveTo(lampLeft.x, lampLeft.y)
      ..lineTo(leftX, lampLeft.y)
      ..lineTo(leftX, batteryLeft.y)
      ..lineTo(batteryLeft.x, batteryLeft.y);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(_path, _wirePaint);
  }
}

class _LibrarySymbol extends SvgComponent {
  _LibrarySymbol({required this.symbolType, required super.svg})
    : super(anchor: Anchor.center);

  final SymbolType symbolType;
  late Vector2 homePosition;
}
