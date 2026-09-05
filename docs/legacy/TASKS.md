# EletroLab — Tarefas do MVP

## 1. Regra de escopo

As tarefas abaixo implementam somente o MVP definido em `mvp.md`. O circuito é fixo, os fios do diagrama estão prontos e a validação compara o tipo de cada símbolo com o tipo esperado em três slots.

Não devem ser adicionados editor livre, fios criados pelo aluno, solver genérico, equivalência elétrica, componentes extras, instrumentos interativos, progressão ou outros modos de atividade.

As tarefas estão na ordem recomendada. Itens de uma mesma etapa podem ser executados em paralelo quando suas dependências estiverem concluídas.

## Etapa 1 — Contratos mínimos

### T01 — Mapear os assets necessários

**Objetivo:** identificar no `asset_manifest.json` os IDs e caminhos dos assets usados pelo MVP: bateria física, interruptor aberto/fechado, lâmpada apagada/acesa, três símbolos técnicos e ponto luminoso de energização.

**Dependências:** nenhuma.

**Critério de aceite:**

- existe um único mapa de assets do MVP, sem caminhos duplicados espalhados pela cena;
- componentes físicos usam os WebPs 2.5D apropriados;
- símbolos usam preferencialmente os SVGs técnicos;
- os estados `switch_open`, `switch_closed`, `lamp_off` e `lamp_on` estão associados corretamente;
- nenhum asset de componente fora do circuito bateria + interruptor + lâmpada é carregado.

### T02 — Definir constantes e tipos do MVP

**Objetivo:** criar os enums/IDs para os três tipos de símbolo e os três slots, o mapa `slot → tipo esperado` e as constantes `6 V` e `12 Ω`.

**Dependências:** nenhuma.

**Critério de aceite:**

- existem exatamente três tipos: bateria, interruptor SPST e lâmpada;
- existem exatamente três slots correspondentes;
- o mapa de resposta esperada está em um único local;
- a corrente é `0 A` com interruptor aberto e `6 / 12 = 0,5 A` com interruptor fechado;
- não foi criado solver, grafo ou modelo genérico de circuito.

### T03 — Implementar o estado e o controller do MVP

**Objetivo:** centralizar o estado aberto/fechado, a ocupação dos slots, o resultado da validação e os slots destacados.

**Dependências:** T02.

**Critério de aceite:**

- o estado visual não depende de consultar sprites;
- cada slot aceita `null` ou um único `SymbolType`;
- qualquer mudança de símbolo limpa o feedback de validação anterior;
- abrir/fechar o interruptor atualiza a corrente derivada;
- o controller não contém lógica de editor livre ou simulação genérica.

## Etapa 2 — Estrutura visual

### T04 — Montar a tela base Flutter + Flame

**Objetivo:** criar a estrutura que reúne o `GameWidget`, o painel de valores, o botão **Verificar diagrama** e a área de feedback.

**Dependências:** T03.

**Critério de aceite:**

- a tela exibe áreas identificáveis para circuito físico, diagrama e símbolos;
- painel, botão e feedback conseguem observar o estado central;
- o Flame recebe o mesmo controller usado pela interface Flutter;
- não há botões de girar, desfazer, limpar ou criar fios.

### T05 — Renderizar o circuito físico fixo

**Objetivo:** posicionar bateria, interruptor e lâmpada 2.5D e desenhar os fios físicos proceduralmente no Flame.

**Dependências:** T01 e T04.

**Critério de aceite:**

- os três componentes aparecem conectados em um único circuito em série;
- os fios são desenhados pelo Flame e não por um sprite esticado;
- bateria, interruptor e lâmpada não são arrastáveis;
- o circuito inicia visualmente com interruptor aberto e lâmpada apagada.

### T06 — Desenhar o diagrama fixo e os três slots

**Objetivo:** desenhar os fios do diagrama e criar os slots predefinidos para bateria, interruptor e lâmpada.

**Dependências:** T02 e T04.

**Critério de aceite:**

- os fios aparecem prontos ao iniciar;
- os fios deixam três lacunas coerentes com os slots;
- os slots possuem posição central e hitbox de drop maior que seu contorno visual;
- fios e slots não podem ser movidos, criados ou excluídos.

### T07 — Implementar a biblioteca de três símbolos

**Objetivo:** exibir uma instância arrastável de cada símbolo técnico do MVP.

**Dependências:** T01, T02 e T04.

**Critério de aceite:**

- aparecem somente bateria, interruptor SPST e lâmpada;
- os símbolos são técnicos e visualmente separados dos componentes físicos 2.5D;
- cada símbolo possui identidade estável;
- a biblioteca não cria clones ao iniciar um arraste.

## Etapa 3 — Interações independentes

### T08 — Implementar drag-and-drop com snap generoso

**Objetivo:** permitir que um símbolo da biblioteca seja solto em qualquer slot com encaixe amplo e centralização automática.

**Dependências:** T03, T06 e T07.

**Critério de aceite:**

- a área válida de drop é maior que a área visual do slot;
- o slot candidato recebe destaque durante o arraste;
- qualquer tipo de símbolo encaixa em qualquer slot;
- o símbolo é centralizado no ponto de snap;
- um drop fora de slots retorna o símbolo à origem;
- o encaixe não executa validação automática.

### T09 — Permitir reposicionamento sem duplicação

**Objetivo:** mover símbolos entre biblioteca e slots, preservando uma única instância de cada símbolo.

**Dependências:** T08.

**Critério de aceite:**

- um símbolo encaixado pode ser arrastado novamente;
- ao mover entre dois slots, a ocupação do estado permanece consistente;
- dois símbolos podem trocar de slot sem gerar cópias;
- se um símbolo da biblioteca substituir o ocupante de um slot, o ocupante volta à biblioteca;
- cada `SymbolType` aparece no máximo uma vez na tela.

### T10 — Implementar o interruptor funcional e os estados da lâmpada

**Objetivo:** alternar o estado lógico e os sprites físicos ao clicar/tocar no interruptor.

**Dependências:** T01, T03 e T05.

**Critério de aceite:**

- a hitbox do interruptor é confortável e restrita à região da peça;
- aberto seleciona `switch_open`, `lamp_off` e corrente `0 A`;
- fechado seleciona `switch_closed`, `lamp_on` e corrente `0,5 A`;
- a atualização é imediata;
- o brilho do sprite não é usado como fonte do estado.

### T11 — Implementar partículas de energização

**Objetivo:** animar pontos luminosos em ciano ao longo dos fios físicos somente com o circuito fechado.

**Dependências:** T01, T05 e T10.

**Critério de aceite:**

- as partículas percorrem o caminho dos fios físicos;
- não existem setas ou marcadores direcionais;
- o circuito aberto não exibe partículas;
- fechar inicia o efeito e abrir o remove imediatamente;
- o efeito não é descrito nem calculado como movimento real de elétrons.

### T12 — Implementar o painel elétrico simples

**Objetivo:** apresentar tensão, resistência, corrente e a substituição básica da Lei de Ohm.

**Dependências:** T03, T04 e T10.

**Critério de aceite:**

- tensão permanece em `6 V`;
- resistência permanece em `12 Ω`;
- a corrente mostra `0 A` aberta e `0,5 A` fechada;
- com o circuito fechado, o painel pode mostrar `I = 6 / 12 = 0,5 A`;
- o painel não aceita entrada e não simula um instrumento virtual.

## Etapa 4 — Verificação pedagógica

### T13 — Implementar a validação por slot

**Objetivo:** retornar `incomplete`, `incorrect` ou `correct` ao comparar a ocupação com o mapa de tipos esperados.

**Dependências:** T02, T03 e T09.

**Critério de aceite:**

- qualquer slot vazio retorna `incomplete`;
- todos preenchidos com ao menos um tipo errado retornam `incorrect`;
- os três tipos nos slots esperados retornam `correct`;
- o estado do interruptor físico não interfere no resultado;
- a validação não usa posição livre, terminais, fios, grafo ou equivalência elétrica.

### T14 — Implementar feedback e destaques

**Objetivo:** conectar o botão **Verificar diagrama** às mensagens e aos estados visuais dos slots.

**Dependências:** T04 e T13.

**Critério de aceite:**

- incompleto mostra **Complete todas as posições antes de verificar.** e destaca slots vazios;
- incorreto mostra **Confira o símbolo utilizado nesta posição.** e destaca slots incorretos;
- correto mostra **Muito bem! O diagrama representa o circuito apresentado.**;
- a resposta correta não é preenchida nem revelada automaticamente;
- mover qualquer símbolo limpa a mensagem e os destaques anteriores.

## Etapa 5 — Testes e integração

### T15 — Criar testes unitários do estado e da validação

**Objetivo:** cobrir a lógica independente da renderização.

**Dependências:** T03 e T13.

**Critério de aceite:**

- há teste para corrente aberta igual a `0 A`;
- há teste para corrente fechada igual a `0,5 A`;
- há testes para validação incompleta, incorreta e correta;
- há teste garantindo uso único de cada símbolo;
- há teste garantindo que mover um símbolo limpa o feedback anterior.

### T16 — Executar integração e aceite final do MVP

**Objetivo:** verificar o fluxo completo, o uso correto dos assets e a ausência de funcionalidades fora do escopo.

**Dependências:** T05 a T15.

**Critério de aceite:**

- o fluxo observar → experimentar → montar → verificar → consultar valores funciona do início ao fim;
- drag-and-drop funciona sem exigir precisão motora;
- o circuito físico e o diagrama representam bateria, interruptor e lâmpada em série;
- sprites, símbolos, fios e partículas respeitam o README do Asset Pack;
- não há exceções, duplicação de símbolos ou estado visual dessincronizado após vários arrastes e cliques;
- não foram adicionados solver, editor livre, fios manuais, componentes extras ou outros modos;
- todos os critérios de conclusão de `IMPLEMENTATION.md` foram conferidos.

## Ordem resumida para distribuição

| Onda | Tarefas | Execução recomendada |
| --- | --- | --- |
| 1 | T01, T02 | paralelas |
| 2 | T03 | após T02 |
| 3 | T04 | após T03 |
| 4 | T05, T06, T07 | paralelas após a tela base e seus contratos |
| 5 | T08, T10 | paralelas |
| 6 | T09, T11, T12 | paralelas conforme dependências |
| 7 | T13 | após reposicionamento |
| 8 | T14, T15 | paralelas após a validação |
| 9 | T16 | integração final |

As ondas indicam apenas a sequência técnica. A divisão entre pessoas deve respeitar as dependências declaradas em cada tarefa e manter o contrato de estado da T03 como ponto comum de integração.
