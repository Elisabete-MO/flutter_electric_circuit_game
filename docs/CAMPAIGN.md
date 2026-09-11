# Campanha: Feira de Ciencias

## Premissa

A escola prepara uma Feira de Ciencias. Equipes organizam demonstracoes de eletrica e eletronica de baixa tensao, explicam fenomenos a visitantes e podem integrar resultados em uma maquete. A campanha usa estandes, missoes e demonstracoes.

Cada estande pode conter 4, 5, 6 ou outra quantidade de missoes adequada a progressao pedagogica e ao que for validado na implementacao. A lista abaixo organiza a direcao atual; nao e compromisso de numero fechado de fases.

## Estandes

| Estande | Conceitos | Status | Banco de possibilidades |
|---|---|---|---|
| Acende Ai | fonte, fios, caminho fechado, iluminacao | Primeiro estande em definicao | circuito pronto, caminho interrompido, curto pedagogico, explicacao. |
| Liga e Desliga | interruptor e controle | Planejado | estados aberto/fechado, controle de carga, previsao. |
| Ruas da Maquete | serie, paralelo e ramificacoes | Implementado | Luminárias táteis, nós WAGO, mini-voltímetro, 4 ramos e isolamento de falha. |
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

### Banco de missões (Implementadas no Estande 04)

| Missão | Objetivo | Componentes / Conceitos | Fenômeno / Validação na Maquete | Status |
|---|---|---|---|---|
| **M1: Primeiro Poste da Alameda** | Rosquear a lâmpada do poste e energizar a luminária. | Bateria 4.5V, Luminária de Poste, Soquete Rosqueável. | Acendimento suave da lâmpada (4.5V) e iluminação radial sobre a via. | **Implementada** |
| **M2: Dois Postes em Série** | Medir a queda de tensão e comprovar o efeito cascata de apagão. | 2 Lâmpadas em série, Mini-voltímetro digital portátil (2.25V / 4.50V). | Divisão da tensão (2.25V + 2.25V = 4.50V), brilho reduzido e apagão mútuo ao desrosquear uma lâmpada. | **Implementada** |
| **M3: O Nó de Kirchhoff** | Criar bifurcação na esquina com bloco de derivação. | Bloco WAGO de derivação (Nó), Poste e Casa Residencial. | Elétrons divididos em dois caminhos com tensão integral (4.5V) e 100% de brilho nos dois ramos. | **Implementada** |
| **M4: Rede Paralela Urbana** | Alimentar rede urbana de 4 ramos e medir a corrente total. | 4 Ramos paralelos (2 Postes, 2 Casas), Telemetria de Corrente (~360 mA). | Cada carga opera a 4.5V independente e a corrente total da bateria é aditiva (soma dos ramos). | **Implementada** |
| **M5: Inspeção & Manutenção** | Simular manutenção isolando a Casa 01 sem desligar a cidade. | 4 Ramos paralelos, Chave seccionadora/disjuntor tátil da Casa 01. | Interrupção seletiva da carga em manutenção enquanto as outras 3 permanecem 100% operacionais. | **Implementada** |

## Letreiros de LED

### Contexto

A Equipe Sinalizacao prepara placas de entrada, saida e atencao sem danificar LEDs.

### Objetivo pedagogico

Introduzir anodo/catodo, polaridade, diodo e limitacao de corrente.

### Mediacao do Professor Volts

“Alguns componentes possuem direcao. Proteger tambem faz parte da montagem.”

### Banco de missões (Implementadas no Estande 05)

| Missão | Objetivo | Componentes / Conceitos | Fenômeno / Validação na Protoboard | Status |
|---|---|---|---|---|
| **M1: Placa de Saída** | Inserir LED e Resistor na Protoboard e energizar. | Bateria 9V, Protoboard, LED Vermelho, R680Ω. | Condução direta, fluxo de elétrons e acendimento do letreiro SAÍDA ➔. | **Implementada** |
| **M2: Polaridade e Sentido** | Diagnosticar e corrigir polaridade invertida do LED. | Ânodo `A(+)`, Cátodo `K(–)`, rotação do LED na Protoboard. | Bloqueio no sentido inverso (LED apagado) vs. condução em polaridade direta. | **Implementada** |
| **M3: Diagnóstico de Falha** | Inspecionar e resolver 3 falhas potenciais do circuito. | Fio rompido, resistor deslocado e LED invertido. | Diagnóstico por hipóteses antes de reenergizar a bancada. | **Implementada** |
| **M4: Proteção e Sobrecarga** | Comparar valores de resistência limitadora de corrente. | Resistores 68Ω, 680Ω e 6.8kΩ com código de 4 cores. | Queima por sobrecorrente (68Ω), ideal (680Ω) e subcorrente (6.8kΩ). | **Implementada** |
| **M5: Sinalização Dupla** | Montar dois ramos em paralelo independentes. | Ramo SAÍDA (Vermelho) e Ramo ENTRADA (Verde). | Dois ramos independentes com proteção individual por resistor 680Ω. | **Implementada** |

## Movimento em Miniatura

### Contexto

Um ventilador ou carrinho da feira mostra conversao de energia eletrica em movimento.

### Objetivo pedagogico

Reconhecer motor CC como carga e relacionar polaridade, controle e movimento.

### Mediacao do Professor Volts

“Luz e movimento sao resultados diferentes da mesma energia eletrica.”

### Banco de missões (Implementadas no Estande 06)

| Missão | Objetivo | Componentes / Conceitos | Fenômeno / Validação na Protoboard | Status |
|---|---|---|---|---|
| **M1: Primeiro Giro** | Conectar motor CC aos barramentos da Protoboard. | Motor CC 6V, Protoboard, Bateria 9V com snap clip. | Torque rotacional no sentido horário ↻ e fluxo de elétrons. | **Implementada** |
| **M2: Troca de Sentido** | Inverter polaridade dos cabos de alimentação. | Polos `(+)` e `(–)` nos terminais do motor. | Inversão do campo magnético e rotação anti-horária ↺. | **Implementada** |
| **M3: Botão de Partida** | Controlar acionamento sob demanda. | Chave táctil (Pushbutton de 4 pinos) na vala central. | Interrupção física do circuito e partida pulsada. | **Implementada** |
| **M4: Chaveamento & Indicador** | Chavear motor via transistor com LED de status. | Transistor NPN TO-92, resistor de base e LED Verde. | Chaveamento de carga indutiva e compartilhamento de tensão 6V. | **Implementada** |
| **M5: Ponte H Bidirecional** | Controlar sentido bidirecional eletronicamente. | Ponte H com 4 transistores NPN e LEDs D0/D1. | Comutação lógica sem inversão manual de fios (D0 Verde / D1 Vermelho). | **Implementada** |

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
