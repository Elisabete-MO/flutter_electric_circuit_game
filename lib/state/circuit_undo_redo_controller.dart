import '../models/circuit_action.dart';

/// Controller para gerenciar undo/redo de ações de circuito.
/// Usa o padrão Command com stack de ações.
class CircuitUndoRedoController {
  final int maxDepth;
  final List<CircuitAction> _undoStack = [];
  final List<CircuitAction> _redoStack = [];

  CircuitUndoRedoController({this.maxDepth = 30});

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  
  int get undoCount => _undoStack.length;
  int get redoCount => _redoStack.length;
  
  String? get lastUndoDescription => 
      _undoStack.isNotEmpty ? _undoStack.last.description : null;
  
  String? get lastRedoDescription => 
      _redoStack.isNotEmpty ? _redoStack.last.description : null;

  /// Executa uma ação e a adiciona à stack de undo.
  void execute(CircuitAction action) {
    action.apply();
    _undoStack.add(action);
    if (_undoStack.length > maxDepth) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  /// Desfaz a última ação.
  void undo() {
    if (!canUndo) return;
    final action = _undoStack.removeLast();
    action.undo();
    _redoStack.add(action);
  }

  /// Refaz a última ação desfeita.
  void redo() {
    if (!canRedo) return;
    final action = _redoStack.removeLast();
    action.apply();
    _undoStack.add(action);
  }

  /// Limpa todas as ações.
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  /// Limpa apenas a stack de redo (usado quando nova ação é executada).
  void clearRedo() {
    _redoStack.clear();
  }
}
