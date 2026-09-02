# Campanha: Feira de Ciencias

## Premissa

A escola prepara uma Feira de Ciencias. Equipes organizam demonstracoes de eletrica e eletronica de baixa tensao, explicam fenomenos a visitantes e podem integrar resultados em uma maquete. A campanha usa estandes, missoes e demonstracoes.

Cada estande pode conter 4, 5, 6 ou outra quantidade de missoes adequada a progressao pedagogica e ao que for validado na implementacao. A lista abaixo organiza a direcao atual; nao e compromisso de numero fechado de fases.

## Estandes

| Estande | Conceitos | Status | Banco de possibilidades |
|---|---|---|---|
| Acende Ai | fonte, fios, caminho fechado, iluminacao | Primeiro estande em definicao | circuito pronto, caminho interrompido, curto pedagogico, explicacao. |
| Liga e Desliga | interruptor e controle | Planejado | estados aberto/fechado, controle de carga, previsao. |
| Ruas da Maquete | serie, paralelo e ramificacoes | Planejado | duas cargas, independencia de ramos, falha simulada. |
| Letreiros de LED | LED, polaridade, diodo e resistor | Planejado | LED invertido, protecao, sinalizacao. |
| Movimento em Miniatura | motor CC | Planejado | primeiro giro, polaridade, botao de partida, indicador. |
| Mede, Testa e Explica | tensao, corrente e resistencia | Planejado | leituras, escolha de resistor, investigacao. |
| Circuito Seguro | aberto, curto pedagogico e protecao | Planejado | fio interrompido, fusivel didatico, vistoria. |
| Horta Monitorada | sensores e comportamentos | Planejado | ajuste, resposta ambiental, capacitor como conceito futuro. |
| Portao da Escola | rele, comando, carga e automacao | Frente avancada | bobina, contatos, controle indireto, motor/portao simulado. |
| Maquete Coletiva | integracao de demonstracoes | Possivel fechamento | iluminacao, horta, portao, inspecao e apresentacao. |

As possibilidades sao materia-prima dos roteiros anteriores e nao definem missao obrigatoria, desbloqueio, pontuacao ou ordem final alem da prioridade do Primeiro Estande e da frente avancada de rele.

## Banco de estandes e missoes candidatas

Os estandes abaixo preservam contexto, mediacao e ideias dos roteiros anteriores. Os nomes de missao sao **propostas**, exceto quando este documento apontar para uma especificacao aprovada mais especifica.

## Acende Ai

### Contexto

A Equipe Luz prepara uma demonstracao de iluminacao e precisa tornar o percurso da corrente observavel para visitantes.

### Objetivo pedagogico

Reconhecer fonte, fios e carga; compreender que a demonstracao funciona quando existe caminho completo e seguro.

### Mediacao do Professor Volts

“Olhe o circuito como um percurso inteiro, nao como pecas isoladas.”

### Banco de missoes candidatas

| Missao candidata | Objetivo | Componentes/conceitos | Fenomeno ou validacao | Status |
|---|---|---|---|---|
| Primeiro ponto de luz | Montar ou reconhecer caminho fechado. | Fonte, fios e carga. | Carga ativa. | Proposta historica; recorte LED em `FIRST_STAND.md` |
| Onde o caminho parou? | Reparar fio solto. | Continuidade. | Circuito aberto deixa de existir. | Proposta |
| Duas luminarias | Comparar duas montagens simples. | Caminhos completos. | Cada carga precisa de percurso. | Proposta |
| Ligacao perigosa | Distinguir curto pedagogico. | Fonte, carga, fios. | Caminho nao ignora carga. | Proposta |
| Explicacao ao visitante | Explicar aberto/fechado. | Linguagem causal. | Resposta conceitual. | Proposta |

### Observacoes

O Primeiro Estande aprovado usa bateria de 9 V, SPST, resistor e LED; as ideias de lampada deste banco permanecem exemplos para futura ampliacao, nao substituem seu circuito de referencia.

## Liga e Desliga

### Contexto

A Equipe Controle precisa permitir que visitantes acionem uma luminaria sem desmontar a demonstracao.

### Objetivo pedagogico

Entender que o interruptor controla a continuidade, mas nao produz energia.

### Mediacao do Professor Volts

“Um interruptor nao cria energia. Ele decide se o caminho esta completo ou interrompido.”

### Banco de missoes candidatas

| Missao candidata | Objetivo | Componentes/conceitos | Fenomeno ou validacao | Status |
|---|---|---|---|---|
| Interruptor da luminaria | Inserir chave no caminho relevante. | SPST e carga. | Carga responde ao estado. | Forte candidata |
| Aberto ou fechado? | Prever os dois estados. | Circuito pronto. | Previsao confrontada com teste. | Proposta |
| Dois controles | Mapear chave e carga. | Dois controles/cargas. | Acionar um por vez. | Proposta |
| Conferencia da equipe | Corrigir chave em ramo inutil. | Topologia. | Chave precisa interromper percurso da carga. | Proposta |
| Demonstracao guiada | Cumprir sequencia de estados. | Controle e leitura de pedido. | Estados solicitados. | Proposta |

## Ruas da Maquete

### Contexto

Casas e postes da maquete exigem decidir como distribuir energia entre mais de uma carga.

### Objetivo pedagogico

Comparar serie, paralelo, ramificacoes e independencia de cargas.

### Mediacao do Professor Volts

“Quando ha mais de um destino, o desenho dos caminhos muda o comportamento de todo o circuito.”

### Banco de missoes candidatas

| Missao candidata | Objetivo | Componentes/conceitos | Fenomeno ou validacao | Status |
|---|---|---|---|---|
| Mesmo caminho | Montar duas lampadas em serie. | Uma rota. | Abertura afeta conjunto. | Forte candidata |
| Comparar brilho | Observar efeito de carga em serie. | Serie e carga. | Comparacao qualitativa. | Proposta |
| Cruzamento de fios | Criar bifurcacao valida. | Juncao. | Ramos se reconectam a fonte. | Proposta |
| Casas independentes | Montar paralelo. | Dois ramos. | Ambas ativas em ramos proprios. | Forte candidata |
| Teste de manutencao | Remover/falhar uma carga. | Paralelo. | Outra permanece ativa. | Forte candidata |

### Exemplo

“Luzes da clinica”: duas lampadas em paralelo com teste de falha em uma delas. E exemplo pedagogico para representacao, previsao e diagnostico, nao modelo aprovado de estrelas ou overlays.

## Letreiros de LED

### Contexto

A Equipe Sinalizacao prepara placas de entrada, saida e atencao sem danificar LEDs.

### Objetivo pedagogico

Introduzir anodo/catodo, polaridade, diodo e limitacao de corrente.

### Mediacao do Professor Volts

“Alguns componentes possuem direcao. Proteger tambem faz parte da montagem.”

### Banco de missoes candidatas

| Missao candidata | Objetivo | Componentes/conceitos | Fenomeno ou validacao | Status |
|---|---|---|---|---|
| Sentido do LED | Acender LED orientado corretamente. | Anodo/catodo. | Conducao direta. | Forte candidata |
| LED invertido | Diagnosticar orientacao incorreta. | Polaridade. | LED bloqueia no sentido inverso. | Forte candidata |
| Resistor protetor | Limitar corrente. | LED, resistor e fonte. | Faixa didatica segura. | Forte candidata |
| Sinalizacao dupla | Proteger dois LEDs. | Ramos e resistores. | Cada ramo protegido. | Proposta |
| Letreiro com defeito | Corrigir polaridade e resistor. | Inspecao. | Diagnostico antes de energizar. | Proposta |

## Movimento em Miniatura

### Contexto

Um ventilador ou carrinho da feira mostra conversao de energia eletrica em movimento.

### Objetivo pedagogico

Reconhecer motor CC como carga e relacionar polaridade, controle e movimento.

### Mediacao do Professor Volts

“Luz e movimento sao resultados diferentes da mesma energia eletrica.”

### Banco de missoes candidatas

| Missao candidata | Objetivo | Componentes/conceitos | Fenomeno ou validacao | Status |
|---|---|---|---|---|
| Primeiro giro | Energizar motor. | Dois terminais do motor. | Rotacao. | Proposta |
| Troca de sentido | Inverter polaridade. | Motor CC e fonte. | Direcao de rotacao. | Em validacao tecnica |
| Botao de partida | Controlar motor. | SPST. | Liga/desliga. | Proposta |
| Indicador | Mostrar motor ativo. | LED/resistor. | Indicacao protegida. | Proposta |
| Carrinho parado | Diagnosticar falha. | Fonte, caminho e chave. | Correcao causal. | Proposta |

## Mede, Testa e Explica

### Contexto

Dois prototipos parecem iguais, mas um se comporta de modo diferente. A equipe usa evidencias antes de trocar pecas.

### Objetivo pedagogico

Relacionar tensao, corrente e resistencia a observacoes e medições.

### Mediacao do Professor Volts

“Medicoes nos dao evidencias. Uma boa pergunta vem antes de trocar pecas.”

### Banco de missoes candidatas

| Missao candidata | Objetivo | Componentes/conceitos | Fenomeno ou validacao | Status |
|---|---|---|---|---|
| Tensao da bateria | Medir fonte. | Voltimetro/fonte. | Diferenca de potencial. | Futura |
| Pontos do circuito | Comparar leituras. | Pontas de prova. | Ponto de medicao importa. | Futura |
| Corrente sob controle | Relacionar R e I. | Resistor variavel e LED. | Resistencia limita corrente. | Futura |
| Valor adequado | Escolher resistor. | LEDs e opcoes. | Protecao da carga. | Forte candidata |
| Relato de investigacao | Registrar causa/evidencia/solucao. | Diagnostico. | Explicacao baseada em medida. | Proposta |

## Circuito Seguro

### Contexto

Antes da abertura, a Equipe Seguranca revisa montagens com falhas simuladas.

### Objetivo pedagogico

Reconhecer curto pedagogico, circuito aberto e protecao sem aproximar o estudante de rede eletrica.

### Mediacao do Professor Volts

“Mesmo em baixa tensao, seguranca comeca ao reconhecer caminhos inadequados.”

### Banco de missoes candidatas

| Missao candidata | Objetivo | Componentes/conceitos | Fenomeno ou validacao | Status |
|---|---|---|---|---|
| Alerta de curto | Identificar caminho que desvia carga. | Curto pedagogico. | Fonte nao energiza caminho inseguro. | Proposta |
| Fio interrompido | Localizar abertura. | Continuidade. | Percurso terminal a terminal. | Proposta |
| Fusivel didatico | Inserir protecao. | Fusivel e sobrecorrente. | Fusivel protege, nao cria energia. | Futura |
| LED protegido | Corrigir resistor. | LED e resistencia. | Limitacao adequada. | Forte candidata |
| Vistoria final | Resolver varias falhas. | Inspecao. | Montagem revisada. | Proposta |

## Horta Monitorada

### Contexto

Uma estufa da maquete responde a condicoes simuladas e ajustes manuais.

### Objetivo pedagogico

Introduzir a ideia de que uma condicao pode alterar comportamento eletrico e acionar uma resposta.

### Mediacao do Professor Volts

“Automacao e perceber uma condicao e produzir uma resposta.”

### Banco de missoes candidatas

| Missao candidata | Objetivo | Componentes/conceitos | Fenomeno ou validacao | Status |
|---|---|---|---|---|
| Brilho ajustavel | Ajustar LED. | Potenciometro. | Mudanca observavel. | Futura |
| Sensor de ambiente | Interpretar mudanca simulada. | Termistor/LDR. | Sensor altera propriedade. | Futura |
| Luz da estufa | Responder a condicao. | Sensor, LED, resistor. | Criterio de acionamento. | Futura |
| Energia por instantes | Observar carga/descarga. | Capacitor. | Efeito nao e fonte permanente. | Futura; modelo atual nao tem transiente |
| Painel da horta | Integrar ajuste e sensor. | Sistemas combinados. | Testar funcoes isoladas. | Futura |

## Portao da Escola

### Contexto

Um botao de visitante deve controlar indiretamente uma carga da maquete por meio de rele.

### Objetivo pedagogico

Separar comando e carga e observar como bobina altera contatos.

### Mediacao do Professor Volts

“Um circuito pequeno pode enviar um comando; outro realiza o trabalho. O rele faz essa ponte.”

### Banco de missoes candidatas

| Missao candidata | Objetivo | Componentes/conceitos | Fenomeno ou validacao | Status |
|---|---|---|---|---|
| Rele responde | Energizar bobina. | Bobina. | Mudanca de estado. | Em validacao |
| Dois circuitos | Distinguir lados. | Comando/carga. | Isolamento conceitual. | Em validacao |
| Luz controlada | Acionar carga simples. | Botao, rele, lampada. | Contato controla outro caminho. | Missao inicial candidata |
| Portao em movimento | Controlar motor. | Rele e motor. | Motor responde a comando. | Futura |
| Botao do visitante | Demonstracao repetivel. | Sistema completo. | Explicacao de percursos. | Futura |

`PORTAO_DA_ESCOLA.md` concentra a especificacao em validacao desta frente.

## Maquete Coletiva

### Contexto

As equipes podem unir iluminacao, horta e portao em uma demonstracao coletiva para visitantes.

### Objetivo pedagogico

Integrar subsistemas somente depois de validar cada um e comunicar o que foi observado.

### Mediacao do Professor Volts

“Testar, comunicar e integrar tambem fazem parte da ciencia.”

### Banco de missoes candidatas

| Missao candidata | Objetivo | Componentes/conceitos | Fenomeno ou validacao | Status |
|---|---|---|---|---|
| Casas iluminadas | Integrar luzes independentes. | LED/lampada e resistores. | Ramos ativos. | Futura |
| Rua em funcionamento | Revisar postes. | Paralelo. | Todos os ramos previstos. | Futura |
| Horta e portao | Unir subsistemas. | Sensor, rele e motor. | Integracao apos validacao isolada. | Futura |
| Inspecao | Resolver falhas inseridas. | Diagnostico. | Registro de observacao. | Proposta |
| Visita da comunidade | Apresentar maquete. | Comunicacao. | Sequencia explicada. | Proposta |

### Observacoes

A Maquete Coletiva e possivel fechamento de campanha, nao requisito ja aprovado.

## Progressao

O estudante inicia com componentes e fenomenos simples, avanca para controle, topologia, diagnostico e medicao, e pode chegar a automacao. A Bancada Livre pode ser restringida por missao e ampliada conforme a progressao, sem deixar de existir como espaco de experimentacao.

## Primeiro estande

`FIRST_STAND.md` e a fonte de verdade para o Estande Acende Ai introdutorio. Seu circuito de LED/resistor atual substitui os desafios guiados legados como referencia de produto futuro.

## Portao da Escola: proof of architecture

O rele e uma frente avancada executada relativamente cedo, em paralelo ao Primeiro Estande. A primeira entrega pode ser uma unica missao para provar componente multipinos, bobina, contatos, circuitos de comando/carga relacionados e uma carga simulada. Rele nao e funcionalidade existente hoje; a limitacao atual de dois terminais esta em `ARCHITECTURE.md`.

## Principios de campanha

- Usar somente baixa tensao didatica/simulada.
- Algumas missoes podem ser Projeto para a Feira Real; outras sao simulacoes conceituais ou inspiradas em aplicacoes reais.
- O contexto escolar e suporte para o conceito, nao pretexto para instrucao de instalacao eletrica residencial.
- Professor Volts pode mediar, mas dicas nao devem montar a resposta pelo estudante.

## Governanca documental

Uma decisao sobre estandes, missoes ou progressao deve atualizar este documento. Nao criar uma segunda especificacao de campanha.
