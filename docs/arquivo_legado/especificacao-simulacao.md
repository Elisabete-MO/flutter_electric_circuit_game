# Especificação do motor de simulação (EletroLab v1.0.0)

## Princípio

O motor de simulação e os widgets de desenho nativo não dependem de frameworks externos como Flame. Tudo é desenhado usando a API `CustomPainter` do Flutter e gerenciado reativamente via `SandboxController`:

```text
Flutter UI (SandboxScreen & Widgets)
     ↓
SandboxController (Notifier / Riverpod)
     ↓
Graph Traversal & Physics Solver (Busca em profundidade em nós/terminais)
     ↓
SandboxState (simulationValues, burnedComponentIds, errorMessage)
     ↓
CustomPainters (WiresPainter, ComponentPhysicalPainter, CircuitSymbolPainter)
```

A lógica de cálculo matemático, travessia de grafos e verificação de queima física fica isolada do layout.

## Modelo do circuito na Bancada Livre (Grafo)

```text
SandboxState
 ├── components         (Lista de SandboxComponent com gridX, gridY, rotation, value, state)
 ├── wires              (Lista de SandboxWire com fromComponentId, fromTerminal, toComponentId, toTerminal)
 ├── simulationValues   (Map com corrente, queda de tensão e potência por componente)
 └── burnedComponentIds (Set com os IDs de componentes danificados por sobrecarga)
```

- Componentes possuem terminais **A** e **B** (coordenadas relativas no grid).
- Fios conectam dois terminais de componentes.
- O `SandboxController` realiza **Graph Traversal (DFS)** a partir da fonte de energia (bateria) para identificar malhas fechadas.
- Componentes com seus IDs em `burnedComponentIds` atuam como **circuitos abertos** na travessia (interrompem o fluxo elétrico).

## Lógica de Sobrecarga e Queima Física (Physical Burnout System)

Cada componente ativo possui limites didáticos e físicos definidos:

| Componente | Limite Máximo de Operação | Condição de Falha | Resultado Educativo |
|---|---|---|---|
| **LED** | $I \le 50\text{ mA}$ ou $V \le 3,3\text{ V}$ | Corrente ou tensão acima do limite | 💥 LED Queimado! Exige resistor em série. |
| **Lâmpada** | $P \le 15\text{ W}$ | Potência dissipada acima do limite | 💥 Filamento Rompido por excesso de potência! |
| **Motor** | $V \le 18\text{ V}$ | Queda de tensão acima do limite | 💥 Bobina Queimada por sobretensão! |
| **Bateria/Fonte** | $R_{total} > 0,1\ \Omega$ | Conexão direta entre polos ($R \le 0,1\ \Omega$) | 🚨 Curto-Circuito Detectado! Circuito desarmado. |

Quando um componente é danificado:
1. O componente recebe uma sobreposição visual de dano (💥).
2. Seu ID é registrado em `burnedComponentIds`.
3. O circuito abre imediatamente.
4. O painel do Prof. Volts exibe um alerta de emergência e oferece a ação rápida **"Substituir Todos Queimados"**.

## Roteamento Ortogonal Inteligente de Fios (Manhattan Wire Routing)

O `WiresPainter` calcula dinamicamente o traçado dos fios:
- **Modo Esquemático (Diagrama)**: Roteamento Ortogonal com cantos arredondados de $90^\circ$. Se o fio for de retorno (conectar terminal direito de volta ao esquerdo), o traçado contorna automaticamente por baixo de todos os componentes da bancada, sem cruzar por cima dos corpos dos componentes.
- **Modo Físico 3D**: Traçado curvo volumétrico com caimento realista por gravidade e destaque especular metálico.
- **Partículas de Corrente**: Elétrons brilhantes deslizam ao longo do caminho calculado quando a simulação está ativa (`isWireActive == true`).

## Grandezas calculadas e exibidas

```text
V = R × I
I = V / R
P = V × I
```

Exemplo de exibição no painel de métricas:

```text
Resistor [R1]
Resistência: 100 Ω
Tensão (Vdrop): 9.0 V
Corrente (I): 90 mA (0.09 A)
Potência (P): 0.81 W
```

## Referências

- [`testes.md`](testes.md) — casos de teste do solver.
- [`especificacao-componentes.md`](especificacao-componentes.md) — componentes e especificações.