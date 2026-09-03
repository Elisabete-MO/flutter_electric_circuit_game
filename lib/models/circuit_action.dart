/// Ações de circuito para o sistema de undo/redo.
/// Cada ação armazena callbacks para apply/undo, permitindo
/// integração flexível com qualquer stand.
abstract class CircuitAction {
  final String description;
  
  const CircuitAction({required this.description});
  
  void apply();
  void undo();
}

/// Ação composta que agrupa múltiplas ações atômicas.
class CompoundAction extends CircuitAction {
  final List<CircuitAction> actions;

  const CompoundAction({
    required super.description,
    required this.actions,
  });

  @override
  void apply() {
    for (final action in actions) {
      action.apply();
    }
  }

  @override
  void undo() {
    for (final action in actions.reversed) {
      action.undo();
    }
  }
}

/// Inserir componente (bateria, interruptor, lâmpada, etc.)
class InsertComponentAction extends CircuitAction {
  final Function() onApply;
  final Function() onUndo;

  const InsertComponentAction({
    required super.description,
    required this.onApply,
    required this.onUndo,
  });

  @override
  void apply() => onApply();

  @override
  void undo() => onUndo();
}

/// Girar componente 90°
class RotateComponentAction extends CircuitAction {
  final Function() onApply;
  final Function() onUndo;

  const RotateComponentAction({
    required super.description,
    required this.onApply,
    required this.onUndo,
  });

  @override
  void apply() => onApply();

  @override
  void undo() => onUndo();
}

/// Toggle de estado booleano (switchClosed, pushButtonPressed, etc.)
class ToggleBoolAction extends CircuitAction {
  final Function() onApply;
  final Function() onUndo;

  const ToggleBoolAction({
    required super.description,
    required this.onApply,
    required this.onUndo,
  });

  @override
  void apply() => onApply();

  @override
  void undo() => onUndo();
}

/// Atualizar valor numérico (slider, resistência, etc.)
class UpdateValueAction extends CircuitAction {
  final Function() onApply;
  final Function() onUndo;

  const UpdateValueAction({
    required super.description,
    required this.onApply,
    required this.onUndo,
  });

  @override
  void apply() => onApply();

  @override
  void undo() => onUndo();
}

/// Seleção de opção (resistor selection, quiz answer, etc.)
class SelectOptionAction extends CircuitAction {
  final Function() onApply;
  final Function() onUndo;

  const SelectOptionAction({
    required super.description,
    required this.onApply,
    required this.onUndo,
  });

  @override
  void apply() => onApply();

  @override
  void undo() => onUndo();
}

/// Toggle de probe (conectar/desconectar)
class ToggleProbeAction extends CircuitAction {
  final Function() onApply;
  final Function() onUndo;

  const ToggleProbeAction({
    required super.description,
    required this.onApply,
    required this.onUndo,
  });

  @override
  void apply() => onApply();

  @override
  void undo() => onUndo();
}
