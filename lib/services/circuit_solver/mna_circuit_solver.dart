import '../../models/first_step_component.dart';
import '../../models/sandbox_state.dart';
import 'circuit_solver_strategy.dart';

class MnaCircuitSolver implements CircuitSolverStrategy {
  @override
  SandboxState solve(SandboxState targetState) {
    if (!targetState.isSimulating) {
      return targetState.copyWith(
        simulationValues: {},
        errorMessage: null,
      );
    }

    final components = targetState.components;
    final wires = targetState.wires;

    // 1. DSU para encontrar componentes conexos (nós elétricos)
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

    // Cada terminal começa no seu próprio nó
    for (final c in components) {
      if (c.type == ComponentType.relay) {
        find('${c.id}_C1');
        find('${c.id}_C2');
        find('${c.id}_COM');
        find('${c.id}_NO');
        find('${c.id}_NC');
      } else {
        find('${c.id}_A');
        find('${c.id}_B');
      }
    }

    // Unir os terminais que estão conectados por fios
    for (final w in wires) {
      union('${w.fromComponentId}_${w.fromTerminal}', '${w.toComponentId}_${w.toTerminal}');
    }

    // Mapear cada raiz única para um índice de nó
    final uniqueRoots = parent.keys.map((k) => find(k)).toSet().toList();
    final totalNodes = uniqueRoots.length;
    if (totalNodes == 0) {
      return targetState;
    }

    final rootToIdx = <String, int>{};
    for (int i = 0; i < totalNodes; i++) {
      rootToIdx[uniqueRoots[i]] = i;
    }

    int getTerminalNode(String compId, String terminal) {
      final key = '${compId}_$terminal';
      final root = find(key);
      return rootToIdx[root] ?? 0;
    }

    // Encontrar o nó terra (GND / Referência): terminal A da primeira bateria/fonte
    int groundNode = 0;
    final firstSource = components.firstWhereOrNull((c) =>
        c.type == ComponentType.battery || c.type == ComponentType.powerSupply);
    if (firstSource != null) {
      groundNode = getTerminalNode(firstSource.id, 'A');
    }

    // Coletar fontes de tensão independentes
    final voltageSources = components.where((c) =>
        c.type == ComponentType.battery || c.type == ComponentType.powerSupply).toList();
    final numVoltSources = voltageSources.length;

    if (numVoltSources == 0) {
      return targetState.copyWith(
        simulationValues: {},
        errorMessage: 'Sem fonte de energia no circuito.',
      );
    }

    // Controle de estado dos diodos/LEDs e Relés
    final diodeOpenStates = <String, bool>{};
    final diodes = components.where((c) =>
        c.type == ComponentType.diode || c.type == ComponentType.led).toList();
    for (final d in diodes) {
      diodeOpenStates[d.id] = false; // assume conduzindo inicialmente
    }

    final relayActiveStates = <String, bool>{};
    final relays = components.where((c) => c.type == ComponentType.relay).toList();
    for (final r in relays) {
      relayActiveStates[r.id] = r.isActive; // Inicia com o estado atual do modelo
    }

    List<double>? solution;
    int iterations = 0;
    bool converged = false;

    while (iterations < 10 && !converged) {
      iterations++;
      final matrixSize = totalNodes + numVoltSources;
      final A = List.generate(matrixSize, (_) => List<double>.filled(matrixSize, 0.0));
      final z = List<double>.filled(matrixSize, 0.0);

      // Adicionar gmin (pequena condutância a terra) para garantir matriz não-singular
      for (int i = 0; i < totalNodes; i++) {
        A[i][i] += 1e-9;
      }

      // Estampar componentes resistivos
      for (final c in components) {
        if (targetState.burnedComponentIds.contains(c.id)) {
          continue; // componentes queimados não conduzem (circuito aberto)
        }

        if (c.type == ComponentType.relay) {
          // Bobina
          final nC1 = getTerminalNode(c.id, 'C1');
          final nC2 = getTerminalNode(c.id, 'C2');
          final double gCoil = 1.0 / 100.0; // 100 ohms
          A[nC1][nC1] += gCoil;
          A[nC2][nC2] += gCoil;
          A[nC1][nC2] -= gCoil;
          A[nC2][nC1] -= gCoil;

          // Contatos
          final nCOM = getTerminalNode(c.id, 'COM');
          final isActive = relayActiveStates[c.id] ?? false;
          final nActiveContact = isActive ? getTerminalNode(c.id, 'NO') : getTerminalNode(c.id, 'NC');
          final double gContact = 1.0 / 0.01; // 0.01 ohms quando fechado
          A[nCOM][nCOM] += gContact;
          A[nActiveContact][nActiveContact] += gContact;
          A[nCOM][nActiveContact] -= gContact;
          A[nActiveContact][nCOM] -= gContact;
          continue; // Já processado
        }

        final nA = getTerminalNode(c.id, 'A');
        final nB = getTerminalNode(c.id, 'B');

        double? R;
        if (c.type == ComponentType.resistor || c.type == ComponentType.bulb) {
          R = c.value <= 0 ? 0.01 : c.value;
        } else if (c.type == ComponentType.potentiometer) {
          R = c.value <= 0 ? 0.01 : c.value;
        } else if (c.type == ComponentType.motor) {
          R = 2.0;
        } else if (c.type == ComponentType.buzzer) {
          R = 8.0;
        } else if (c.type == ComponentType.fuse) {
          R = 0.1;
        } else if (c.type == ComponentType.capacitor) {
          R = 10.0;
        } else if (c.type == ComponentType.switchComponent) {
          R = c.isActive ? 0.01 : null; // null representa circuito aberto
        } else if (c.type == ComponentType.diode || c.type == ComponentType.led) {
          final isOpen = diodeOpenStates[c.id] ?? false;
          if (!isOpen) {
            R = c.type == ComponentType.diode ? 0.5 : 2.0;
          }
        }

        if (R != null) {
          final G = 1.0 / R;
          A[nA][nA] += G;
          A[nB][nB] += G;
          A[nA][nB] -= G;
          A[nB][nA] -= G;
        }
      }

      // Estampar fontes de tensão independentes
      for (int j = 0; j < numVoltSources; j++) {
        final src = voltageSources[j];
        final nA = getTerminalNode(src.id, 'A'); // pólo negativo
        final nB = getTerminalNode(src.id, 'B'); // pólo positivo
        final vsIdx = totalNodes + j;

        A[vsIdx][nB] = 1.0;
        A[vsIdx][nA] = -1.0;
        z[vsIdx] = src.value;

        A[nA][vsIdx] += 1.0;
        A[nB][vsIdx] -= 1.0;
      }

      // Forçar nó terra a ter 0V
      for (int col = 0; col < matrixSize; col++) {
        A[groundNode][col] = 0.0;
      }
      A[groundNode][groundNode] = 1.0;
      z[groundNode] = 0.0;

      // Resolver sistema linear
      solution = _solveLinearSystem(A, z);
      if (solution == null) {
        break; // Matriz singular, abortar
      }

      // Atualizar o estado dos diodos/LEDs
      bool stateChanged = false;
      for (final d in diodes) {
        final nA = getTerminalNode(d.id, 'A');
        final nB = getTerminalNode(d.id, 'B');
        final vA = solution[nA];
        final vB = solution[nB];

        // Determinar Anodo e Cátodo com base na rotação
        final bool isAnodeA = (d.rotation == 0.0 || d.rotation == 90.0);
        final vAnode = isAnodeA ? vA : vB;
        final vCathode = isAnodeA ? vB : vA;
        final vDiff = vAnode - vCathode;

        final isCurrentlyOpen = diodeOpenStates[d.id] ?? false;
        final forwardVoltage = d.type == ComponentType.diode ? 0.7 : 1.8;

        if (isCurrentlyOpen) {
          // Se estava aberto, mas a tensão ultrapassa Vf, ele fecha (conduz)
          if (vDiff > forwardVoltage) {
            diodeOpenStates[d.id] = false;
            stateChanged = true;
          }
        } else {
          // Se estava fechado, mas a corrente inverte (vDiff < 0), ele abre
          if (vDiff < 0) {
            diodeOpenStates[d.id] = true;
            stateChanged = true;
          }
        }
      }

      // Atualizar o estado dos Relés
      for (final r in relays) {
        final nC1 = getTerminalNode(r.id, 'C1');
        final nC2 = getTerminalNode(r.id, 'C2');
        final vC1 = solution[nC1];
        final vC2 = solution[nC2];
        
        final coilDrop = (vC2 - vC1).abs();
        final coilCurrent = coilDrop / 100.0;
        final hasCoilCurrent = coilCurrent >= 0.01;

        final isCurrentlyActive = relayActiveStates[r.id] ?? false;
        if (isCurrentlyActive != hasCoilCurrent) {
          relayActiveStates[r.id] = hasCoilCurrent;
          stateChanged = true;
        }
      }

      if (!stateChanged) {
        converged = true;
      }
    }

    if (solution == null) {
      return targetState.copyWith(
        simulationValues: {},
        errorMessage: 'Erro ao resolver o sistema linear do circuito.',
      );
    }

    final Map<String, double> values = {};
    String? error;
    final Set<String> newBurnedSet = Set.from(targetState.burnedComponentIds);
    bool isShortCircuit = false;
    final Set<String> shortCircuitWireIds = {};

    // Mapear a solução de volta para os componentes
    for (final c in components) {
      if (c.type == ComponentType.relay) {
        final nC1 = getTerminalNode(c.id, 'C1');
        final nC2 = getTerminalNode(c.id, 'C2');
        final nCOM = getTerminalNode(c.id, 'COM');
        final nNO = getTerminalNode(c.id, 'NO');
        final nNC = getTerminalNode(c.id, 'NC');

        values['node_voltage_${c.id}_C1'] = solution[nC1];
        values['node_voltage_${c.id}_C2'] = solution[nC2];
        values['node_voltage_${c.id}_COM'] = solution[nCOM];
        values['node_voltage_${c.id}_NO'] = solution[nNO];
        values['node_voltage_${c.id}_NC'] = solution[nNC];

        final coilDrop = (solution[nC2] - solution[nC1]).abs();
        final coilCurrent = coilDrop / 100.0;
        values['coil_current_${c.id}'] = coilCurrent;
        values['current_${c.id}'] = coilCurrent; // Corrente principal pro HUD
        values['voltage_drop_${c.id}'] = coilDrop;
        values['power_${c.id}'] = coilDrop * coilCurrent;
        if (coilCurrent > 0.001) {
          values['active_${c.id}'] = 1.0;
        }
        continue; // Já processado
      }

      final nA = getTerminalNode(c.id, 'A');
      final nB = getTerminalNode(c.id, 'B');
      final vA = solution[nA];
      final vB = solution[nB];

      values['node_voltage_${c.id}_A'] = vA;
      values['node_voltage_${c.id}_B'] = vB;

      final vDrop = (vB - vA).abs();
      double current = 0.0;

      if (c.type == ComponentType.battery || c.type == ComponentType.powerSupply) {
        final j = voltageSources.indexOf(c);
        if (j != -1) {
          current = solution[totalNodes + j].abs();
        }
      } else if (!targetState.burnedComponentIds.contains(c.id)) {
        double? R;
        if (c.type == ComponentType.resistor || c.type == ComponentType.bulb) {
          R = c.value <= 0 ? 0.01 : c.value;
        } else if (c.type == ComponentType.potentiometer) {
          R = c.value <= 0 ? 0.01 : c.value;
        } else if (c.type == ComponentType.motor) {
          R = 2.0;
        } else if (c.type == ComponentType.buzzer) {
          R = 8.0;
        } else if (c.type == ComponentType.fuse) {
          R = 0.1;
        } else if (c.type == ComponentType.capacitor) {
          R = 10.0;
        } else if (c.type == ComponentType.switchComponent) {
          R = c.isActive ? 0.01 : null;
        } else if (c.type == ComponentType.diode || c.type == ComponentType.led) {
          final isOpen = diodeOpenStates[c.id] ?? false;
          if (!isOpen) {
            R = c.type == ComponentType.diode ? 0.5 : 2.0;
          }
        }

        if (R != null) {
          current = vDrop / R;
        }
      }

      final power = vDrop * current;

      if (current > 0.001) {
        values['active_${c.id}'] = 1.0;
      }
      values['current_${c.id}'] = current;
      values['voltage_drop_${c.id}'] = vDrop;
      values['power_${c.id}'] = power;

      // Verificação de limites físicos e sobrecarga
      if (!targetState.burnedComponentIds.contains(c.id)) {
        if (c.type == ComponentType.led) {
          if (current > 0.05 || vDrop > 3.3) {
            newBurnedSet.add(c.id);
            error =
                'O LED QUEIMOU! Corrente (${(current * 1000).toStringAsFixed(0)}mA) excedeu o limite seguro (50mA). Conecte um resistor em série!';
          }
        } else if (c.type == ComponentType.bulb) {
          if (power > 15.0) {
            newBurnedSet.add(c.id);
            error =
                'FILAMENTO ROMPIDO! A lâmpada queimou por excesso de potência (${power.toStringAsFixed(1)}W > 15W)!';
          }
        } else if (c.type == ComponentType.motor) {
          if (vDrop > 18.0) {
            newBurnedSet.add(c.id);
            error =
                'BOBINA QUEIMADA! O motor sofreu sobretensão (${vDrop.toStringAsFixed(1)}V > 18V)!';
          }
        } else if (c.type == ComponentType.fuse) {
          final maxCurrent = c.value;
          if (current > maxCurrent) {
            newBurnedSet.add(c.id);
            error =
                'FUSÍVEL QUEIMOU! Corrente de ${current.toStringAsFixed(2)}A excedeu o limite do fusível (${maxCurrent.toStringAsFixed(1)}A), desarmando o circuito!';
          }
        }
      }
    }

    // Verificar se houve curto-circuito: qualquer corrente de fonte maior que 20A
    for (final src in voltageSources) {
      final j = voltageSources.indexOf(src);
      if (j != -1) {
        final current = solution[totalNodes + j].abs();
        if (current > 20.0) {
          isShortCircuit = true;
          error = 'CURTO-CIRCUITO DETECTADO! Conexão direta entre pólos sem carga!';
          final srcNodeA = getTerminalNode(src.id, 'A');
          final srcNodeB = getTerminalNode(src.id, 'B');
          for (final w in wires) {
            final wNodeA = getTerminalNode(w.fromComponentId, w.fromTerminal);
            final wNodeB = getTerminalNode(w.toComponentId, w.toTerminal);
            if (wNodeA == srcNodeA || wNodeB == srcNodeA || wNodeA == srcNodeB || wNodeB == srcNodeB) {
              shortCircuitWireIds.add(w.id);
            }
          }
        }
      }
    }

    // Atualizar os componentes baseados nos estados resolvidos
    final newComponents = components.map((c) {
      if (c.type == ComponentType.relay) {
        final isActive = relayActiveStates[c.id] ?? c.isActive;
        return c.copyWith(isActive: isActive);
      }
      return c;
    }).toList();

    return targetState.copyWith(
      components: newComponents,
      simulationValues: values,
      errorMessage: error,
      burnedComponentIds: newBurnedSet,
      isShortCircuit: isShortCircuit,
      shortCircuitWireIds: shortCircuitWireIds,
    );
  }

  List<double>? _solveLinearSystem(List<List<double>> A, List<double> b) {
    int n = b.length;
    List<List<double>> M = List.generate(n, (i) {
      List<double> row = List<double>.from(A[i]);
      row.add(b[i]);
      return row;
    });

    for (int i = 0; i < n; i++) {
      double maxEl = M[i][i].abs();
      int maxRow = i;
      for (int k = i + 1; k < n; k++) {
        if (M[k][i].abs() > maxEl) {
          maxEl = M[k][i].abs();
          maxRow = k;
        }
      }

      if (maxRow != i) {
        List<double> tmp = M[i];
        M[i] = M[maxRow];
        M[maxRow] = tmp;
      }

      if (M[i][i].abs() < 1e-12) {
        return null;
      }

      for (int k = i + 1; k < n; k++) {
        double c = -M[k][i] / M[i][i];
        for (int j = i; j <= n; j++) {
          if (i == j) {
            M[k][j] = 0;
          } else {
            M[k][j] += c * M[i][j];
          }
        }
      }
    }

    List<double> x = List<double>.filled(n, 0);
    for (int i = n - 1; i >= 0; i--) {
      x[i] = M[i][n] / M[i][i];
      for (int k = i - 1; k >= 0; k--) {
        M[k][n] -= M[k][i] * x[i];
      }
    }
    return x;
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
