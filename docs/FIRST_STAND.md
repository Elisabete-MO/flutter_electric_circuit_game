# Primeiro Estande: Acende Ai

## Objetivo

O primeiro estande introduz um estudante sem conhecimento previo a uma demonstracao de iluminacao de baixa tensao. A progressao e:

```text
Conhecer -> Inspecionar -> Representar -> Construir
```

Ele e a principal entrega introdutoria atual e tambem valida a relacao entre circuito fisico, simbolo tecnico e comportamento.

## Circuito de referencia

```text
bateria (+) -> interruptor SPST -> resistor 680 ohms -> LED -> bateria (-)
```

| Componente | Modelo didatico |
|---|---|
| Bateria | 9 V |
| Interruptor | SPST; abre ou fecha o percurso |
| Resistor | 680 ohms; limita corrente |
| LED vermelho | Aproximadamente `Vf = 2 V`; respeita polaridade |
| Fios | Conectam terminais e formam o caminho condutor |

```text
I = (9 V - 2 V) / 680 ohms
I ~= 10,3 mA
```

O conjunto e eletricamente plausivel para a demonstracao didatica. Nenhuma especificacao adicional de LED e assumida aqui.

## Fase 1 - Conhecer

Apresentar bateria, LED, resistor, interruptor SPST e fios em cards. Cada card inclui nome, aparencia, funcao, terminais, polaridade quando houver, simbolo tecnico e cuidado relevante.

**Conteudo proposto para o MVP:** quiz curto de multipla escolha sobre qual componente fornece energia, produz luz, limita/protege, abre/fecha o caminho e conecta os demais. O feedback explica a causa e permite nova tentativa; esse formato nao define o sistema geral de avaliacao.

## Fase 2 - Inspecionar

O circuito fisico ja esta montado. Antes de testar, o estudante observa presenca dos componentes, uso dos polos da bateria, polaridade do LED, presenca/valor do resistor, continuidade, estado do interruptor e ausencia de curto pedagogico. Ele pode consultar informacoes dos componentes e formular uma previsao antes do teste quando a missao pedir.

| Variacao candidata | O que o estudante deve observar | Status |
|---|---|---|
| Circuito correto | Componentes, polaridade, resistor e caminho completo. | Forte candidata |
| LED invertido | Anodo/catodo em relacao a fonte. | Forte candidata |
| Resistor inadequado ou ausente | Protecao e corrente didatica. | Em validacao de implementacao |
| Circuito aberto | Fio ou percurso interrompido. | Forte candidata |
| Curto pedagogico | Caminho direto entre polos que ignora a carga. | Em validacao de implementacao |

## Fase 3 - Representar

Esta fase aplica o requisito **circuito fisico fantasma sob o diagrama**.

- O circuito fisico/2.5D permanece visivel como camada faded/ghost.
- Simbolos tecnicos e fios esquematicos aparecem acima e continuam legiveis.
- O estudante associa cada simbolo ao componente fisico correspondente.
- O encaixe e generoso e nao avalia precisao motora.
- O modo fisico pode continuar como apoio, mas ele nao substitui a referencia ghost durante a representacao.

O banco de simbolos proposto contem bateria, interruptor, resistor e LED, com lampada e diodo comum como distratores controlados. Fios do diagrama podem ficar predesenhados; a tarefa e traduzir os componentes, incluindo orientacao do LED e estado do interruptor quando pedagogicamente relevante. Verificar e Reiniciar sao controles candidatos para o MVP, com feedback educativo por erro.

O circuito nao desaparece para dar lugar a espacos vazios. A capacidade conceitualmente mais proxima ja existe na Bancada atual: composicao fisica atenuada sob esquema.

## Fase 4 - Construir

Uma versao controlada da Bancada Livre permite posicionar componentes, conectar terminais manualmente, escolher resistor, abrir/fechar interruptor, testar, corrigir e tentar novamente. A biblioteca candidata contem uma bateria de 9 V, um SPST, um LED vermelho, resistores de 68 ohms, 680 ohms e 6,8 kohms e fios com ferramenta de remover conexoes.

A validade depende das conexoes eletricas, nao das coordenadas. O resistor pode vir antes ou depois do LED se ambos permanecerem no mesmo ramo em serie. A missao deve diferenciar circuito correto, aberto, LED invertido, resistor inadequado/ausente e curto pedagogico conforme as regras didaticas que forem implementadas e testadas.

### Validacoes propostas

| Situacao | Resposta didatica pretendida | Status |
|---|---|---|
| Circuito correto com 680 ohms | LED e ponto de luz da maquete ativos. | Proposta do MVP |
| Interruptor aberto | Circuito topologicamente valido, sem corrente. | Proposta do MVP |
| LED invertido | LED apagado e orientacao a conferir. | Em validacao de implementacao |
| Resistor 68 ohms | Alerta de corrente excessiva; comportamento seguro a definir. | Em validacao de implementacao |
| Resistor 6,8 kohms | Corrente baixa e brilho fraco/apagado no modelo didatico. | Em validacao de implementacao |
| Resistor ausente | Alerta de protecao ausente. | Em validacao de implementacao |
| Fio ausente | Circuito aberto; trecho incompleto indicado. | Proposta do MVP |
| Polos ligados diretamente | Curto pedagogico; energizacao bloqueada/explicada. | Em validacao de implementacao |

O painel de resultado proposto mostra bateria 9 V, LED com `Vf` didatico aproximado de 2 V, resistor selecionado de 680 ohms, corrente aproximada de 10,3 mA e avaliacao de circuito seguro/funcional. Ele e proposta de interface, nao leitura obrigatoria do solver atual.

## Feedback e conclusao minima

O fenomeno aparece antes da explicacao: LED acende/apaga ou o sistema mostra consequencia compreensivel da falha. Feedback explica causa e permite correcao.

Pistas candidatas: “A corrente precisa percorrer um caminho completo”; “Confira a orientacao do LED e o valor do resistor”; e destaque visual de terminais ou componente problematico. Pergunta final candidata: “Por que o LED apaga quando o interruptor abre?”. A maquete pode acender seu primeiro ponto de luz como confirmacao visual; ambos sao propostas ainda nao implementadas.

Conclusao minima do estande: o estudante reconhece os componentes, inspeciona o circuito, relaciona os simbolos a referencia fisica e monta/testa um circuito seguro que energiza o LED. Avaliacao, estrelas e pontuacao permanecem em validacao e nao sao criterio fechado desta especificacao.

## Relacao com a Bancada e seguranca

A Bancada e o ativo tecnico a evoluir/restringir para a fase Construir; nao ha necessidade aprovada de criar outro canvas. As limitacoes atuais de modelo e simulacao estao em `ARCHITECTURE.md`.

O estande representa baixa tensao didatica. Ele nao autoriza instrucoes para rede eletrica ou outros contextos de maior risco.

## Governanca documental

Uma decisao nova sobre este MVP deve atualizar este documento, e nao criar outra especificacao de primeiro estande.
