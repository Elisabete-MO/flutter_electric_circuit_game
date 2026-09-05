# EletroLab — Especificação detalhada dos circuitos

## Convenções de bancada

Todos os circuitos são de baixa tensão simulada. Um fio só conecta dois terminais visíveis; cruzamento visual não cria junção. Use estas abreviações:

- B+ e B−: polos de bateria/fonte.
- L1/L2: lâmpadas; LED A/K: ânodo/cátodo.
- S1: interruptor SPST; PB1: push-button normalmente aberto.
- M1: motor CC; R: resistor; RV1: potenciômetro.
- J: junção; F1: fusível; C1: capacitor; RL1: relé.

O motor identifica os dois terminais como M+ e M−. A troca dos fios muda seu sentido. O relé contém dois conjuntos isolados: bobina A1/A2 no circuito de comando e contato COM/NA no circuito de carga.

## Regras de validação

| Regra | Condição reconhecida pelo simulador | Feedback curto |
|---|---|---|
| Circuito aberto | Não há caminho completo B+ → carga → B− | “Ainda falta um trecho do percurso.” |
| Curto | B+ e B− são unidos sem uma carga no caminho | “A corrente desviou da carga: curto simulado.” |
| Polaridade invertida | LED/capacitor polarizado recebe sentido inverso | “Confira os terminais +/− ou A/K.” |
| Corrente insegura | LED sem resistor ou com resistência abaixo do limite | “O LED precisa de limitação de corrente.” |
| Topologia errada | Série quando a missão exige ramos independentes | “Cada carga precisa do próprio caminho.” |
| Erro de medição | Voltímetro em série ou amperímetro em paralelo à fonte | “Mude a posição do instrumento.” |

## 1. Acende Aí — circuitos de iluminação básica

| Missão | Circuito esperado | Passos de montagem | Teste e estados | Falhas relevantes |
|---|---|---|---|---|
| 1. Luz para a recepção | B+ → L1 → B− | Conectar um fio B+–L1.1 e outro L1.2–B−. | Testar: L1 acesa. | Aberto; curto B+–B−. |
| 2. Antes de testar | Mesmo circuito, com L1.2–B− ausente. | Escolher previsão e instalar o fio ausente. | Antes: apagada; depois: acesa. | Tentativa de unir polos não resolve a missão. |
| 3. Onde parou? | B+ → L1 → B− com uma abertura sorteada. | Medir continuidade por trecho e completar somente o elo aberto. | Continuidade muda de ausente para presente. | Alterar vários fios reduz nota de investigação. |
| 4. Duas luzes | Paralelo: B+ → J → L1/L2 → J → B−. | Criar duas junções e um ramo completo por lâmpada. | Remover L1 mantém L2 acesa. | Série apaga L2 ao remover L1. |
| 5. Recepção segura | Circuito de L1 correto, sem fio B+–B−. | Desconectar o fio de curto, manter L1 entre polos e demonstrar. | L1 acesa; alerta de curto desaparece. | Energizar antes da correção vale apenas pontuação parcial. |

## 2. Liga e Desliga — circuitos de comando simples

| Missão | Circuito esperado | Passos de montagem | Teste e estados | Falhas relevantes |
|---|---|---|---|---|
| 1. Interruptor | B+ → S1 → L1 → B−. | Colocar S1 no caminho e ligar seus dois terminais. | S1 aberto: L1 apagada; fechado: acesa. | S1 em paralelo não controla L1. |
| 2. Previsão de estado | Mesmo circuito, com S1 aberto ou fechado. | Alterar a alavanca e registrar previsão antes de testar. | O grafo fecha somente em S1 fechado. | Não há mudança de fios obrigatória nesta leitura de estado. |
| 3. Dois controles | Dois ramos: B+ → S1 → L1 → B− e B+ → S2 → L2 → B−. | Acionar uma chave por vez e etiquetar cada par. | Apenas sua própria lâmpada responde. | Acionar ambas ao mesmo tempo não produz evidência suficiente. |
| 4. Chave no desvio | Montagem inicial B+ → L1 → B− e S1 em ramo paralelo inútil. | Remover S1 do desvio e inserir B+ → S1 → L1 → B−. | Aberta interrompe L1. | Chave continua sem efeito se ficar fora do ramo. |
| 5. Botão de chamada | B+ → PB1 → L1 → B−. | Inserir PB1 e manter pressionado durante teste. | Pressionado: acesa; solto: apagada. | SPST não cumpre comportamento momentâneo. |

## 3. Ruas da Maquete — série, paralelo e manutenção

| Missão | Circuito esperado | Passos de montagem | Teste e estados | Falhas relevantes |
|---|---|---|---|---|
| 1. Primeiro poste | B+ → Poste1 → B−. | Conectar os dois terminais do poste. | Poste iluminado. | Circuito aberto. |
| 2. Comparação | Série: B+ → Poste1 → Poste2 → B−; paralelo: dois ramos completos. | Montar, testar e desmontar/reconfigurar as duas versões. | Em paralelo, retirada de Poste1 mantém Poste2. | Não confundir bifurcação com cruzamento de fios. |
| 3. Casa em manutenção | Ramo da casa: B+ → S1 → Casa1 → B−, em paralelo aos demais. | Instalar S1 apenas no ramo da casa. | S1 aberto isola Casa1. | S1 geral desliga toda a rede. |
| 4. Bairro | Quatro ramos paralelos: Casa1, Casa2, Poste1, Poste2. | Criar barramento positivo e negativo por junções; fechar cada ramo. | Todas as quatro cargas respondem individualmente. | Retorno compartilhado incompleto cria aberto. |
| 5. Demonstração | Circuito da missão 4. | Abrir S1 ou remover uma lâmpada e apontar os outros ramos energizados. | Restante continua ativo. | Explicação precisa mencionar ramos. |

## 4. Letreiros de LED — polaridade e corrente

| Missão | Circuito esperado | Passos de montagem | Teste e estados | Falhas relevantes |
|---|---|---|---|---|
| 1. Saída | B+ → R680 → LED A; LED K → B−. | Inserir resistor e LED em série; orientar A para positivo. | LED acende com brilho normal. | Sem R; LED K no positivo. |
| 2. LED invertido | Mesmo circuito, LED inicialmente K ← R680. | Registrar hipótese, girar LED 180° e testar. | Apagado antes; aceso depois. | Trocar fonte não é correção válida. |
| 3. Diagnóstico | Uma falha entre fio aberto, LED invertido e resistor desconectado. | Inspecionar terminais e medir tensão nos pontos relevantes. | Uma evidência elimina cada hipótese. | Trocas sem medição não dão nota máxima. |
| 4. Escolha do resistor | B+ → R escolhido → LED → B−. | Instalar 68 Ω, 680 Ω e 6,8 kΩ separadamente. | 68 Ω inseguro; 680 Ω adequado; 6,8 kΩ fraco. | Corrente insegura bloqueia demonstração. |
| 5. Duas placas | Dois ramos, cada um R680 + LED. | Montar Entrada e Saída com resistor próprio. | Remover uma não apaga a outra. | Um resistor compartilhado não atende ao objetivo. |

## 5. Movimento em Miniatura — motor, botão e indicador

| Missão | Circuito esperado | Passos de montagem | Teste e estados | Falhas relevantes |
|---|---|---|---|---|
| 1. Ventilador | B+ → M1+; M1− → B−. | Ligar os dois terminais do motor à fonte. | M1 gira no sentido padrão. | Terminal solto. |
| 2. Carrinho | Mesma topologia; polaridade alternada. | Trocar os dois fios de M1. | A rota muda para frente/ré. | Apenas mover um fio cria aberto. |
| 3. Diagnóstico | Circuito de motor com um mau contato em fonte, S1 ou M1. | Medir/testar em plano: fonte → chave → motor. | Falha identificada sem trocar componentes ao acaso. | Curto não é reparo. |
| 4. Motor sob comando | B+ → PB1 → M1 → B−; ramo paralelo B+ → R → LED → B− após PB1. | Inserir PB1 antes da bifurcação; criar ramo de LED protegido. | PB1 pressiona: motor gira e LED acende. | LED direto na fonte; LED fora do controle. |
| 5. Demonstração | Circuito da missão 4 com fios do motor reversíveis. | Visitante segura PB1; jogador troca polaridade para direção solicitada. | Movimento e indicador acompanham comando. | Soltar PB1 precisa parar ambos. |

## 6. Mede, Testa e Explica — medição correta

| Missão | Circuito esperado | Passos de montagem | Teste e estados | Falhas relevantes |
|---|---|---|---|---|
| 1. Tensão da bateria | Voltímetro V+ em B+, V− em B−. | Prender ponteiras em paralelo, sem abrir o circuito. | Aproximadamente 9 V. | Voltímetro em série. |
| 2. Queda na carga | Voltímetro entre os terminais de L1/LED. | Mover as ponteiras para os dois lados da carga. | Exibe a queda de tensão da carga. | Ponteiras no mesmo nó: 0 V. |
| 3. Corrente | B+ → amperímetro → RV1 → carga → B−. | Abrir fio, inserir amperímetro e girar RV1. | Corrente varia e é registrada. | Amperímetro em paralelo à fonte. |
| 4. Resistor por medida | Circuito LED com amperímetro em série. | Trocar resistor, testar e comparar corrente. | Valor seguro mantém brilho visível. | Retirar resistor causa corrente insegura. |
| 5. LED fraco | Fonte, R, LED e voltímetro/amperímetro. | Coletar leituras que diferenciem bateria baixa, R alto e LED invertido. | Diário contém hipótese, medida e conclusão. | Conclusão sem evidência. |

## 7. Circuito Seguro — inspeção e proteção

| Missão | Circuito esperado | Passos de montagem | Teste e estados | Falhas relevantes |
|---|---|---|---|---|
| 1. Aprovação | Uma bancada válida e duas inválidas. | Percorrer os caminhos e aprovar somente a que contém carga. | Carimbo correto antes de energizar. | Curto e circuito aberto são reprovados. |
| 2. Fusível | B+ → F1 → carga → B−. | Inserir F1 antes da bifurcação do ramo principal. | Sobrecorrente simulada abre F1. | F1 em paralelo não protege. |
| 3. Ruptura | Um elo aberto em circuito simples. | Usar continuidade em sequência e instalar fio no elo. | Retorno de continuidade e carga ativa. | Ignorar teste reduz explicação. |
| 4. Carga sensível | B+ → R → carga → B−. | Comparar R disponível e medir/observar corrente. | Limite seguro respeitado. | R pequeno demais gera aviso. |
| 5. Vistoria final | Curto, polaridade invertida e F1 aberto presentes. | Desenergizar; remover curto; girar componente; trocar F1; testar. | Selo após três correções. | Testar antes da vistoria reduz segurança. |

## 8. Horta Monitorada — ajuste, sensor e capacitor

| Missão | Circuito esperado | Passos de montagem | Teste e estados | Falhas relevantes |
|---|---|---|---|---|
| 1. Brilho ajustável | B+ → RV1 → luz de cultivo → B−. | Girar RV1 até faixa de brilho solicitada. | Brilho e corrente mudam gradualmente. | RV1 em curto não controla. |
| 2. LDR | LDR ligado ao medidor/controlador. | Alterar cenário de luz e medir resistência em cada estado. | Mais luz reduz a resistência no modelo. | Medição fora dos terminais do LDR. |
| 3. Diagnóstico | LDR + sensorController + lâmpada, com um erro definido. | Testar sensor, fios e limiar. | Descobre conexão ou limiar errado. | Não revelar defeito sem teste. |
| 4. Anoitecer | LDR → sensorController → luz. | Conectar entradas/saída e ajustar limiar. | Evento noite liga a luz; dia a desliga. | Se houver transistor, ele deve ser item explícito. |
| 5. Capacitor e override | C1 em paralelo com LED; chave manual no comando do controlador. | Carregar C1, abrir chave, observar descarga; instalar override. | LED persiste brevemente; manual assume conforme regra definida. | C1 polarizado invertido. |

## 9. Portão da Escola — relé, comando e carga

| Missão | Circuito esperado | Passos de montagem | Teste e estados | Falhas relevantes |
|---|---|---|---|---|
| 1. Bobina | Controle: 5V+ → PB1 → RL1 A1; RL1 A2 → 5V−. | Ligar somente botão, fonte 5 V e bobina. | Pressionar PB1 energiza RL1. | Não ligar motor à bobina. |
| 2. Previsão | Controle acima; carga separada. | Etiquetar componentes e prever qual circuito muda. | Só o contato da carga muda por efeito da bobina. | Fio comum entre fontes invalida separação. |
| 3. Diagnóstico | Falha única em PB1/bobina ou contato/motor. | Testar estado da bobina; depois continuidade/energia na carga. | Define lado de comando ou de carga. | Testar todos os componentes ao acaso. |
| 4. Alerta NA | Carga: Vcarga+ → RL1 COM/NA → R → LED → Vcarga−. | Ligar LED protegido ao contato normalmente aberto. | LED acende apenas com bobina energizada. | LED sem resistor. |
| 5. Portão integrado | Controle da missão 1; carga com motor e LED em paralelo protegido. | Montar os dois grafos isolados e demonstrar PB1. | RL1 comuta motor/LED sem unir os circuitos. | Conectar bobina e carga no mesmo nó. |

## 10. Praça da Maquete Coletiva — integração

| Missão | Circuito esperado | Passos de montagem | Teste e estados | Falhas relevantes |
|---|---|---|---|---|
| 1. Três casas | Barramentos B+/B− e três ramos de casa protegidos. | Montar e testar cada ramo antes de seguir. | Cada casa é independente. | Série entre casas. |
| 2. Chave geral | B+ → Sgeral → junção → ramos de postes → B−. | Inserir chave antes da distribuição e montar ramos. | Sgeral controla todos os postes. | Sgeral em só um ramo. |
| 3. Módulos | Horta e portão como subcircuitos válidos. | Executar checklist local e só então conectar alimentação de cada módulo. | Integração não propaga falha. | Ignorar módulo não validado. |
| 4. Eventos simultâneos | Casas/postes + horta + portão com ramos/módulos independentes. | Acionar noite, PB do portão e manutenção de uma casa. | Três eventos coexistem. | Um único ramo que derruba tudo. |
| 5. Banca | Circuito integrado, com uma falha final sorteada. | Medir/inspecionar, reparar e justificar decisão. | Sistema recuperado e explicado. | Reparar sem desenergizar quando necessário. |