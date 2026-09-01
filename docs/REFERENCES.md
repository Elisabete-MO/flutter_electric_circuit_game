# Referencias e Estado da Arte

## Escopo e leitura da evidencia

Esta pesquisa compara jogos, simuladores e experiencias educacionais relevantes ao EletroLab. Referencias oferecem precedente, justificativa e inspiracao; nao se transformam automaticamente em requisito.

Classificacao usada:

- **Comprovado pela fonte:** recurso explicitamente descrito ou exibido no material pesquisado.
- **Nao verificado:** nao houve evidencia publica suficiente nesta pesquisa; nao significa ausencia do recurso.
- **Inferencia para o EletroLab:** possibilidade de design derivada da comparacao, nao afirmacao da referencia.

As fontes originais foram pesquisadas ate 2026-09-01. O material recebido preservava citacoes de pesquisa, mas nao links Markdown diretos; por isso este documento preserva os nomes, evidencias e limites sem inventar URLs.

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

## Comparacao sintetica

| Tema | Precedentes principais | Inferencia para o EletroLab |
|---|---|---|
| Fisico <-> esquema | PhET | O ghost alinhado sob o diagrama e proposta propria a validar, nao recurso atribuido ao PhET. |
| Bancada e transferencia | Tinkercad, Arduino, Snap Circuits | A Bancada pode apoiar alguns projetos fisicos sem obrigar reproducao universal. |
| Puzzles e progressao | Circuit Jam, Electronics Puzzle Lab, Ohmie | Missoes guiadas, diagnostico e liberdade gradual podem compartilhar infraestrutura. |
| Feedback eletrico | PhET, EveryCircuit | Fenomeno e grandezas podem ser visiveis sem substituir explicacao conceitual. |
| Rele e automacao | DigiSim, EveryCircuit, Arduino | Bobina, contatos e comando/carga devem ser introduzidos progressivamente; Portao da Escola e inferencia de contexto. |

## Fisico, esquema e ghost

**Comprovado pela referencia:** PhET e precedente forte para demonstrar o mesmo circuito em aparencia semelhante ao mundo real ou em diagrama esquematico.

**Nao verificado:** nao foi encontrada entre as referencias analisadas uma documentacao explicita da mecanica de manter a montagem fisica esmaecida, espacialmente alinhada, enquanto o estudante coloca simbolos sobre ela.

**Inferencia para o EletroLab:** o ghost pode transformar representar em competencia observavel. A afirmacao defensavel e que, entre as referencias analisadas, nao foi encontrada uma experiencia que documente explicitamente toda essa combinacao; isso nao prova originalidade absoluta.

## Rele, automacao e Feira Real

DigiSim comprova uma progressao publica que inclui interruptor, rele, NO, NC e change-over. A pesquisa nao comprovou como COM e apresentado na licao; ele permanece **nao verificado** para decisao pedagogica.

Arduino e outras referencias mostram reles e atuadores de baixa tensao em contexto educacional. Daqui resulta uma inferencia, nao requisito: uma missao de portao/motor em maquete pode ser uma aplicacao didatica realista. Ela nao deve ser apresentada como instrucao de rede eletrica.

| Tipo de experiencia | Posicao |
|---|---|
| Simulacao conceitual | Nao precisa ter montagem fisica correspondente. |
| Inspirada em aplicacao real | Pode representar automacao, como portao, sem ser manual de montagem. |
| Projeto para a Feira Real | Exige baixa tensao, circuito e componentes validados e instrucoes proprias. |

## O que nao copiar

Nao copiar interfaces, conteudo protegido, complexidade tecnica sem mediacao, narrativas alheias ao contexto escolar ou a ideia de que simulacao automaticamente equivale a instrucao fisica.

## Uso da pesquisa

As referencias apoiam, mas nao decidem, a Feira, o Primeiro Estande, a Bancada restringida e a prova de rele. Avaliacao, estrelas e numero de missoes continuam decisoes internas em validacao.

## Governanca documental

Nova pesquisa deve atualizar este documento com evidencia, limitacao e inferencia separadas, e nao criar especificacao paralela.
