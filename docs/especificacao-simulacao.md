# Especificação do motor de simulação

## Princípio

O motor elétrico é **completamente separado da camada visual do Flame**:

```text
Flutter UI
     ↓
Flame
     ↓
Circuit Model
     ↓
Circuit Solver
     ↓
Simulation Result
```

A lógica matemática não fica nos componentes visuais.

## Modelo do circuito (grafo)

```text
Circuit
 ├── Nodes          (nós = pontos de potencial único)
 ├── Terminals      (terminais dos componentes)
 ├── Connections    (conexões entre terminais)
 └── Components     (bateria, resistor, lâmpada, interruptor, fio, ...)
```

- Componentes ligam **terminais**.
- Conexões equivalentes agrupam terminais em **nós**.
- O solver resolve tensões nodais e correntes nos componentes.

## Solvers

- **Lei de Ohm**: `V = R × I`, `I = V / R`.
- **Leis de Kirchhoff**: conservação de corrente nos nós e de tensão nas malhas.
- **Análise nodal** quando necessário (circuitos com múltiplas malhas).

## Resultado da simulação

```dart
class SimulationResult {
  Map<String, double> nodeVoltages;
  Map<String, double> componentCurrents;
  Map<String, double> componentVoltages;
  Map<String, double> componentPower;

  bool isValid;
  String? error;
}
```

Cada componente/informação é referenciada por chave (ex.: id do componente).

## Estados de erro identificados

O solver e a validação do desafio devem reconhecer:

- **Circuito aberto** — não há caminho fechado para a corrente.
- **Curto-circuito** — caminho sem resistência/fonte adequada.
- **Componente desconectado** — terminal sem conexão.
- **Valor incorreto** — propriedade diferente do solicitado.
- **Ausência de fonte** — não há fonte de tensão conectada.
- **Resposta numérica incorreta** — resposta diferente da esperada.

## Grandezas calculadas e exibidas

```text
V = R × I
I = V / R
P = V × I
```

Exemplo de exibição:

```text
Resistor
100 Ω

V: 10 V
I: 0,1 A
P: 1 W
```

## Corrente elétrica visual

- Animar partículas pelos fios quando o circuito está fechado e conduzindo
  (Flame).
- Velocidade proporcional à intensidade da corrente.
- Interromper o movimento quando o circuito estiver aberto.
- A animação é uma **representação didática** apenas.

## Casos esperados (referência para testes)

| Cenário | Valores | Resultado esperado |
|---|---|---|
| Lei de Ohm 1 | `V = 10 V`, `R = 100 Ω` | `I = 0,1 A` |
| Lei de Ohm 2 | `V = 10 V`, `R = 1 kΩ` | `I = 0,01 A` |
| Interruptor aberto | qualquer | `I = 0 A` |
| Série | `R1 = 100 Ω`, `R2 = 200 Ω`, `V = 10 V` | `Req = 300 Ω`, `I ≈ 0,0333 A` |

## Referências

- [`testes.md`](testes.md) — casos de teste detalhados.
- [`especificacao-componentes.md`](especificacao-componentes.md) — componentes.