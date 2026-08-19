# EletroLab — Implementação do MVP

## 1. Autoridade e limite deste documento

Este documento descreve exclusivamente a implementação da entrega atual do EletroLab. Em caso de divergência com o escopo consolidado, prevalecem as decisões de `mvp.md`.

O objetivo desta versão é validar uma única experiência pedagógica: o aluno observa e experimenta um circuito físico já montado e, em seguida, associa bateria, interruptor e lâmpada aos respectivos símbolos técnicos em três posições predefinidas.

Esta entrega mantém Flutter + Flame e utiliza o EletroLab Asset Pack conforme o README do pacote. Não inclui recursos do produto completo que não sejam necessários a esse fluxo.

## 2. Escopo implementado

O MVP contém somente:

- um circuito físico fixo em série: bateria → interruptor SPST → lâmpada → bateria;
- três componentes físicos não reposicionáveis;
- um interruptor físico clicável;
- uma lâmpada com estados apagado e aceso;
- pontos luminosos em ciano nos fios quando o circuito está energizado;
- uma área de diagrama com três slots predefinidos;
- fios do diagrama já desenhados;
- uma biblioteca com apenas três símbolos: bateria, interruptor e lâmpada;
- drag-and-drop com área de encaixe ampla e centralização automática;
- uso único de cada símbolo;
- validação pelo tipo esperado em cada slot;
- feedback de diagrama incompleto, incorreto ou correto;
- um painel simples com `6 V`, `12 Ω` e corrente igual a `0 A` ou `0,5 A`, conforme o estado do interruptor.

## 3. Fluxo da atividade

1. A tela abre com o circuito físico completo e o interruptor aberto.
2. O aluno pode clicar no interruptor para observar a lâmpada apagada ou acesa e a presença ou ausência das partículas de energização.
3. O aluno arrasta os três símbolos técnicos para os slots do diagrama.
4. Enquanto ainda não verificou, o aluno pode reposicionar os símbolos sem criar cópias.
5. Ao selecionar **Verificar diagrama**, o sistema avalia o preenchimento e o tipo de símbolo de cada slot.
6. O sistema exibe feedback sem revelar imediatamente a resposta correta.
7. O painel apresenta os valores fixos do circuito e a corrente correspondente ao estado aberto ou fechado.

O estado do interruptor físico não altera a resposta esperada nos slots: a validação do diagrama considera somente o tipo de cada símbolo.

## 4. Divisão de responsabilidades entre Flutter e Flame

| Camada | Responsabilidade no MVP |
| --- | --- |
| Flutter | Estrutura da tela, títulos, instruções, painel de valores, botão **Verificar diagrama** e mensagens de feedback. |
| Flame | Circuito físico 2.5D, desenho procedural dos fios, interação do interruptor, slots, símbolos arrastáveis, hitboxes, snap e partículas de energização. |
| Estado em Dart | Estado aberto/fechado, ocupação dos três slots, resultado da validação e valores elétricos derivados. |

Os sprites e componentes visuais não são a fonte oficial do estado. Eles apenas refletem o estado mínimo mantido em Dart pelo controller/notifier já adotado no projeto.

## 5. Estado mínimo do MVP

O estado necessário pode ser representado sem um modelo elétrico genérico:

```dart
enum SymbolType { battery, switchSpst, lamp }

enum SlotId { battery, switchSpst, lamp }

enum ValidationStatus { idle, incomplete, incorrect, correct }

const expectedSymbolBySlot = <SlotId, SymbolType>{
  SlotId.battery: SymbolType.battery,
  SlotId.switchSpst: SymbolType.switchSpst,
  SlotId.lamp: SymbolType.lamp,
};

const voltageVolts = 6.0;
const lampResistanceOhms = 12.0;

double currentAmps(bool isSwitchClosed) =>
    isSwitchClosed ? voltageVolts / lampResistanceOhms : 0.0;
```

Além dessas constantes, o estado contém:

- `isSwitchClosed`;
- `Map<SlotId, SymbolType?> slotOccupancy`;
- `ValidationStatus validationStatus`;
- o conjunto de slots incorretos para destaque visual.

Qualquer alteração de posição de símbolo deve voltar a validação para `idle` e remover destaques anteriores.

## 6. Implementação da tela

### 6.1 Circuito físico fixo

O circuito físico é montado uma única vez pela cena do Flame. Bateria, interruptor e lâmpada utilizam os componentes 2.5D do Asset Pack. Os fios são desenhados proceduralmente no Flame e formam um único caminho fechado quando o interruptor está acionado.

Regras:

- bateria, interruptor e lâmpada não possuem drag-and-drop;
- os componentes permanecem em posições fixas;
- somente a área interativa do interruptor responde ao clique/toque;
- a hitbox do interruptor deve abranger confortavelmente a peça, sem exigir precisão sobre a alavanca;
- o desenho físico e o diagrama representam o mesmo circuito em série.

### 6.2 Estados elétricos e visuais

| Interruptor | Corrente | Lâmpada | Partículas |
| --- | ---: | --- | --- |
| Aberto | `0 A` | `lamp_off` | ausentes |
| Fechado | `0,5 A` | `lamp_on` | ativas nos fios |

Ao clicar no interruptor:

1. `isSwitchClosed` é alternado;
2. o sprite físico troca entre os estados `switch_open` e `switch_closed`;
3. a lâmpada troca entre `lamp_off` e `lamp_on`;
4. o painel atualiza a corrente;
5. as partículas são iniciadas ou removidas.

O brilho existente no arquivo visual não determina se o circuito está ligado. O estado lógico é que seleciona o asset e controla os efeitos.

### 6.3 Partículas de energização

As partículas representam energização de forma pedagógica, não o movimento físico de elétrons nem uma simulação temporal.

Implementação:

- utilizar o efeito luminoso ciano fornecido pelo Asset Pack;
- movimentar instâncias ao longo do caminho procedural já usado pelos fios físicos;
- distribuir os pontos com espaçamento regular e velocidade visual constante;
- não usar setas, pontas ou indicadores direcionais;
- exibir partículas somente quando `isSwitchClosed == true` e a corrente for maior que zero;
- interromper e remover as partículas imediatamente ao abrir o interruptor.

### 6.4 Área do diagrama

O diagrama possui um único circuito fixo e três slots:

| Slot | Tipo esperado | Posição visual fixa |
| --- | --- | --- |
| `SlotId.battery` | `SymbolType.battery` | região da bateria |
| `SlotId.switchSpst` | `SymbolType.switchSpst` | região do interruptor |
| `SlotId.lamp` | `SymbolType.lamp` | região da lâmpada |

As coordenadas dos slots devem ficar centralizadas em uma única configuração da cena, em vez de serem repetidas nos componentes visuais.

Os fios do diagrama:

- já aparecem ao iniciar a atividade;
- são desenhados proceduralmente no Flame;
- deixam lacunas visuais nas três regiões de componente;
- permanecem fixos e não são selecionáveis;
- não podem ser criados, removidos ou reposicionados pelo aluno.

### 6.5 Biblioteca de símbolos

A biblioteca apresenta somente uma instância de cada símbolo técnico:

- bateria;
- interruptor SPST;
- lâmpada.

Os SVGs do Asset Pack são a fonte preferencial. Os símbolos são planos, técnicos e não recebem o tratamento 2.5D dos componentes físicos.

Quando um símbolo ocupa um slot, ele deixa de ficar disponível na biblioteca. Ao sair do slot, volta a ficar disponível. Em nenhum momento podem existir duas instâncias do mesmo símbolo.

### 6.6 Drag-and-drop e snap

Cada símbolo arrastável mantém sua origem atual: biblioteca ou slot. Cada slot possui:

- uma área visual de destino;
- uma hitbox de encaixe maior que a área visual;
- um ponto central de snap.

Comportamento esperado:

1. Durante o arraste, o símbolo acompanha o ponteiro ou toque sem exigir que o usuário segure um ponto específico da imagem.
2. Ao entrar suficientemente na hitbox de um slot, o slot recebe um destaque de candidato.
3. Ao soltar, o símbolo é centralizado automaticamente no slot.
4. Ao soltar fora de uma área válida, o símbolo retorna à origem.
5. Um símbolo já encaixado pode ser arrastado novamente.
6. Se um símbolo vindo de outro slot for solto em um slot ocupado, os dois trocam de posição.
7. Se um símbolo vindo da biblioteca for solto em um slot ocupado, o símbolo anterior retorna à biblioteca.

O encaixe não valida a resposta. Um símbolo incorreto também deve encaixar; a correção é avaliada somente ao selecionar **Verificar diagrama**.

### 6.7 Validação por tipo esperado

A validação segue esta ordem:

```text
se algum slot estiver vazio
  resultado = incomplete
senão se algum slot contiver tipo diferente do esperado
  resultado = incorrect
senão
  resultado = correct
```

Feedback:

- `incomplete`: exibir **Complete todas as posições antes de verificar.** e destacar os slots vazios;
- `incorrect`: exibir **Confira o símbolo utilizado nesta posição.** e destacar somente os slots incorretos;
- `correct`: exibir **Muito bem! O diagrama representa o circuito apresentado.** e aplicar o estado visual de sucesso.

A resposta correta não é inserida automaticamente, e o sistema não revela qual símbolo deveria ocupar cada slot.

### 6.8 Painel de valores

O painel é informativo e utiliza valores fixos:

```text
Tensão:      6 V
Resistência: 12 Ω
Corrente:    0 A     (interruptor aberto)
Corrente:    0,5 A   (interruptor fechado)
```

Com o interruptor fechado, pode ser exibida a substituição introdutória:

```text
I = V / R
I = 6 / 12
I = 0,5 A
```

O painel não é um multímetro, não aceita entrada e não oferece outros cálculos nesta entrega.

## 7. Regras obrigatórias do Asset Pack

- Componentes físicos 2.5D são usados somente no circuito físico.
- Símbolos técnicos são usados somente no editor do diagrama.
- Os IDs e caminhos reais dos assets devem ser resolvidos pelo `asset_manifest.json` do pacote.
- Os SVGs são preferidos para símbolos; WebP é usado quando o fluxo exigir raster.
- Os fios são desenhados proceduralmente no Flame; `wire.svg/webp` não deve ser esticado para formar o circuito.
- `switch_open`/`switch_closed` e `lamp_off`/`lamp_on` são selecionados a partir do estado lógico.
- O efeito de energização usa pontos luminosos em ciano e nunca setas.
- Não devem ser criadas variantes visuais improvisadas fora do pacote para substituir estados já fornecidos.

## 8. Simplificações temporárias do MVP

| Implementação desta entrega | Natureza da simplificação | Fora desta entrega |
| --- | --- | --- |
| Um circuito fixo com três componentes | Temporária | catálogo amplo e múltiplos circuitos |
| Três slots com posição e tipo esperados | Temporária | posicionamento livre e validação pela topologia |
| Fios do diagrama prontos | Temporária | criação e conexão manual de fios |
| `I = 6 / 12` com estado aberto/fechado | Temporária | solver elétrico genérico |
| Estado mínimo do circuito em Dart | Específico do MVP | documento/netlist genéricos e serialização do editor completo |

Essas simplificações não redefinem a arquitetura futura descrita no escopo consolidado. Elas apenas evitam implementar essa arquitetura antes de validar a experiência central do MVP.

## 9. Fora do escopo desta implementação

Não implementar nesta entrega:

- montagem ou reposicionamento do circuito físico;
- desenho manual, conexão, desconexão ou exclusão de fios;
- rotação de símbolos;
- desfazer, refazer ou limpar em massa;
- resistores separados, LEDs, diodos, motores ou instrumentos;
- circuitos em paralelo, mistos ou com mais de uma fonte;
- polaridade editável, detecção de curto-circuito ou terminais soltos;
- equivalência elétrica, comparação topológica ou netlist;
- motor MNA ou outro solver elétrico genérico;
- modos livre, professor, planta ou circuito misterioso;
- pontuação, progressão, salvamento ou desafios adicionais.

## 10. Critério de conclusão do MVP

O MVP está pronto quando:

- o circuito físico inicia montado e com o interruptor aberto;
- abrir e fechar o interruptor atualiza imediatamente sprite, lâmpada, corrente e partículas;
- bateria, interruptor e lâmpada físicos não podem ser arrastados;
- somente os três símbolos previstos aparecem na biblioteca;
- os fios do diagrama já estão desenhados e não são editáveis;
- qualquer símbolo pode encaixar em qualquer slot por uma área de drop generosa;
- o snap centraliza o símbolo e um drop inválido retorna à origem;
- cada símbolo existe uma única vez e pode ser reposicionado antes da verificação;
- a validação distingue corretamente estados incompleto, incorreto e correto;
- erros destacam slots sem revelar automaticamente a solução;
- o painel mostra `6 V`, `12 Ω`, `0 A` com o circuito aberto e `0,5 A` com o circuito fechado;
- os assets físicos, técnicos e de efeito obedecem às regras do Asset Pack;
- não há implementação de funcionalidades listadas como fora do escopo.
