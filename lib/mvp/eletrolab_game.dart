import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'activity_controller.dart';
import 'mvp_contract.dart';

class EletroLabGame extends FlameGame {
  EletroLabGame({required this.controller});

  final ActivityController controller;

  late final SpriteComponent _battery;
  late final _SwitchComponent _switch;
  late final SpriteComponent _lamp;
  late final _CircuitWires _wires;
  late final Sprite _switchOpenSprite;
  late final Sprite _switchClosedSprite;
  late final Sprite _lampOffSprite;
  late final Sprite _lampOnSprite;
  late final Sprite _energyDotSprite;
  final List<_EnergyDot> _energyDots = [];
  bool _isCircuitLoaded = false;

  @override
  Color backgroundColor() => const Color(0xFFF3F7FA);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    images.prefix = '';

    _switchOpenSprite = await _loadSprite(MvpAsset.switchOpenPhysical);
    _switchClosedSprite = await _loadSprite(MvpAsset.switchClosedPhysical);
    _lampOffSprite = await _loadSprite(MvpAsset.lampOffPhysical);
    _lampOnSprite = await _loadSprite(MvpAsset.lampOnPhysical);
    _energyDotSprite = await _loadSprite(MvpAsset.energyDot);
    _battery = SpriteComponent(
      sprite: await _loadSprite(MvpAsset.batteryPhysical),
      size: Vector2(88, 120),
      anchor: Anchor.center,
    );
    _switch = _SwitchComponent(
      controller: controller,
      sprite: _switchOpenSprite,
      size: Vector2(126, 84),
      anchor: Anchor.center,
    );
    _lamp = SpriteComponent(
      sprite: _lampOffSprite,
      size: Vector2(116, 98),
      anchor: Anchor.center,
    );
    _wires = _CircuitWires();

    await add(_wires);
    await add(_battery);
    await add(_switch);
    await add(_lamp);

    _isCircuitLoaded = true;
    _layoutCircuit();
    controller.addListener(_syncVisualState);
    _syncVisualState();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_isCircuitLoaded) {
      _layoutCircuit();
    }
  }

  @override
  void onRemove() {
    controller.removeListener(_syncVisualState);
    super.onRemove();
  }

  Future<Sprite> _loadSprite(MvpAsset asset) async {
    return Sprite(await images.load(mvpAssetPaths[asset]!));
  }

  void _syncVisualState() {
    _switch.sprite = controller.isSwitchClosed
        ? _switchClosedSprite
        : _switchOpenSprite;
    _lamp.sprite = controller.isSwitchClosed ? _lampOnSprite : _lampOffSprite;

    if (controller.isSwitchClosed) {
      _showEnergyDots();
    } else {
      _hideEnergyDots();
    }
  }

  void _showEnergyDots() {
    if (_energyDots.isNotEmpty) {
      return;
    }

    const dotCount = 9;
    _energyDots.addAll(
      List.generate(
        dotCount,
        (index) => _EnergyDot(
          sprite: _energyDotSprite,
          wires: _wires,
          progress: index / dotCount,
        ),
      ),
    );
    addAll(_energyDots);
  }

  void _hideEnergyDots() {
    for (final dot in _energyDots) {
      dot.removeFromParent();
    }
    _energyDots.clear();
  }

  void _layoutCircuit() {
    final layoutScale = (size.x / 360).clamp(0.9, 1.0).toDouble();
    _battery
      ..size = Vector2(88, 120) * layoutScale
      ..position = Vector2(size.x * 0.19, size.y * 0.60);
    _switch
      ..size = Vector2(126, 84) * layoutScale
      ..position = Vector2(size.x * 0.50, size.y * 0.32);
    _lamp
      ..size = Vector2(116, 98) * layoutScale
      ..position = Vector2(size.x * 0.81, size.y * 0.60);

    _wires.size = size;
    _wires.setTerminals(
      battery: _battery.position,
      batterySize: _battery.size,
      switchPosition: _switch.position,
      switchSize: _switch.size,
      lamp: _lamp.position,
      lampSize: _lamp.size,
    );
  }
}

class _SwitchComponent extends SpriteComponent with TapCallbacks {
  _SwitchComponent({
    required this.controller,
    required super.sprite,
    required super.size,
    required super.anchor,
  });

  final ActivityController controller;

  @override
  bool containsLocalPoint(Vector2 point) {
    const padding = 10.0;
    return point.x >= -padding &&
        point.x < size.x + padding &&
        point.y >= -padding &&
        point.y < size.y + padding;
  }

  @override
  void onTapUp(TapUpEvent event) {
    controller.toggleSwitch();
    super.onTapUp(event);
  }
}

class _EnergyDot extends SpriteComponent {
  _EnergyDot({
    required super.sprite,
    required this._wires,
    required this._progress,
  }) : super(size: Vector2.all(16), anchor: Anchor.center, priority: 1);

  final _CircuitWires _wires;
  double _progress;

  @override
  void update(double dt) {
    super.update(dt);
    _progress = (_progress + dt * 0.18) % 1;
    position = _wires.pointAt(_progress);
  }
}

class _CircuitWires extends PositionComponent {
  final Paint _wirePaint = Paint()
    ..color = const Color(0xFF334155)
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  Path _path = Path();
  List<List<Vector2>> _segments = const [];

  void setTerminals({
    required Vector2 battery,
    required Vector2 batterySize,
    required Vector2 switchPosition,
    required Vector2 switchSize,
    required Vector2 lamp,
    required Vector2 lampSize,
  }) {
    final batteryRight = Vector2(
      battery.x + batterySize.x * 0.17,
      battery.y - batterySize.y * 0.34,
    );
    final switchLeft = Vector2(
      switchPosition.x - switchSize.x * 0.33,
      switchPosition.y + switchSize.y * 0.12,
    );
    final switchRight = Vector2(
      switchPosition.x + switchSize.x * 0.33,
      switchPosition.y + switchSize.y * 0.12,
    );
    final lampLeft = Vector2(
      lamp.x - lampSize.x * 0.34,
      lamp.y + lampSize.y * 0.12,
    );
    final lampRight = Vector2(
      lamp.x + lampSize.x * 0.34,
      lamp.y + lampSize.y * 0.12,
    );
    final batteryLeft = Vector2(
      battery.x - batterySize.x * 0.17,
      battery.y - batterySize.y * 0.34,
    );
    final bottomY = size.y - 16;

    _segments = [
      [batteryRight, switchLeft],
      [switchRight, lampLeft],
      [
        lampRight,
        Vector2(lampRight.x, bottomY),
        Vector2(batteryLeft.x, bottomY),
        batteryLeft,
      ],
    ];
    _path = Path();
    for (final segment in _segments) {
      _path.moveTo(segment.first.x, segment.first.y);
      for (final point in segment.skip(1)) {
        _path.lineTo(point.x, point.y);
      }
    }
  }

  Vector2 pointAt(double progress) {
    final totalLength = _totalLength;
    if (totalLength == 0) {
      return Vector2.zero();
    }

    var distance = progress * totalLength;
    for (final segment in _segments) {
      for (var index = 0; index < segment.length - 1; index++) {
        final start = segment[index];
        final end = segment[index + 1];
        final length = start.distanceTo(end);
        if (distance <= length) {
          return start + (end - start) * (distance / length);
        }
        distance -= length;
      }
    }
    return _segments.last.last.clone();
  }

  double get _totalLength {
    var length = 0.0;
    for (final segment in _segments) {
      for (var index = 0; index < segment.length - 1; index++) {
        length += segment[index].distanceTo(segment[index + 1]);
      }
    }
    return length;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(_path, _wirePaint);
  }
}
