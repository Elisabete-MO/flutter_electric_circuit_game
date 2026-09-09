# Asset Registry

## Objetivo

Este documento registra o primeiro lote de assets canônicos do EletroLab para o Primeiro Stand, **Acende Aí**, sua identidade técnica e o respectivo status de validação.

O circuito de referência é:

```text
bateria de 9 V (+) -> interruptor SPST -> resistor de 680 Ω -> LED vermelho -> bateria de 9 V (-)
```

Este documento **não** define rotação, ghost, hitbox, snap, coordenadas de terminais, solver, comportamento interno da Bancada, animações ou layout. Esses aspectos pertencem à arquitetura e à implementação posterior.

Quando um detalhe físico importante não puder ser percebido com clareza no asset principal, ele pode ser ensinado por **material de apoio pedagógico complementar**, desde que o asset não contradiga o componente real. Esse apoio não substitui a validação técnica do componente.

## Regras

- Precisão elétrica prevalece sobre aparência e conveniência visual.
- Um asset só representa um dispositivo quando tipo/subtipo, terminais, polaridade (quando houver) e símbolo técnico forem coerentes entre si.
- Valores elétricos do circuito didático não são especificações universais do componente físico.
- Imagens geradas ou estilizadas são referências visuais, nunca fonte técnica.
- Nenhuma especificação que não esteja no código, na documentação canônica ou na referência citada é inferida.
- Se uma propriedade essencial não puder ser confirmada, o item permanece `EM_VALIDACAO`.
- Cores dos fios são apoio visual; não definem polaridade nem topologia.
- Material pedagógico complementar pode destacar detalhes reais difíceis de perceber no asset, como comprimento dos terminais, face plana do LED, ânodo/cátodo, código de cores e símbolos.

## Status

- `INVENTARIADO`: asset e uso localizados, ainda sem validação técnica suficiente.
- `EM_VALIDACAO`: há informação ausente, ambígua ou contraditória.
- `APROVADO`: identidade, terminais, polaridade quando aplicável, símbolo, uso pedagógico e referência técnica são coerentes.
- `REJEITADO`: o asset contradiz o dispositivo que deveria representar ou não pode cumprir seu papel pedagógico.

## Índice

| ID | Componente | Asset canônico | Status | Uso principal |
|---|---|---|---|---|
| BAT-001 | Bateria alcalina de 9 V | `assets/components/battery.png` | APROVADO | Fonte do circuito de referência. |
| RES-001 | Resistor axial de 680 Ω | `assets/components/resistor.png` | EM_VALIDACAO | Novo asset correto, aguardando substituição no repositório. |
| LED-001 | LED vermelho de dois terminais | `assets/components/led_off.png` | APROVADO | Carga luminosa polarizada; A/K reforçados por apoio pedagógico. |
| SW-001 | Interruptor-faca SPST | `assets/components/switch_open.png` | APROVADO | Abrir e fechar o caminho em série. |
| WIRE-001 | Fios de conexão didáticos | `assets/components/wires.png` | EM_VALIDACAO | Tipo físico de conector ainda a definir. |

## BAT-001 — Bateria 9 V

- **Asset canônico:** `assets/components/battery.png`
- **Alternativas existentes:** `assets/images/component_battery_horizontal.png`
- **Asset de origem/referência visual:** bateria Duracell 9 V usada como referência visual; o asset canônico final foi desmarcado e não deve exibir branding comercial.

- **Nome técnico:** bateria alcalina de 9 V.
- **Tipo/subtipo:** bateria primária alcalina, formato 9 V, com dois terminais snap.
- **Quantidade de terminais:** 2.
- **Função dos terminais:** positivo (+) e negativo (−).
- **Polaridade:** sim.

- **Tensão/faixa relevante para a demonstração:** 9 V nominal.
- **Corrente/faixa relevante:** depende da carga; no circuito de referência, aproximadamente 10,3 mA, valor que não representa corrente nominal da bateria.
- **Outros parâmetros relevantes:** os dois terminais possuem formatos físicos distintos e precisam permanecer coerentes com a identificação +/−.

- **Representação esquemática correspondente:** símbolo de bateria, com polaridade explícita.
- **Implementação da representação:** representação esquemática desenhada por código; manter correspondência com o tipo físico e os polos.

- **Referência real confiável:** documentação técnica oficial Duracell para bateria alcalina de 9 V.
- **Fabricante/modelo de referência:** Duracell MN1604 ou referência tecnicamente compatível, sem afirmar que o asset genérico é esse modelo exato.

- **Uso pedagógico:** fornecer a diferença de potencial do circuito de baixa tensão.
- **Comportamento que o estudante deve reconhecer:** + e − indicam polaridade/potencial; a bateria fornece diferença de potencial entre seus polos.

- **Observações visuais:** asset final sem marca comercial; dois terminais e polaridade coerentes com bateria de 9 V real.
- **Status:** `APROVADO`
- **Pendências:** nenhuma de identidade técnica. Hitboxes e coordenadas ficam fora deste registro.

## RES-001 — Resistor 680 Ω

- **Asset canônico:** `assets/components/resistor.png`
- **Alternativas existentes:** `assets/images/component_resistor.png`
- **Asset de origem/referência visual:** novo asset visual baseado em resistor axial realista, sem identificação comercial específica.

- **Nome técnico:** resistor fixo axial.
- **Tipo/subtipo:** resistor axial de dois terminais; material construtivo exato não deve ser inferido pela aparência.
- **Quantidade de terminais:** 2.
- **Função dos terminais:** extremidades do elemento resistivo; eletricamente intercambiáveis neste uso.
- **Polaridade:** não possui.

- **Tensão/faixa relevante para a demonstração:** circuito alimentado por 9 V; não inferir tensão nominal do resistor pelo asset.
- **Corrente/faixa relevante:** aproximadamente 10,3 mA no circuito de referência.
- **Outros parâmetros relevantes:** valor pedagógico: `680 Ω`. Código de cores de 4 faixas adotado: **azul – cinza – marrom – dourado**, correspondente a **680 Ω ±5 %**.

- **Representação esquemática correspondente:** símbolo IEC de resistor, sem polaridade.
- **Implementação da representação:** representação esquemática desenhada por código.

- **Referência real confiável:** resistor axial comercial de 680 Ω com datasheet de fabricante ou distribuidor técnico confiável.
- **Fabricante/modelo de referência:** referência técnica compatível, sem identificar o asset como modelo comercial exato.

- **Uso pedagógico:** limitar a corrente em série e proteger o LED.
- **Comportamento que o estudante deve reconhecer:** o resistor de 680 Ω limita a corrente; inverter suas extremidades não altera sua função.

- **Observações visuais:** o novo asset revisado está horizontal, com fundo transparente e faixas `azul – cinza – marrom – dourado`, coerentes com 680 Ω ±5 %. A arte anterior incompatível não deve permanecer como canônica.
- **Status:** `EM_VALIDACAO`
- **Pendências:** substituir `assets/components/resistor.png` pelo novo asset e confirmar o arquivo final no repositório. Depois disso, pode passar para `APROVADO`.

## LED-001 — LED vermelho

- **Asset canônico:** `assets/components/led_off.png`
- **Asset de estado ligado:** `assets/components/led_on.png`
- **Alternativas existentes:** `assets/images/component_led_off.png`, `assets/images/component_led_on.png`
- **Asset de origem/referência visual:** não identificado com segurança.

- **Nome técnico:** LED vermelho de furo passante.
- **Tipo/subtipo:** LED vermelho de dois terminais, encapsulamento visualmente compatível com formato comum de aproximadamente 5 mm; modelo comercial exato não identificado.
- **Quantidade de terminais:** 2.
- **Função dos terminais:** ânodo (A) e cátodo (K).
- **Polaridade:** sim.

- **Tensão/faixa relevante para a demonstração:** o Primeiro Stand usa aproximadamente `Vf = 2 V` como modelo didático; não é valor universal para todo LED vermelho.
- **Corrente/faixa relevante:** no circuito com resistor de 680 Ω, aproximadamente 10,3 mA.
- **Outros parâmetros relevantes:** exige limitação de corrente; não deve ser ligado diretamente à bateria de 9 V.

- **Representação esquemática correspondente:** símbolo de LED; orientação A/K deve ser coerente com a montagem.
- **Implementação da representação:** representação esquemática desenhada por código e mapeamento A/K no modelo de terminais.

- **Referência real confiável:** datasheet de LED vermelho comercial de dois terminais e encapsulamento compatível.
- **Fabricante/modelo de referência:** referência técnica compatível, não identificação exata do asset.

- **Uso pedagógico:** carga luminosa polarizada do circuito-base do Primeiro Stand.
- **Comportamento que o estudante deve reconhecer:** o LED emite luz quando polarizado diretamente e com corrente limitada; a orientação dos terminais importa.

- **Observações visuais:** `led_off` e `led_on` representam o mesmo LED em dois estados. A diferença A/K não precisa ser artificialmente exagerada no asset principal. O apoio pedagógico deve mostrar claramente os indicadores reais adotados para o componente de referência: **perna mais longa = ânodo**, **perna mais curta = cátodo** e **face plana do encapsulamento = lado do cátodo**, além do símbolo correspondente.
- **Status:** `APROVADO`
- **Pendências:** criar material de apoio pedagógico com diagrama claro de A/K, comprimento das pernas, face plana e símbolo; confirmar que a orientação usada pelo código não contradiz esse material.

## SW-001 — Interruptor SPST

- **Asset canônico:** `assets/components/switch_open.png`
- **Asset de estado fechado:** `assets/components/switch_closed.png`
- **Alternativas existentes:** `assets/images/component_switch_off.png`, `assets/images/component_switch_on.png`
- **Asset de origem/referência visual:** não identificado com segurança; visualmente compatível com chave-faca didática.

- **Nome técnico:** interruptor-faca SPST.
- **Tipo/subtipo:** single pole, single throw (SPST), acionamento manual e contato visível.
- **Quantidade de terminais:** 2.
- **Função dos terminais:** conectados quando fechado e separados quando aberto.
- **Polaridade:** não possui.

- **Tensão/faixa relevante para a demonstração:** uso didático no circuito de 9 V; não inferir tensão nominal comercial pelo asset.
- **Corrente/faixa relevante:** aproximadamente 10,3 mA no circuito de referência quando fechado; não é corrente nominal da chave.
- **Outros parâmetros relevantes:** não é SPDT, DPST, DPDT, relé, fusível ou disjuntor.

- **Representação esquemática correspondente:** símbolo de interruptor SPST, aberto ou fechado conforme o estado.
- **Implementação da representação:** representação esquemática desenhada por código.

- **Referência real confiável:** chave-faca SPST real de uso didático/laboratorial.
- **Fabricante/modelo de referência:** referência técnica compatível, não identificação exata do asset.

- **Uso pedagógico:** controlar a continuidade do único percurso em série.
- **Comportamento que o estudante deve reconhecer:** aberto = contatos separados; fechado = contatos unidos.

- **Observações visuais:** `switch_open.png` e `switch_closed.png` representam estados coerentes. `on/off` não deve substituir automaticamente aberto/fechado sem mapeamento explícito.
- **Status:** `APROVADO`
- **Pendências:** nenhuma de identidade técnica.

## WIRE-001 — Fios/conexões

- **Asset canônico:** `assets/components/wires.png`
- **Alternativas existentes:** não localizadas neste lote.
- **Asset de origem/referência visual:** não identificado com segurança.

- **Nome técnico:** fios de conexão para circuito didático de baixa tensão.
- **Tipo/subtipo:** a definir conforme o sistema físico de terminais adotado para a bancada.
- **Quantidade de terminais:** duas extremidades condutoras por fio.
- **Função dos terminais:** estabelecer conexão elétrica entre dois pontos.
- **Polaridade:** o fio em si não possui polaridade; sua cor não determina potencial.

- **Tensão/faixa relevante para a demonstração:** baixa tensão didática de 9 V.
- **Corrente/faixa relevante:** aproximadamente 10,3 mA no circuito de referência; não usar como corrente nominal do fio.
- **Outros parâmetros relevantes:** não inferir bitola, material, tipo de conector, isolamento, tensão máxima ou corrente nominal pela imagem.

- **Representação esquemática correspondente:** linha condutora/conexão elétrica; junções dependem da topologia e da marcação de nó.
- **Implementação da representação:** conexões elétricas são modeladas separadamente dos componentes físicos.

- **Referência real confiável:** deverá corresponder ao sistema físico de conexão efetivamente adotado.
- **Fabricante/modelo de referência:** ainda não definido.

- **Uso pedagógico:** tornar visível a continuidade entre terminais e formar o caminho condutor.
- **Comportamento que o estudante deve reconhecer:** um fio conecta eletricamente os pontos de suas extremidades; fio ausente/solto abre o percurso; cor é apoio visual.

- **Observações visuais:** o asset atual aparenta fios jumper, mas não deve ser classificado definitivamente como macho-macho enquanto não houver decisão sobre compatibilidade física com os componentes e a bancada.
- **Status:** `EM_VALIDACAO`
- **Pendências:** definir o sistema físico de conexão/terminais da bancada e então confirmar ou substituir o asset.

## Relatório de validação

### Aprovados

- **BAT-001 — Bateria alcalina de 9 V.**
- **LED-001 — LED vermelho.**
- **SW-001 — Interruptor-faca SPST.**

### Em validação

- **RES-001 — Resistor de 680 Ω.** Novo asset correto; falta sincronizar o arquivo canônico no repositório.
- **WIRE-001 — Fios de conexão.** Função elétrica clara, mas tipo físico de conector ainda não fixado.

### Apoio pedagógico recomendado

Criar documentação complementar de componentes para as fases **Conhecer** e **Inspecionar**.

Para o LED, mostrar lado a lado:

- fotografia/asset;
- ânodo (A);
- cátodo (K);
- perna longa;
- perna curta;
- face plana do encapsulamento;
- símbolo esquemático;
- necessidade de resistor limitador;
- exemplo de orientação correta no circuito do Primeiro Stand.

Esse material deve apoiar a observação sem transformar o asset físico em um diagrama artificial.
