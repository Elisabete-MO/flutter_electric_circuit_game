import '../../models/sandbox_state.dart';

abstract class CircuitSolverStrategy {
  SandboxState solve(SandboxState state);
}
