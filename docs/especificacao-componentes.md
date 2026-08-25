# Especificação de componentes

A arquitetura de componentes (Fase 4+) é baseada em uma classe base comum. Cada
componente possui `id`, `position`, `rotation`, `terminals`, `properties` e
`state`.

## Classe base (referência)

```dart
abstract class CircuitComponent {
  String id;
  Vector2 position;
  double rotation;

  List<Terminal> terminals;

  void updateSimulation();
}
```

A implementação concreta pode ser adaptada conforme a arquitetura escolhida,
mas deve manter separados:

- **modelo matemático** (planejado em `simulation/` para a Banqueta) — terminais, propriedades, participação no solver;
- **componente visual** (`widgets/` e pintores em `lib/widgets/component_physical_painter.dart`, `lib/widgets/circuit_symbol_painter.dart`) — desenho customizado 2D/3D no canvas.

## Componentes da v1

### Battery
- Propriedades: `voltage`, `internalResistance`.
- Papel: fornecer tensão ao circuito (fonte).

### Resistor
- Propriedade: `resistance` (Ω).
- Papel: limitar a corrente; base para Introduzir `V = R × I`.

### Lamp (lâmpada)
- Propriedades: `resistance`, `brightness`.
- A **intensidade da iluminação depende da potência elétrica**
  (`P = V × I`). Circuito aberto ou sem fonte → apagada.

### Switch (interruptor)
- Estados: `aberto`, `fechado`.
- Fechado → permite passagem de corrente; aberto → a corrente é zero.

### Wire (fio)
- Representa a conexão entre dois terminais.
- Deve acompanhar os terminais quando componentes são movidos.

### Multimeter (multímetro)
- Inicialmente: medição de **tensão** e **corrente**.
- Posteriormente: **resistência**.

## Componentes previstos (versões futuras)

capacitor · indutor · LED · diodo · transistor · motor · sensores ·
fontes AC · portas lógicas.

## Como adicionar um componente

1. Criar o modelo visual físico em `lib/widgets/component_physical_painter.dart` e o modelo visual esquemático correspondente em `lib/widgets/circuit_symbol_painter.dart`.
2. Definir as constantes físicas do componente (por exemplo, bornes, tamanho relativo e gradientes de renderização).
3. Se for um componente dinâmico ou interativo, implementar a lógica reativa em sua tela de controle (por exemplo, rotação do motor baseada em animação contínua, status aceso/apagado da lâmpada, estados aberto/fechado do interruptor).
4. Para a Banqueta Livre futura, registrar o componente no catálogo matemático em `simulation/`.

## Grandezas elétricas

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

## Representação da corrente

- Partículas animadas pelos fios (pintadas via `CustomPainter` com otimização `RepaintBoundary`) quando o circuito conduz.
- Velocidade proporcional à intensidade da corrente e controlada pelas configurações.
- Movimento interrompido quando o circuito está aberto.
- **Representação didática** — não sugere velocidade real de elétrons.