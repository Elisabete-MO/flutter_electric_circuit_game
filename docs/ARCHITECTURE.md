# Arquitetura e Estado Tecnico

## Autoridade e escopo

Esta documentacao resume fatos observados na auditoria tecnica de 2026-09-01 e a direcao minima de evolucao. Estado atual e direcao planejada sao distintos. A auditoria original foi migrada para este documento; o codigo continua sendo a evidencia para afirmacoes de runtime.

## Estado atual

### Runtime

O fluxo principal usa Flutter, Riverpod e `CustomPainter`. Flame continua em `pubspec.yaml` como dependencia/legado, mas os arquivos de gameplay Flame encontrados estavam vazios e nao participam do runtime principal.

`main.dart` inicializa preferencias e Riverpod. O app possui telas de inicio, primeiros passos, desafios, Bancada Livre e configuracoes. Preferencias e progresso usam `shared_preferences` localmente.

### Desafios guiados legados

Ha tres desafios guiados em telas independentes: bateria/interruptor/lampada; bateria/interruptor/motor; e bateria/interruptor/resistor/lampada. Sao composicoes visuais com slots fixos, estado local e pontuacao por tentativas/tempo. Eles nao usam o solver da Bancada e nao sao modelo para a campanha futura.

### Bancada Livre

A Bancada e funcional, porem limitada. Ela oferece paleta, posicionamento livre em grade, movimentacao, rotacao, selecao, fios, snap de terminais, remocao, undo/redo, presets, persistencia, instrumentos e diagnosticos de interface.

`SandboxState` guarda componentes, fios, estado de simulacao, valores calculados, componentes queimados e curto. `SandboxController` concentra mutacoes, historico, persistencia e recalcule.

Componentes disponiveis na paleta incluem bateria, fonte, interruptor, lampada, resistor, potenciometro, motor, LED, diodo, fusivel, capacitor e buzzer. O catalogo visual nao garante que todos tenham modelo eletrico completo ou rigoroso.

| Interacao | Estado observado |
|---|---|
| Posicionar/mover/rotacionar | Funcional em grade; ha selecao multipla e atalhos. |
| Fios | Criados entre terminais por clique/arraste; removiveis. |
| Snap de fio | Espacial, com destino proximo dentro de 60 px; nao e validacao pedagogica/eletrica previa. |
| Undo/redo | Historico com profundidade maxima de 30 snapshots. |
| Fisico/esquema | Mesmo modelo, com fios curvos/ortogonais e composicao ghost no esquema. |
| Instrumentos/diagnosticos | Existem widgets de interface; precisao de cada leitura depende do modelo simplificado. |

### Topologia e simulacao

Um fio conecta IDs de componentes e terminais. O solver seleciona DFS para casos simples e MNA para multiplas fontes ou nos com mais de dois terminais unidos. Ele calcula estados DC didaticos, corrente, queda de tensao, potencia, curto e alguns limites de sobrecarga.

O modelo de cada `SandboxComponent` fixa dois terminais geometricos, `A` e `B`, alem de um valor numerico e estado ativo. Essa abstracao atende resistor, LED, diodo, lampada, motor DC simples, SPST e fonte, mas nao representa diretamente rele, sensor multipino ou componentes com terminais configuraveis.

O solver contem aproximacoes: capacitor e tratado como resistencia fixa, e ha valores internos fixos para alguns tipos. Nao ha simulacao transitoria de carga/descarga. A Bancada nao e um simulador eletrico universal ou fisicamente rigoroso para todos os componentes.

Em particular, MNA usa aproximacoes fixas para capacitor, motor, buzzer, fusivel, interruptor fechado, diodo e LED. Valores editados na interface nao necessariamente controlam todos esses modelos internos. Defaults tambem divergem: o modelo cria resistor de 220 ohms, enquanto o drop da Bancada o cria com 10 ohms.

### Fisico, esquema e ghost

Os mesmos componentes/fios sao renderizados em modo fisico e esquematico. No modo esquema, o circuito fisico e pintado com opacidade reduzida sob os simbolos e fios tecnicos. Essa e uma capacidade existente e reutilizavel para o requisito pedagogico ghost; ainda nao e uma fase configuravel com alvos semanticos.

Particulas, brilho e rotacao sao efeitos visuais derivados de estado/resultados. Animacao nao e fonte da verdade eletrica.

### Persistencia e testes

Configuracoes, conclusao/estrelas de desafios e parte do estado da Bancada sao persistidos localmente. Leituras calculadas, erros, curto e componentes queimados nao sao preservados integralmente na Bancada.

Na auditoria, `flutter analyze` passou. `flutter test` falhou porque havia arquivos de teste vazios sem `main()`, antes de executar a suite util. Faltam coberturas ativas para solver, polaridade, curto, snap, desafios, undo/redo e renderizacao. Isso e estado conhecido, nao afirmacao de qualidade aprovada.

Arquivos vazios identificados incluem `test/widgets/intro_screen_test.dart`, `test/domain/circuit_solver_test.dart`, `test/domain/topological_equivalence_test.dart`, `test/models/phase1_circuit_test.dart` e `test/infrastructure/circuit_serializer_test.dart`. Cobertura futura deve priorizar Lei de Ohm, interruptor aberto, serie/paralelo, curto, polaridade, componentes desconectados, leituras e regras de missao.

| Persistencia/configuracao | Estado observado |
|---|---|
| Preferencias | Tema, exibicao de corrente/valores/grade/terminais, escala, alto contraste e reducao de movimento usam preferencias locais. |
| Progresso legado | Desafios concluidos e maximo de estrelas por ID sao locais. |
| Bancada | Componentes, fios e estado de simulacao sao salvos; resultados, erros, curto e danos nao sao integralmente restaurados. |

## Ativos reutilizaveis

- Pintores fisico e esquematico e sua sobreposicao ghost.
- Bancada livre: componentes, fios, terminais, movimentacao, snap, rotacao, historico e topologia.
- Solver DFS/MNA para circuitos DC introdutorios, com validacao por missao.
- Componentes/representacoes de bateria, SPST, resistor, LED, lampada e motor.
- Persistencia local e preferencias de acessibilidade.

## Limitacoes e riscos reais

- Terminais A/B fixos bloqueiam rele corretamente modelado e outros componentes multipinos.
- Desafios atuais sao hardcoded e duplicam logica/pontuacao.
- Fios validam apenas auto-conexao exata e duplicata; viabilidade eletrica e avaliada depois.
- Defaults de valores podem divergir entre modelo e drop da interface.
- Recalculos assincronos nao possuem guarda de versao de requisicao.
- Grade visual e limites de movimento do controlador usam dimensoes independentes.
- Novas fases nao devem reutilizar diretamente slots rigidos dos desafios: o alvo de simbolo deve ser semantico, enquanto o snap de terminal permanece geometrico.

## Direcao planejada, ainda nao implementada

- Novas fases devem reduzir gradualmente a duplicacao entre definicao de missao e apresentacao; nao ha arquitetura data-driven aprovada nesta etapa.
- O Primeiro Estande deve reutilizar conceitualmente a capacidade de ghost e uma Bancada restrita, conforme `FIRST_STAND.md`.
- O proof of architecture de rele exigira definir subtipo, terminais, bobina, contatos e relacao bobina energizada -> mudanca de contato. Nao requer decidir agora um novo solver geral, mas o modelo A/B atual e obstaculo real.

## Governanca documental

Uma decisao tecnica nova deve atualizar este documento, e nao criar especificacao paralela. Afirmações sobre o que existe devem ser verificadas no codigo.
