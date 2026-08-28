import 'package:flutter/foundation.dart';
import '../../models/sandbox_state.dart';
import '../../models/first_step_component.dart';
import 'circuit_solver_strategy.dart';
import 'dfs_circuit_solver.dart';
import 'mna_circuit_solver.dart';

// Função de nível superior para o compute
SandboxState solveCircuitInIsolate(SandboxState state) {
  final solver = CircuitSolverService.selectSolver(state);
  return solver.solve(state);
}

class CircuitSolverService {
  static CircuitSolverStrategy selectSolver(SandboxState state) {
    if (_isComplexCircuit(state)) {
      return MnaCircuitSolver();
    } else {
      return DfsCircuitSolver();
    }
  }

  static bool _isComplexCircuit(SandboxState state) {
    final sources = state.components.where((c) =>
        c.type == ComponentType.battery || c.type == ComponentType.powerSupply).toList();
    if (sources.length > 1) return true;

    final parent = <String, String>{};
    String find(String x) {
      if (parent[x] == null) {
        parent[x] = x;
        return x;
      }
      if (parent[x] == x) return x;
      parent[x] = find(parent[x]!);
      return parent[x]!;
    }

    void union(String x, String y) {
      final rootX = find(x);
      final rootY = find(y);
      if (rootX != rootY) {
        parent[rootX] = rootY;
      }
    }

    for (final c in state.components) {
      find('${c.id}_A');
      find('${c.id}_B');
    }

    for (final w in state.wires) {
      union('${w.fromComponentId}_${w.fromTerminal}', '${w.toComponentId}_${w.toTerminal}');
    }

    final nodeCounts = <String, int>{};
    for (final key in parent.keys) {
      final root = find(key);
      nodeCounts[root] = (nodeCounts[root] ?? 0) + 1;
    }

    for (final count in nodeCounts.values) {
      if (count > 2) {
        return true;
      }
    }

    return false;
  }

  Future<SandboxState> solve(SandboxState state) async {
    // Executa o solver em um Isolate em segundo plano para não bloquear a UI Thread
    return compute(solveCircuitInIsolate, state);
  }
}
