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

Apresentar bateria, LED, resistor, interruptor SPST e fios. Cada apresentacao inclui nome, funcao, terminais, polaridade quando houver, simbolo tecnico e cuidado relevante. Um quiz curto pode confirmar reconhecimento, com nova tentativa e feedback explicativo.

## Fase 2 - Inspecionar

O circuito fisico ja esta montado. Antes de testar, o estudante observa presenca dos componentes, polaridade do LED, resistor, continuidade, estado do interruptor e ausencia de curto pedagogico. Ele pode consultar informacoes dos componentes e formular uma previsao antes do teste quando a missao pedir.

## Fase 3 - Representar

Esta fase aplica o requisito **circuito fisico fantasma sob o diagrama**.

- O circuito fisico/2.5D permanece visivel como camada faded/ghost.
- Simbolos tecnicos e fios esquematicos aparecem acima e continuam legiveis.
- O estudante associa cada simbolo ao componente fisico correspondente.
- O encaixe e generoso e nao avalia precisao motora.
- O modo fisico pode continuar como apoio, mas ele nao substitui a referencia ghost durante a representacao.

O circuito nao desaparece para dar lugar a espacos vazios. A capacidade conceitualmente mais proxima ja existe na Bancada atual: composicao fisica atenuada sob esquema.

## Fase 4 - Construir

Uma versao controlada da Bancada Livre permite posicionar componentes, conectar terminais, escolher resistor, abrir/fechar interruptor, testar, corrigir e tentar novamente.

A validade depende das conexoes eletricas, nao das coordenadas. O resistor pode vir antes ou depois do LED se ambos permanecerem no mesmo ramo em serie. A missao deve diferenciar circuito correto, aberto, LED invertido, resistor inadequado/ausente e curto pedagogico conforme as regras didaticas que forem implementadas e testadas.

## Feedback e conclusao minima

O fenomeno aparece antes da explicacao: LED acende/apaga ou o sistema mostra consequencia compreensivel da falha. Feedback explica causa e permite correcao.

Conclusao minima do estande: o estudante reconhece os componentes, inspeciona o circuito, relaciona os simbolos a referencia fisica e monta/testa um circuito seguro que energiza o LED. Avaliacao, estrelas e pontuacao permanecem em validacao e nao sao criterio fechado desta especificacao.

## Relacao com a Bancada e seguranca

A Bancada e o ativo tecnico a evoluir/restringir para a fase Construir; nao ha necessidade aprovada de criar outro canvas. As limitacoes atuais de modelo e simulacao estao em `ARCHITECTURE.md`.

O estande representa baixa tensao didatica. Ele nao autoriza instrucoes para rede eletrica ou outros contextos de maior risco.

## Governanca documental

Uma decisao nova sobre este MVP deve atualizar este documento, e nao criar outra especificacao de primeiro estande.
