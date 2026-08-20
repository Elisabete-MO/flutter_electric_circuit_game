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
  Color backgroundColor() => const Color(0x00000000); // Transparent to show dot grid

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
    controller.addListener(_syncValidationState);
    _syncValidationState();
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

  @override
  void onRemove() {
    controller.removeListener(_syncValidationState);
    super.onRemove();
  }

  void _syncValidationState() {
    if (!_isDiagramLoaded) {
      return;
    }
    for (final entry in _slots.entries) {
      entry.value
        ..isHighlighted = controller.highlightedSlots.contains(entry.key)
        ..isSuccessful =
            controller.validationStatus == ValidationStatus.correct;
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
    final topY = size.y * 0.22;
    final bottomY = size.y * 0.78;
    final leftX = size.x * 0.25;

    return DiagramLayout(
      slots: {
        SlotId.battery: DiagramSlotLayout(
          snapCenter: Vector2(leftX, size.y * 0.50),
          visualSize: Vector2(50, 80),
        ),
        SlotId.switchSpst: DiagramSlotLayout(
          snapCenter: Vector2(size.x * 0.50, topY),
          visualSize: Vector2(80, 50),
        ),
        SlotId.lamp: DiagramSlotLayout(
          snapCenter: Vector2(size.x * 0.50, bottomY),
          visualSize: Vector2(80, 50),
        ),
      },
    );
  }
}

class DiagramSlotLayout {
  const DiagramSlotLayout({required this.snapCenter, required this.visualSize});

  final Vector2 snapCenter;
  final Vector2 visualSize;

  Vector2 get dropSize => visualSize + Vector2(30, 24);
}

class _DiagramSlot extends PositionComponent {
  _DiagramSlot({required this.slotId}) : super(anchor: Anchor.center);

  final SlotId slotId;
  late Vector2 snapCenter;
  late Vector2 dropSize;
  bool isCandidate = false;
  bool isHighlighted = false;
  bool isSuccessful = false;

  final Paint _slotPaint = Paint()
    ..color = const Color(0xFF94A3B8)
    ..strokeWidth = 1.8
    ..style = PaintingStyle.stroke;
  final Paint _candidatePaint = Paint()
    ..color = const Color(0xFF0284C7)
    ..strokeWidth = 2.2
    ..style = PaintingStyle.stroke;
  final Paint _errorPaint = Paint()
    ..color = const Color(0xFFEF4444)
    ..strokeWidth = 2.2
    ..style = PaintingStyle.stroke;
  final Paint _successPaint = Paint()
    ..color = const Color(0xFF10B981)
    ..strokeWidth = 2.2
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
    final paint = isSuccessful
        ? _successPaint
        : isHighlighted
        ? _errorPaint
        : isCandidate
        ? _candidatePaint
        : _slotPaint;

    // Draw dashed rectangle for empty slots
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
    ..color = const Color(0xFF1E293B) // Dark slate for schematic wires
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  Path _path = Path();

  void setLayout(DiagramLayout layout) {
    final battery = layout.slots[SlotId.battery]!;
    final switchSpst = layout.slots[SlotId.switchSpst]!;
    final lamp = layout.slots[SlotId.lamp]!;

    final leftX = battery.snapCenter.x;
    final rightX = size.x * 0.75;
    final topY = switchSpst.snapCenter.y;
    final bottomY = lamp.snapCenter.y;

    final batteryTop = battery.snapCenter - Vector2(0, battery.visualSize.y / 2);
    final batteryBottom = battery.snapCenter + Vector2(0, battery.visualSize.y / 2);

    final switchLeft = switchSpst.snapCenter - Vector2(switchSpst.visualSize.x / 2, 0);
    final switchRight = switchSpst.snapCenter + Vector2(switchSpst.visualSize.x / 2, 0);

    final lampLeft = lamp.snapCenter - Vector2(lamp.visualSize.x / 2, 0);
    final lampRight = lamp.snapCenter + Vector2(lamp.visualSize.x / 2, 0);

    _path = Path()
      ..moveTo(batteryTop.x, batteryTop.y)
      ..lineTo(leftX, topY)
      ..lineTo(switchLeft.x, switchLeft.y)
      
      ..moveTo(switchRight.x, switchRight.y)
      ..lineTo(rightX, topY)
      ..lineTo(rightX, bottomY)
      ..lineTo(lampRight.x, lampRight.y)
      
      ..moveTo(lampLeft.x, lampLeft.y)
      ..lineTo(leftX, bottomY)
      ..lineTo(batteryBottom.x, batteryBottom.y);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(_path, _wirePaint);
  }
}
