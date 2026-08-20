import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/effects.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'activity_controller.dart';
import 'mvp_contract.dart';

class EletroLabGame extends FlameGame {
  EletroLabGame({required this.controller});

  final ActivityController controller;

  late final SpriteComponent _background;
  late final SpriteComponent _battery;
  late final _SwitchComponent _switch;
  late final SpriteComponent _lampBase;
  late final SpriteComponent _lampGlow;
  late final _CircuitWires _wires;
  late final Sprite _switchOpenSprite;
  late final Sprite _switchClosedSprite;
  late final Sprite _lampOffSprite;
  late final Sprite _lampOnSprite;
  late final Sprite _energyDotSprite;
  final List<_EnergyDot> _energyDots = [];
  bool _isCircuitLoaded = false;
  double _lampOpacityTarget = 0.0;

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

    _background = SpriteComponent(
      sprite: await _loadSprite(MvpAsset.woodTableBackground),
      size: size,
    );

    _battery = SpriteComponent(
      sprite: await _loadSprite(MvpAsset.batteryPhysical),
      size: Vector2(70, 110),
      anchor: Anchor.center,
    );
    _switch = _SwitchComponent(
      controller: controller,
      sprite: _switchOpenSprite,
      size: Vector2(120, 80),
      anchor: Anchor.center,
    );
    _lampBase = SpriteComponent(
      sprite: _lampOffSprite,
      size: Vector2(100, 100),
      anchor: Anchor.center,
    );
    _lampGlow = SpriteComponent(
      sprite: _lampOnSprite,
      size: Vector2(100, 100),
      anchor: Anchor.center,
      priority: 1,
    );
    _lampGlow.opacity = 0.0;

    _wires = _CircuitWires();

    await add(_background);
    await add(_wires);
    await add(_battery);
    await add(_switch);
    await add(_lampBase);
    await add(_lampGlow);

    _isCircuitLoaded = true;
    _layoutCircuit();
    controller.addListener(_syncVisualState);
    _syncVisualState();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isCircuitLoaded) {
      final currentOpacity = _lampGlow.opacity;
      if ((currentOpacity - _lampOpacityTarget).abs() > 0.01) {
        _lampGlow.opacity = lerpDouble(currentOpacity, _lampOpacityTarget, dt * 12.0) ?? _lampOpacityTarget;
      } else {
        _lampGlow.opacity = _lampOpacityTarget;
      }
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_isCircuitLoaded) {
      _background.size = size;
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
    _lampOpacityTarget = controller.isSwitchClosed ? 1.0 : 0.0;

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

    const dotCount = 12;
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
    final layoutScale = (size.x / 360).clamp(0.80, 1.15).toDouble();
    _battery
      ..size = Vector2(65, 110) * layoutScale
      ..position = Vector2(size.x * 0.18, size.y * 0.50);

    _lampBase
      ..size = Vector2(95, 95) * layoutScale
      ..position = Vector2(size.x * 0.72, size.y * 0.50)
      ..angle = math.pi / 2;

    _lampGlow
      ..size = _lampBase.size
      ..position = _lampBase.position
      ..angle = _lampBase.angle;

    final lampTerminalX = _lampBase.position.x - (_lampBase.size.y * 0.36);
    final switchX = (_battery.position.x + lampTerminalX) / 2;

    _switch
      ..size = Vector2(105, 70) * layoutScale
      ..position = Vector2(switchX, size.y * 0.15);

    _wires.size = size;
    _wires.setTerminals(
      battery: _battery.position,
      batterySize: _battery.size,
      switchPosition: _switch.position,
      switchSize: _switch.size,
      lamp: _lampBase.position,
      lampSize: _lampBase.size,
      lampAngle: _lampBase.angle,
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
    const padding = 12.0;
    return point.x >= -padding &&
        point.x < size.x + padding &&
        point.y >= -padding &&
        point.y < size.y + padding;
  }

  @override
  void onTapUp(TapUpEvent event) {
    add(
      ScaleEffect.by(
        Vector2.all(0.92),
        EffectController(duration: 0.08, alternate: true),
      ),
    );
    controller.toggleSwitch();
    super.onTapUp(event);
  }
}

class _EnergyDot extends SpriteComponent {
  _EnergyDot({
    required super.sprite,
    required this._wires,
    required this._progress,
  }) : super(size: Vector2.all(16), anchor: Anchor.center, priority: 2);

  final _CircuitWires _wires;
  double _progress;

  @override
  void update(double dt) {
    super.update(dt);
    _progress = (_progress + dt * 0.18) % 1;
    position = _wires.pointAt(_progress);

    final pulse = 1.0 + 0.18 * math.sin(_progress * math.pi * 10);
    scale = Vector2.all(pulse);
  }
}

class _CircuitWires extends PositionComponent {
  final Paint _wirePaint = Paint()
    ..color = const Color(0xFFDC2626) // Red wires
    ..strokeWidth = 4.5
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  final Paint _connectorPaint = Paint()
    ..color = const Color(0xFFE2E8F0) // Silver metal connectors
    ..style = PaintingStyle.fill;

  final Paint _connectorBorder = Paint()
    ..color = const Color(0xFF475569)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  Path _path = Path();
  List<List<Vector2>> _segments = const [];
  List<Vector2> _terminals = [];

  void setTerminals({
    required Vector2 battery,
    required Vector2 batterySize,
    required Vector2 switchPosition,
    required Vector2 switchSize,
    required Vector2 lamp,
    required Vector2 lampSize,
    required double lampAngle,
  }) {
    final batteryPositive = battery - Vector2(0, batterySize.y * 0.42);
    final batteryNegative = battery + Vector2(0, batterySize.y * 0.42);

    final switchLeft = switchPosition + Vector2(-switchSize.x * 0.38, switchSize.y * 0.14);
    final switchRight = switchPosition + Vector2(switchSize.x * 0.38, switchSize.y * 0.14);

    final localA = Vector2(-lampSize.x * 0.25, lampSize.y * 0.25);
    final localB = Vector2(lampSize.x * 0.25, lampSize.y * 0.25);

    final cosA = math.cos(lampAngle);
    final sinA = math.sin(lampAngle);

    final lampTop = lamp + Vector2(
      localA.x * cosA - localA.y * sinA,
      localA.x * sinA + localA.y * cosA,
    );
    final lampBottom = lamp + Vector2(
      localB.x * cosA - localB.y * sinA,
      localB.x * sinA + localB.y * cosA,
    );

    // Connector circles (bolinhas) are drawn only on switch and lamp screw terminals
    _terminals = [
      switchLeft,
      switchRight,
      lampTop,
      lampBottom,
    ];

    final bottomY = size.y * 0.78;
    final cornerX = lampTop.x - (25 * (size.x / 360).clamp(0.80, 1.15));

    _segments = [
      [
        batteryPositive,
        Vector2(batteryPositive.x, switchLeft.y),
        switchLeft,
      ],
      [
        switchRight,
        Vector2(cornerX, switchRight.y),
        Vector2(cornerX, lampTop.y),
        lampTop,
      ],
      [
        lampBottom,
        Vector2(cornerX, lampBottom.y),
        Vector2(cornerX, bottomY),
        Vector2(batteryNegative.x, bottomY),
        batteryNegative,
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
    for (final terminal in _terminals) {
      canvas.drawCircle(Offset(terminal.x, terminal.y), 5, _connectorPaint);
      canvas.drawCircle(Offset(terminal.x, terminal.y), 5, _connectorBorder);
    }
  }
}

