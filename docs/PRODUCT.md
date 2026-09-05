# Produto

## Visao

EletroLab e um jogo educacional de eletrica e eletronica para estudantes de aproximadamente 9 a 15 anos. Ele usa uma Feira de Ciencias escolar como contexto para demonstracoes, experimentos, bancadas e uma possivel maquete coletiva.

O produto aproxima objeto fisico, linguagem esquematica e comportamento eletrico sem se apresentar como ferramenta profissional de engenharia nem como instrucao para rede eletrica.

## Proposta de valor

O estudante reconhece componentes, observa circuitos, relaciona objetos a simbolos tecnicos, testa hipoteses, diagnostica falhas e construi solucoes progressivamente. A Bancada Livre e um ativo reutilizavel para experimentacao e para missoes com liberdade controlada.

O produto combina jogo guiado e experimentacao livre: a campanha oferece contexto e mediacao, enquanto a Bancada permite testar ideias quando a missao liberar essa liberdade. EletroLab usa codigo, textos, assets e identidade visual proprios; referencias externas inspiram comparacoes, nao sao conteudo a copiar.

## Contexto e vocabulario

O vocabulario ativo e Feira de Ciencias, estande, missao/fase, demonstracao, bancada, experimento, maquete, visitantes e equipe.

Professor Volts pode atuar como mediador de abertura, dica e reflexao, sem substituir a observacao e a acao do estudante.

## Tipos de experiencia

| Tipo | Relacao com o mundo fisico |
|---|---|
| Simulacao conceitual | Ensina dentro do jogo e nao precisa de reproducao fisica. |
| Inspirada em aplicacao real | Usa contexto e comportamento realistas, mas nao e roteiro de montagem. Um portao automatizado e exemplo possivel. |
| Projeto para a Feira Real | Pode ter versao fisica somente com baixa tensao, componentes adequados, circuito validado e instrucoes proprias de seguranca. |

Nem toda missao precisa ser reproduzivel fora do jogo.

## Seguranca e precisao

EletroLab representa circuitos virtuais e kits didaticos de baixa tensao. Nunca deve orientar manipulacao de rede residencial ou alta tensao.

Precisao eletrica tem prioridade sobre conveniencia visual. Antes de aprovar um componente fisico ou asset, registrar nome tecnico, tipo/subtipo, terminais, funcao dos terminais, faixa eletrica relevante, polaridade, simbolo tecnico, referencia real confiavel e papel pedagogico. A aparencia nao basta para identificar um componente.

LED exige polaridade e limitacao de corrente; tipos de interruptor nao sao intercambiaveis; rele precisa ser definido por seus terminais e comportamento; topologia determina serie/paralelo; `+` e `-` indicam polaridade/potencial, nao sentido da corrente.

O produto e local-first no estado atual: preferencias e progresso sao locais, sem backend ou sincronizacao em nuvem. Isso descreve o escopo atual, nao impede decisao futura explicitamente aprovada.

## Decisoes aprovadas

- A campanha e contextualizada como Feira de Ciencias.
- O Primeiro Estande segue Conhecer -> Inspecionar -> Representar -> Construir.
- Missoes de representacao usam circuito fisico ghost/faded sob o diagrama tecnico.
- A Bancada Livre deve ser evoluida/restringida quando adequada, nao substituida automaticamente por novo canvas.

## Decisoes abertas

- Quantidade e ordem final de missoes por estande.
- Avaliacao e estrelas, explicitamente em validacao.
- Quais missoes terao versao Projeto para a Feira Real.
- Escopo e subtipo tecnico do rele para a prova avancada.

## Governanca documental

Uma decisao nova deve atualizar o documento canonico responsavel pelo tema, e nao criar uma especificacao paralela. Produto e escopo pertencem a este documento.
