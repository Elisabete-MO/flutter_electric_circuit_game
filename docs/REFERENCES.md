# Referencias e Estado da Arte

## Escopo e leitura da evidencia

Esta pesquisa compara jogos, simuladores e experiencias educacionais relevantes ao EletroLab. Referencias oferecem precedente, justificativa e inspiracao; nao se transformam automaticamente em requisito.

Classificacao usada:

- **Comprovado pela fonte:** recurso explicitamente descrito ou exibido no material pesquisado.
- **Nao verificado:** nao houve evidencia publica suficiente nesta pesquisa; nao significa ausencia do recurso.
- **Inferencia para o EletroLab:** possibilidade de design derivada da comparacao, nao afirmacao da referencia.

As fontes originais foram pesquisadas ate 2026-09-01. O material recebido preservava citacoes de pesquisa, mas nao links Markdown diretos; por isso este documento preserva os nomes, evidencias e limites sem inventar URLs.

## Metodo e limites

A pesquisa priorizou documentacao de desenvolvedores, instituicoes e literatura primaria; catalogos de aplicativos foram usados somente quando necessarios para contexto ou disponibilidade. A matriz usa `✓` para comprovado, `◐` para parcial/indireto, `N/V` para nao verificado e `—` para caracteristica que nao e parte central da experiencia documentada.

Uma evidencia academica sobre PhET comparou estudantes universitarios que iniciaram por simulacao com grupos que iniciaram por equipamento fisico e relatou vantagem conceitual e posterior em tarefa com circuito real para o primeiro grupo. O estudo nao deve ser generalizado diretamente para estudantes de 9-15 anos; ele apenas contraria a suposicao de que simulacao impede necessariamente transferencia ao fisico.

## Referencias principais

| Referencia | Evidencia relevante | Limite/nao verificado | Aprendizado para o EletroLab |
|---|---|---|---|
| PhET Circuit Construction Kit: DC | Alterna componentes semelhantes aos reais e diagramas esquematicos; oferece manipulacao, instrumentos e acessibilidade documentada. | Ghost simultaneo fisico+simbolo nao foi comprovado. | Principal precedente para fisico <-> esquema mantendo a topologia. |
| Tinkercad Circuits | Bancada virtual com breadboard, componentes, Arduino e projetos. | Vista esquematica tecnica nativa equivalente ao PhET nao foi verificada; e ferramenta aberta. | Aproximar bancada virtual de componentes que o estudante pode encontrar no mundo fisico. |
| EveryCircuit | Esquema com comportamento dinamico, grandezas e biblioteca tecnica incluindo LED, motor e rele. | Representacao fisica e campanha guiada nao sao o foco documentado. | Feedback eletrico visual e alvo de maturidade tecnica futura. |
| Circuit Jam | Puzzles progressivos e liberacao de componentes para sandbox. | Ponte fisica e rele/automacao nao foram verificados. | Precedente para bancada restringida por missao e ampliada com progresso. |
| DigiSim Relay Lab | Progressao de interruptor para bobina, contatos, NO, NC, change-over, isolamento e logica com reles. | Como COM e rotulado/ensinado nao foi verificado na evidencia publica. | Principal referencia pedagogica para decompor rele antes de automacao. |
| Electronics Puzzle Lab | Inspecao, manipulacao e reparo de circuitos como jogo. | Rigor de simulacao e traducao para esquema nao foram verificados. | Diagnostico pode ser atividade jogavel propria. |
| Ohmie | Microlicoes, circuitos a consertar, laboratorio aberto e progressao para sistemas avancados. | Publico e recursos nao coincidem integralmente; rele nao verificado. | Trilha guiada e laboratorio aberto podem coexistir. |
| Arduino Education ELAB/CTC GO | Experiencias praticas progressivas para faixa escolar, LEDs, sensores e projetos. | Nao sao jogo ou simulador. | Alguns estandes podem gerar projetos fisicos opcionais de baixa tensao. |
| Snap Circuits | Kits de baixa tensao e encaixe sem solda para iniciantes. | Esquema tecnico nao e o foco. | Alternativa segura para experiencias fisicas selecionadas. |

Wokwi e CircuitVerse permanecem referencias complementares para sistemas programaveis, logica e gestao pedagogica em fases futuras.

## Prioridades para apresentacao ao professor

As referencias nao devem ser apresentadas como concorrentes equivalentes. Para uma conversa curta, priorizar:

| Prioridade | Referencia | Pergunta que ajuda a responder |
|---|---|---|
| Muito alta | PhET Circuit Construction Kit: DC | Como demonstrar que montagem realista e esquema descrevem o mesmo circuito? |
| Muito alta | Tinkercad Circuits | Como fazer a bancada virtual lembrar componentes que podem ser encontrados fora da tela? |
| Muito alta | DigiSim Relay Lab | Como decompor rele e controle indireto antes de automacao? |
| Alta | Circuit Jam | Como combinar puzzles progressivos e liberdade gradual de bancada? |
| Alta | EveryCircuit | Como tornar grandezas e comportamento eletrico visiveis ao crescer a complexidade? |
| Alta, para experiencias fisicas | Arduino Education ELAB/CTC GO e Snap Circuits | Como derivar alguns projetos escolares seguros de baixa tensao? |
| Complementar | Electronics Puzzle Lab e Ohmie | Como tornar diagnostico jogavel e combinar microlicoes com laboratorio aberto? |

## Leitura detalhada das referencias

### PhET Circuit Construction Kit: DC

**Comprovado:** montagem livre, instrumentos, animacao de corrente e escolha entre componentes semelhantes aos reais e componentes em diagrama. A documentacao de acessibilidade consultada tambem descreve suporte a teclado, leitores de tela, descricoes e alertas em tempo real.

**Limite:** a pesquisa comprovou alternancia entre representacoes, nao a sobreposicao ghost alinhada nem uma campanha de Feira. Para as demais referencias, ausencia de documentacao equivalente de acessibilidade foi tratada como N/V, nao ausencia de acessibilidade.

### Tinkercad Circuits

**Comprovado:** simulacao web de componentes, breadboard, Arduino, tutoriais e projetos. E a referencia mais direta para uma bancada que lembra a manipulacao de hardware e pode apoiar ponte seletiva para projetos fisicos.

**Limite:** nao foi verificada vista esquematica tecnica nativa equivalente a alternancia do PhET, nem sequencia pedagogica igual ao Primeiro Estande. Sua abertura e potencia tambem podem exigir mais mediacao para iniciantes.

### EveryCircuit

**Comprovado:** simulacao esquematica com tensoes, correntes e comportamento dinamico; biblioteca documentada inclui resistores, capacitores, diodos, LEDs, interruptores, botoes NO/NC, rele, instrumentos, lampada e motor DC.

**Limite:** e mais abstrato/esquematico e nao foi encontrado foco equivalente em representacao fisica ou campanha guiada. Serve como referencia de maturidade para feedback visual, nao como interface a copiar.

### Circuit Jam

**Comprovado:** puzzles progressivos e componentes liberados para sandbox em material pesquisado. Sua principal contribuicao e mostrar que atividade estruturada e liberdade posterior podem coexistir.

**Limite:** ponte fisica, rele e automacao nao foram verificados. Parte da documentacao encontrada e historica, portanto deve ser usada como referencia de design pedagogico, nao como plataforma atual a imitar.

### DigiSim Relay Lab

**Comprovado:** sequencia de interruptor, bobina, armadura, contatos, NO, NC, change-over, isolamento e logica; o rele e apresentado como interruptor operado por eletricidade.

**Limite:** a pesquisa nao confirmou como COM e nomeado ou em qual momento e apresentado. DigiSim tambem nao e precedente para Feira ou ghost fisico->esquema. O rele do EletroLab continua exigindo dispositivo real de referencia e decisao propria.

### Electronics Puzzle Lab e Ohmie

Electronics Puzzle Lab fornece precedente para inspecao, manipulacao e reparo como atividade ludica. Ohmie combina microlicoes, circuitos a consertar, laboratorio aberto e progressao para sistemas avancados. Em ambos os casos, representacao tecnica, rele e adequacao exata ao publico devem ser tratados conforme as limitacoes N/V registradas na tabela.

### Arduino Education e Snap Circuits

Essas referencias nao sao jogos digitais, mas mostram caminhos de pratica de baixa tensao para faixas escolares: breadboard e componentes em curriculo progressivo, ou encaixes sem solda. Elas sustentam Projeto para a Feira Real como possibilidade seletiva, nao obrigacao para toda missao.

## Comparacao sintetica

| Tema | Precedentes principais | Inferencia para o EletroLab |
|---|---|---|
| Fisico <-> esquema | PhET | O ghost alinhado sob o diagrama e proposta propria a validar, nao recurso atribuido ao PhET. |
| Bancada e transferencia | Tinkercad, Arduino, Snap Circuits | A Bancada pode apoiar alguns projetos fisicos sem obrigar reproducao universal. |
| Puzzles e progressao | Circuit Jam, Electronics Puzzle Lab, Ohmie | Missoes guiadas, diagnostico e liberdade gradual podem compartilhar infraestrutura. |
| Feedback eletrico | PhET, EveryCircuit | Fenomeno e grandezas podem ser visiveis sem substituir explicacao conceitual. |
| Rele e automacao | DigiSim, EveryCircuit, Arduino | Bobina, contatos e comando/carga devem ser introduzidos progressivamente; Portao da Escola e inferencia de contexto. |

### Matriz funcional

| Referencia | Jogo/puzzle | Simulacao | Fisico/realista | Esquema | Construcao livre | Progressao | Ponte fisica | Eletronica avancada | Rele/automacao |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| PhET CCK DC | — | ✓ | ✓ | ✓ | ✓ | ◐ | ◐ | ◐ | N/V |
| Tinkercad Circuits | ◐ | ✓ | ✓ | N/V | ✓ | ◐ | ✓ | ✓ | N/V |
| EveryCircuit | — | ✓ | — | ✓ | ✓ | — | ◐ | ✓ | ◐ |
| Circuit Jam | ✓ | ✓ | — | ✓ | ✓ | ✓ | N/V | ◐ | N/V |
| DigiSim | ◐ | ✓ | ◐ | ✓ | ✓ | ✓ | ◐ | ✓ | ✓ |
| Electronics Puzzle Lab | ✓ | N/V | ✓ | N/V | — | ✓ | N/V | ◐ | N/V |
| Ohmie | ✓/guiado | ✓ | ✓ | ◐ | ✓ | ✓ | ◐ | ✓ | N/V |
| Arduino ELAB | — | — | ✓ | N/V | ✓ | ✓ | ✓ | ◐ | N/V |
| Snap Circuits | — | — | ✓ | N/V | ✓ | ◐ | ✓ | ◐ | N/V |

### Matriz pedagogica

| Referencia | Forca principal | Limitacao para o EletroLab | Aprendizado transferivel |
|---|---|---|---|
| PhET | Mesma topologia em aparencia realista e esquema. | Ghost simultaneo nao comprovado; nao e campanha. | Duas representacoes descrevem o mesmo sistema. |
| Tinkercad | Bancada proxima de hardware. | Ferramenta aberta, com menos mediacao ludica. | Objetos e conexoes virtuais devem fazer sentido fora da tela. |
| EveryCircuit | Grandezas visiveis sobre esquema. | Abstracao alta para iniciante. | Tornar fenomeno perceptivel sem substituir compreensao. |
| Circuit Jam | Puzzles e sandbox progressiva. | Pouca ponte concreta. | Campanha e Bancada podem compartilhar progressao. |
| DigiSim | Decomposicao gradual de rele. | Sem contexto Feira/ghost. | Bobina e contatos antes de automacao completa. |
| Electronics Puzzle Lab | Inspecao e reparo. | Rigor tecnico N/V. | Diagnostico e uma mecanica, nao so mensagem de erro. |
| Arduino/Snap | Pratica escolar de baixa tensao. | Nao sao simuladores/jogos. | Transferencia fisica deve ser opcional e validada. |

### Familias de referencias

| Familia | Referencias | Contribuicao principal |
|---|---|---|
| Representacao e fenomeno | PhET, EveryCircuit | Relacionar topologia, simbolos, grandezas e comportamento observavel. |
| Bancada e transferencia ao fisico | Tinkercad, Arduino Education, Snap Circuits | Aproximar componentes, construcao e experiencias escolares de baixa tensao. |
| Progressao ludica e diagnostico | Circuit Jam, Electronics Puzzle Lab, Ohmie | Estruturar puzzles, reparo, microlicoes e liberdade gradual. |
| Profundidade tecnica e automacao | EveryCircuit, DigiSim, Wokwi, CircuitVerse | Sustentar evolucao para eletronica, logica, sistemas programaveis e rele. |

Essa organizacao e uma inferencia de design: o EletroLab pode orquestrar familias complementares sem copiar uma plataforma inteira.

## Fisico, esquema e ghost

**Comprovado pela referencia:** PhET e precedente forte para demonstrar o mesmo circuito em aparencia semelhante ao mundo real ou em diagrama esquematico.

**Nao verificado:** nao foi encontrada entre as referencias analisadas uma documentacao explicita da mecanica de manter a montagem fisica esmaecida, espacialmente alinhada, enquanto o estudante coloca simbolos sobre ela.

**Inferencia para o EletroLab:** o ghost pode transformar representar em competencia observavel. A afirmacao defensavel e que, entre as referencias analisadas, nao foi encontrada uma experiencia que documente explicitamente toda essa combinacao; isso nao prova originalidade absoluta.

## Rele, automacao e Feira Real

DigiSim comprova uma progressao publica que inclui interruptor, rele, NO, NC e change-over. A pesquisa nao comprovou como COM e apresentado na licao; ele permanece **nao verificado** para decisao pedagogica.

O material analisado do DigiSim tambem descreve bobina, armadura e contatos, inclusive comportamento mecanico e clique auditivo. Isso sugere duas leituras complementares a validar no EletroLab: o que muda dentro do rele e o que muda no circuito quando o contato troca de estado. A definicao publica de NO/NF sustenta introduzir primeiro o estado de repouso e a mudanca causada pela bobina; COM continua N/V ate haver evidencia especifica.

Arduino e outras referencias mostram reles e atuadores de baixa tensao em contexto educacional, incluindo cargas como lampadas, motores e bombas. Daqui resulta uma inferencia, nao requisito: uma missao de portao/motor em maquete pode ser uma aplicacao didatica realista. Ela nao deve ser apresentada como instrucao de rede eletrica.

| Tipo de experiencia | Posicao |
|---|---|
| Simulacao conceitual | Nao precisa ter montagem fisica correspondente. |
| Inspirada em aplicacao real | Pode representar automacao, como portao, sem ser manual de montagem. |
| Projeto para a Feira Real | Exige baixa tensao, circuito e componentes validados e instrucoes proprias. |

## Implicacoes classificadas para o EletroLab

| Implicacao | Classificacao | Base |
|---|---|---|
| Manter equivalencia entre representacao fisica e esquematica. | Forte referencia | PhET documenta as duas representacoes do mesmo circuito. |
| Usar ghost alinhado e pedir que o estudante posicione simbolos. | Ideia interessante a validar | A combinacao explicita nao foi encontrada na pesquisa. |
| Restringir componentes por missao e liberar a Bancada gradualmente. | Forte referencia | Circuit Jam oferece precedente para puzzles e sandbox progressiva. |
| Mostrar corrente, tensao ou consequencias eletricas de modo visual. | Forte referencia | PhET e EveryCircuit tornam fenomenos e grandezas observaveis. |
| Tratar diagnostico como missao. | Forte referencia / ideia promissora | Electronics Puzzle Lab usa inspecao e reparo como atividade central. |
| Introduzir rele por interruptor, bobina, contatos, NO/NF e depois controle indireto. | Forte referencia | DigiSim documenta progressao equivalente; COM permanece N/V. |
| Usar Portao da Escola com motor de baixa tensao simulado. | Ideia interessante a validar | Rele controlando atuadores possui precedentes; o contexto do portao e proprio. |
| Derivar alguns estandes em projetos fisicos opcionais. | Forte referencia conceitual | Tinkercad, Arduino e Snap Circuits apoiam trajetos virtual-pratico. |
| Exigir equivalente fisico para toda simulacao. | Nao aplicavel | Reduziria indevidamente o espaco conceitual da simulacao. |
| Fixar estrelas, pontuacao ou quantidade de missoes. | Decisao ainda necessaria | Avaliacao e estrutura de campanha seguem em validacao. |

## O que nao copiar

Nao copiar interfaces, conteudo protegido, complexidade tecnica sem mediacao, narrativas alheias ao contexto escolar ou a ideia de que simulacao automaticamente equivale a instrucao fisica.

## Uso da pesquisa

As referencias apoiam, mas nao decidem, a Feira, o Primeiro Estande, a Bancada restringida e a prova de rele. Avaliacao, estrelas e numero de missoes continuam decisoes internas em validacao.

## Posicionamento comparativo

O EletroLab pode ocupar o espaco entre jogo de puzzles, simulador conceitual e bancada educacional. Seu diferencial a investigar nao e uma funcao isolada, mas a trajetoria: reconhecer o objeto fisico, observar o comportamento, traduzir a montagem para linguagem esquematica, construir, diagnosticar e aplicar a mesma logica a rele e automacao em estandes de uma Feira de Ciencias.

Essa e uma sintese comparativa e uma oportunidade de design, nao uma alegacao de originalidade absoluta: as referencias examinadas oferecem ingredientes dessa trajetoria, mas nao documentam explicitamente todos eles em uma unica experiencia.

Para novas referencias, registrar responsavel, plataforma, publico/modelo de acesso, representacoes, instrumentos, progressao, componentes, ponte virtual->fisico, rele/automacao, acessibilidade documentada, evidencia, limitacoes e inferencia para o EletroLab.

## Governanca documental

Nova pesquisa deve atualizar este documento com evidencia, limitacao e inferencia separadas, e nao criar especificacao paralela.
