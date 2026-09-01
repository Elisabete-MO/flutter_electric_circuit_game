import 'dart:ui';
import '../../../models/first_step_component.dart';

/// Representa um ponto no grid (onde fios e componentes podem se conectar).
class GridNode {
  final int x;
  final int y;

  GridNode(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridNode &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

/// Representa um componente posicionado no grid.
class SchematicComponent {
  final String id;
  final ComponentType type;
  /// O nó principal onde o componente foi solto.
  final GridNode position;
  /// A direção (horizontal ou vertical) em que ele está orientado.
  final bool isHorizontal;
  
  SchematicComponent({
    required this.id,
    required this.type,
    required this.position,
    this.isHorizontal = true,
  });
  
  /// Retorna os dois nós (terminais) de conexão deste componente.
  /// (Assumindo que cada componente ocupa o espaço entre 2 nós adjacentes no grid).
  List<GridNode> get terminals {
    if (isHorizontal) {
      return [position, GridNode(position.x + 1, position.y)];
    } else {
      return [position, GridNode(position.x, position.y + 1)];
    }
  }
}

/// Representa um fio conectado entre dois nós do grid.
class SchematicWire {
  final GridNode start;
  final GridNode end;

  SchematicWire(this.start, this.end);
}
