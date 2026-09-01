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

## Interacao e acessibilidade

- Simbolos tecnicos devem ser visualmente distintos de componentes fisicos.
- O snap de simbolos deve ser generoso; precisao motora nao mede conhecimento.
- Oferecer alternativa tocar no simbolo -> tocar no destino quando aplicavel.
- Usar alvos grandes, teclado quando a plataforma permitir e informacao alem de cor.
- Respeitar alto contraste, texto redimensionavel, reducao de movimento e controles de audio.
- `+` e `-` indicam polaridade da fonte. Cores de fios sao apoio visual e nao substituem topologia ou simbolos.

## Teste e feedback

Testar nao equivale a entregar resposta. O fenomeno deve aparecer antes da explicacao: carga ativa/inativa, circuito aberto, polaridade incorreta, curto pedagogico ou outra consequencia compreensivel.

Feedback deve explicar causa e convidar a nova tentativa. Erro nao bloqueia aprendizagem. Particulas de energizacao sao metafora didatica; nao sao a fonte da verdade eletrica nem devem sugerir que carga desaparece em uma lampada.

## Profundidade progressiva

Para 9-11 anos, priorizar reconhecimento, caminho fechado, interruptor, causa e efeito e primeiros simbolos. Para 12-15, introduzir gradualmente serie/paralelo, grandezas, medicao, diagnostico, otimizacao e automacao. A diferenca e a profundidade da tarefa, nao uma identidade visual infantilizada.

## Avaliacao e estrelas - EM VALIDACAO

O formato definitivo sera decidido apos implementacao e observacao das primeiras missoes. Nenhuma missao e obrigada a ter drag-and-drop, previsao, experimento, overlay, pergunta ou tres estrelas.

Nao ha regra aprovada para numero de estrelas, telas, pontuacao, tempo, tentativas ou rubrica fixa. Principios vigentes: testar permite experimentar; feedback explica causa; erro nao bloqueia aprendizagem; velocidade e precisao motora nao sao criterios pedagogicos principais.

## Governanca documental

Uma decisao nova de aprendizagem ou interacao deve atualizar este documento, e nao criar uma especificacao paralela.
