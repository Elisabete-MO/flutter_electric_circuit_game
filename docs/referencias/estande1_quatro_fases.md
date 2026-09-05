# EletroLab — Primeiro Estande (4 Fases)

## Visão geral

**Sumário:** MVP do primeiro estande como uma jornada guiada em quatro fases: reconhecer componentes, inspecionar um circuito pronto, associar símbolos ao circuito físico e montar livremente um circuito em uma bancada controlada até acender a primeira luz da maquete.

**Esforço:** grande.

**Fluxo crítico:** contrato da missão → coordenador do fluxo → regras elétricas → fases 1 a 4 → persistência e integração com o mapa → testes.

---

## Objetivos e entregáveis

| Item | Descrição |
|---|---|
| **Objetivo central** | Entregar o primeiro estande como uma jornada jogável de quatro fases que termina com a iluminação do primeiro ponto da maquete. |
| **Entregáveis** | Rota dedicada, coordenador do fluxo, quatro fases, estado de progresso local, validação elétrica, feedback pedagógico, painel de resultados e cobertura de testes. |
| **Obrigatório** | Seguir `docs/EletroLab_MVP_Primeiro_Estande.md`, permitir montagem livre controlada na Fase 4, validar conexões elétricas, funcionar em 360 × 740 e cobrir cenários de sucesso, erro e persistência. |
| **Fora do escopo** | Simulador elétrico geral, múltiplos estandes completos, backend, sincronização em nuvem, ranking, SPICE e análise nodal avançada. |

## Distinção entre as duas bancadas livres

| Experiência | Definição |
|---|---|
| **Fase 4 do estande 1** | Bancada livre controlada. O aluno posiciona e conecta livremente somente os componentes previstos no primeiro desafio. |
| **Estande 12** | Laboratório livre geral, com catálogo ampliado e sem as restrições pedagógicas do primeiro estande. |

A Fase 4 não deve reutilizar a interface do estande 12 de forma que as duas experiências se tornem iguais. Mecânicas internas podem ser compartilhadas, mas catálogo, regras, objetivos, progresso e apresentação devem permanecer separados.

---

## Referências cruzadas

- Fonte de verdade: `docs/EletroLab_MVP_Primeiro_Estande.md`.
- Estrutura existente: `lib/models/stand_data.dart` e `lib/models/first_step_component.dart`.
- Tutorial atual: `lib/screens/first_steps/first_steps_screen.dart`.
- Bancada geral: `lib/screens/sandbox/sandbox_screen.dart`.
- Navegação: `lib/app/routes.dart` e `lib/screens/home/home_screen.dart`.
- Estado e simulação: `lib/state/sandbox_controller.dart` e `lib/state/progress_controller.dart`.
- Widgets reutilizáveis: `lib/widgets/symbol_card.dart`, `lib/widgets/prof_volts_feedback_dialog.dart` e `lib/widgets/glass_container.dart`.

Antes de alterar os arquivos listados, conferir se os caminhos e contratos continuam válidos na versão atual do projeto.

---

## Modelo de estado

O fluxo deve possuir um estado único e consistente, sem duplicar informações deriváveis.

Estrutura conceitual recomendada:

```dart
class FirstBenchFlowState {
  final int currentPhaseId;
  final Set<int> completedPhaseIds;
  final int snapshotVersion;

  bool get firstBenchCompleted => completedPhaseIds.contains(4);
  bool get maquetteLit => firstBenchCompleted;
}
```

### Invariantes

- `currentPhaseId` deve permanecer entre 1 e 4.
- Uma fase só pode ser concluída depois de desbloqueada.
- A progressão padrão é sequencial.
- Fases concluídas podem ser repetidas sem apagar o progresso posterior.
- `maquetteLit` deve ser derivado da conclusão da Fase 4, não persistido separadamente.
- Dados ausentes ou corrompidos devem restaurar um estado inicial seguro.
- O snapshot deve possuir versão para permitir migrações futuras.
- A chave de persistência deve ser exclusiva do primeiro estande.

---

## Regras elétricas consolidadas

O motor de validação deve analisar a topologia das conexões, não as coordenadas visuais nem uma ordem rígida de componentes.

### Circuito esperado

**Bateria (+) → interruptor → resistor → LED → bateria (−)**

O resistor pode aparecer antes ou depois do LED, desde que ambos estejam no mesmo caminho em série. A organização espacial escolhida pelo aluno não interfere na validade elétrica.

### Matriz obrigatória de resultados

| Situação | Resultado esperado |
|---|---|
| Circuito correto com interruptor fechado | LED e primeiro ponto da maquete acendem. |
| Circuito correto com interruptor aberto | Circuito válido, porém sem corrente; LED apagado. |
| LED invertido | LED apagado e feedback sobre ânodo e cátodo. |
| Resistor de 68 Ω | Corrente excessiva; energização segura bloqueada ou simulada. |
| Resistor de 680 Ω | Circuito seguro e funcional, com corrente aproximada de 10,3 mA. |
| Resistor de 6,8 kΩ | Corrente baixa; LED muito fraco ou apagado no modelo didático. |
| Resistor ausente | Proteção ausente; sucesso bloqueado. |
| Fio ausente | Circuito aberto; trecho incompleto indicado. |
| Polos ligados diretamente | Curto-circuito; energização bloqueada. |

### Serviço de domínio recomendado

Criar uma validação independente da interface, com entrada serializável e saída estruturada:

```dart
enum CircuitStatus {
  safeAndLit,
  validButOpen,
  reversedLed,
  excessiveCurrent,
  lowCurrent,
  missingResistor,
  openCircuit,
  shortCircuit,
}
```

Cada resultado deve informar status, mensagem pedagógica, componente relacionado e se a energização é permitida.

---

## Estratégia de execução

| Onda | Tarefas | Dependência |
|---|---|---|
| **Onda 1 — Fundação** | 1 a 3 | A auditoria precede os contratos; modelo e validação podem avançar após ela. |
| **Onda 2 — Orquestração** | 4 e 5 | Modelo de fluxo definido e estrutura existente confirmada. |
| **Onda 3 — Experiência jogável** | 6 a 9 | Coordenador, rotas e serviço de validação disponíveis. |
| **Onda 4 — Integração e qualidade** | 10 | Todas as fases implementadas. |

As tarefas devem ser paralelizadas somente quando não modificarem os mesmos arquivos ou contratos. Não utilizar quantidade mínima artificial de tarefas por onda.

---

## Tarefas

### 1. Auditar a estrutura existente

**Objetivo:** confirmar rotas, controllers, componentes reutilizáveis, regras da sandbox e convenções atuais antes da implementação.

**Critérios de aceitação:**

- [ ] Todos os caminhos citados no plano foram confirmados ou atualizados.
- [ ] Foram identificadas as mecânicas da sandbox que podem ser compartilhadas sem acoplar a Fase 4 ao estande 12.
- [ ] Nenhum arquivo fora do escopo foi incluído sem justificativa.

### 2. `lib/models/first_bench_flow.dart` — contrato do fluxo

**Objetivo:** representar fase atual, fases concluídas, desbloqueio, repetição, versão do snapshot e recuperação segura.

**Critérios de aceitação:**

- [ ] O modelo representa exatamente quatro fases.
- [ ] Estados inconsistentes são impedidos ou normalizados.
- [ ] Serialização e desserialização não perdem dados.
- [ ] Snapshot inválido restaura a Fase 1 sem causar erro.

### 3. Serviço de validação elétrica

**Objetivo:** implementar as regras elétricas em Dart puro, sem dependência de widgets ou coordenadas visuais.

**Critérios de aceitação:**

- [ ] A matriz completa de resultados elétricos está implementada.
- [ ] Resistor antes ou depois do LED é aceito.
- [ ] Curto-circuito e corrente excessiva bloqueiam energização real.
- [ ] Cada falha retorna feedback pedagógico específico.
- [ ] O serviço possui testes unitários determinísticos.

### 4. `lib/screens/first_bench/first_bench_flow_screen.dart` — coordenador

**Objetivo:** controlar carregamento, fase atual, desbloqueio, avanço, repetição, retomada, conclusão e retorno ao mapa.

**Critérios de aceitação:**

- [ ] O fluxo abre na primeira fase incompleta.
- [ ] Fases futuras permanecem bloqueadas.
- [ ] Fases concluídas podem ser repetidas.
- [ ] Cada tela recebe estado e callbacks pelo coordenador.
- [ ] A conclusão da Fase 4 atualiza o estande 1 e retorna ao mapa corretamente.

### 5. Rotas e entrada pelo mapa

**Arquivos candidatos:** `lib/app/routes.dart` e `lib/screens/home/home_screen.dart`.

**Objetivo:** fazer o estande 1 abrir o coordenador do primeiro estande e preservar o comportamento do estande 12 e das demais rotas.

**Critérios de aceitação:**

- [ ] Selecionar o estande 1 abre o fluxo correto.
- [ ] O estande 12 continua abrindo o laboratório geral.
- [ ] Configurações e demais rotas não sofrem regressão.
- [ ] Ao retornar ao mapa, o estado visual do estande 1 é atualizado.

### 6. Fase 1 — Conheça os componentes

**Arquivo candidato:** `lib/screens/first_steps/first_steps_screen.dart`.

**Objetivo:** apresentar bateria, LED, resistor, interruptor e fios, seguidos de um quiz curto com feedback explicativo.

**Critérios de aceitação:**

- [ ] Os cinco componentes são apresentados com nome, função, terminais e cuidados aplicáveis.
- [ ] Todos os cards necessários são visualizados.
- [ ] Resposta errada explica o erro e permite nova tentativa sem penalidade.
- [ ] A conclusão exige acerto de todas as perguntas.
- [ ] O avanço desbloqueia a Fase 2.

### 7. Fase 2 — Inspecione o circuito

**Arquivo candidato:** `lib/screens/first_bench/first_bench_phase2.dart`.

**Objetivo:** apresentar um circuito não editável para inspeção de componentes, resistor, polaridade, estado do interruptor e continuidade.

Definir cenários por dados:

```dart
enum InspectionScenario {
  correct,
  reversedLed,
  missingResistor,
  incorrectResistor,
  openCircuit,
}
```

**Critérios de aceitação:**

- [ ] O circuito permanece somente para leitura.
- [ ] O aluno inspeciona todos os pontos exigidos antes de responder.
- [ ] Cada cenário possui uma conclusão e um feedback específicos.
- [ ] Cenários podem ser injetados nos testes, sem depender de sorteio.
- [ ] A conclusão desbloqueia a Fase 3.

### 8. Fase 3 — Do componente ao símbolo

**Arquivo candidato:** `lib/screens/first_bench/first_bench_phase3.dart`.

**Objetivo:** relacionar o circuito físico ao diagrama por meio de símbolos embaralhados.

**Símbolos obrigatórios:**

- bateria;
- interruptor;
- resistor;
- LED;
- lâmpada como distrator;
- diodo comum como distrator.

Os fios permanecem desenhados. O desafio valida identidade, orientação do LED e estado do interruptor.

**Critérios de aceitação:**

- [ ] Alternância entre os modos Físico e Diagrama funciona.
- [ ] Os símbolos aparecem em ordem embaralhada.
- [ ] Arrastar funciona com mouse e toque.
- [ ] Associações incorretas recebem feedback específico.
- [ ] A conclusão exige os quatro símbolos corretos.
- [ ] O avanço desbloqueia a Fase 4.

### 9. Fase 4 — Bancada livre controlada

**Arquivo candidato:** `lib/screens/first_bench/first_bench_phase4.dart`.

**Objetivo:** permitir que o aluno monte, conecte, preveja, teste e corrija sozinho o circuito responsável pela primeira luz da maquete.

**Biblioteca controlada:**

- bateria de 9 V;
- interruptor SPST;
- LED vermelho;
- resistores de 68 Ω, 680 Ω e 6,8 kΩ;
- fios;
- ferramenta para remover conexões.

**Liberdade obrigatória:**

- posicionar componentes em qualquer local da bancada;
- conectar terminais manualmente;
- escolher a organização visual e a ordem dos componentes em série;
- abrir e fechar o interruptor;
- testar e corrigir sem reiniciar toda a fase.

**Ciclo obrigatório:**

1. O aluno monta o circuito.
2. Pressiona **Testar**.
3. Prevê se o LED acenderá, ficará apagado, receberá corrente excessiva ou se existe curto-circuito.
4. Confirma em **Energizar circuito**.
5. Observa o resultado e recebe uma explicação.
6. Corrige possíveis erros permanecendo na mesma bancada.

**Critérios de aceitação:**

- [ ] Não existem posições predeterminadas obrigatórias.
- [ ] A validação usa conexões elétricas, não coordenadas.
- [ ] Todos os estados da matriz elétrica são reconhecidos.
- [ ] A previsão é registrada e comparada ao resultado real.
- [ ] Curto-circuito e situações inseguras são bloqueados de forma didática.
- [ ] A montagem correta acende simultaneamente o LED e o ponto da maquete.
- [ ] A conclusão marca o primeiro estande como concluído.

### 10. Persistência, mapa, responsividade e testes integrados

**Objetivo:** finalizar a integração, garantir retomada segura e provar o fluxo completo em diferentes telas e formas de entrada.

**Persistência:**

- salvar fases concluídas e fase atual;
- restaurar o fluxo após reabrir o aplicativo;
- recuperar estado inválido de maneira segura;
- resetar somente o progresso do primeiro estande quando solicitado;
- atualizar o indicador visual do estande 1 no mapa.

**Painel de resultados da Fase 4:**

| Grandeza | Resultado didático |
|---|---|
| Tensão da bateria | 9 V |
| Tensão direta do LED | 2 V |
| Resistor selecionado | 680 Ω |
| Corrente aproximada | 10,3 mA |
| Avaliação | Circuito seguro e funcional |

Exibir a relação:

**I = (9 V − 2 V) ÷ 680 Ω ≈ 10,3 mA**

**Testes obrigatórios:**

- testes unitários do modelo de fluxo;
- testes unitários da matriz elétrica;
- testes de widget para cada fase;
- navegação mapa → estande 1 → fases 1 a 4 → mapa;
- pelo menos um caso de falha por fase;
- persistência usando uma instância simulada de `SharedPreferences`;
- repetição de fase concluída;
- recuperação de snapshot corrompido;
- ausência de regressão no estande 12.

**Matriz de dispositivos:**

- 360 × 740;
- tablet em orientação vertical e horizontal;
- 1366 × 768;
- 1920 × 1080;
- mouse;
- toque;
- rolagem da biblioteca no celular;
- textos sem sobreposição ou transbordamento.

---

## Verificação final

Executar e registrar:

- [ ] `flutter analyze` sem novos erros.
- [ ] Suíte de testes automatizados aprovada.
- [ ] Auditoria de conformidade com este plano.
- [ ] Revisão de qualidade do código.
- [ ] Teste manual real do caminho completo.
- [ ] Revisão de fidelidade ao escopo pedagógico.
- [ ] Conferência visual nas resoluções definidas.

Essas verificações podem ser executadas sequencialmente ou em paralelo, conforme as ferramentas disponíveis. A aprovação não depende de uma quantidade fixa de agentes.

---

## Critérios finais de sucesso

- O primeiro estande segue as quatro fases documentadas.
- Um aluno iniciante recebe apoio progressivamente reduzido.
- A Fase 4 oferece liberdade de montagem dentro de um catálogo controlado.
- A validação considera conexões e topologia, não posições na tela.
- O aluno prevê o resultado antes da energização.
- O sistema diferencia circuito correto, aberto, invertido, fraco, excessivo e em curto.
- O painel final apresenta os resultados elétricos didáticos.
- A conclusão ilumina a maquete e atualiza o mapa.
- O progresso persiste localmente e se recupera de dados inválidos.
- A experiência funciona em desktop, tablet e 360 × 740.
- Testes comprovam sucesso, falha, persistência e ausência de regressão.

---

## Guardrails

- Não transformar o primeiro estande em simulador elétrico geral.
- Não expandir a implementação para outros estandes.
- Não adicionar backend, sincronização em nuvem ou ranking.
- Não exigir conhecimento prévio do aluno.
- Não transformar a Fase 4 em montagem por posições predeterminadas.
- Não expor o catálogo completo do estande 12 na Fase 4.
- Não validar circuitos por coordenadas ou por uma única ordem visual.
- Não adicionar SPICE ou análise nodal avançada.
- Não alterar rotas, telas ou assets fora do escopo sem justificativa e autorização.
