import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/first_step_component.dart';
import '../../../l10n/app_localizations.dart';
import 'models/schematic_models.dart';
import 'widgets/schematic_painter.dart';
import 'widgets/sandbox_toolbox.dart';

class SchematicSandboxScreen extends StatefulWidget {
  const SchematicSandboxScreen({super.key});

  @override
  State<SchematicSandboxScreen> createState() => _SchematicSandboxScreenState();
}

class _SchematicSandboxScreenState extends State<SchematicSandboxScreen> {
  static const double cellSize = 40.0;
  final _uuid = const Uuid();
  
  final List<SchematicComponent> _components = [];
  final List<SchematicWire> _wires = [];

  Offset? _currentDragStart;
  Offset? _currentDragEnd;
  GridNode? _startNode;

  @override
  void initState() {
    super.initState();
    // Exemplo inicial (opcional, pode ser removido se quiser iniciar vazio)
    _components.add(SchematicComponent(
      id: _uuid.v4(),
      type: ComponentType.battery,
      position: GridNode(3, 4),
      isHorizontal: false,
    ));
    _components.add(SchematicComponent(
      id: _uuid.v4(),
      type: ComponentType.bulb,
      position: GridNode(7, 4),
      isHorizontal: false,
    ));
  }

  String _getComponentName(ComponentType type, AppLocalizations l10n) {
    switch (type) {
      case ComponentType.battery: return 'Bateria';
      case ComponentType.bulb: return 'Lâmpada';
      case ComponentType.resistor: return 'Resistor';
      case ComponentType.switchComponent: return 'Interruptor';
      case ComponentType.connectingWire: return 'Fio';
      case ComponentType.diode: return 'Diodo';
      case ComponentType.led: return 'LED';
      case ComponentType.motor: return 'Motor';
      case ComponentType.potentiometer: return 'Potenciômetro';
      case ComponentType.powerSupply: return 'Fonte';
      case ComponentType.fuse: return 'Fusível';
      case ComponentType.capacitor: return 'Capacitor';
      case ComponentType.buzzer: return 'Buzzer';
    }
  }

  GridNode? _getNodeAt(Offset localPosition) {
    const double touchTolerance = 25.0; // Tolerância maior para toque
    
    int x = (localPosition.dx / cellSize).round();
    int y = (localPosition.dy / cellSize).round();
    
    if (x < 1 || y < 1) return null;

    final nodeCenter = Offset(x * cellSize, y * cellSize);
    if ((localPosition - nodeCenter).distance <= touchTolerance) {
      return GridNode(x, y);
    }
    return null;
  }

  void _onPanStart(DragStartDetails details) {
    // Usar localPosition diretamente resolve o problema do offset de tela
    final localPosition = details.localPosition;
    
    final node = _getNodeAt(localPosition);
    if (node != null) {
      setState(() {
        _startNode = node;
        _currentDragStart = Offset(node.x * cellSize, node.y * cellSize);
        _currentDragEnd = localPosition;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_startNode == null) return;
    setState(() {
      _currentDragEnd = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_startNode == null || _currentDragEnd == null) return;

    final endNode = _getNodeAt(_currentDragEnd!);
    
    if (endNode != null && endNode != _startNode) {
      setState(() {
        _wires.add(SchematicWire(_startNode!, endNode));
      });
    }

    setState(() {
      _startNode = null;
      _currentDragStart = null;
      _currentDragEnd = null;
    });
  }

  void _clearBoard() {
    setState(() {
      _wires.clear();
      _components.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5), // Cor de blueprint (azul)
      appBar: AppBar(
        title: const Text('Bancada Esquemática'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearBoard,
            tooltip: 'Limpar tudo',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: DragTarget<ComponentType>(
              onAcceptWithDetails: (details) {
                // details.offset é global, precisamos converter para local no canvas
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localPos = renderBox.globalToLocal(details.offset);
                
                // Ajusta o offset subtraindo o appbar e pegando o nó mais próximo
                // A altura do AppBar normalmente é kToolbarHeight (56.0) + MediaQuery padding top
                // Mas globalToLocal deve resolver a maioria, exceto a posição exata de soltura
                final adjustedPos = Offset(localPos.dx + 44, localPos.dy - 80); 
                
                int x = (adjustedPos.dx / cellSize).round();
                int y = (adjustedPos.dy / cellSize).round();
                
                // Evita colocar fora do grid
                if (x < 1) x = 1;
                if (y < 1) y = 1;

                setState(() {
                  _components.add(
                    SchematicComponent(
                      id: _uuid.v4(),
                      type: details.data,
                      position: GridNode(x, y),
                      isHorizontal: false, // Pode adicionar lógica para girar depois
                    )
                  );
                });
              },
              builder: (context, candidateData, rejectedData) {
                return GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox.expand(
                    child: CustomPaint(
                      painter: SchematicPainter(
                        cellSize: cellSize,
                        components: _components,
                        wires: _wires,
                        currentDragStart: _currentDragStart,
                        currentDragEnd: _currentDragEnd,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Toolbox inferior idêntica à Bancada Livre
          SizedBox(
            height: 115,
            child: SandboxToolboxWidget(
              isHorizontal: true,
              isDark: Theme.of(context).brightness == Brightness.dark,
              isDiagramMode: true,
              useRealisticAssets: false,
              getComponentName: _getComponentName,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
