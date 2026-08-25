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

- **modelo matemático** (`simulation/`) — terminais, propriedades, participação
  no solver;
- **componente visual** (`game/components/`) — desenho, animação, interação.

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

1. Criar o **modelo matemático** em `simulation/` (terminais + propriedades +
   participação no solver) e o **componente visual** em `game/components/`.
2. Definir terminais e propriedades editáveis.
3. Registrar no catálogo/paleta da banqueta (nome, ícone, cor).
4. Adicionar testes do solver se o componente alterar o comportamento do
   circuito.
5. Não colocar lógica matemática nos componentes visuais.

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

- Partículas animadas pelos fios (Flame) quando o circuito conduz.
- Velocidade proporcional à intensidade da corrente.
- Movimento interrompido quando o circuito está aberto.
- **Representação didática** — não sugere velocidade real de elétrons.