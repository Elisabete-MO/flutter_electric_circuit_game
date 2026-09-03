# EletroLab — Especificação de implementação reformulada

## Objetivo

Implementar em Flutter/Flame a campanha **Feira de Ciências da Comunidade**. São dez estandes de circuitos de baixa tensão simulada. O jogador prepara demonstrações para visitantes, formula previsões, investiga falhas, toma decisões de projeto e integra uma maquete comunitária.

## Estrutura de missão obrigatória

Cada estande contém exatamente cinco missões, na sequência:

1. `prepare` — introdução montável e contextualizada.
2. `predict` — escolha ou registro de resultado esperado antes do teste.
3. `investigate` — diagnóstico por observação, continuidade ou medição.
4. `design` — solução com uma condição prática, comparação ou restrição.
5. `demonstrate` — cenário de visita, verificação e explicação.

Uma previsão não precisa estar correta para a missão continuar, mas precisa ser comparada ao resultado. A vitória elétrica e a explicação são registradas separadamente; a missão fica plenamente concluída apenas com as três dimensões da rubrica.

## UX de missão

- Cabeçalho: estande, objetivo em linguagem de situação, etapa e botão de dica.
- Antes de **Testar circuito**, abrir um cartão curto: “O que você prevê que acontecerá?”
- Após o teste, mostrar `previsão`, `observação` e `por quê`, sem revelar uma montagem pronta.
- Missões de investigação apresentam hipóteses plausíveis e exigem evidência para descartá-las.
- Missões de projeto possuem critérios visíveis, por exemplo: independência, brilho seguro, resposta a botão ou funcionamento sob evento.
- Missões de demonstração usam eventos simulados: visitante pressiona botão, escurece, lâmpada entra em manutenção ou surge uma falha final.

## Dados

```dart
enum MissionMode { prepare, predict, investigate, design, demonstrate }

class MissionDefinition {
  final String id;
  final MissionMode mode;
  final String situation;
  final String objective;
  final List<ComponentType> allowedComponents;
  final CircuitGoal goal;
  final PredictionPrompt? prediction;
  final List<InvestigationHypothesis> hypotheses;
  final List<ScenarioEvent> events;
  final String visitorExplanation;
}
```

`PredictionPrompt` contém alternativas e uma explicação curta após o teste. `InvestigationHypothesis` define uma hipótese, indícios permitidos e medições/testes capazes de refutá-la. `ScenarioEvent` modela ações como `nightFalls`, `visitorPressesButton`, `removeLamp` e `finalFault`.

## Componentes e coerência

Componentes iniciais: `battery`, `wire`, `bulb`, `switchComponent`.

Desbloqueáveis: `junction`, `led`, `diode`, `resistor`, `motor`, `voltmeter`, `ammeter`, `fuse`, `potentiometer`, `ldr`, `capacitor`, `relay`, **`transistor`**. Se não houver transistor na interface, substituí-lo explicitamente por `sensorController`; não manter o transistor implícito em uma missão.

Preservar regras de circuito fechado, interruptor, polaridade, resistor para LED, série/paralelo, inversão de motor, curto didático, fusível, capacitor e relé. O relé deve separar visualmente e funcionalmente `controlCircuit` e `loadCircuit`.

## Avaliação

| Dimensão | Evidência para 3 pontos |
|---|---|
| Funciona | Cumpre o comportamento solicitado no cenário sem correção posterior |
| Está seguro | Identifica risco antes de energizar e usa proteção apropriada |
| Consegue explicar | Justifica a escolha usando previsão, observação ou valor medido |

Estados de feedback principais: `success`, `openCircuit`, `shortCircuit`, `reversePolarity`, `unsafeCurrent`, `wrongTopology`, `measurementError`. Acrescentar `predictionMismatch` como retorno informativo, nunca como falha punitiva.

## Progressão e desbloqueio

O estande seguinte é liberado com quatro das cinco missões completas no atual. A Praça da Maquete Coletiva exige quatro missões concluídas nos nove estandes anteriores. A apresentação final libera todos os componentes na Bancada Livre.

## Critérios de aceite adicionais

1. Toda missão tem situação concreta, objetivo, dica, teste, feedback e explicação.
2. Em cada estande há ao menos uma previsão e uma decisão baseada em evidência.
3. Diagnósticos não revelam diretamente o componente errado; o jogador coleta evidência.
4. A maquete final inclui um cenário simultâneo: noite, portão e manutenção de uma casa.
5. Nenhuma instrução ensina manipulação de rede elétrica ou alta tensão.
