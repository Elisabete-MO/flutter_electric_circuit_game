# EletroLab — Especificação para implementação da campanha Feira de Ciências

## 1. Objetivo

Implementar, em Flutter/Flame, a campanha **Feira de Ciências da Comunidade**. A experiência é uma trilha de dez estandes de circuitos em baixa tensão simulada. O jogador realiza missões de montagem, diagnóstico, medição e explicação; ao final integra os subsistemas em uma maquete comunitária.

## 2. Escopo narrativo e UX

- Professor Volts é o coordenador da feira e aparece em abertura, dica opcional e encerramento de cada estande.
- Cada estande é um cartão de campanha com: equipe, objetivo científico, cinco missões, progresso `0/5` e selo de conclusão.
- Nunca apresentar linguagem de fantasia, “mundos”, magia, vilões, cristais ou recompensas sobrenaturais.
- A narrativa deve mencionar alunos, cartazes, protótipos, visitantes, demonstrações, revisão e maquete coletiva.
- Usar apenas termos de **baixa tensão didática/simulada**; não orientar montagem em rede elétrica residencial.

## 3. Fluxo de telas

```text
Menu inicial
  ├─ Primeiros passos: tutorial de fios, terminais e feedback
  ├─ Começar: mapa/lista da Feira de Ciências
  │   └─ Estande → abertura → missões → encerramento
  ├─ Bancada Livre: sandbox com componentes desbloqueados
  └─ Configurações: áudio, acessibilidade e reiniciar progresso
```

### Tela “Mapa da Feira”

- Exibir os dez estandes em ordem; o seguinte é liberado ao concluir pelo menos quatro das cinco missões do atual.
- Mostrar nome, equipe, ícone, conceito, progresso e selo.
- A Praça da Maquete Coletiva é liberada quando os nove estandes anteriores tiverem pelo menos quatro missões concluídas.

### Tela de missão

- Cabeçalho: nome do estande, missão atual, objetivo em uma frase e botão de dica.
- Lado esquerdo/superior: paleta de componentes liberados.
- Centro: bancada com pontos de conexão e fios manipuláveis.
- Lado direito/inferior: painel de estado, medidores quando liberados e botão **Testar circuito**.
- Rodapé: fala de Professor Volts, botão de desfazer e botão de reiniciar somente a missão.
- Após êxito: painel com conceito observado, pontuação por critério e breve texto para o visitante.

## 4. Dados de campanha

```dart
class FairStand {
  final String id;
  final String title;
  final String teamName;
  final String concept;
  final String openingDialogue;
  final String hintDialogue;
  final String closingDialogue;
  final List<MissionDefinition> missions;
}

class MissionDefinition {
  final String id;
  final String title;
  final String objective;
  final List<ComponentType> allowedComponents;
  final CircuitGoal goal;
  final List<FaultRule> expectedFaults;
  final String visitorExplanation;
  final int unlockThreshold;
}
```

Cadastrar os estandes, nesta ordem: `acende_ai`, `liga_desliga`, `ruas_maquete`, `letreiros_led`, `movimento_miniatura`, `mede_testa_explica`, `circuito_seguro`, `horta_monitorada`, `portao_escola`, `maquete_coletiva`.

Cada estande contém exatamente cinco missões dinâmicas conforme `estandes-missoes-detalhadas.md`, combinando mecânicas variadas (Montagem de Circuito, Previsão & Teste, Diagnóstico & Correção, Mapeamento & Medição e Demonstração Didática / Explicação). Não gerar missões aleatórias na campanha principal.

## 5. Componentes e simulação

### Componentes iniciais

`battery`, `wire`, `bulb`, `switchComponent`.

### Componentes desbloqueáveis

`junction`, `led`, `diode`, `resistor`, `motor`, `voltmeter`, `ammeter` (se existir), `fuse`, `potentiometer`, `thermistor` ou `ldr`, `capacitor`, `relay`.

### Regras essenciais

- Terminais conectados formam um grafo de circuito.
- Uma carga só deve ativar quando houver percurso válido entre terminais da fonte.
- Interruptor aberto interrompe a conexão; fechado a permite.
- LED/diodo respeitam polaridade. LED requer resistor para estado “seguro”.
- Lâmpadas em paralelo continuam ativas se outro ramo for removido; em série, a abertura interrompe o conjunto.
- Motor CC muda sentido ao inverter a polaridade.
- Curto-circuito didático: detectar caminho de resistência muito baixa entre polos que ignora a carga; nunca simular risco físico real, apenas pausar e explicar.
- Fusível entra em estado `blown` quando a regra de sobrecorrente simulada for atingida.
- Relé separa `controlCircuit` e `loadCircuit`; bobina energizada muda contatos.
- Medidores devem exibir valores coerentes com o modelo simplificado e indicar ponto de medição inválido.

## 6. Avaliação e feedback

Ao pressionar **Testar circuito**, retornar exatamente um estado principal:

| Estado | Condição | Mensagem-base |
|---|---|---|
| `success` | critérios da missão atendidos | “Demonstração pronta para os visitantes!” |
| `openCircuit` | caminho interrompido | “O circuito está aberto. Revise os terminais.” |
| `shortCircuit` | fonte desviada sem carga | “Curto simulado detectado. Reorganize os fios.” |
| `reversePolarity` | LED/diodo invertido | “A polaridade deste componente precisa ser respeitada.” |
| `unsafeCurrent` | LED sem limitação adequada | “Inclua um resistor para limitar a corrente.” |
| `wrongTopology` | série/paralelo diferente do objetivo | “O circuito funciona, mas não atende à demonstração pedida.” |
| `measurementError` | medidor em ponto inadequado | “Revise onde as pontas de prova foram colocadas.” |

Pontuar de 0 a 3 em `functionality`, `safety` e `communication`. A dimensão de comunicação é concluída por uma pergunta objetiva ou pela seleção de uma explicação correta; não bloquear a vitória elétrica caso essa etapa esteja pendente, mas marcar a missão como completa apenas quando as três dimensões forem registradas.

## 7. Persistência

Salvar localmente:

```json
{
  "campaignVersion": 2,
  "stands": {"acende_ai": {"completedMissionIds": ["m1"], "bestScores": {"m1": 9}}},
  "unlockedComponentIds": ["battery", "wire", "bulb"],
  "maqueteColetivaUnlocked": false,
  "settings": {"sound": true, "highContrast": false, "reducedMotion": false}
}
```

Aplicar migração não destrutiva: progresso anterior incompatível deve ser arquivado/reiniciado com aviso claro, sem travar o aplicativo.

## 8. Acessibilidade e comunicação

- Não depender somente de cor para indicar estado; combinar cor, ícone e texto.
- Fornecer descrições semânticas para componentes e terminais.
- Permitir fonte ampliada, alto contraste, redução de movimento e controles por toque/mouse.
- Manter mensagens curtas, em português do Brasil, com termos explicados no primeiro uso.
- Permitir repetir as falas do Professor Volts e pular animações narrativas.

## 9. Critérios de aceite

1. Os dez estandes e suas cinco missões são navegáveis.
2. A narrativa usa somente contexto de feira de ciências comunitária.
3. Todas as missões apresentam objetivo, componentes, dica, teste, feedback e conclusão.
4. Série, paralelo, polaridade, resistor, motor, medição, falhas, sensor, capacitor e relé possuem comportamentos verificáveis.
5. A maquete coletiva requer integração de iluminação, horta e portão, além de uma inspeção final.
6. O progresso persiste após fechar e reabrir o aplicativo.
7. Nenhum conteúdo sugere manipulação de rede elétrica ou alta tensão.

## 10. Testes mínimos

- Unitários para grafo de conexão, estado do interruptor, polaridade, série/paralelo, curto simulado, fusível, motor e relé.
- Widget tests para estados de feedback e desbloqueio sequencial dos estandes.
- Teste de integração: concluir quatro missões em cada estande 1–9 libera a Praça da Maquete Coletiva; concluir a apresentação final libera todos os componentes na Bancada Livre.
- Teste de regressão do salvamento e das configurações de acessibilidade.
