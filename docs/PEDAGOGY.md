# Pedagogia e Interacao

## Principio central

O percurso de aprendizagem e:

```text
componente fisico -> representacao esquematica -> comportamento -> compreensao
```

O estudante nao deve apenas acertar um encaixe nem ser jogado diretamente em uma bancada aberta. A experiencia combina observacao, representacao, teste, diagnostico, correcao e, quando fizer sentido, previsao, explicacao ou transferencia.

## Primeiro ciclo introdutorio

```text
Conhecer -> Inspecionar -> Representar -> Construir
```

- **Conhecer:** nome, funcao, terminais, polaridade, cuidado e simbolo.
- **Inspecionar:** observar um circuito pronto antes de energiza-lo.
- **Representar:** traduzir objeto fisico para simbolo tecnico.
- **Construir:** aplicar o conhecimento em bancada controlada, testar e corrigir.

Diagnosticar e uma familia adicional de missao: localizar e explicar por que uma demonstracao nao atende ao objetivo.

## Circuito fisico ghost sob o diagrama

Este e um requisito explicito das missoes de representacao.

1. O circuito fisico/2.5D permanece visivel na area de montagem.
2. Ele tem opacidade, contraste e saturacao reduzidos para funcionar como referencia ghost/faded.
3. O diagrama e seus fios permanecem legiveis acima dessa referencia.
4. O estudante posiciona simbolos tecnicos sobre os componentes fisicos correspondentes.
5. O simbolo se torna visualmente dominante apos o encaixe.

```text
simbolo tecnico
       ^
diagrama legivel
       ^
circuito fisico faded / ghost
```

O objetivo e conectar realidade fisica e linguagem tecnica, nao esconder o objeto e mostrar lacunas vazias. A arquitetura atual da Bancada ja possui sobreposicao fisica atenuada sob simbolos, conforme documentado em `ARCHITECTURE.md`.

## Ghost, diagramas e qualidade visual

O componente fisico e o simbolo precisam representar exatamente o mesmo dispositivo. O ghost preserva terminais reconheciveis, mas nao compete com o diagrama: opacidade e contraste devem ser reduzidos sem apagar a referencia. Fios esquematicos, juncoes e cruzamentos precisam continuar legiveis.

Em alto contraste, a diferenca entre ghost e simbolo nao pode depender somente de opacidade: usar tambem contorno, textura ou espessura. O apoio ghost pode reduzir progressivamente quando a competencia for dominada, sem eliminar a identidade visual da mecanica.

## Snap, alvos e acessibilidade

- Simbolos tecnicos devem ser visualmente distintos de componentes fisicos.
- Cada componente ghost e um alvo semantico para o simbolo correspondente.
- A hitbox e maior que a silhueta; ao entrar na area valida, o alvo recebe destaque sutil e o simbolo centraliza ao soltar.
- O snap de simbolos deve ser generoso; precisao motora nao mede conhecimento.
- Oferecer alternativa tocar no simbolo -> tocar no destino quando aplicavel.
- Usar alvos grandes, teclado quando a plataforma permitir e informacao alem de cor.
- Respeitar alto contraste, texto redimensionavel, reducao de movimento e controles de audio.
- `+` e `-` indicam polaridade da fonte. Cores de fios sao apoio visual e nao substituem topologia ou simbolos.

O snap de simbolo e pedagogico e semantico; ele nao deve ser confundido com o snap espacial de terminais/fios da Bancada.

## Evitar encaixe de forma

O ghost e apoio concreto, nao resposta visual pronta. Simbolos tecnicos nao devem imitar a silhueta do objeto; nomes nao devem aparecer junto ao alvo quando entregarem a resposta; distratores plausiveis podem ser usados quando adequados; e a orientacao fisica do componente pode variar sem mudar seu simbolo esperado. Algumas fases podem permitir encaixe provisoriamente incorreto para posterior diagnostico.

## Teste e feedback

Testar nao equivale a entregar resposta. O fenomeno deve aparecer antes da explicacao: carga ativa/inativa, circuito aberto, polaridade incorreta, curto pedagogico ou outra consequencia compreensivel.

Feedback deve explicar causa e convidar a nova tentativa. Erro nao bloqueia aprendizagem. Particulas de energizacao sao metafora didatica; nao sao a fonte da verdade eletrica nem devem sugerir que carga desaparece em uma lampada.

Antes de uma previsao ou verificacao conceitual, o texto de apoio nao deve entregar a resposta. A explicacao completa vem depois da observacao do fenomeno.

## Pistas recomendadas

Quando uma missao oferecer pistas, usar uma escada progressiva, sem obrigar todas as etapas:

1. **Leve:** chama atencao ao fenomeno.
2. **Focal:** destaca regiao, terminal ou ramo relevante.
3. **Conceitual:** relembra a ideia eletrica envolvida.
4. **Procedural:** indica a proxima acao ou alvo a observar.
5. **Demonstracao parcial:** mostra somente o proximo passo necessario.

Pedir ajuda nao deve bloquear progresso.

## Familias de missao

| Familia | Acao central |
|---|---|
| Conhecer | Reconhecer componente, funcao, terminais e simbolo. |
| Inspecionar | Observar circuito pronto antes de energizar. |
| Representar | Associar objeto fisico e simbolo tecnico. |
| Construir | Posicionar, conectar, testar e corrigir. |
| Prever | Antecipar comportamento antes do teste. |
| Testar | Energizar e observar consequencia. |
| Diagnosticar | Localizar causa de falha. |
| Corrigir | Alterar estado, componente ou conexao inadequada. |
| Comparar | Contrastar topologias ou resultados. |
| Medir | Escolher instrumento/pontos e interpretar leitura. |
| Inferir | Deduzir componente ou valor a partir do comportamento. |
| Otimizar | Cumprir objetivo com restricao. |
| Transferir | Aplicar conceito em situacao nova. |

Uma missao nao precisa usar todas essas familias. Falhas candidatas para diagnostico incluem fio interrompido, interruptor aberto, componente incorreto, curto pedagogico e instrumento conectado de modo inadequado.

## Validacao e qualidade de fase

Ha duas validacoes distintas: **representacao**, que verifica a associacao simbolo -> componente fisico; e **conceitual/funcional**, que pode verificar previsao, teste de falha, medicao, topologia, explicacao ou transferencia. Acertar um simbolo nao prova sozinho compreensao eletrica.

Antes de aprovar uma fase, conferir:

- circuito de referencia eletricamente coerente;
- simbolos tecnicos e topologia correspondentes ao circuito;
- ghost perceptivel sem esconder diagrama nem entregar resposta;
- alvos e snap acessiveis e independentes de precisao motora;
- polaridade e juncoes legiveis;
- fenomeno e feedback causal coerentes com o estado eletrico;
- particulas apresentadas como metafora, nao como fisica literal;
- uso viavel em celular, tablet e desktop.

## Profundidade progressiva

Para 9-11 anos, priorizar reconhecimento, caminho fechado, interruptor, causa e efeito e primeiros simbolos. Para 12-15, introduzir gradualmente serie/paralelo, grandezas, medicao, diagnostico, otimizacao e automacao. A diferenca e a profundidade da tarefa, nao uma identidade visual infantilizada.

## Avaliacao e estrelas - EM VALIDACAO

O formato definitivo sera decidido apos implementacao e observacao das primeiras missoes. Nenhuma missao e obrigada a ter drag-and-drop, previsao, experimento, overlay, pergunta ou tres estrelas.

Nao ha regra aprovada para numero de estrelas, telas, pontuacao, tempo, tentativas ou rubrica fixa. Principios vigentes: testar permite experimentar; feedback explica causa; erro nao bloqueia aprendizagem; velocidade e precisao motora nao sao criterios pedagogicos principais.

### Exemplos ja discutidos, ainda nao aprovados

Propostas anteriores separavam evidencias de funcionamento, restricao de projeto e compreensao, por exemplo com previsao, teste de falha e explicacao/transferencia em uma mesma missao. Esses exemplos sao repertorio para testes de produto, nao um sistema obrigatorio de estrelas, overlays ou pontuacao.

## Governanca documental

Uma decisao nova de aprendizagem ou interacao deve atualizar este documento, e nao criar uma especificacao paralela.
