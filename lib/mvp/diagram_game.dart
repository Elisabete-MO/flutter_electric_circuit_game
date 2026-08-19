import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

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

  void setCandidateSlot(SlotId? candidateSlot) {
    if (!_isDiagramLoaded) {
      return;
    }
    for (final entry in _slots.entries) {
      entry.value.isCandidate = entry.key == candidateSlot;
    }
  }

  void _layoutDiagram() {
    final layout = DiagramLayout.fromSize(size);
    for (final entry in layout.slots.entries) {
      _slots[entry.key]!.setLayout(entry.value);
    }
    _wires
      ..size = size
      ..setLayout(layout);
  }
}

class DiagramLayout {
  DiagramLayout({required this.slots});

  final Map<SlotId, DiagramSlotLayout> slots;

  factory DiagramLayout.fromSize(Vector2 size) {
    return DiagramLayout(
      slots: {
        SlotId.battery: DiagramSlotLayout(
          snapCenter: Vector2(size.x * 0.25, size.y * 0.28),
          visualSize: Vector2(92, 48),
        ),
        SlotId.switchSpst: DiagramSlotLayout(
          snapCenter: Vector2(size.x * 0.72, size.y * 0.28),
          visualSize: Vector2(100, 48),
        ),
        SlotId.lamp: DiagramSlotLayout(
          snapCenter: Vector2(size.x * 0.50, size.y * 0.70),
          visualSize: Vector2(92, 48),
        ),
      },
    );
  }
}

class DiagramSlotLayout {
  const DiagramSlotLayout({required this.snapCenter, required this.visualSize});

  final Vector2 snapCenter;
  final Vector2 visualSize;

  Vector2 get dropSize => visualSize + Vector2(36, 28);
}

class _DiagramSlot extends PositionComponent {
  _DiagramSlot({required this.slotId}) : super(anchor: Anchor.center);

  final SlotId slotId;
  late Vector2 snapCenter;
  late Vector2 dropSize;
  bool isCandidate = false;
  final Paint _slotPaint = Paint()
    ..color = const Color(0xFF7B8A97)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;
  final Paint _candidatePaint = Paint()
    ..color = const Color(0xFF0E9FAD)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  Rect get dropHitbox => Rect.fromCenter(
    center: Offset(snapCenter.x, snapCenter.y),
    width: dropSize.x,
    height: dropSize.y,
  );

  void setLayout(DiagramSlotLayout layout) {
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
    final paint = isCandidate ? _candidatePaint : _slotPaint;

    for (var x = 0.0; x < rect.width; x += dashLength + gapLength) {
      canvas.drawLine(
        Offset(x, 0),
        Offset((x + dashLength).clamp(0, rect.width).toDouble(), 0),
        paint,
      );
      canvas.drawLine(
        Offset(x, rect.height),
        Offset((x + dashLength).clamp(0, rect.width).toDouble(), rect.height),
        paint,
      );
    }
    for (var y = 0.0; y < rect.height; y += dashLength + gapLength) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, (y + dashLength).clamp(0, rect.height).toDouble()),
        paint,
      );
      canvas.drawLine(
        Offset(rect.width, y),
        Offset(rect.width, (y + dashLength).clamp(0, rect.height).toDouble()),
        paint,
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

  void setLayout(DiagramLayout layout) {
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
