# Requisitos do Sistema — EletroLab

Este documento consolida os Requisitos Funcionais (RF) e Não Funcionais (RNF) do projeto EletroLab, definindo o comportamento esperado da plataforma de simulação e da campanha pedagógica.

---

## 📋 Requisitos Funcionais (RF)

### 1. Navegação e Campanha (Feira de Ciências)
* **RF01 — Mapa da Feira**: O sistema deve apresentar um mapa/lista de navegação exibindo os 10 estandes temáticos da Feira de Ciências, com nome da equipe, conceito científico, progresso de missões (`X/5`) e selo de conclusão.
* **RF02 — Desbloqueio Progressivo de Estandes**: Um estande deve ser desbloqueado para o aluno assim que o estande imediatamente anterior atingir pelo menos 4 missões concluídas. A *Praça da Maquete Coletiva* requer 4 missões em todos os 9 estandes anteriores.
* **RF03 — Estrutura de Missão em 5 Etapas**: Cada estande deve possuir 5 missões obrigatórias seguindo o ciclo pedagógico:
  1. `prepare`: Introdução prática e contextualizada ao problema.
  2. `predict`: Registro da hipótese ou resultado esperado pelo aluno antes de energizar o circuito.
  3. `investigate`: Diagnóstico de falha por observação de percurso, teste de continuidade ou medição.
  4. `design`: Resolução de problema com restrição prática (ex.: independência de ramos ou dimensionamento de resistor).
  5. `demonstrate`: Apresentação do protótipo final perante os visitantes da feira sob eventos dinâmicos.
* **RF04 — Rubrica Formativa Tripla**: A avaliação de cada missão deve registrar pontuações independentes (de 1 a 3 pontos) para:
  * **Funciona**: Cumprimento do objetivo elétrico do circuito.
  * **Está seguro**: Prevenção ativa de curto-circuito, sobretensão ou danos a componentes.
  * **Consegue explicar**: Justificativa da escolha fundamentada em previsões, observações ou dados medidos.
* **RF05 — Diálogos do Professor Volts**: O mascote deve apresentar fala de abertura da missão, fornecer dica curta quando solicitada (sem entregar a resposta pronta) e conduzir o fechamento conceitual após a conclusão.

### 2. Simulação Elétrica e Regras Físicas
* **RF06 — Validação de Percurso Fechado**: O motor de simulação deve reconhecer malhas elétricas fechadas partindo do polo positivo da fonte e retornando ao polo negativo. Cargas elétricas só devem ser ativadas quando o percurso estiver completo.
* **RF07 — Controle por Chaves e Interruptores**:
  * Chave SPST aberta deve interromper o percurso da corrente no ramo.
  * Chave SPST fechada deve permitir a passagem da corrente.
  * Push-button (botão de pulso) só deve conduzir enquanto estiver ativamente pressionado pelo usuário.
* **RF08 — Diferenciação Série vs. Paralelo**:
  * Em circuitos em série, a interrupção de um componente deve interromper todo o percurso e a tensão da fonte deve ser dividida proporcionalmente entre as cargas.
  * Em circuitos em paralelo, a desconexão ou falha de uma carga não deve afetar os ramos independentes conectados à fonte.
* **RF09 — Polaridade e Semicondutores**:
  * Diodos e LEDs só devem conduzir quando diretamente polarizados (ânodo no potencial maior, cátodo no menor).
  * Motores de corrente contínua devem inverter o sentido de rotação mecânica quando os terminais de alimentação forem invertidos.
* **RF10 — Detecção de Curto-Circuito**: Conexões diretas entre terminais de uma fonte que ignorem as cargas do circuito (com resistência equivalente $R_{eq} \le 0,1\ \Omega$) devem pausar a energização, acionar aviso sonoro/visual de curto didático e impedir o avanço sem danificar virtualmente o app.
* **RF11 — Sistema de Sobrecarga e Queima (Burnout)**:
  * LEDs submetidos a $I > 50\text{ mA}$ ou $V > 3,3\text{ V}$ devem ser registrados em `burnedComponentIds` com efeito visual de ruptura e fumaça.
  * Lâmpadas submetidas a $P > 15\text{ W}$ devem romper o filamento incandescente.
  * Motores submetidos a $V > 18\text{ V}$ devem ter suas bobinas danificadas por sobretensão.
  * Componentes queimados devem atuar imediatamente como circuito aberto até serem reparados.

### 3. Bancada Livre (Sandbox) e Ferramentas
* **RF12 — Manipulação Livre de Componentes**: A bancada deve permitir arrastar, soltar, mover em lote, rotacionar em 90° e excluir componentes (bateria, fonte ajustável, resistor, potenciômetro, lâmpada, LED, interruptor, push-button, motor, fusível, buzzer e capacitor).
* **RF13 — Fiação com Atração Magnética (Snap)**: Ao arrastar um condutor a partir de um borne, bornes próximos a uma distância de até 60 px devem atrair a ponta do fio e acender auréola neon indicativa.
* **RF14 — Dualidade Visual Físico / Esquemático**: A interface deve permitir alternar instantaneamente entre a visualização realista 3D e o diagrama técnico padronizado (NBR/IEEE).
* **RF15 — Roteamento Ortogonal de Fios (Manhattan Routing)**: No modo diagrama esquemático, os fios devem ser traçados com cantos retos de 90° e desviar por baixo dos componentes da bancada, sem cruzar sobre seus corpos.
* **RF16 — Instrumentos de Medição Virtuais**:
  * **Multímetro Digital**: Ponteiras vermelha (+) e preta (-) aplicáveis em quaisquer terminais para medição de diferença de potencial ($\text{V}$), corrente ($\text{mA}/\text{A}$) e resistência ôhmica ($\Omega$).
  * **Osciloscópio HUD**: Leitura gráfica contínua do sinal de tensão/corrente ao longo do tempo.
* **RF17 — Histórico de Ações (Undo / Redo)**: A bancada deve manter uma pilha de até 30 snapshots históricos para desfazer e refazer ações via botões da interface ou atalhos de teclado (`Ctrl+Z` / `Ctrl+Y`).
* **RF18 — Carregador de Presets e Desafios Rápidos**: O usuário deve poder carregar modelos pré-configurados de circuitos para teste rápido e resolução de problemas diagnósticos.

### 4. Configurações e Persistência
* **RF19 — Persistência Local 100% Offline**: Configurações gerais, progresso da Feira de Ciências e estado da Bancada Livre devem ser salvos em tempo real via `SharedPreferences`, sem necessidade de conexão com a internet ou autenticação de usuário.
* **RF20 — Redefinição e Limpeza Segura**: O usuário deve poder restaurar as preferências padrão de configuração ou reiniciar o progresso da campanha de forma explícita e controlada.

---

## ⚙️ Requisitos Não Funcionais (RNF)

| Identificador | Requisito | Critério de Aceitação |
|---|---|---|
| **RNF01** | **Desempenho Visual** | A simulação física e a animação do fluxo de elétrons devem rodar a **60 FPS estáveis**. As camadas de animação devem ser isoladas por `RepaintBoundary` para não disparar re-renderizações desnecessárias da tela inteira. |
| **RNF02** | **Multiplataforma e Responsividade** | A aplicação deve operar de forma fluida em telas mobile pequenas (mínimo **360 × 740 px**), tablets e desktops widescreen até resolução 4K. |
| **RNF03** | **Acessibilidade Visual** | O sistema deve suportar: alternância entre **Tema Claro** e **Tema Escuro**; modo de **Alto Contraste**; controle de **Redução de Movimento** (diminui animações intensas de elétrons e giros); e **Escala Linear de Interface** ajustável via slider. |
| **RNF04** | **Internacionalização (i18n)** | Todos os textos da interface devem ser extraídos para arquivos `.arb` de internacionalização, suportando nativamente **Português (pt)** e **Inglês (en)** com alternância instantânea. |
| **RNF05** | **Arquitetura Desacoplada** | O motor elétrico de resolução de malhas e cálculo de grandezas deve residir em camada de domínio/controlador independente de widgets ou do motor visual `CustomPainter`, permitindo testes 100% isolados. |
| **RNF06** | **Qualidade de Código e Testabilidade** | O projeto deve manter **0 erros e 0 alertas** no comando `flutter analyze lib/ test/` e garantir que toda a suíte de testes (`flutter test`) passe com 100% de sucesso sem regressões. |
| **RNF07** | **Segurança Pedagógica** | Nenhum componente, texto, asset ou diálogo deve descrever ou orientar o manuseio de tomadas, disjuntores residenciais ou tensões superiores a 30 V CC. |

---

## 🔗 Próximas Leituras

* [Arquitetura Técnica e Módulos](arquitetura.md)
* [Telas, UX e Fluxos de Navegação](ux-e-fluxos.md)
* [Conteúdo: Estandes, Missões e Rubricas](conteudo.md)
