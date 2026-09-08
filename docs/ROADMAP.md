# Roadmap

## 1. Objetivo

Este roadmap organiza a evolução do EletroLab a partir da base técnica existente até a experiência de produto definida para a Feira de Ciências.

Ele não substitui as especificações canônicas:

* `PRODUCT.md` define produto e escopo;
* `PEDAGOGY.md` define aprendizagem e interação;
* `CAMPAIGN.md` define campanha, estandes e progressão;
* `FIRST_STAND.md` define o Primeiro Estande;
* `PORTAO_DA_ESCOLA.md` define a prova avançada de arquitetura;
* `ARCHITECTURE.md` descreve o estado técnico atual;
* `REFERENCES.md` registra referências e evidências externas;
* `CODEBASE_AUDIT.md` é registro histórico congelado;
* este documento organiza **o trabalho ainda necessário**.

Quando uma tarefa altera comportamento já implementado, `ARCHITECTURE.md` deve ser atualizado depois que a alteração existir no código.

---

# 2. Estado de partida

A limpeza estrutural e documental do repositório foi concluída.

A aplicação atual já possui:

* runtime Flutter + Riverpod;
* navegação por rotas;
* experiências guiadas legadas ainda alcançáveis;
* Bancada Livre;
* representação física/realista e esquemática;
* edição de circuitos;
* fios entre terminais;
* DFS e MNA;
* `CircuitValidator`;
* `MissionCircuitBuilder`;
* persistência local por `SharedPreferences`;
* testes reais e `flutter analyze` verde.

Essa implementação é ponto de partida técnico, não especificação da campanha futura.

O estado atual também possui limitações elétricas conhecidas, principalmente em LED, diodo, motor, capacitor, potenciômetro, critérios de curto e componentes multipinos.

A evolução do produto deve reutilizar o que estiver tecnicamente válido sem perpetuar comportamentos fisicamente incorretos apenas por compatibilidade com código legado.

---

# 3. Princípios de execução

## 3.1 Precisão elétrica primeiro

Quando precisão elétrica e conveniência visual entrarem em conflito, preservar primeiro a precisão elétrica.

Consequentemente:

* componente não é identificado somente pela aparência;
* tipo e subtipo precisam ser conhecidos;
* terminais precisam corresponder ao dispositivo real representado;
* polaridade deve ser respeitada;
* LEDs exigem análise de polaridade e limitação de corrente;
* símbolos e componentes físicos precisam representar o mesmo dispositivo;
* série e paralelo dependem das conexões elétricas;
* `+` e `−` representam polaridade/potencial, não direção da corrente;
* cores de fios não substituem topologia;
* componentes multipinos não podem ser reduzidos artificialmente a dois terminais.

## 3.2 Fenômeno antes da explicação

Sempre que a missão envolver comportamento elétrico, o estudante deve observar primeiro a consequência relevante e depois receber a explicação causal.

## 3.3 Bancada existente antes de novo canvas

A Bancada Livre é um ativo técnico existente.

Missões que precisarem de montagem devem primeiro avaliar se podem reutilizar ou restringir essa infraestrutura antes de criar um editor paralelo.

## 3.4 Não bloquear todas as frentes pela estabilização completa

A estabilização elétrica pode ser distribuída entre integrantes do grupo.

Primeiro Estande, dicionário de assets, Hub e proof do relé podem avançar em paralelo quando suas dependências específicas estiverem satisfeitas.

Uma divergência técnica só bloqueia a missão que depende daquele comportamento.

## 3.5 Avaliação continua em validação

Não implementar como regra global sem nova decisão:

* três estrelas obrigatórias;
* quantidade fixa de estrelas;
* overlays obrigatórios;
* tempo;
* precisão motora;
* quantidade fixa de tentativas;
* rubrica universal;
* número fixo de missões por estande.

---

# 4. Frente 0 — Estabilização técnica

Esta frente reúne dívida técnica real do runtime atual.

As tarefas podem ser distribuídas independentemente quando possível.

## 4.1 Modelo de LED

### Problema

DFS, MNA, modelo de componente e missões não utilizam hoje uma interpretação única e coerente para LED.

### Trabalho

* definir o modelo didático aprovado;
* separar claramente tensão direta (`Vf`), corrente e qualquer aproximação resistiva;
* preservar polaridade;
* garantir limitação de corrente nos circuitos pedagógicos;
* revisar valores hardcoded;
* revisar comportamento de LED invertido;
* alinhar DFS, MNA, UI e validações de missão.

### Critério de aceite

O mesmo circuito não recebe conclusões eletricamente contraditórias conforme o solver escolhido.

Casos aprovados possuem testes explícitos.

---

## 4.2 Diodo

Revisar o comportamento atualmente divergente entre DFS e MNA.

Definir explicitamente o modelo didático utilizado e suas limitações.

Não apresentar uma aproximação numérica como curva física completa de um diodo real.

---

## 4.3 Curto-circuito

### Problema

DFS e MNA utilizam critérios diferentes para classificar curto.

### Trabalho

* definir o conceito pedagógico de curto usado pelo EletroLab;
* determinar comportamento seguro da simulação;
* alinhar as estratégias;
* garantir mensagens consistentes.

### Critério de aceite

Um mesmo circuito não muda de classificação apenas porque outro solver foi selecionado pela heurística interna.

---

## 4.4 Motor

Resolver a divergência entre o valor armazenado no componente e a resistência fixa utilizada atualmente pelos solvers.

Antes de alterar o código, definir qual modelo didático de motor CC pertence ao escopo do EletroLab.

Não inventar comportamento físico detalhado apenas para manter funcionalidades antigas.

---

## 4.5 Capacitor

O estado atual apresenta capacitância em µF, mas o solver utiliza aproximação resistiva fixa.

Antes de usar capacitor como conteúdo pedagógico, decidir entre:

1. implementar um modelo adequado ao fenômeno que se deseja ensinar;
2. restringir o componente a contextos onde seu comportamento elétrico não seja simulado;
3. remover temporariamente sua participação em missões simuladas.

Não ensinar `100 µF` como equivalente a uma resistência fixa.

---

## 4.6 Potenciômetro

Resolver a diferença entre:

* representação visual com `A`, `B` e `W`;
* modelo elétrico efetivo baseado apenas em `A/B`.

Esse trabalho deve contribuir para a arquitetura geral de componentes multipinos.

---

## 4.7 MissionCircuitBuilder

Revisar diferenças entre o helper de missões e o solver geral, incluindo:

* fontes reconhecidas;
* detecção de caminho fechado;
* interpretação de componentes;
* critérios de sucesso.

Evitar que uma missão considere correto um circuito que o runtime geral interpreta de outra forma.

---

## 4.8 Push-button / interruptores

O conteúdo legado menciona botão de pressão em pontos onde o modelo possui somente interruptor SPST genérico.

Definir explicitamente os tipos necessários antes de reutilizar essas missões.

Não tratar:

* SPST mantido;
* SPST momentâneo;
* SPDT;
* outros tipos de chave

como componentes equivalentes.

---

## 4.9 Referência quebrada `background2.png`

Investigar a referência ainda existente a `assets/stands/background2.png`.

Determinar qual asset era realmente pretendido ou eliminar a referência quando a nova navegação tornar esse caminho obsoleto.

Não inventar substituição apenas para eliminar erro visual.

---

## 4.10 Cobertura elétrica

Cada correção de comportamento elétrico deve incluir testes que expressem a regra aprovada.

Priorizar testes para:

* LED;
* circuito aberto;
* curto;
* polaridade;
* resistor;
* série/paralelo;
* motor quando seu modelo for aprovado;
* componentes multipinos quando introduzidos.

Testes existentes não devem ser enfraquecidos apenas para acomodar uma implementação nova.

---

# 5. Frente 1 — Dicionário técnico de componentes e assets

Criar um único catálogo canônico para decidir **quais assets podem ser usados, onde podem ser usados e quais características técnicas representam**.

Documento candidato:

```text
ASSETS.md
```

O objetivo não é apenas listar arquivos PNG.

O catálogo deve impedir que uma representação visual seja tratada como definição técnica do componente.

## 5.1 Registro de componente elétrico

Antes de um componente físico ser aprovado para uso em missão, registrar pelo menos:

| Campo                    | Conteúdo                                                   |
| ------------------------ | ---------------------------------------------------------- |
| Identificador interno    | ID usado pelo projeto                                      |
| Nome técnico             | Nome do componente                                         |
| Tipo/subtipo             | Ex.: SPST, LED vermelho, resistor fixo                     |
| Asset físico aprovado    | Arquivo/variante utilizada                                 |
| Estado visual            | Ex.: ligado/desligado, aberto/fechado                      |
| Número de terminais      | Quantidade real representada                               |
| Função dos terminais     | Papel de cada terminal                                     |
| Polaridade               | Quando aplicável                                           |
| Faixa elétrica relevante | Tensão, corrente, resistência ou outra grandeza pertinente |
| Símbolo correspondente   | Representação técnica usada                                |
| Modelo no runtime        | Como o solver/validador representa o dispositivo           |
| Referência real          | Fabricante, kit, laboratório ou fonte confiável            |
| Papel pedagógico         | Por que esse componente aparece                            |
| Uso autorizado           | Estando/fase/contexto em que pode aparecer                 |
| Limitações               | Simplificações ou comportamento ainda não suportado        |
| Status                   | aprovado / em validação / legado / não usar                |

## 5.2 Relação físico ↔ símbolo

Para cada componente usado em representação ghost:

```text
asset físico
      ↕
mesmo dispositivo
      ↕
símbolo técnico
```

A correspondência deve incluir terminais, polaridade e estado quando relevantes.

## 5.3 Assets de ambiente e interface

Assets que não representam componentes elétricos também devem registrar:

* identificador;
* arquivo;
* finalidade;
* tela/estande em que são usados;
* estado ou variante visual;
* relação com modo claro/escuro quando aplicável;
* status atual;
* substituições planejadas.

## 5.4 Imagens geradas por IA

Imagem gerada pode servir como referência visual.

Ela não é fonte técnica.

Se terminais, contatos, polaridade ou geometria funcional estiverem incorretos, o asset deve ser corrigido antes de ser aprovado.

## 5.5 Critério de conclusão

Nenhum novo componente físico entra em missão de campanha sem entrada válida no catálogo.

---

# 6. Frente A — Primeiro Estande: Acende Aí

`FIRST_STAND.md` é a autoridade desta frente.

O Primeiro Estande é a principal entrega introdutória.

Progressão:

```text
Conhecer
   ↓
Inspecionar
   ↓
Representar
   ↓
Construir
```

Circuito de referência:

```text
bateria 9 V
   ↓
interruptor SPST
   ↓
resistor 680 Ω
   ↓
LED vermelho
   ↓
retorno à bateria
```

Modelo didático de referência:

```text
Vfonte = 9 V
Vf_LED ≈ 2 V
R = 680 Ω

I ≈ (9 - 2) / 680
I ≈ 10,3 mA
```

Esse circuito deve ser validado no runtime antes da conclusão da fase Construir.

---

## A1 — Validar componentes e assets

Cadastrar no dicionário técnico:

* bateria de 9 V;
* interruptor SPST;
* resistor de 680 Ω;
* LED vermelho;
* fios;
* símbolos correspondentes.

Confirmar terminais, polaridade, estados visuais e referências reais adequadas.

---

## A2 — Conhecer

Implementar/revisar apresentação dos componentes com:

* nome;
* função;
* terminais;
* polaridade;
* símbolo;
* cuidado relevante.

O quiz introdutório é permitido como mecanismo local.

Ele não define o sistema global de avaliação.

---

## A3 — Inspecionar

Apresentar circuito físico já montado.

O estudante deve observar antes de energizar:

* presença dos componentes;
* caminho completo;
* estado do interruptor;
* polaridade do LED;
* resistor;
* conexões;
* ausência de curto pedagógico.

Falhas iniciais candidatas:

* LED invertido;
* circuito aberto;
* resistor inadequado ou ausente;
* caminho direto entre polos.

Somente utilizar uma falha quando o runtime puder representá-la corretamente.

---

## A4 — Representar

Implementar a mecânica pedagógica de ghost.

Requisitos:

* representação física permanece faded;
* diagrama permanece legível acima dela;
* símbolos são tecnicamente corretos;
* estudante associa símbolo ao componente;
* snap é semântico e generoso;
* precisão motora não é critério;
* símbolo domina visualmente depois do encaixe;
* componente físico e símbolo representam o mesmo dispositivo.

A técnica visual de sobreposição já existente pode ser reutilizada, mas não constitui sozinha essa mecânica.

---

## A5 — Construir

Reutilizar uma versão controlada da Bancada Livre.

Biblioteca candidata:

* bateria 9 V;
* SPST;
* LED vermelho;
* resistor 68 Ω;
* resistor 680 Ω;
* resistor 6,8 kΩ;
* fios.

Permitir:

* inserir;
* conectar;
* abrir/fechar interruptor;
* testar;
* corrigir;
* tentar novamente.

A validade depende das conexões, não da posição visual.

---

## A6 — Feedback

O fenômeno deve preceder a explicação.

Feedback deve:

* indicar consequência;
* explicar causa;
* permitir correção;
* não resolver automaticamente a missão.

Pistas seguem progressão de leve para procedural conforme `PEDAGOGY.md`.

---

## A7 — Critério de conclusão do Primeiro Estande

O estudante consegue:

* reconhecer os componentes;
* inspecionar o circuito;
* relacionar componente físico e símbolo;
* montar um circuito eletricamente válido;
* testar;
* corrigir erros simples;
* explicar ao menos o papel do caminho completo e do interruptor.

O sistema global de estrelas continua fora do critério de conclusão até decisão própria.

---

# 7. Frente B — Proof of Architecture do Relé

Esta frente deve avançar relativamente cedo.

Ela não precisa esperar a implementação de todos os demais estandes.

Objetivo principal:

> provar que a arquitetura do EletroLab consegue representar corretamente um componente que não cabe no modelo simples A/B.

`PORTAO_DA_ESCOLA.md` é a autoridade desta frente.

---

## B1 — Selecionar dispositivo real

Antes de implementar asset ou símbolo, identificar e validar um relé real apropriado.

Registrar no dicionário:

* fabricante/modelo;
* tipo/subtipo;
* quantidade de terminais;
* função de cada terminal;
* tensão nominal da bobina;
* corrente de bobina quando pertinente;
* contatos disponíveis;
* COM, NA/NO e NF/NC somente quando existirem no dispositivo escolhido;
* capacidade relevante;
* símbolo;
* referência confiável;
* papel pedagógico.

Não escolher relé pela aparência.

---

## B2 — Modelo multipinos

Evoluir a arquitetura A/B pelo menor mecanismo suficiente para representar corretamente o dispositivo validado.

A solução deve permitir distinguir:

* terminais da bobina;
* terminais dos contatos;
* estado interno;
* relação bobina energizada → mudança dos contatos.

Não unir eletricamente comando e carga apenas porque pertencem ao mesmo componente visual.

---

## B3 — Missão mínima

Primeiro slice candidato:

```text
circuito de comando
fonte → controle → bobina

bobina energizada
        ↓
mudança de contato

circuito de carga
fonte → contato → carga simples
```

A carga inicial pode ser uma luz de baixa tensão simulada.

Motor/portão não é requisito da primeira prova.

---

## B4 — Critério de aceite

* dispositivo fisicamente identificado;
* terminais corretos;
* símbolo correspondente;
* bobina e contatos modelados;
* comando e carga topologicamente distintos;
* mudança de contato testável;
* asset e runtime representam o mesmo dispositivo;
* testes cobrem estado energizado e não energizado.

---

# 8. Frente C — Hub da Feira e navegação da campanha

A campanha futura é uma Feira de Ciências organizada em estandes.

O Hub será a camada principal de navegação da campanha.

A estrutura legada de `StandData` não é autoridade para quantidade ou ordem final de estandes.

## C1 — Substituir progressivamente navegação legada

O Hub deve navegar para especificações de campanha, e não apenas reproduzir os números do mapa atual.

A migração deve preservar acesso funcional à Bancada Livre.

## C2 — Integração com progresso

Definir apenas quando necessário:

* estado disponível;
* concluído;
* próximo conteúdo;
* progresso do estande.

Não fixar estrelas ou quantidade de fases como requisito do Hub enquanto o sistema de avaliação estiver em validação.

## C3 — Primeiro destino real

O Hub deve ser integrado inicialmente ao Primeiro Estande bem acabado.

Não é necessário implementar todos os estandes antes de validar a navegação de campanha.

## C4 — Proof avançado

A missão de relé pode existir como frente avançada relativamente cedo, mesmo que os estandes intermediários ainda não estejam completos.

Isso é intencionalmente uma prova de arquitetura, não progressão pedagógica completa da campanha.

---

# 9. Frente D — Expansão da campanha

`CAMPAIGN.md` contém o banco atual de estandes e missões candidatas.

A expansão não deve ser interpretada como obrigação de implementar exatamente cinco missões por estande.

Estandes atualmente planejados incluem:

* Acende Aí;
* Liga e Desliga;
* Ruas da Maquete;
* Letreiros de LED;
* Movimento em Miniatura;
* Mede, Testa e Explica;
* Circuito Seguro;
* Horta Monitorada;
* Portão da Escola;
* possível Maquete Coletiva.

A ordem e quantidade finais continuam sujeitas a validação, exceto:

1. prioridade do Primeiro Estande;
2. execução relativamente precoce do proof do relé.

---

## D1 — Controle

Evoluir atividades de interruptor somente com tipos de chave corretamente definidos.

---

## D2 — Série, paralelo e ramificações

Validar topologia pelo grafo de conexões.

Experiência importante:

* duas cargas em paralelo;
* simulação de falha em uma carga;
* outra carga permanece energizada.

A independência deve resultar da topologia, não de posição ou cor dos fios.

---

## D3 — LEDs e proteção

Expandir somente depois da estabilização do modelo de LED.

Incluir:

* polaridade;
* resistor limitador;
* diagnóstico;
* ramos independentes quando apropriado.

---

## D4 — Movimento

Utilizar motor CC somente depois de definir o modelo didático necessário.

Não apresentar resistência arbitrária hardcoded como característica física do motor.

---

## D5 — Medição e diagnóstico

Expandir multímetro e atividades de medição conforme a confiabilidade dos valores produzidos pelo solver.

Medição deve ser evidência para raciocínio, não decoração de interface.

---

## D6 — Segurança didática

Trabalhar:

* circuito aberto;
* curto pedagógico;
* proteção;
* fusível quando tecnicamente validado.

Continuar exclusivamente em baixa tensão didática/simulada.

---

## D7 — Sensores e horta

Só introduzir componentes como sensores e capacitor depois de seus modelos serem definidos ou explicitamente classificados como simulação conceitual sem equivalente elétrico completo no runtime.

---

## D8 — Integração / Maquete Coletiva

A Maquete Coletiva permanece possibilidade de fechamento, não compromisso obrigatório.

Subsistemas só devem ser integrados depois de validados isoladamente.

---

# 10. Frente E — Projetos para a Feira Real

Nem toda missão precisa ter equivalente físico.

Antes de classificar uma missão como **Projeto para a Feira Real**, validar:

* baixa tensão;
* componentes reais apropriados;
* fonte adequada;
* corrente/tensão compatíveis;
* circuito reproduzível;
* instruções próprias;
* segurança;
* correspondência entre jogo e montagem física.

Missões que não cumprirem esses critérios permanecem:

* simulação conceitual; ou
* experiência inspirada em aplicação real.

Contextos como casa, clínica, rua, escola ou portão continuam sendo maquetes didáticas de baixa tensão.

---

# 11. Frente transversal — Acessibilidade e qualidade pedagógica

Cada nova missão deve verificar:

* alvos grandes;
* snap generoso quando houver drag;
* informação além de cor;
* contraste adequado;
* suporte a redução de movimento quando aplicável;
* texto legível;
* interação alternativa quando necessária;
* feedback causal;
* erro recuperável;
* precisão motora não utilizada como substituto de conhecimento.

Para missões de representação, o ghost deve permanecer legível inclusive em modos de maior contraste.

---

# 12. Gate técnico para aprovação de uma nova missão

Antes de considerar uma missão pronta, verificar:

## Elétrica

* circuito coerente;
* topologia correta;
* fonte e carga compatíveis;
* polaridade correta;
* ausência de especificações inventadas;
* solver/validador representa o fenômeno necessário;
* resultados testados.

## Componentes/assets

* entradas correspondentes existem no dicionário;
* asset físico e símbolo representam o mesmo dispositivo;
* terminais correspondem;
* referência real registrada;
* status aprovado para aquela missão.

## Pedagogia

* objetivo observável;
* atividade adequada à habilidade;
* feedback causal;
* pistas não entregam resposta antecipadamente;
* erro permite nova tentativa.

## Interface

* interação acessível;
* hitboxes adequadas;
* fios e junções legíveis;
* ghost não compete com o esquema quando presente.

## Testes

* comportamento principal;
* falhas relevantes;
* regressões elétricas;
* estados de interação essenciais.

---

# 13. Prioridade operacional

A ordem recomendada de trabalho é:

```text
BASE LIMPA
    ↓
Frente 0 — estabilização elétrica necessária
    +
Frente 1 — dicionário de componentes/assets
    ↓
Frente A — Primeiro Estande bem acabado
    ↘
     Frente B — proof multipinos do relé
    ↘
     Frente C — Hub da Feira
    ↓
Frente D — expansão progressiva
    ↓
Frente E — projetos físicos selecionados / integração
```

As Frentes B e C podem avançar em paralelo ao acabamento do Primeiro Estande quando suas dependências estiverem disponíveis.

Não é necessário concluir toda a Frente 0 antes de qualquer desenvolvimento.

---

# 14. Decisões ainda abertas

Continuam explicitamente abertas:

* sistema definitivo de avaliação;
* estrelas;
* quantidade final de missões por estande;
* ordem final completa dos estandes;
* quais missões serão reproduzíveis fisicamente;
* subtipo/modelo do relé;
* escopo final da Maquete Coletiva;
* profundidade elétrica de sensores e capacitor;
* evolução futura do solver além do necessário para o produto.

Decisão aberta não deve ser silenciosamente transformada em requisito de implementação.

---

# 15. Regra de atualização

Atualizar este roadmap quando:

* uma frente for concluída;
* uma dependência mudar;
* uma decisão de produto deixar de ser aberta;
* uma limitação técnica for resolvida;
* nova evidência exigir mudança de prioridade.

Não registrar aqui detalhes históricos que pertencem ao Git ou ao `CODEBASE_AUDIT.md`.

Não criar outro roadmap concorrente.

---

# 16. Definição de avanço

O EletroLab estará pronto para escalar a campanha quando houver evidência de que:

1. o Primeiro Estande ensina corretamente seu circuito de referência;
2. componentes e assets usados possuem identidade técnica rastreável;
3. representação física e símbolo correspondem ao mesmo dispositivo;
4. Bancada controlada consegue suportar a construção introdutória;
5. correções elétricas necessárias ao conteúdo implementado possuem testes;
6. o modelo multipinos foi provado por pelo menos uma missão avançada tecnicamente válida;
7. o Hub consegue navegar pela campanha sem depender da estrutura legada;
8. novas missões podem ser adicionadas sem reintroduzir inconsistências elétricas ou documentação concorrente.
