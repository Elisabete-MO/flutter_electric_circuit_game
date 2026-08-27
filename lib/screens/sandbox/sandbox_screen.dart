import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/first_step_component.dart';
import '../../models/sandbox_component.dart';
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

class _SandboxScreenState extends ConsumerState<SandboxScreen> with SingleTickerProviderStateMixin {
  int _gridCols = 6;
  int _gridRows = 5;

  String? _selectedComponentId;
  ConnectionSource? _connectionSource;
  ConnectionSource? _snappedTarget;
  Offset? _currentMousePos;
  late final AnimationController _wireAnimationController;
  bool _showMascot = true;
  bool _isDiagramMode = false;
  ProfVoltsEmotion _lastVoltsEmotion = ProfVoltsEmotion.neutral;

  // Pilar 1: Instrumentos Virtuais de Medição (Multímetro & Osciloscópio)
  bool _showMultimeter = false;
  bool _showOscilloscope = false;
  MultimeterMode _multimeterMode = MultimeterMode.voltageDC;
  MultimeterProbeConnection _redProbe = const MultimeterProbeConnection();
  MultimeterProbeConnection _blackProbe = const MultimeterProbeConnection();
  bool _isHoldMultimeter = false;

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

  @override
  void initState() {
    super.initState();
    _wireAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _wireAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEn = l10n.localeName == 'en';

    final sandboxState = ref.watch(sandboxControllerProvider);
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

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.delete): () {
          if (_selectedComponentId != null) {
            controller.removeComponent(_selectedComponentId!);
            setState(() => _selectedComponentId = null);
          }
        },
        const SingleActivator(LogicalKeyboardKey.backspace): () {
          if (_selectedComponentId != null) {
            controller.removeComponent(_selectedComponentId!);
            setState(() => _selectedComponentId = null);
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyR): () {
          if (_selectedComponentId != null) {
            controller.rotateComponent(_selectedComponentId!);
          }
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
            title: Text(
              isEn ? 'Free Sandbox' : 'Bancada Livre',
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            actions: [
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
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                          value: '6x5',
                          child: Text('6 × 5 (${isEn ? "Standard" : "Padrão"})', style: const TextStyle(fontSize: 12)),
                        ),
                        PopupMenuItem(
                          value: '8x6',
                          child: Text('8 × 6 (${isEn ? "Medium" : "Médio"})', style: const TextStyle(fontSize: 12)),
                        ),
                        PopupMenuItem(
                          value: '10x8',
                          child: Text('10 × 8 (${isEn ? "Large" : "Grande"})', style: const TextStyle(fontSize: 12)),
                        ),
                        PopupMenuItem(
                          value: '12x10',
                          child: Text('12 × 10 (${isEn ? "Extra Large" : "Extra Grande"})', style: const TextStyle(fontSize: 12)),
                        ),
                        PopupMenuItem(
                          value: '16x12',
                          child: Text('16 × 12 (${isEn ? "Maximum" : "Máximo"})', style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
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
                          height: 90,
                          child: SandboxToolboxWidget(
                            isHorizontal: true,
                            isDark: isDark,
                            isDiagramMode: _isDiagramMode,
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
                            height: 220,
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
              // 1. Grid de fundo
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPainter(
                    columns: _gridCols,
                    rows: _gridRows,
                    isDark: isDark,
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
                        animationValue: _wireAnimationController.value,
                      ),
                    );
                  },
                ),
              ),

              // 3. DragTargets em cada célula
              for (int x = 0; x < _gridCols; x++)
                for (int y = 0; y < _gridRows; y++)
                  _buildGridCellDragTarget(x, y, cellSize, state),

              // 4. Render dos componentes colocados
              for (final component in state.components)
                _buildPlacedComponent(component, cellSize, selectedId, isDark),

              // 4.5. Floating Quick HUD Toolbar no componente selecionado
              if (selectedComponent != null)
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
                    setState(() => _selectedComponentId = null);
                  },
                ),

              // 5. Linha guia de fiação temporária
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
            ],
          ),
        );

        return MouseRegion(
          onHover: (event) {
            if (_connectionSource != null) {
              final mousePos = event.localPosition;
              final snapped = _findNearestTerminal(mousePos, cellSize, state.components, _connectionSource);
              if (_snappedTarget?.componentId != snapped?.componentId || _snappedTarget?.terminal != snapped?.terminal) {
                setState(() {
                  _currentMousePos = mousePos;
                  _snappedTarget = snapped;
                });
              } else if (_currentMousePos != mousePos) {
                setState(() {
                  _currentMousePos = mousePos;
                });
              }
            }
          },
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: gridContainer,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridCellDragTarget(int gridX, int gridY, double cellSize, SandboxState state) {
    return Positioned(
      left: gridX * cellSize,
      top: gridY * cellSize,
      width: cellSize,
      height: cellSize,
      child: DragTarget<ComponentType>(
        onWillAcceptWithDetails: (details) {
          final isOccupied = state.components.any((c) => c.gridX == gridX && c.gridY == gridY);
          return !isOccupied;
        },
        onAcceptWithDetails: (details) {
          final type = details.data;
          final newComponent = SandboxComponent(
            id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}',
            type: type,
            gridX: gridX,
            gridY: gridY,
            value: type == ComponentType.battery ? 9.0 : (type == ComponentType.resistor ? 10.0 : 0.0),
          );
          ref.read(sandboxControllerProvider.notifier).addComponent(newComponent);
          setState(() {
            _selectedComponentId = newComponent.id;
          });
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
    final isSelected = component.id == selectedId;
    final state = ref.watch(sandboxControllerProvider);
    final active = state.simulationValues['active_${component.id}'] == 1.0;
    final isBurned = state.burnedComponentIds.contains(component.id);
    final power = state.simulationValues['power_${component.id}'] ?? 0.0;
    final isHighThermal = state.isSimulating && power > 5.0 && !isBurned && component.type != ComponentType.battery && component.type != ComponentType.powerSupply;

    final bodyWidget = InkWell(
      onTap: () {
        setState(() {
          _selectedComponentId = component.id;
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
              child: Transform.rotate(
                angle: component.rotation * (math.pi / 180.0),
                child: CustomPaint(
                  painter: _isDiagramMode
                      ? CircuitSymbolPainter(
                          type: component.type,
                          isActive: component.type == ComponentType.switchComponent ? component.isActive : (active || component.isActive),
                          isBurned: isBurned,
                          color: isDark ? const Color(0xFF00F5D4) : Colors.black87,
                          activeColor: active || component.isActive ? const Color(0xFF00FF9D) : const Color(0xFFFFB300),
                          strokeWidth: active || component.isActive ? 2.8 : 2.0,
                        )
                      : ComponentPhysicalPainter(
                          type: component.type,
                          isActive: component.type == ComponentType.switchComponent ? component.isActive : (active || component.isActive),
                          isBurned: isBurned,
                          isDarkMode: isDark,
                        ),
                ),
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
      ],
    );

    return Positioned(
      left: component.gridX * cellSize,
      top: component.gridY * cellSize,
      width: cellSize,
      height: cellSize,
      child: LongPressDraggable<SandboxComponent>(
        data: component,
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: cellSize,
            height: cellSize,
            child: Opacity(
              opacity: 0.8,
              child: bodyWidget,
            ),
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final connSource = _connectionSource;
          if (_showMultimeter && connSource == null) {
            setState(() {
              if (_redProbe.componentId == null || (_redProbe.componentId != null && _blackProbe.componentId != null)) {
                _redProbe = MultimeterProbeConnection(componentId: component.id, terminal: terminal);
              } else {
                _blackProbe = MultimeterProbeConnection(componentId: component.id, terminal: terminal);
              }
            });
            return;
          }

          if (connSource == null) {
            setState(() {
              _connectionSource = ConnectionSource(component.id, terminal);
              _snappedTarget = null;
            });
          } else {
            if (connSource.componentId != component.id || connSource.terminal != terminal) {
              final targetTerm = isSnapped ? _snappedTarget!.terminal : terminal;
              final targetCompId = isSnapped ? _snappedTarget!.componentId : component.id;
              ref.read(sandboxControllerProvider.notifier).addWire(
                connSource.componentId,
                connSource.terminal,
                targetCompId,
                targetTerm,
              );
            }
            setState(() {
              _connectionSource = null;
              _snappedTarget = null;
            });
          }
        },
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