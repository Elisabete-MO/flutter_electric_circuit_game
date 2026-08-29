import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/first_step_component.dart';
import '../../models/sandbox_component.dart';
import '../../models/sandbox_wire.dart';
import '../../models/sandbox_state.dart';
import '../../state/sandbox_controller.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/prof_volts_full_body.dart';
import '../../widgets/component_physical_painter.dart';
import '../../widgets/circuit_symbol_painter.dart';
import '../../widgets/challenge_layout_components.dart';

import 'models/connection_source.dart';
import 'widgets/sandbox_grid_painters.dart';
import 'widgets/sandbox_toolbox.dart';
import 'widgets/sandbox_quick_hud.dart';
import 'widgets/sandbox_mascot_panel.dart';
import 'widgets/sandbox_control_bar.dart';
import 'widgets/sandbox_metrics_panel.dart';
import 'widgets/sandbox_multimeter.dart';
import 'widgets/sandbox_oscilloscope.dart';
import 'widgets/sandbox_inspector_dialog.dart';
import 'widgets/sandbox_challenges_dialog.dart';
import 'widgets/sandbox_export_dialog.dart';

class SandboxScreen extends ConsumerStatefulWidget {
  const SandboxScreen({super.key});

  @override
  ConsumerState<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends ConsumerState<SandboxScreen> with TickerProviderStateMixin {
  int _gridCols = 8;
  int _gridRows = 5;

  Set<String> _selectedComponentIds = {};
  String? _selectedWireId;
  String? get _selectedComponentId => _selectedComponentIds.length == 1 ? _selectedComponentIds.first : null;
  set _selectedComponentId(String? id) {
    _selectedComponentIds = id != null ? {id} : {};
  }
  Offset? _boxSelectionStart;
  Offset? _boxSelectionCurrent;
  bool _isBoxSelecting = false;
  ConnectionSource? _connectionSource;
  ConnectionSource? _snappedTarget;
  Offset? _currentMousePos;
  Offset? _dragStartPosition;
  Offset? _hoverGridCell;
  bool _isDraggingWire = false;
  late final AnimationController _wireAnimationController;
  late final AnimationController _sparkAnimationController;
  Offset? _sparkPosition;
  bool _showMascot = true;
  bool _isDiagramMode = false;
  bool _useRealisticAssets = true;
  ProfVoltsEmotion _lastVoltsEmotion = ProfVoltsEmotion.neutral;

  // Pilar 1: Instrumentos Virtuais de Medição (Multímetro & Osciloscópio)
  bool _showMultimeter = false;
  bool _showOscilloscope = false;
  MultimeterMode _multimeterMode = MultimeterMode.voltageDC;
  MultimeterProbeConnection _redProbe = const MultimeterProbeConnection();
  MultimeterProbeConnection _blackProbe = const MultimeterProbeConnection();
  bool _isHoldMultimeter = false;

  void _triggerSpark(Offset position) {
    setState(() {
      _sparkPosition = position;
    });
    _sparkAnimationController.forward(from: 0.0);
  }

  ConnectionSource? _findTerminalAtPosition(
    Offset mousePos,
    double cellSize,
    List<SandboxComponent> components, {
    double touchRadius = 30.0,
  }) {
    ConnectionSource? nearest;
    double minDistance = touchRadius;

    for (final comp in components) {
      // Terminal A
      final posA = comp.getTerminalAPosition();
      final offsetA = Offset(posA.dx * cellSize, posA.dy * cellSize);
      final distA = (mousePos - offsetA).distance;
      if (distA < minDistance) {
        minDistance = distA;
        nearest = ConnectionSource(comp.id, 'A');
      }

      // Terminal B
      final posB = comp.getTerminalBPosition();
      final offsetB = Offset(posB.dx * cellSize, posB.dy * cellSize);
      final distB = (mousePos - offsetB).distance;
      if (distB < minDistance) {
        minDistance = distB;
        nearest = ConnectionSource(comp.id, 'B');
      }
    }

    return nearest;
  }

  ConnectionSource? _findNearestTerminal(
    Offset mousePos,
    double cellSize,
    List<SandboxComponent> components,
    ConnectionSource? currentSource,
  ) {
    if (currentSource == null) return null;

    ConnectionSource? nearest;
    double minDistance = 60.0; // Raio magnético de 60px para atração fluida

    for (final comp in components) {
      // Terminal A
      if (currentSource.componentId != comp.id || currentSource.terminal != 'A') {
        final posA = comp.getTerminalAPosition();
        final offsetA = Offset(posA.dx * cellSize, posA.dy * cellSize);
        final distA = (mousePos - offsetA).distance;
        if (distA < minDistance) {
          minDistance = distA;
          nearest = ConnectionSource(comp.id, 'A');
        }
      }

      // Terminal B
      if (currentSource.componentId != comp.id || currentSource.terminal != 'B') {
        final posB = comp.getTerminalBPosition();
        final offsetB = Offset(posB.dx * cellSize, posB.dy * cellSize);
        final distB = (mousePos - offsetB).distance;
        if (distB < minDistance) {
          minDistance = distB;
          nearest = ConnectionSource(comp.id, 'B');
        }
      }
    }

    return nearest;
  }

  SandboxWire? _findWireAtPosition(
    Offset mousePos,
    double cellSize,
    List<SandboxWire> wires,
    List<SandboxComponent> components,
  ) {
    for (final wire in wires) {
      final fromCompList = components.where((c) => c.id == wire.fromComponentId).toList();
      final toCompList = components.where((c) => c.id == wire.toComponentId).toList();
      if (fromCompList.isEmpty || toCompList.isEmpty) continue;

      final fromComp = fromCompList.first;
      final toComp = toCompList.first;

      final fromRelPos = wire.fromTerminal == 'A' ? fromComp.getTerminalAPosition() : fromComp.getTerminalBPosition();
      final toRelPos = wire.toTerminal == 'A' ? toComp.getTerminalAPosition() : toComp.getTerminalBPosition();

      final start = Offset(fromRelPos.dx * cellSize, fromRelPos.dy * cellSize);
      final end = Offset(toRelPos.dx * cellSize, toRelPos.dy * cellSize);

      final path = buildSmartWirePath(
        start: start,
        end: end,
        cellSize: cellSize,
        isDiagramMode: _isDiagramMode,
        components: components,
      );

      for (final metric in path.computeMetrics()) {
        final length = metric.length;
        const step = 6.0;
        for (double d = 0; d <= length; d += step) {
          final tangent = metric.getTangentForOffset(d);
          if (tangent != null) {
            if ((mousePos - tangent.position).distance <= 14.0) {
              return wire;
            }
          }
        }
      }
    }
    return null;
  }

  Offset? _getWireMidpoint(
    SandboxWire wire,
    double cellSize,
    List<SandboxComponent> components,
  ) {
    final fromCompList = components.where((c) => c.id == wire.fromComponentId).toList();
    final toCompList = components.where((c) => c.id == wire.toComponentId).toList();
    if (fromCompList.isEmpty || toCompList.isEmpty) return null;

    final fromComp = fromCompList.first;
    final toComp = toCompList.first;

    final fromRelPos = wire.fromTerminal == 'A' ? fromComp.getTerminalAPosition() : fromComp.getTerminalBPosition();
    final toRelPos = wire.toTerminal == 'A' ? toComp.getTerminalAPosition() : toComp.getTerminalBPosition();

    final start = Offset(fromRelPos.dx * cellSize, fromRelPos.dy * cellSize);
    final end = Offset(toRelPos.dx * cellSize, toRelPos.dy * cellSize);

    final path = buildSmartWirePath(
      start: start,
      end: end,
      cellSize: cellSize,
      isDiagramMode: _isDiagramMode,
      components: components,
    );

    for (final metric in path.computeMetrics()) {
      final tangent = metric.getTangentForOffset(metric.length * 0.5);
      if (tangent != null) return tangent.position;
    }
    return Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
  }

  bool _isPositionOverHudOrComponent(
    Offset mousePos,
    double cellSize,
    double gridWidth,
    List<SandboxComponent> components,
    Set<String> selectedIds, [
    String? selectedWireId,
    List<SandboxWire>? wires,
  ]) {
    if (selectedWireId != null && wires != null) {
      final selectedWireList = wires.where((w) => w.id == selectedWireId).toList();
      if (selectedWireList.isNotEmpty) {
        final mid = _getWireMidpoint(selectedWireList.first, cellSize, components);
        if (mid != null) {
          final wireHudRect = Rect.fromLTWH(mid.dx - 60, mid.dy - 45, 120, 50);
          if (wireHudRect.contains(mousePos)) return true;
        }
      }
    }

    if (selectedIds.length > 1) {
      final multiHudRect = Rect.fromLTWH((gridWidth / 2) - 140, 0, 280, 56);
      if (multiHudRect.contains(mousePos)) return true;
    }

    if (selectedIds.length == 1) {
      final selectedId = selectedIds.first;
      final selectedCompList = components.where((c) => c.id == selectedId).toList();
      if (selectedCompList.isNotEmpty) {
        final comp = selectedCompList.first;
        final hudLeft = (comp.gridX * cellSize).clamp(0.0, math.max(0.0, gridWidth - 140)).toDouble();
        final hudTop = math.max(0.0, (comp.gridY * cellSize) - 40).toDouble();
        final hudRect = Rect.fromLTWH(hudLeft - 10, hudTop - 10, 160, 64);
        if (hudRect.contains(mousePos)) return true;
      }
    }

    for (final comp in components) {
      final compRect = Rect.fromLTWH(comp.gridX * cellSize, comp.gridY * cellSize, cellSize, cellSize);
      if (compRect.contains(mousePos)) return true;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    _wireAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _sparkAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _wireAnimationController.dispose();
    _sparkAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEn = l10n.localeName == 'en';

    final sandboxState = ref.watch(sandboxControllerProvider);

    // Liga/Desliga o loop de animação conforme a simulação estiver rodando ou pausada
    if (sandboxState.isSimulating) {
      if (!_wireAnimationController.isAnimating) {
        _wireAnimationController.repeat();
      }
    } else {
      if (_wireAnimationController.isAnimating) {
        _wireAnimationController.stop();
        _wireAnimationController.reset();
      }
    }

    final controller = ref.read(sandboxControllerProvider.notifier);
    final selectedId = _selectedComponentId;
    final connSource = _connectionSource;

    // Encontra o componente selecionado atualmente
    final selectedComponentList = sandboxState.components.where((c) => c.id == selectedId).toList();
    final selectedComponent = selectedComponentList.isNotEmpty ? selectedComponentList.first : null;

    // Determina a emoção e mensagem do Professor Volts
    ProfVoltsEmotion voltsEmotion = ProfVoltsEmotion.neutral;
    String voltsMessage = isEn
        ? "Click and drag components from the palette to the grid, then connect their terminals (red/black circles) to build a circuit!"
        : "Arraste componentes da paleta para o grid, depois ligue seus terminais (círculos vermelho/preto) para montar um circuito!";

    if (sandboxState.isSimulating) {
      if (sandboxState.errorMessage != null) {
        voltsEmotion = ProfVoltsEmotion.sad;
        voltsMessage = isEn
            ? "WARNING: ${sandboxState.errorMessage} The circuit was disconnected to prevent overload."
            : "ALERTA: ${sandboxState.errorMessage} O circuito foi desarmado para proteção.";
      } else if (sandboxState.simulationValues.isNotEmpty) {
        voltsEmotion = ProfVoltsEmotion.happy;
        voltsMessage = isEn
            ? "SUCCESS: Loop closed! Check the currents and voltage drops on the components."
            : "SUCESSO: Loop fechado! Veja as correntes e quedas de tensão nos componentes.";
      } else {
        voltsEmotion = ProfVoltsEmotion.neutral;
        voltsMessage = isEn
            ? "Simulation active, but no closed loop found. Connect wires to complete the path."
            : "Simulação ligada, mas sem loop fechado. Conecte fios para fechar o circuito.";
      }
    }

    // Reabre o painel do mascote quando a emoção mudar de neutro para happy/sad
    if (voltsEmotion != _lastVoltsEmotion && voltsEmotion != ProfVoltsEmotion.neutral) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() { _showMascot = true; });
      });
    }
    if (voltsEmotion != _lastVoltsEmotion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() { _lastVoltsEmotion = voltsEmotion; });
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileWidth = screenWidth < 460;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.delete): () {
          if (_selectedWireId != null) {
            controller.removeWire(_selectedWireId!);
            setState(() => _selectedWireId = null);
          } else if (_selectedComponentIds.isNotEmpty) {
            controller.removeComponents(_selectedComponentIds);
            setState(() => _selectedComponentIds.clear());
          }
        },
        const SingleActivator(LogicalKeyboardKey.backspace): () {
          if (_selectedWireId != null) {
            controller.removeWire(_selectedWireId!);
            setState(() => _selectedWireId = null);
          } else if (_selectedComponentIds.isNotEmpty) {
            controller.removeComponents(_selectedComponentIds);
            setState(() => _selectedComponentIds.clear());
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyR): () {
          if (_selectedComponentIds.isNotEmpty) {
            controller.rotateComponents(_selectedComponentIds);
          }
        },
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          if (_selectedComponentIds.isNotEmpty) {
            controller.moveComponents(_selectedComponentIds, 0, -1);
          }
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          if (_selectedComponentIds.isNotEmpty) {
            controller.moveComponents(_selectedComponentIds, 0, 1);
          }
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          if (_selectedComponentIds.isNotEmpty) {
            controller.moveComponents(_selectedComponentIds, -1, 0);
          }
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          if (_selectedComponentIds.isNotEmpty) {
            controller.moveComponents(_selectedComponentIds, 1, 0);
          }
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          setState(() {
            _selectedComponentIds.clear();
            _selectedWireId = null;
          });
        },
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
          controller.undo();
        },
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): () {
          controller.undo();
        },
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () {
          controller.redo();
        },
        const SingleActivator(LogicalKeyboardKey.keyY, meta: true): () {
          controller.redo();
        },
        const SingleActivator(LogicalKeyboardKey.space): () {
          if (_selectedComponentId != null) {
            final compList = sandboxState.components.where((c) => c.id == _selectedComponentId).toList();
            if (compList.isNotEmpty && compList.first.type == ComponentType.switchComponent) {
              controller.toggleComponentActive(_selectedComponentId!);
            }
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: isMobileWidth
                ? null
                : Text(
                    isEn ? 'Free Sandbox' : 'Bancada Livre',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
            actions: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Menu de Presets / Exemplos de Circuitos
                    PopupMenuButton<String>(
                      tooltip: isEn ? "Circuit Presets" : "Exemplos de Circuitos",
                      icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF00F5D4)),
                      color: isDark ? const Color(0xFF141E33) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (key) {
                        controller.loadPreset(key);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEn ? 'Loaded circuit preset!' : 'Circuito de exemplo carregado!'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'simple_bulb',
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded, size: 18, color: Color(0xFFFFB300)),
                              const SizedBox(width: 8),
                              Text(isEn ? 'Simple Circuit (Lamp)' : 'Circuito Simples (Lâmpada)', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'switch_motor',
                          child: Row(
                            children: [
                              const Icon(Icons.toggle_on_rounded, size: 18, color: Color(0xFF00F5D4)),
                              const SizedBox(width: 8),
                              Text(isEn ? 'Switch & Motor' : 'Interruptor & Motor', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'led_resistor',
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on_rounded, size: 18, color: Color(0xFFFF3B7F)),
                              const SizedBox(width: 8),
                              Text(isEn ? 'LED & Resistor' : 'LED com Resistor', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'parallel_bulbs',
                          child: Row(
                            children: [
                              const Icon(Icons.account_tree_rounded, size: 18, color: Color(0xFF00FF9D)),
                              const SizedBox(width: 8),
                              Text(isEn ? 'Parallel Circuit' : 'Circuito em Paralelo', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Alternador de Modo: Componentes Físicos vs Diagrama Esquemático
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ModeToggleSwitch(
                        isDiagramMode: _isDiagramMode,
                        onChanged: (val) => setState(() => _isDiagramMode = val),
                        isCompact: true,
                      ),
                    ),
                    // Botão "Modo realista" / "Modo cartoon"
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(() {
                            _useRealisticAssets = !_useRealisticAssets;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _useRealisticAssets
                                ? theme.colorScheme.primary.withValues(alpha: 0.18)
                                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _useRealisticAssets
                                  ? theme.colorScheme.primary
                                  : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _useRealisticAssets ? Icons.photo_library_rounded : Icons.brush_rounded,
                                size: 14,
                                color: _useRealisticAssets ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _useRealisticAssets ? 'Modo realista' : 'Modo cartoon',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: GoogleFonts.rajdhani().fontFamily,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  color: _useRealisticAssets ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Seletor de Tamanho da Bancada / Grid
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black45 : Colors.white60,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF00F5D4).withValues(alpha: 0.4) : const Color(0xFF00F5D4),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isMobileWidth)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              icon: Icon(Icons.remove, size: 14, color: isDark ? Colors.white70 : Colors.black87),
                              tooltip: isEn ? "Decrease Grid Size" : "Diminuir Grid",
                              onPressed: (_gridCols > 4 && _gridRows > 3)
                                  ? () {
                                      setState(() {
                                        _gridCols = math.max(4, _gridCols - 1);
                                        _gridRows = math.max(3, _gridRows - 1);
                                      });
                                    }
                                  : null,
                            ),
                          PopupMenuButton<String>(
                            tooltip: isEn ? "Grid Presets" : "Tamanhos de Grid",
                            offset: const Offset(0, 36),
                            color: isDark ? const Color(0xFF141E33) : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.grid_4x4_rounded, size: 14, color: isDark ? const Color(0xFF00F5D4) : Colors.black87),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_gridCols x $_gridRows',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                                      color: isDark ? const Color(0xFF00F5D4) : Colors.black87,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down, size: 14, color: isDark ? const Color(0xFF00F5D4) : Colors.black87),
                                ],
                              ),
                            ),
                            onSelected: (preset) {
                              final parts = preset.split('x');
                              if (parts.length == 2) {
                                setState(() {
                                  _gridCols = int.parse(parts[0]);
                                  _gridRows = int.parse(parts[1]);
                                });
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: '8x5',
                                child: Text('8 × 5 (${isEn ? "Standard" : "Padrão"})', style: const TextStyle(fontSize: 12)),
                              ),
                              PopupMenuItem(
                                value: '10x6',
                                child: Text('10 × 6 (${isEn ? "Medium" : "Médio"})', style: const TextStyle(fontSize: 12)),
                              ),
                              PopupMenuItem(
                                value: '12x8',
                                child: Text('12 × 8 (${isEn ? "Large" : "Grande"})', style: const TextStyle(fontSize: 12)),
                              ),
                              PopupMenuItem(
                                value: '14x10',
                                child: Text('14 × 10 (${isEn ? "Extra Large" : "Extra Grande"})', style: const TextStyle(fontSize: 12)),
                              ),
                              PopupMenuItem(
                                value: '18x12',
                                child: Text('18 × 12 (${isEn ? "Maximum" : "Máximo"})', style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          if (!isMobileWidth)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              icon: Icon(Icons.add, size: 14, color: isDark ? Colors.white70 : Colors.black87),
                              tooltip: isEn ? "Increase Grid Size" : "Aumentar Grid",
                              onPressed: (_gridCols < 18 && _gridRows < 15)
                                  ? () {
                                      setState(() {
                                        _gridCols = math.min(18, _gridCols + 1);
                                        _gridRows = math.min(15, _gridRows + 1);
                                      });
                                    }
                                  : null,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: TechGridBackground(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 650;

                  Widget bodyContent;
                  if (isNarrow) {
                    bodyContent = Column(
                      children: [
                        SizedBox(
                          height: 115,
                          child: SandboxToolboxWidget(
                            isHorizontal: true,
                            isDark: isDark,
                            isDiagramMode: _isDiagramMode,
                            useRealisticAssets: _useRealisticAssets,
                            getComponentName: _getComponentName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _buildGridCanvas(sandboxState, selectedId, connSource, isDark),
                        ),
                        if (selectedComponent != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 260,
                            child: SandboxMetricsPanelWidget(
                              component: selectedComponent,
                              wires: sandboxState.wires,
                              allComponents: sandboxState.components,
                              isEn: isEn,
                              isDark: isDark,
                              getComponentName: _getComponentName,
                              onDeselect: () => setState(() => _selectedComponentId = null),
                            ),
                          ),
                        ],
                      ],
                    );
                  } else {
                    bodyContent = Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: SandboxToolboxWidget(
                            isHorizontal: false,
                            isDark: isDark,
                            isDiagramMode: _isDiagramMode,
                            useRealisticAssets: _useRealisticAssets,
                            getComponentName: _getComponentName,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGridCanvas(sandboxState, selectedId, connSource, isDark),
                        ),
                        if (selectedComponent != null) ...[
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 200,
                            child: SandboxMetricsPanelWidget(
                              component: selectedComponent,
                              wires: sandboxState.wires,
                              allComponents: sandboxState.components,
                              isEn: isEn,
                              isDark: isDark,
                              getComponentName: _getComponentName,
                              onDeselect: () => setState(() => _selectedComponentId = null),
                            ),
                          ),
                        ],
                      ],
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(child: bodyContent),

                              // Instrumento Flutuante 1: Multímetro Digital
                              if (_showMultimeter)
                                Positioned(
                                  top: 8,
                                  left: isNarrow ? 8 : 150,
                                  child: SandboxMultimeterWidget(
                                    mode: _multimeterMode,
                                    sandboxState: sandboxState,
                                    redProbe: _redProbe,
                                    blackProbe: _blackProbe,
                                    isDark: isDark,
                                    isEn: isEn,
                                    isHold: _isHoldMultimeter,
                                    onModeChanged: (newMode) => setState(() => _multimeterMode = newMode),
                                    onResetProbes: () => setState(() {
                                      _redProbe = const MultimeterProbeConnection();
                                      _blackProbe = const MultimeterProbeConnection();
                                    }),
                                    onToggleHold: () => setState(() => _isHoldMultimeter = !_isHoldMultimeter),
                                  ),
                                ),

                              // Instrumento Flutuante 2: Osciloscópio HUD
                              if (_showOscilloscope)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: SandboxOscilloscopeWidget(
                                    sandboxState: sandboxState,
                                    isDark: isDark,
                                    isEn: isEn,
                                    voltageSignal: sandboxState.simulationValues['voltage_drop_${selectedId ?? ""}'] ??
                                        (sandboxState.simulationValues.values.isNotEmpty ? sandboxState.simulationValues.values.first : 0.0),
                                    currentSignal: sandboxState.simulationValues['current_${selectedId ?? ""}'] ?? 0.0,
                                    onClose: () => setState(() => _showOscilloscope = false),
                                  ),
                                ),

                              // Painel Flutuante do Prof. Volts no Canto Inferior Direito (Overlay sem achatar o canvas)
                              if (_showMascot)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  width: isNarrow ? (constraints.maxWidth - 48) : 380,
                                  child: SandboxMascotPanelWidget(
                                    emotion: voltsEmotion,
                                    message: voltsMessage,
                                    isDark: isDark,
                                    onClose: () => setState(() => _showMascot = false),
                                    onQuickAction: sandboxState.burnedComponentIds.isNotEmpty
                                        ? () => controller.replaceAllBurnedComponents()
                                        : null,
                                    quickActionLabel: sandboxState.burnedComponentIds.isNotEmpty
                                        ? (isEn ? 'Replace All Burned' : 'Substituir Todos Queimados')
                                        : null,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SandboxControlBarWidget(
                          state: sandboxState,
                          connSource: connSource,
                          isEn: isEn,
                          isDark: isDark,
                          canUndo: controller.canUndo,
                          canRedo: controller.canRedo,
                          onCancelWiring: () => setState(() => _connectionSource = null),
                          onClearCanvas: () {
                            controller.clearCanvas();
                            setState(() => _selectedComponentId = null);
                          },
                          onUndo: () {
                            controller.undo();
                            setState(() {});
                          },
                          onRedo: () {
                            controller.redo();
                            setState(() {});
                          },
                          onToggleSimulation: () => controller.toggleSimulation(),
                          showMultimeter: _showMultimeter,
                          showOscilloscope: _showOscilloscope,
                          onToggleMultimeter: () => setState(() => _showMultimeter = !_showMultimeter),
                          onToggleOscilloscope: () => setState(() => _showOscilloscope = !_showOscilloscope),
                          onOpenInspector: () => _openInspectorDialog(sandboxState, isEn, isDark),
                          onOpenChallenges: () => _openChallengesDialog(sandboxState, isEn, isDark),
                          onOpenExportReport: () => _openExportReportDialog(sandboxState, isEn, isDark),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- GRID INTERATIVO E RENDER DE COMPONENTES ---

  Widget _buildGridCanvas(SandboxState state, String? selectedId, ConnectionSource? connSource, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth.isInfinite ? 520.0 : constraints.maxWidth;
        final double availableHeight = constraints.maxHeight.isInfinite ? 420.0 : constraints.maxHeight;

        final double cellSizeFromWidth = availableWidth / _gridCols;
        final double cellSizeFromHeight = availableHeight / _gridRows;
        final double cellSize = cellSizeFromWidth.clamp(0, cellSizeFromHeight);

        final double width = cellSize * _gridCols;
        final double height = cellSize * _gridRows;

        final selectedComponentList = state.components.where((c) => c.id == selectedId).toList();
        final selectedComponent = selectedComponentList.isNotEmpty ? selectedComponentList.first : null;

        final gridContainer = Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1424).withValues(alpha: 0.4) : Colors.grey.shade100.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 1.8,
            ),
          ),
          child: Stack(
            children: [
              // 1. Grid de fundo com retículo HUD
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPainter(
                    columns: _gridCols,
                    rows: _gridRows,
                    isDark: isDark,
                    hoverCell: _hoverGridCell,
                  ),
                ),
              ),

              // 2. Fios conectados
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _wireAnimationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: WiresPainter(
                        wires: state.wires,
                        components: state.components,
                        cellSize: cellSize,
                        isDark: isDark,
                        isDiagramMode: _isDiagramMode,
                        isSimulating: state.isSimulating,
                        simulationValues: state.simulationValues,
                        animationValue: state.isSimulating ? _wireAnimationController.value : 0.0,
                        isShortCircuit: state.isShortCircuit,
                        shortCircuitWireIds: state.shortCircuitWireIds,
                        selectedWireId: _selectedWireId,
                      ),
                    );
                  },
                ),
              ),

              // 3. DragTargets em cada célula
              for (int x = 0; x < _gridCols; x++)
                for (int y = 0; y < _gridRows; y++)
                  _buildGridCellDragTarget(x, y, cellSize, state),

              // 3.5. Retângulo de Seleção por Caixa (Marquee Box Selection)
              if (_isBoxSelecting && _boxSelectionStart != null && _boxSelectionCurrent != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: MarqueeSelectionPainter(
                        start: _boxSelectionStart!,
                        current: _boxSelectionCurrent!,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),

              // 4. Render dos componentes colocados
              for (final component in state.components)
                _buildPlacedComponent(component, cellSize, selectedId, isDark),

              // 4.5. Floating Quick HUD Toolbar no componente selecionado (Seleção Única)
              if (_selectedComponentIds.length == 1 && selectedComponent != null)
                SandboxQuickHudWidget(
                  selectedComponent: selectedComponent,
                  cellSize: cellSize,
                  width: width,
                  isDark: isDark,
                  onRotate: () => ref.read(sandboxControllerProvider.notifier).rotateComponent(selectedComponent.id),
                  onToggleActive: selectedComponent.type == ComponentType.switchComponent
                      ? () => ref.read(sandboxControllerProvider.notifier).toggleComponentActive(selectedComponent.id)
                      : null,
                  onDelete: () {
                    ref.read(sandboxControllerProvider.notifier).removeComponent(selectedComponent.id);
                    setState(() => _selectedComponentIds.clear());
                  },
                ),

              // 4.6. Floating Multi-Selection HUD Toolbar quando múltiplos componentes estão selecionados
              if (_selectedComponentIds.length > 1)
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SandboxMultiSelectionHudWidget(
                      selectedCount: _selectedComponentIds.length,
                      onRotate: () => ref.read(sandboxControllerProvider.notifier).rotateComponents(_selectedComponentIds),
                      onDelete: () {
                        ref.read(sandboxControllerProvider.notifier).removeComponents(_selectedComponentIds);
                        setState(() => _selectedComponentIds.clear());
                      },
                      onDeselect: () => setState(() => _selectedComponentIds.clear()),
                      isDark: isDark,
                    ),
                  ),
                ),

              // 4.7. Floating Wire HUD Toolbar quando um fio é selecionado no canvas
              if (_selectedWireId != null) () {
                final selectedWireList = state.wires.where((w) => w.id == _selectedWireId).toList();
                if (selectedWireList.isNotEmpty) {
                  final wireMidpoint = _getWireMidpoint(selectedWireList.first, cellSize, state.components);
                  if (wireMidpoint != null) {
                    return SandboxWireHudWidget(
                      position: wireMidpoint,
                      isDark: isDark,
                      onDelete: () {
                        ref.read(sandboxControllerProvider.notifier).removeWire(_selectedWireId!);
                        setState(() => _selectedWireId = null);
                      },
                    );
                  }
                }
                return const SizedBox.shrink();
              }(),

              // 5. Linha guia de fiação temporária (Acompanha o cursor em tempo real)
              if (connSource != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: TemporaryWireLayer(
                      source: connSource,
                      snappedTarget: _snappedTarget,
                      mousePosition: _currentMousePos,
                      components: state.components,
                      cellSize: cellSize,
                      isDark: isDark,
                    ),
                  ),
                ),

              // 6. Camada de Faísca Elétrica de Conexão (Spark Flash)
              if (_sparkPosition != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _sparkAnimationController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ConnectionSparkPainter(
                            position: _sparkPosition!,
                            progress: _sparkAnimationController.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );

        final interactiveGridContainer = Listener(
          onPointerDown: (event) {
            final mousePos = event.localPosition;
            final hitTerminal = _findTerminalAtPosition(mousePos, cellSize, state.components);

            if (_showMultimeter && _connectionSource == null && hitTerminal != null) {
              setState(() {
                if (_redProbe.componentId == null || (_redProbe.componentId != null && _blackProbe.componentId != null)) {
                  _redProbe = MultimeterProbeConnection(componentId: hitTerminal.componentId, terminal: hitTerminal.terminal);
                } else {
                  _blackProbe = MultimeterProbeConnection(componentId: hitTerminal.componentId, terminal: hitTerminal.terminal);
                }
              });
              return;
            }

            if (_connectionSource == null) {
              if (hitTerminal != null) {
                final snapped = _findNearestTerminal(mousePos, cellSize, state.components, hitTerminal);
                setState(() {
                  _connectionSource = hitTerminal;
                  _dragStartPosition = mousePos;
                  _currentMousePos = mousePos;
                  _snappedTarget = snapped;
                  _isDraggingWire = true;
                  _selectedWireId = null;
                });
              } else {
                final hitComp = _findComponentAtPosition(mousePos, cellSize, state.components);
                if (hitComp != null) {
                  setState(() {
                    _selectedWireId = null;
                    if (HardwareKeyboard.instance.isShiftPressed || HardwareKeyboard.instance.isControlPressed) {
                      if (_selectedComponentIds.contains(hitComp.id)) {
                        _selectedComponentIds.remove(hitComp.id);
                      } else {
                        _selectedComponentIds.add(hitComp.id);
                      }
                    } else if (!_selectedComponentIds.contains(hitComp.id)) {
                      _selectedComponentIds = {hitComp.id};
                    }
                  });
                } else {
                  final hitWire = _findWireAtPosition(mousePos, cellSize, state.wires, state.components);
                  if (hitWire != null) {
                    setState(() {
                      _selectedWireId = hitWire.id;
                      _selectedComponentIds.clear();
                    });
                  } else if (!_isPositionOverHudOrComponent(mousePos, cellSize, width, state.components, _selectedComponentIds, _selectedWireId, state.wires)) {
                    setState(() {
                      _selectedWireId = null;
                      if (!HardwareKeyboard.instance.isShiftPressed && !HardwareKeyboard.instance.isControlPressed) {
                        _selectedComponentIds.clear();
                      }
                      _boxSelectionStart = mousePos;
                      _boxSelectionCurrent = mousePos;
                      _isBoxSelecting = true;
                    });
                  }
                }
              }
            } else {
              if (!_isDraggingWire) {
                final target = _snappedTarget ?? hitTerminal;
                if (target != null && (target.componentId != _connectionSource!.componentId || target.terminal != _connectionSource!.terminal)) {
                  ref.read(sandboxControllerProvider.notifier).addWire(
                    _connectionSource!.componentId,
                    _connectionSource!.terminal,
                    target.componentId,
                    target.terminal,
                  );
                  _triggerSpark(mousePos);
                }
                setState(() {
                  _connectionSource = null;
                  _snappedTarget = null;
                  _currentMousePos = null;
                  _isDraggingWire = false;
                  _dragStartPosition = null;
                });
              }
            }
          },
          onPointerMove: (event) {
            final mousePos = event.localPosition;
            final cellX = (mousePos.dx / cellSize).clamp(0.0, (_gridCols - 1).toDouble());
            final cellY = (mousePos.dy / cellSize).clamp(0.0, (_gridRows - 1).toDouble());

            if (_isBoxSelecting && _boxSelectionStart != null) {
              setState(() {
                _boxSelectionCurrent = mousePos;
                final selRect = Rect.fromPoints(_boxSelectionStart!, _boxSelectionCurrent!);
                final newlySelected = <String>{..._selectedComponentIds};
                for (final comp in state.components) {
                  final compRect = Rect.fromLTWH(
                    comp.gridX * cellSize,
                    comp.gridY * cellSize,
                    cellSize,
                    cellSize,
                  );
                  if (selRect.overlaps(compRect)) {
                    newlySelected.add(comp.id);
                  }
                }
                _selectedComponentIds = newlySelected;
                _hoverGridCell = Offset(cellX, cellY);
              });
            } else if (_connectionSource != null) {
              final snapped = _findNearestTerminal(mousePos, cellSize, state.components, _connectionSource);
              setState(() {
                _currentMousePos = mousePos;
                _snappedTarget = snapped;
                _hoverGridCell = Offset(cellX, cellY);
              });
            } else {
              setState(() {
                _hoverGridCell = Offset(cellX, cellY);
              });
            }
          },
          onPointerHover: (event) {
            final mousePos = event.localPosition;
            final cellX = (mousePos.dx / cellSize).clamp(0.0, (_gridCols - 1).toDouble());
            final cellY = (mousePos.dy / cellSize).clamp(0.0, (_gridRows - 1).toDouble());

            if (_connectionSource != null) {
              final snapped = _findNearestTerminal(mousePos, cellSize, state.components, _connectionSource);
              setState(() {
                _currentMousePos = mousePos;
                _snappedTarget = snapped;
                _hoverGridCell = Offset(cellX, cellY);
              });
            } else {
              setState(() {
                _hoverGridCell = Offset(cellX, cellY);
              });
            }
          },
          onPointerUp: (event) {
            if (_isBoxSelecting) {
              setState(() {
                _isBoxSelecting = false;
                _boxSelectionStart = null;
                _boxSelectionCurrent = null;
              });
            }
            if (_connectionSource != null && _isDraggingWire && _dragStartPosition != null) {
              final mousePos = event.localPosition;
              final dragDistance = (mousePos - _dragStartPosition!).distance;

              if (dragDistance < 10.0) {
                setState(() {
                  _isDraggingWire = false;
                });
              } else {
                final hitTerminal = _findTerminalAtPosition(mousePos, cellSize, state.components);
                final target = _snappedTarget ?? hitTerminal;

                if (target != null && (target.componentId != _connectionSource!.componentId || target.terminal != _connectionSource!.terminal)) {
                  ref.read(sandboxControllerProvider.notifier).addWire(
                    _connectionSource!.componentId,
                    _connectionSource!.terminal,
                    target.componentId,
                    target.terminal,
                  );
                  _triggerSpark(mousePos);
                }

                setState(() {
                  _connectionSource = null;
                  _snappedTarget = null;
                  _currentMousePos = null;
                  _isDraggingWire = false;
                  _dragStartPosition = null;
                });
              }
            }
          },
          child: gridContainer,
        );

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: interactiveGridContainer,
            ),
          ),
        );
      },
    );
  }

  SandboxComponent? _findComponentAtPosition(Offset pos, double cellSize, List<SandboxComponent> components) {
    for (final comp in components) {
      final rect = Rect.fromLTWH(comp.gridX * cellSize, comp.gridY * cellSize, cellSize, cellSize);
      if (rect.contains(pos)) {
        return comp;
      }
    }
    return null;
  }

  Widget _buildGridCellDragTarget(int gridX, int gridY, double cellSize, SandboxState state) {
    return Positioned(
      left: gridX * cellSize,
      top: gridY * cellSize,
      width: cellSize,
      height: cellSize,
      child: DragTarget<Object>(
        onWillAcceptWithDetails: (details) {
          final data = details.data;
          if (data is ComponentType) {
            final isOccupied = state.components.any((c) => c.gridX == gridX && c.gridY == gridY);
            return !isOccupied;
          } else if (data is SandboxComponent) {
            return true;
          }
          return false;
        },
        onAcceptWithDetails: (details) {
          final data = details.data;
          if (data is ComponentType) {
            final newComponent = SandboxComponent(
              id: '${data.name}_${DateTime.now().millisecondsSinceEpoch}',
              type: data,
              gridX: gridX,
              gridY: gridY,
              value: data == ComponentType.battery ? 9.0 : (data == ComponentType.resistor ? 10.0 : 0.0),
            );
            ref.read(sandboxControllerProvider.notifier).addComponent(newComponent);
            setState(() {
              _selectedComponentIds = {newComponent.id};
            });
          } else if (data is SandboxComponent) {
            final deltaX = gridX - data.gridX;
            final deltaY = gridY - data.gridY;
            if (_selectedComponentIds.contains(data.id) && _selectedComponentIds.length > 1) {
              ref.read(sandboxControllerProvider.notifier).moveComponents(_selectedComponentIds, deltaX, deltaY);
            } else {
              ref.read(sandboxControllerProvider.notifier).moveComponent(data.id, gridX, gridY);
            }
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovered = candidateData.isNotEmpty;
          return Container(
            decoration: BoxDecoration(
              color: isHovered ? const Color(0xFF00F5D4).withValues(alpha: 0.15) : Colors.transparent,
              border: isHovered ? Border.all(color: const Color(0xFF00F5D4), width: 1.5) : null,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }

  void _openInspectorDialog(SandboxState state, bool isEn, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => SandboxInspectorDialog(
        state: state,
        isEn: isEn,
        isDark: isDark,
        onSelectComponent: (compFilterId) {
          setState(() {
            _selectedComponentId = compFilterId;
          });
        },
      ),
    );
  }

  void _openChallengesDialog(SandboxState state, bool isEn, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => SandboxChallengesDialog(
        currentState: state,
        isEn: isEn,
        isDark: isDark,
        onLoadCircuit: (components, wires) {
          ref.read(sandboxControllerProvider.notifier).loadCircuit(components, wires);
          setState(() {
            _selectedComponentId = null;
          });
        },
      ),
    );
  }

  void _openExportReportDialog(SandboxState state, bool isEn, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => SandboxExportDialog(
        state: state,
        isEn: isEn,
        isDark: isDark,
      ),
    );
  }

  Widget _buildPlacedComponent(SandboxComponent component, double cellSize, String? selectedId, bool isDark) {
    final isSelected = _selectedComponentIds.contains(component.id);
    final state = ref.watch(sandboxControllerProvider);
    final active = state.simulationValues['active_${component.id}'] == 1.0;
    final isBurned = state.burnedComponentIds.contains(component.id);
    final power = state.simulationValues['power_${component.id}'] ?? 0.0;
    final voltageDrop = state.simulationValues['voltage_drop_${component.id}'] ?? (component.type == ComponentType.battery ? component.value : 0.0);
    final current = state.simulationValues['current_${component.id}'] ?? 0.0;
    final isHighThermal = state.isSimulating && power > 5.0 && !isBurned && component.type != ComponentType.battery && component.type != ComponentType.powerSupply;
    final showTelemetry = state.isSimulating && (current > 0.0001 || active || isSelected || component.type == ComponentType.battery || component.type == ComponentType.powerSupply);

    final bodyWidget = InkWell(
      onTap: () {
        setState(() {
          if (HardwareKeyboard.instance.isShiftPressed || HardwareKeyboard.instance.isControlPressed) {
            if (_selectedComponentIds.contains(component.id)) {
              _selectedComponentIds.remove(component.id);
            } else {
              _selectedComponentIds.add(component.id);
            }
          } else {
            _selectedComponentIds = {component.id};
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isBurned
              ? const Color(0xFFFF3B7F).withValues(alpha: 0.15)
              : (isHighThermal
                  ? const Color(0xFFFFB300).withValues(alpha: 0.22)
                  : (isSelected
                      ? const Color(0xFF00F5D4).withValues(alpha: 0.12)
                      : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02)))),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBurned
                ? const Color(0xFFFF3B7F)
                : (isHighThermal
                    ? const Color(0xFFFFB300)
                    : (isSelected
                        ? const Color(0xFF00F5D4)
                        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)))),
            width: isSelected || isBurned || isHighThermal ? 2.0 : 1.0,
          ),
          boxShadow: isBurned
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF3B7F).withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : (isHighThermal
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                        blurRadius: 14,
                        spreadRadius: 2,
                      )
                    ]
                  : (isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00F5D4).withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ]
                      : null)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _wireAnimationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: component.rotation * (math.pi / 180.0),
                    child: Stack(
                      children: [
                        if (_isDiagramMode)
                          Positioned.fill(
                            child: Opacity(
                              opacity: isDark ? 0.25 : 0.30,
                              child: CustomPaint(
                                painter: ComponentPhysicalPainter(
                                  type: component.type,
                                  isActive: component.type == ComponentType.switchComponent ? component.isActive : (active || component.isActive),
                                  isBurned: isBurned,
                                  isDarkMode: isDark,
                                  value: component.value,
                                  animationValue: state.isSimulating ? _wireAnimationController.value : 0.0,
                                ),
                              ),
                            ),
                          ),
                        Positioned.fill(
                          child: _isDiagramMode
                              ? CustomPaint(
                                  painter: CircuitSymbolPainter(
                                    type: component.type,
                                    isActive: component.type == ComponentType.switchComponent ? component.isActive : (active || component.isActive),
                                    isBurned: isBurned,
                                    color: isDark ? const Color(0xFF00F5D4) : Colors.black87,
                                    activeColor: active || component.isActive ? const Color(0xFF00FF9D) : const Color(0xFFFFB300),
                                    strokeWidth: active || component.isActive ? 2.8 : 2.0,
                                    value: component.value,
                                    animationValue: state.isSimulating ? _wireAnimationController.value : 0.0,
                                  ),
                                )
                              : (_useRealisticAssets && component.type.getAssetPath(component.type == ComponentType.switchComponent ? component.isActive : (active || component.isActive)) != null
                                  ? Image.asset(
                                      component.type.getAssetPath(component.type == ComponentType.switchComponent ? component.isActive : (active || component.isActive))!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => CustomPaint(
                                        painter: ComponentPhysicalPainter(
                                          type: component.type,
                                          isActive: component.type == ComponentType.switchComponent ? component.isActive : (active || component.isActive),
                                          isBurned: isBurned,
                                          isDarkMode: isDark,
                                          value: component.value,
                                          animationValue: state.isSimulating ? _wireAnimationController.value : 0.0,
                                        ),
                                      ),
                                    )
                                  : CustomPaint(
                                      painter: ComponentPhysicalPainter(
                                        type: component.type,
                                        isActive: component.type == ComponentType.switchComponent ? component.isActive : (active || component.isActive),
                                        isBurned: isBurned,
                                        isDarkMode: isDark,
                                        value: component.value,
                                        animationValue: state.isSimulating ? _wireAnimationController.value : 0.0,
                                      ),
                                    )),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (isHighThermal)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB300),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🔥', style: TextStyle(fontSize: 9)),
                ),
              ),
          ],
        ),
      ),
    );

    final stackChild = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: bodyWidget),
        _buildTerminalPoint(component, 'A', cellSize, isDark),
        _buildTerminalPoint(component, 'B', cellSize, isDark),
        if (showTelemetry)
          Positioned(
            top: -16,
            left: -14,
            right: -14,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1424).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: active ? const Color(0xFF00FF9D) : const Color(0xFF00F5D4).withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (active ? const Color(0xFF00FF9D) : const Color(0xFF00F5D4)).withValues(alpha: 0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${voltageDrop.toStringAsFixed(1)}V',
                      style: TextStyle(
                        color: active ? const Color(0xFF00FF9D) : const Color(0xFF00F5D4),
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Text('•', style: TextStyle(color: Colors.white38, fontSize: 8)),
                    const SizedBox(width: 3),
                    Text(
                      '${(current * 1000).toStringAsFixed(0)}mA',
                      style: const TextStyle(
                        color: Color(0xFFFFD54F),
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    return Positioned(
      left: component.gridX * cellSize,
      top: component.gridY * cellSize,
      width: cellSize,
      height: cellSize,
      child: Draggable<SandboxComponent>(
        data: component,
        onDragStarted: () {
          setState(() {
            if (!_selectedComponentIds.contains(component.id)) {
              _selectedComponentIds = {component.id};
            }
          });
        },
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: cellSize,
            height: cellSize,
            child: Opacity(
              opacity: 0.85,
              child: bodyWidget,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.25,
          child: stackChild,
        ),
        child: stackChild,
      ),
    );
  }

  Widget _buildTerminalPoint(SandboxComponent component, String terminal, double cellSize, bool isDark) {
    final relPos = terminal == 'A' ? component.getTerminalAPosition() : component.getTerminalBPosition();
    final localX = (relPos.dx - component.gridX) * cellSize;
    final localY = (relPos.dy - component.gridY) * cellSize;

    final isSource = _connectionSource?.componentId == component.id && _connectionSource?.terminal == terminal;
    final isSnapped = _snappedTarget?.componentId == component.id && _snappedTarget?.terminal == terminal;
    final isWiringMode = _connectionSource != null;

    final showPolarity = component.type == ComponentType.battery ||
        component.type == ComponentType.led ||
        component.type == ComponentType.diode;
    final polaritySign = terminal == 'B' ? '+' : '-';

    final color = terminal == 'A' ? Colors.black87 : Colors.red;

    const touchAreaSize = 36.0;
    final double currentDotSize = isSource ? 20.0 : (isSnapped ? 22.0 : (isWiringMode ? 16.0 : 14.0));

    return Positioned(
      left: localX - (touchAreaSize / 2),
      top: localY - (touchAreaSize / 2),
      width: touchAreaSize,
      height: touchAreaSize,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            width: currentDotSize,
            height: currentDotSize,
            decoration: BoxDecoration(
              color: (isSource || isSnapped) ? const Color(0xFF00F5D4) : color,
              shape: BoxShape.circle,
              border: Border.all(
                color: (isSource || isSnapped) ? Colors.white : (isWiringMode ? const Color(0xFF00F5D4) : Colors.white),
                width: (isSource || isSnapped) ? 2.8 : 1.5,
              ),
              boxShadow: [
                if (isSnapped)
                  BoxShadow(
                    color: const Color(0xFF00F5D4).withValues(alpha: 0.9),
                    blurRadius: 16,
                    spreadRadius: 4,
                  )
                else if (isSource)
                  BoxShadow(
                    color: const Color(0xFF00F5D4).withValues(alpha: 0.8),
                    blurRadius: 12,
                    spreadRadius: 3,
                  )
                else if (isWiringMode)
                  BoxShadow(
                    color: const Color(0xFF00F5D4).withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 3,
                    spreadRadius: 0.5,
                  ),
              ],
            ),
            child: showPolarity
                ? Center(
                    child: Text(
                      polaritySign,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: currentDotSize * 0.65,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  String _getComponentName(ComponentType type, AppLocalizations l10n) {
    switch (type) {
      case ComponentType.battery:
        return l10n.compBattery;
      case ComponentType.connectingWire:
        return l10n.compConnectingWire;
      case ComponentType.switchComponent:
        return l10n.compSwitch;
      case ComponentType.bulb:
        return l10n.compBulb;
      case ComponentType.resistor:
        return l10n.compResistor;
      case ComponentType.diode:
        return l10n.compDiode;
      case ComponentType.led:
        return l10n.compLED;
      case ComponentType.motor:
        return l10n.compMotor;
      case ComponentType.potentiometer:
        return l10n.localeName == 'en' ? 'Potentiometer' : 'Potenciômetro';
      case ComponentType.powerSupply:
        return l10n.localeName == 'en' ? 'Power Supply Studio' : 'Fonte Regulável';
      case ComponentType.fuse:
        return l10n.localeName == 'en' ? 'Fuse' : 'Fusível';
      case ComponentType.capacitor:
        return l10n.localeName == 'en' ? 'Capacitor' : 'Capacitor';
      case ComponentType.buzzer:
        return l10n.localeName == 'en' ? 'Buzzer Alarm' : 'Buzzer / Alarme';
    }
  }
}