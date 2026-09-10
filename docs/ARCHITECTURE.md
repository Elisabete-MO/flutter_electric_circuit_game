# Arquitetura e Estado Técnico

## 1. Autoridade e escopo

O código-fonte é a autoridade para o comportamento efetivamente implementado em runtime.

Este documento descreve a arquitetura e o estado técnico atual do EletroLab. Ele não define sozinho produto futuro, pedagogia, campanha ou prioridade de implementação.

A responsabilidade documental é separada:

* `PRODUCT.md` — visão, escopo e decisões de produto;
* `PEDAGOGY.md` — aprendizagem e interação;
* `CAMPAIGN.md` — campanha, estandes e progressão;
* `FIRST_STAND.md` — especificação do Primeiro Estande;
* `PORTAO_DA_ESCOLA.md` — proof of architecture avançado do relé;
* `ROADMAP.md` — trabalho futuro e frentes de desenvolvimento;
* `CODEBASE_AUDIT.md` — registro factual e histórico das auditorias e limpezas do repositório.

Quando houver divergência entre este documento e o comportamento efetivamente implementado, o código deve ser novamente verificado e a documentação corrigida.

---

## 2. Runtime

| Área         | Tecnologia / mecanismo          | Estado atual                                          |
| ------------ | ------------------------------- | ----------------------------------------------------- |
| Framework    | Flutter                         | Runtime principal da aplicação                        |
| Estado       | Riverpod                        | Controllers e providers                               |
| UI           | MaterialApp                     | Rotas nomeadas e navegação via Navigator              |
| Renderização | CustomPainter + widgets Flutter | Circuitos, fios, instrumentos e elementos visuais     |
| Persistência | SharedPreferences               | Preferências, progresso, Bancada e fluxos específicos |
| Localização  | flutter_localizations + intl    | Português e inglês                                    |
| Solver       | Dart + `compute()`              | Execução do cálculo fora da isolate principal         |
| Tipografia   | Google Fonts                    | Uso ativo na interface                                |

Flame não faz parte do runtime atual.

---

## 3. Navegação

As rotas atuais são definidas em `lib/app/routes.dart`.

| Rota                   | Tela                       | Estado |
| ---------------------- | -------------------------- | ------ |
| `/`                    | `SplashScreen`             | Ativa (Boot e pré-carregamento de assets via `Preloader`) |
| `/menu`                | `MainMenuScreen`           | Ativa (Menu Principal e seleção de modos) |
| `/intro`               | `IntroScreen`              | Ativa (Introdução com a Professora Nuri) |
| `/home`                | `HomeScreen`               | Ativa (Mapa da Feira de Ciências) |
| `/first-steps`         | `FirstStepsScreen`         | Ativa  |
| `/second-bench`        | `SecondBenchFlowScreen`    | Ativa  |
| `/liga-desliga`        | `LigaDesligaScreen`        | Ativa  |
| `/ruas-maquete`        | `RuasMaqueteScreen`        | Ativa  |
| `/letreros-led`        | `LetrerosLedScreen`        | Ativa  |
| `/movimento-miniatura` | `MovimentoMiniaturaScreen` | Ativa  |
| `/mede-testa-explica`  | `MedeTestaExplicaScreen`   | Ativa  |
| `/circuito-seguro`     | `CircuitoSeguroScreen`     | Ativa  |
| `/sandbox`             | `SandboxScreen`            | Ativa  |
| `/settings`            | `SettingsScreen`           | Ativa  |

O fluxo de abertura inicia na `SplashScreen`, que executa o `Preloader.preloadResources()` para carregar preventivamente os assets gráficos e de som, redirecionando em seguida para o `MainMenuScreen`.

O fluxo legado `/first-bench` foi removido após a auditoria inicial por estar sem navegação ativa e ter sido funcionalmente substituído pelo fluxo `second_bench`.

### Estado atual dos itens do mapa

A estrutura atual de `StandData` e a navegação existente são legado de implementação e não definem sozinhas a campanha futura.

No estado atual:

* os fluxos correspondentes aos estandes 1–7 possuem experiências ou destinos implementados;
* os estandes 8–10 não possuem fluxo completo de missão;
* o item 11 possui comportamento informativo, não um fluxo completo de missão;
* o item 12 conduz à Bancada Livre.

A campanha futura é definida em `CAMPAIGN.md`, não pelos números legados da navegação atual.

---

## 4. Estado da aplicação

### Controllers principais

| Controller                  | Responsabilidade atual                                                            |
| --------------------------- | --------------------------------------------------------------------------------- |
| `SandboxController`         | Componentes, fios, edição, simulação, resultados e histórico de edição da Bancada |
| `ProgressController`        | Desafios concluídos e maior quantidade de estrelas registrada por desafio         |
| `SettingsController`        | Preferências persistidas de interface, idioma e opções configuráveis              |
| `CircuitUndoRedoController` | Ações de undo/redo utilizadas por missões guiadas                                 |

### Modelos de estado relevantes

| Modelo                 | Uso                                                                         |
| ---------------------- | --------------------------------------------------------------------------- |
| `SandboxState`         | Estado da Bancada, componentes, fios e informações relacionadas à simulação |
| `SecondBenchFlowState` | Estado persistido do fluxo atualmente alcançável do `second_bench`          |
| `StandFlowState`       | Estado compartilhado utilizado pelos estandes guiados compatíveis           |
| `SettingsModel`        | Preferências serializáveis                                                  |

O antigo `FirstBenchFlowState` não faz parte do estado atual após a limpeza do fluxo legado `first_bench`.

Além desses modelos, várias missões mantêm estado local por `StatefulWidget`/`setState`.

---

## 5. Bancada Livre

A Bancada Livre (`SandboxScreen`) é o principal ambiente atual de experimentação aberta.

### Componentes disponíveis

O enum `ComponentType` possui 13 valores, mas a paleta atual disponibiliza 12 tipos de componente:

* bateria;
* interruptor;
* lâmpada;
* resistor;
* diodo;
* LED;
* motor;
* potenciômetro;
* fonte de alimentação;
* fusível;
* capacitor;
* buzzer.

`connectingWire` existe no modelo/catalogação, mas não aparece como um componente da paleta. As conexões elétricas da Bancada são representadas por `SandboxWire`.

### Capacidades atuais

| Capacidade              | Estado                                                             |
| ----------------------- | ------------------------------------------------------------------ |
| Inserção e movimentação | Componentes podem ser adicionados e movidos na área de trabalho    |
| Grade                   | Área redimensionável                                               |
| Rotação                 | 0°, 90°, 180° e 270°                                               |
| Conexões                | Fios entre terminais com snap de destino e prevenção de duplicatas |
| Seleção                 | Seleção simples e múltipla                                         |
| Undo / redo             | Histórico limitado de edição                                       |
| Presets                 | Circuitos predefinidos para carregamento rápido                    |
| Persistência            | Componentes, fios e estado de simulação são restaurados localmente |
| Multímetro              | Interface ligada a valores nodais produzidos pelo solver           |
| Osciloscópio            | Interface disponível na Bancada                                    |
| Painéis auxiliares      | Métricas, mascote, HUD, inspetor e exportação                      |
| Representação           | Modo físico/realista por assets e modo esquemático                 |
| Solver                  | DFS ou MNA conforme a estrutura do circuito                        |

> Capacidade de UI não implica fidelidade elétrica completa. Um componente ou instrumento visível na interface não deve ser considerado tecnicamente modelado apenas por existir visualmente.

---

## 6. Terminais, fios e topologia

### Fios

`SandboxWire` conecta:

```text
componente + identificador de terminal
        ->
componente + identificador de terminal
```

Os identificadores de terminal são armazenados como strings.

### Modelo predominante

A arquitetura efetiva da Bancada e dos solvers foi construída predominantemente em torno de dois terminais elétricos por componente:

```text
A
B
```

Os solvers constroem os nós elétricos a partir dessa estrutura.

### Potenciômetro

O potenciômetro possui representação visual de três terminais:

```text
A
B
W
```

Porém `W` não participa de forma completa da conectividade e dos cálculos atuais.

Portanto, a presença visual desse terminal não constitui suporte real a componente multipinos.

### Componentes multipinos

A arquitetura atual não oferece suporte geral suficiente para componentes como relés com bobina e múltiplos contatos relacionados.

A expansão desse modelo é uma necessidade técnica registrada no `ROADMAP.md` e na especificação `PORTAO_DA_ESCOLA.md`.

### Topologia

Série e paralelo são consequências das conexões elétricas.

A posição espacial do componente na tela não determina série ou paralelo.

### Polaridade

LED, diodo e fontes possuem comportamento dependente de polaridade/orientação no modelo atual.

Os sinais `+` e `−` indicam polaridade ou potencial; não representam sentido da corrente.

Cores de fios são apoio de interface e não substituem a conectividade elétrica.

---

## 7. Solver

A implementação atual possui duas estratégias:

| Estratégia                    | Uso atual                                             |
| ----------------------------- | ----------------------------------------------------- |
| DFS                           | Circuitos tratados como estrutura simples de caminhos |
| MNA — Modified Nodal Analysis | Circuitos que exigem análise nodal mais geral         |

### Seleção

O `CircuitSolverService` seleciona MNA quando:

* existe mais de uma fonte; ou
* algum nó reúne mais de dois terminais.

Nos demais casos, utiliza DFS.

Essa é uma heurística da implementação atual e não uma afirmação de que um método seja fisicamente mais adequado a toda classe de circuito correspondente.

### DFS

O solver DFS percorre caminhos a partir da fonte e procura um percurso de retorno à própria fonte.

Para os loops encontrados, calcula corrente principalmente a partir da relação entre tensão da fonte e resistência equivalente do caminho.

### MNA

O solver MNA:

* agrupa terminais conectados em nós;
* monta uma matriz de condutâncias;
* inclui fontes de tensão;
* resolve o sistema por eliminação gaussiana;
* possui iteração simplificada para diodos e LEDs.

### Limite de escopo

O EletroLab não implementa SPICE nem um simulador elétrico universal.

Os solvers atuais foram desenvolvidos como modelos didáticos e contêm aproximações importantes.

---

## 8. Limitações elétricas conhecidas

| Área                    | Estado atual                                                                                                                                                              |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| LED                     | DFS e MNA utilizam interpretações diferentes para parâmetros equivalentes; `Vf`, resistência aproximada e critérios de condução não formam ainda um único modelo coerente |
| Diodo                   | DFS utiliza o valor do componente como resistência; MNA utiliza resistência aproximada fixa e `Vf` próprio                                                                |
| Motor                   | O valor armazenado no componente não corresponde ao valor resistivo fixo utilizado pelos solvers                                                                          |
| Capacitor               | O valor é apresentado em µF, mas não existe comportamento capacitivo ou transiente; o solver o aproxima como resistência fixa                                             |
| Potenciômetro           | Terminal `W` existe visualmente, mas não possui suporte elétrico completo                                                                                                 |
| Curto-circuito          | DFS e MNA utilizam critérios diferentes para determinar curto                                                                                                             |
| `MissionCircuitBuilder` | O helper possui diferenças de comportamento em relação ao solver geral, inclusive na detecção auxiliar de caminho fechado                                                 |
| Parâmetros internos     | Existem resistências equivalentes, limiares, quedas de tensão e outros parâmetros fixos utilizados como aproximações didáticas                                            |

A tensão das fontes `battery` e `powerSupply` é obtida do valor armazenado no componente; não deve ser descrita genericamente como constante fixa do solver.

Essas limitações são dívida técnica conhecida e estão organizadas na Frente 0 do `ROADMAP.md`.

---

## 9. Validação das missões guiadas

O projeto não possui hoje um único mecanismo universal de validação para todas as missões.

Existem três padrões principais.

### `CircuitValidator`

Usado por fluxos guiados como o `second_bench` para validar montagens específicas.

### `MissionCircuitBuilder`

Utilizado em várias missões dos estandes posteriores para construir um circuito de missão e utilizar o solver.

### Validação local

Algumas missões validam estados diretamente por condições locais, como estado de interruptor, orientação ou escolha realizada pelo estudante.

Consequentemente:

```text
missão concluída
        ≠
necessariamente circuito validado pelo mesmo solver
```

Uma evolução futura deve preservar essa distinção até que haja uma decisão explícita de unificação.

---

## 10. Representação física e esquemática

O projeto possui renderizações separadas para:

* representação física/realista;
* representação esquemática;
* fios;
* estados visuais;
* efeitos de componentes.

A Bancada também possui uma composição visual em que uma representação física atenuada aparece sob o símbolo no modo de diagrama.

Essa capacidade existente deve ser descrita como **técnica de renderização**.

Ela não equivale, por si só, à mecânica pedagógica de representação ghost definida em `PEDAGOGY.md` e `FIRST_STAND.md`.

A mecânica pedagógica futura exige, além da sobreposição visual:

* associação semântica símbolo ↔ componente;
* alvos e snap apropriados;
* validação da correspondência;
* equivalência entre o dispositivo físico representado e o símbolo técnico;
* integração ao fluxo da missão.

---

## 11. Persistência

A persistência atual utiliza `SharedPreferences`.

### Dados verificados

| Área                          | Persistência                                               |
| ----------------------------- | ---------------------------------------------------------- |
| Settings                      | Key `eletrolab.settings.v1`                                |
| Bancada — componentes         | `sandbox_components`                                       |
| Bancada — fios                | `sandbox_wires`                                            |
| Bancada — estado de simulação | `sandbox_is_simulating`                                    |
| Progresso                     | `completed_challenges`                                     |
| Estrelas                      | `stars_<id>`                                               |
| Fluxo `second_bench`          | Persistido via SharedPreferences pelo fluxo correspondente |

### Dados não restaurados como estado persistido

O estado atual não restaura diretamente:

* valores elétricos calculados;
* componentes queimados como snapshot persistido;
* estado de curto como snapshot persistido;
* histórico de undo/redo da Bancada.

Após carregamento, a simulação pode ser recalculada a partir dos componentes, fios e estado persistidos.

Não existe atualmente backend ou sincronização em nuvem.

---

## 12. Testes e qualidade

A limpeza estrutural removeu:

* testes placeholder sem comportamento real;
* testes exclusivos do fluxo legado `first_bench`.

A baseline técnica deve permanecer sincronizada com a última execução real de:

```bash
flutter analyze
flutter test
```

No estado atual da suíte de testes:

| Métrica           | Estado         |
| ----------------- | -------------- |
| Arquivos de teste | 18             |
| `flutter test`    | Todos passando |
| Cobertura de Responsividade | Suíte dedicada com 12 resoluções para SplashScreen, MainMenuScreen e IntroScreen |

A suíte cobre atualmente partes reais do sistema, incluindo:

* `CircuitValidator`;
* fluxo `second_bench` (fases 1, 2 e 3);
* missões guiadas selecionadas (`liga_desliga`, `letreros_led`, `movimento_miniatura`, `circuito_seguro`, `first_steps`);
* geometria/alinhamento de terminais e sockets;
* navegação e widgets principais (`SplashScreen`, `MainMenuScreen`, `IntroScreen`);
* responsividade de interface e bancada de trabalho (`Workbench`, `UiScale`);
* comportamentos e persistência da Bancada.

Não há suíte `integration_test/` dedicada registrada na auditoria original.

O `CODEBASE_AUDIT.md` deve manter seu caráter histórico e receber um snapshot final separado caso ainda não registre a redução de 75 para 47 casos após a remoção de `first_bench`.

---

## 13. Precisão elétrica

Quando precisão elétrica e conveniência visual entrarem em conflito, preservar primeiro a precisão elétrica.

Consequentemente:

* componente não é identificado apenas pela aparência;
* tipo e subtipo precisam ser confirmados;
* quantidade e função dos terminais precisam corresponder ao dispositivo;
* polaridade deve ser respeitada quando existir;
* LED exige análise de polaridade e limitação de corrente;
* símbolo e representação física precisam corresponder ao mesmo dispositivo;
* série e paralelo dependem das conexões elétricas;
* `+` e `−` representam polaridade/potencial, não direção da corrente;
* cores de fios não substituem topologia;
* um componente multipinos não pode ser reduzido a dois terminais apenas por conveniência de implementação.

Assets visuais gerados ou desenhados não constituem fonte técnica para especificação elétrica.

---

## 14. Relação com o trabalho futuro

Este documento descreve o que existe.

As mudanças necessárias estão organizadas em `ROADMAP.md`.

As decisões sobre o que o EletroLab deve se tornar pertencem às especificações de produto e pedagogia correspondentes.

A relação esperada é:

```text
código atual
    ↓
ARCHITECTURE.md
    ↓
lacunas técnicas
    ↓
ROADMAP.md
    ↓
implementação orientada por
PRODUCT / PEDAGOGY / CAMPAIGN /
FIRST_STAND / PORTAO_DA_ESCOLA
```

Uma alteração arquitetural relevante deve atualizar este documento depois que o comportamento correspondente existir no código.
