import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/first_step_component.dart';
import '../../models/sandbox_component.dart';
import '../../models/sandbox_wire.dart';
import '../../models/sandbox_state.dart';
import '../../state/sandbox_controller.dart';
import '../../widgets/tech_grid_background.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/prof_volts_full_body.dart';
import '../../widgets/component_physical_painter.dart';

// Estrutura local para rastrear se o usuário está criando uma conexão (borne de origem selecionado)
class ConnectionSource {
  final String componentId;
  final String terminal; // 'A' ou 'B'

  ConnectionSource(this.componentId, this.terminal);
}

class SandboxScreen extends ConsumerStatefulWidget {
  const SandboxScreen({super.key});

  @override
  ConsumerState<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends ConsumerState<SandboxScreen> with SingleTickerProviderStateMixin {
  static const int gridCols = 6;
  static const int gridRows = 5;

  String? _selectedComponentId;
  ConnectionSource? _connectionSource;
  late final AnimationController _wireAnimationController;

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

    return Scaffold(
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
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEn
                        ? "Double tap a component to rotate it. Tap terminals to draw wires."
                        : "Toque duplo em um componente para rotacioná-lo. Toque nos terminais para puxar fios.",
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: TechGridBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;

              // Layout responsivo: duas colunas em telas largas, uma em telas estreitas
              final bodyContent = isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Coluna da Esquerda: Paleta de Componentes
                        SizedBox(
                          width: 180,
                          child: _buildToolbox(l10n, isDark),
                        ),
                        const SizedBox(width: 16),

                        // Coluna Central: Grid Canvas
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: _buildGridCanvas(sandboxState, selectedId, connSource, isDark),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildMascotPanel(voltsEmotion, voltsMessage, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Coluna da Direita: Detalhes do Componente
                        SizedBox(
                          width: 200,
                          child: _buildDetailsPanel(selectedComponent, isEn, isDark),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Paleta horizontal no topo
                          SizedBox(
                            height: 120,
                            child: _buildHorizontalToolbox(l10n, isDark),
                          ),
                          const SizedBox(height: 16),

                          // Grid Canvas
                          _buildGridCanvas(sandboxState, selectedId, connSource, isDark),
                          const SizedBox(height: 16),

                          // Detalhes do Componente
                          _buildDetailsPanel(selectedComponent, isEn, isDark),
                          const SizedBox(height: 16),

                          // Mascote
                          _buildMascotPanel(voltsEmotion, voltsMessage, isDark),
                        ],
                      ),
                    );

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Área Principal
                    Expanded(child: bodyContent),
                    const SizedBox(height: 16),

                    // Barra de Controles Inferior
                    _buildSimulationControlBar(sandboxState, isEn, isDark),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- PALETA DE COMPONENTES (TOOLBOX VERTICAL E HORIZONTAL) ---

  Widget _buildToolbox(AppLocalizations l10n, bool isDark) {
    final types = _availableTypes();
    return GlassContainer(
      borderRadius: 16,
      opacity: isDark ? 0.35 : 0.6,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.symbolsPaletteTitle.toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: types.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildToolboxItem(types[index], l10n, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalToolbox(AppLocalizations l10n, bool isDark) {
    final types = _availableTypes();
    return GlassContainer(
      borderRadius: 16,
      opacity: isDark ? 0.35 : 0.6,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.symbolsPaletteTitle.toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: types.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 90,
                  child: _buildToolboxItem(types[index], l10n, isDark, compact: true),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ComponentType> _availableTypes() {
    return [
      ComponentType.battery,
      ComponentType.switchComponent,
      ComponentType.bulb,
      ComponentType.resistor,
      ComponentType.motor,
      ComponentType.led,
      ComponentType.diode,
    ];
  }

  Widget _buildToolboxItem(ComponentType type, AppLocalizations l10n, bool isDark, {bool compact = false}) {
    final name = _getComponentName(type, l10n);

    // Widget que vive na lista (tamanho controlado pelo ListView)
    final itemWidget = LayoutBuilder(
      builder: (context, constraints) {
        // Calcula altura disponível para o ícone descontando o padding e o texto
        final iconHeight = (constraints.maxHeight - 6 - 6 - 4 - 16).clamp(24.0, 64.0);
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: iconHeight,
                width: double.infinity,
                child: CustomPaint(
                  painter: ComponentPhysicalPainter(
                    type: type,
                    isActive: false,
                    isDarkMode: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: compact ? 9 : 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );

    // Widget independente para o feedback de arrastar (tamanho fixo, não depende de constraints externas)
    final feedbackWidget = Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: 0.75,
        child: SizedBox(
          width: 90,
          height: 90,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF00F5D4).withValues(alpha: 0.5) : const Color(0xFF00F5D4).withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: ComponentPhysicalPainter(
                      type: type,
                      isActive: false,
                      isDarkMode: isDark,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Draggable<ComponentType>(
      data: type,
      feedback: feedbackWidget,
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: itemWidget,
      ),
      child: itemWidget,
    );
  }

  // --- GRID INTERATIVO E RENDER DE COMPONENTES ---

  Widget _buildGridCanvas(SandboxState state, String? selectedId, ConnectionSource? connSource, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth.clamp(280.0, 520.0);
        final double cellSize = width / gridCols;
        final double height = cellSize * gridRows;

        return Container(
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
            clipBehavior: Clip.none,
            children: [
              // 1. Linhas de Grid
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPainter(columns: gridCols, rows: gridRows, isDark: isDark),
                ),
              ),

              // 2. DragTargets em cada célula para receber os arrastes
              for (int x = 0; x < gridCols; x++)
                for (int y = 0; y < gridRows; y++)
                  _buildGridCellDragTarget(x, y, cellSize, state),

              // 3. Render das conexões de fios (Phase 3)
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
                        isSimulating: state.isSimulating,
                        simulationValues: state.simulationValues,
                        animationValue: _wireAnimationController.value,
                      ),
                    );
                  },
                ),
              ),

              // 4. Render dos componentes colocados no grid
              for (final component in state.components)
                _buildPlacedComponent(component, cellSize, selectedId, isDark),

              // 5. Linha guia de fiação temporária ativa
              if (connSource != null)
                Positioned.fill(
                  child: _TemporaryWireLayer(
                    source: connSource,
                    components: state.components,
                    cellSize: cellSize,
                    isDark: isDark,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridCellDragTarget(int x, int y, double cellSize, SandboxState state) {
    final isOccupied = state.components.any((c) => c.gridX == x && c.gridY == y);

    return Positioned(
      left: x * cellSize,
      top: y * cellSize,
      width: cellSize,
      height: cellSize,
      child: DragTarget<Object>(
        onWillAcceptWithDetails: (details) {
          // Apenas aceita se a célula estiver livre
          return !isOccupied;
        },
        onAcceptWithDetails: (details) {
          if (details.data is ComponentType) {
            final type = details.data as ComponentType;
            final component = SandboxComponent(
              id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
              type: type,
              gridX: x,
              gridY: y,
            );
            ref.read(sandboxControllerProvider.notifier).addComponent(component);
            setState(() {
              _selectedComponentId = component.id;
            });
          } else if (details.data is SandboxComponent) {
            // Mover componente existente
            final existing = details.data as SandboxComponent;
            ref.read(sandboxControllerProvider.notifier).moveComponent(existing.id, x, y);
            setState(() {
              _selectedComponentId = existing.id;
            });
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isHovering
                  ? const Color(0xFF00F5D4).withValues(alpha: 0.15)
                  : Colors.transparent,
              border: isHovering
                  ? Border.all(color: const Color(0xFF00F5D4), width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlacedComponent(SandboxComponent component, double cellSize, String? selectedId, bool isDark) {
    final isSelected = selectedId == component.id;
    final isSimulating = ref.watch(sandboxControllerProvider).isSimulating;
    final simValues = ref.watch(sandboxControllerProvider).simulationValues;
    
    // Verifica se componente está ativo eletricamente (com corrente)
    final isActiveElectric = isSimulating && simValues['active_${component.id}'] == 1.0;
    
    // No caso do interruptor físico, seu estado interno "isActive" abre/fecha o circuito físico
    // No caso de lâmpada/motor/led, eles ficam acesos se houver corrente elétrica passando.
    final visualActive = component.type == ComponentType.switchComponent
        ? component.isActive
        : isActiveElectric;

    final componentWidget = GestureDetector(
      onTap: () {
        setState(() {
          _selectedComponentId = component.id;
        });
      },
      onDoubleTap: () {
        ref.read(sandboxControllerProvider.notifier).rotateComponent(component.id);
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: const Color(0xFF00F5D4), width: 2.0)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00F5D4).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Corpo físico rotacionado
            Positioned.fill(
              child: Transform.rotate(
                angle: component.rotation * math.pi / 180,
                child: CustomPaint(
                  painter: ComponentPhysicalPainter(
                    type: component.type,
                    isActive: visualActive,
                    isDarkMode: isDark,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            // Marcador de corrente/dados se estiver ativo na simulação
            if (isActiveElectric)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FF9D),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // Terminais interativos (Bornes vermelho e preto) para puxar fios
            _buildTerminalPoint(component, 'A', cellSize, isDark),
            _buildTerminalPoint(component, 'B', cellSize, isDark),
          ],
        ),
      ),
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
              child: componentWidget,
            ),
          ),
        ),
        childWhenDragging: Container(),
        child: componentWidget,
      ),
    );
  }

  Widget _buildTerminalPoint(SandboxComponent component, String terminal, double cellSize, bool isDark) {
    // Calcula a posição do borne na célula (0.0 a 1.0)
    final relPos = terminal == 'A' ? component.getTerminalAPosition() : component.getTerminalBPosition();
    final localX = (relPos.dx - component.gridX) * cellSize;
    final localY = (relPos.dy - component.gridY) * cellSize;

    final color = terminal == 'A' ? Colors.black87 : Colors.red;

    return Positioned(
      left: localX - 6,
      top: localY - 6,
      width: 12,
      height: 12,
      child: GestureDetector(
        onTap: () {
          final connSource = _connectionSource;
          if (connSource == null) {
            // Inicia criação do fio
            setState(() {
              _connectionSource = ConnectionSource(component.id, terminal);
            });
          } else {
            // Finaliza criação do fio se for um borne diferente
            if (connSource.componentId != component.id || connSource.terminal != terminal) {
              ref.read(sandboxControllerProvider.notifier).addWire(
                connSource.componentId,
                connSource.terminal,
                component.id,
                terminal,
              );
            }
            // Limpa o estado temporário
            setState(() {
              _connectionSource = null;
            });
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  // --- PAINEL DE CONTROLE DE PARÂMETROS / DETALHES ---

  Widget _buildDetailsPanel(SandboxComponent? component, bool isEn, bool isDark) {
    if (component == null) {
      return GlassContainer(
        borderRadius: 16,
        opacity: isDark ? 0.35 : 0.6,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            isEn
                ? "Select a component on the grid to edit values."
                : "Selecione um componente no grid para editar valores.",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final hasValueSlider = component.type == ComponentType.battery || component.type == ComponentType.resistor;
    final isSwitch = component.type == ComponentType.switchComponent;

    final sandboxState = ref.watch(sandboxControllerProvider);
    final connectedWires = sandboxState.wires.where((w) {
      return w.fromComponentId == component.id || w.toComponentId == component.id;
    }).toList();

    String getWireDescription(SandboxWire wire) {
      final isFrom = wire.fromComponentId == component.id;
      final otherId = isFrom ? wire.toComponentId : wire.fromComponentId;
      final otherTerm = isFrom ? wire.toTerminal : wire.fromTerminal;
      final myTerm = isFrom ? wire.fromTerminal : wire.toTerminal;
      
      final otherCompList = sandboxState.components.where((c) => c.id == otherId).toList();
      if (otherCompList.isEmpty) return 'Terminal $myTerm ↔ Borne órfão';
      final otherComp = otherCompList.first;
      
      String compName = otherComp.type.name;
      if (isEn) {
        if (otherComp.type == ComponentType.battery) compName = 'Battery';
        if (otherComp.type == ComponentType.resistor) compName = 'Resistor';
        if (otherComp.type == ComponentType.bulb) compName = 'Bulb';
        if (otherComp.type == ComponentType.switchComponent) compName = 'Switch';
        if (otherComp.type == ComponentType.motor) compName = 'Motor';
        if (otherComp.type == ComponentType.led) compName = 'LED';
        if (otherComp.type == ComponentType.diode) compName = 'Diode';
      } else {
        if (otherComp.type == ComponentType.battery) compName = 'Bateria';
        if (otherComp.type == ComponentType.resistor) compName = 'Resistor';
        if (otherComp.type == ComponentType.bulb) compName = 'Lâmpada';
        if (otherComp.type == ComponentType.switchComponent) compName = 'Interruptor';
        if (otherComp.type == ComponentType.motor) compName = 'Motor';
        if (otherComp.type == ComponentType.led) compName = 'LED';
        if (otherComp.type == ComponentType.diode) compName = 'Diodo';
      }
      
      return 'Term. $myTerm ↔ $compName ($otherTerm)';
    }

    String valueLabel = '';
    String unit = '';
    double minVal = 1.0;
    double maxVal = 100.0;
    if (component.type == ComponentType.battery) {
      valueLabel = isEn ? 'Voltage' : 'Tensão';
      unit = 'V';
      minVal = 1.5;
      maxVal = 24.0;
    } else if (component.type == ComponentType.resistor) {
      valueLabel = isEn ? 'Resistance' : 'Resistência';
      unit = 'Ω';
      minVal = 1.0;
      maxVal = 100.0;
    }

    return GlassContainer(
      borderRadius: 16,
      opacity: isDark ? 0.35 : 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título do Componente
          Text(
            _getComponentName(component.type, AppLocalizations.of(context)!).toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? const Color(0xFF00F5D4) : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Se for interruptor, controle liga/desliga
          if (isSwitch) ...[
            Text(
              isEn ? 'Switch State:' : 'Estado do interruptor:',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(sandboxControllerProvider.notifier).toggleComponentActive(component.id);
              },
              icon: Icon(component.isActive ? Icons.power_rounded : Icons.power_off_rounded, size: 16),
              label: Text(component.isActive ? (isEn ? 'OPENED' : 'ABERTO') : (isEn ? 'CLOSED' : 'FECHADO')),
              style: ElevatedButton.styleFrom(
                backgroundColor: component.isActive
                    ? const Color(0xFF00FF9D).withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
                foregroundColor: component.isActive ? const Color(0xFF00FF9D) : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Slider de Valor (Battery / Resistor)
          if (hasValueSlider) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  valueLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${component.value.toStringAsFixed(1)}$unit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF00F5D4) : Colors.black87,
                  ),
                ),
              ],
            ),
            Slider(
              value: component.value.clamp(minVal, maxVal),
              min: minVal,
              max: maxVal,
              divisions: maxVal > 50 ? 50 : 15,
              activeColor: const Color(0xFF00F5D4),
              onChanged: (val) {
                ref.read(sandboxControllerProvider.notifier).updateComponentValue(component.id, val);
              },
            ),
            const SizedBox(height: 16),
          ],

          // Detalhes Elétricos em Tempo Real (Phase 4)
          _buildElectricityDetails(component, isEn, isDark),

          if (connectedWires.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              isEn ? 'Connected Wires:' : 'Fios Conectados:',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              child: SingleChildScrollView(
                child: Column(
                  children: connectedWires.map((wire) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              getWireDescription(wire),
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFFF3B7F)),
                            onPressed: () {
                              ref.read(sandboxControllerProvider.notifier).removeWire(wire.id);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
          const Spacer(),

          // Botões de Ação
          OutlinedButton.icon(
            onPressed: () {
              ref.read(sandboxControllerProvider.notifier).rotateComponent(component.id);
            },
            icon: const Icon(Icons.rotate_right_rounded, size: 16),
            label: Text(isEn ? 'Rotate 90°' : 'Rotacionar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              ref.read(sandboxControllerProvider.notifier).removeComponent(component.id);
              setState(() {
                _selectedComponentId = null;
              });
            },
            icon: const Icon(Icons.delete_forever_rounded, size: 16),
            label: Text(isEn ? 'Delete' : 'Excluir'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B7F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectricityDetails(SandboxComponent component, bool isEn, bool isDark) {
    final state = ref.watch(sandboxControllerProvider);
    if (!state.isSimulating) return Container();

    final active = state.simulationValues['active_${component.id}'] == 1.0;
    if (!active) {
      return Text(
        isEn ? 'No current flow.' : 'Sem passagem de corrente.',
        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    final current = state.simulationValues['current_${component.id}'] ?? 0.0;
    final vDrop = state.simulationValues['voltage_drop_${component.id}'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white60,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Live Metrics:' : 'Métricas Elétricas:',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            '${isEn ? 'Current:' : 'Corrente:'} ${current.toStringAsFixed(2)} A',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          if (component.type != ComponentType.battery)
            Text(
              '${isEn ? 'V Drop:' : 'Queda V:'} ${vDrop.toStringAsFixed(2)} V',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  // --- PAINEL DO MASCOTE PROFESSOR VOLTS ---

  Widget _buildMascotPanel(ProfVoltsEmotion emotion, String message, bool isDark) {
    return GlassContainer(
      borderRadius: 16,
      opacity: isDark ? 0.35 : 0.6,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ProfVoltsFullBody(
            emotion: emotion,
            size: 64,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                fontFamily: GoogleFonts.outfit().fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BARRA DE CONTROLE DA SIMULAÇÃO ---

  Widget _buildSimulationControlBar(SandboxState state, bool isEn, bool isDark) {
    final connSource = _connectionSource;

    return GlassContainer(
      borderRadius: 16,
      opacity: isDark ? 0.45 : 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão Cancelar Fiação se estiver criando uma conexão
          if (connSource != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _connectionSource = null;
                });
              },
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: Text(isEn ? 'Cancel Wiring' : 'Cancelar Conexão'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF3B7F),
              ),
            )
          else
            TextButton.icon(
              onPressed: () {
                ref.read(sandboxControllerProvider.notifier).clearCanvas();
                setState(() {
                  _selectedComponentId = null;
                });
              },
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: Text(isEn ? 'Clear Grid' : 'Limpar Bancada'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.black87,
              ),
            ),

          // Botão Simulação
          FilledButton.icon(
            onPressed: () {
              ref.read(sandboxControllerProvider.notifier).toggleSimulation();
            },
            icon: Icon(
              state.isSimulating ? Icons.stop_circle_outlined : Icons.play_circle_outlined,
              size: 20,
            ),
            label: Text(
              state.isSimulating
                  ? (isEn ? 'STOP SIMULATION' : 'PARAR SIMULAÇÃO')
                  : (isEn ? 'START SIMULATION' : 'INICIAR SIMULAÇÃO'),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: state.isSimulating
                  ? const Color(0xFFFF3B7F)
                  : const Color(0xFF00FF9D),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: GoogleFonts.rajdhani(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
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
    }
  }
}

// --- PAINTER DO GRID DE EDICÃO ---

class GridPainter extends CustomPainter {
  final int columns;
  final int rows;
  final bool isDark;

  GridPainter({required this.columns, required this.rows, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.2;

    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    // Linhas Verticais
    for (int i = 1; i < columns; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Linhas Horizontais
    for (int i = 1; i < rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- PAINTER DOS FIOS CONECTADOS ---

class WiresPainter extends CustomPainter {
  final List<SandboxWire> wires;
  final List<SandboxComponent> components;
  final double cellSize;
  final bool isDark;
  final bool isSimulating;
  final Map<String, double> simulationValues;
  final double animationValue;

  WiresPainter({
    required this.wires,
    required this.components,
    required this.cellSize,
    required this.isDark,
    required this.isSimulating,
    required this.simulationValues,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final wire in wires) {
      final fromCompList = components.where((c) => c.id == wire.fromComponentId).toList();
      final toCompList = components.where((c) => c.id == wire.toComponentId).toList();
      if (fromCompList.isEmpty || toCompList.isEmpty) continue;

      final fromComp = fromCompList.first;
      final toComp = toCompList.first;

      // Obtém as coordenadas relativas dos terminais A ou B
      final fromRelPos = wire.fromTerminal == 'A' ? fromComp.getTerminalAPosition() : fromComp.getTerminalBPosition();
      final toRelPos = wire.toTerminal == 'A' ? toComp.getTerminalAPosition() : toComp.getTerminalBPosition();

      // Transforma para coordenadas absolutas em pixels
      final start = Offset(fromRelPos.dx * cellSize, fromRelPos.dy * cellSize);
      final end = Offset(toRelPos.dx * cellSize, toRelPos.dy * cellSize);

      // Rota eletricamente ativa se a simulação estiver rodando e ambos os componentes conectados tiverem corrente
      final isWireActive = isSimulating && 
          simulationValues['active_${fromComp.id}'] == 1.0 && 
          simulationValues['active_${toComp.id}'] == 1.0;

      // Desenha o cabo elétrico (Curva Bézier cúbica para parecer mais físico e natural)
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          (start.dx + end.dx) / 2, start.dy,
          (start.dx + end.dx) / 2, end.dy,
          end.dx, end.dy,
        );

      // 1. Sombra do Fio
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black26
          ..strokeWidth = 5.0
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // 2. Fio de base
      canvas.drawPath(
        path,
        Paint()
          ..color = isWireActive
              ? const Color(0xFF00FF9D).withValues(alpha: 0.8)
              : (isDark ? Colors.blueGrey.shade700 : Colors.grey.shade400)
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // 3. Highlight especular central para efeito 3D metálico
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // 4. Animação de fluxo de corrente (partículas de elétrons pulsantes/correndo)
      if (isWireActive) {
        final paintParticle = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        
        for (final metric in path.computeMetrics()) {
          final length = metric.length;
          const double spacing = 24.0;
          final double initialOffset = animationValue * spacing;
          
          for (double d = initialOffset; d < length; d += spacing) {
            final tangent = metric.getTangentForOffset(d);
            if (tangent != null) {
              // Desenha o elétron como um círculo branco brilhante
              canvas.drawCircle(tangent.position, 2.0, paintParticle);
              
              // Efeito de brilho ao redor do elétron
              canvas.drawCircle(
                tangent.position, 
                4.5, 
                Paint()
                  ..color = const Color(0xFF00FF9D).withValues(alpha: 0.4)
                  ..style = PaintingStyle.fill
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
              );
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant WiresPainter oldDelegate) {
    return oldDelegate.wires != wires ||
        oldDelegate.components != components ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isSimulating != isSimulating ||
        oldDelegate.simulationValues != simulationValues ||
        oldDelegate.animationValue != animationValue;
  }
}

// --- CAMADA VISUAL DE FIO TEMPORÁRIO (ENQUANTO ARRASTA) ---

class _TemporaryWireLayer extends StatefulWidget {
  final ConnectionSource source;
  final List<SandboxComponent> components;
  final double cellSize;
  final bool isDark;

  const _TemporaryWireLayer({
    required this.source,
    required this.components,
    required this.cellSize,
    required this.isDark,
  });

  @override
  State<_TemporaryWireLayer> createState() => _TemporaryWireLayerState();
}

class _TemporaryWireLayerState extends State<_TemporaryWireLayer> {
  Offset? _mousePosition;

  @override
  Widget build(BuildContext context) {
    final fromComp = widget.components.firstWhere((c) => c.id == widget.source.componentId);
    final fromRel = widget.source.terminal == 'A' ? fromComp.getTerminalAPosition() : fromComp.getTerminalBPosition();
    final start = Offset(fromRel.dx * widget.cellSize, fromRel.dy * widget.cellSize);

    return MouseRegion(
      onHover: (event) {
        setState(() {
          _mousePosition = event.localPosition;
        });
      },
      child: CustomPaint(
        painter: _TempWirePainter(
          start: start,
          currentEnd: _mousePosition,
          isDark: widget.isDark,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TempWirePainter extends CustomPainter {
  final Offset start;
  final Offset? currentEnd;
  final bool isDark;

  _TempWirePainter({
    required this.start,
    required this.currentEnd,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final end = currentEnd;
    if (end == null) return;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        (start.dx + end.dx) / 2, start.dy,
        (start.dx + end.dx) / 2, end.dy,
        end.dx, end.dy,
      );

    canvas.drawPath(
      path,
      Paint()
        ..color = isDark ? const Color(0xFF00F5D4).withValues(alpha: 0.5) : const Color(0xFF00875A).withValues(alpha: 0.4)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TempWirePainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.currentEnd != currentEnd || oldDelegate.isDark != isDark;
  }
}