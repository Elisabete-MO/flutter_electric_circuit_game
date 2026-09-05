# Backlog do Projeto e Decisões em Aberto — EletroLab

Este documento registra as funcionalidades entregues, os estandes pendentes para implementação futura, as melhorias técnicas planejadas e os pontos que necessitam de confirmação.

---

## 📌 1. Estado Atual de Conclusão do Projeto

| Módulo / Estande | Status | Detalhes da Entrega |
|---|:---:|---|
| **Estande 01 — Primeiro Estande** | ✅ Concluído | Jornada de 4 fases (`FirstBenchFlowScreen`): Conhecer, Inspecionar, Representar e Construir. |
| **Tutorial — Primeiros Passos** | ✅ Concluído | Guia interativo aos 8 símbolos e componentes elétricos com quiz (`FirstStepsScreen`). |
| **Estande 02 — Acende Aí** | ✅ Concluído | Modularizado em 3 fases (`second_bench`): Inspeção de circuito, percurso e diagramas. |
| **Estande 03 — Liga e Desliga** | ✅ Concluído | Modularizado com 5 missões independentes (`lib/screens/liga_desliga/missions/`). |
| **Estande 04 — Ruas da Maquete** | ✅ Concluído | Modularizado com 5 missões e mapa vetorial urbano (`ruas_maquete_painter.dart`). |
| **Estande 05 — Letreiros de LED** | ✅ Concluído | Modularizado com 5 missões, painéis neon e resistores de 680 Ω (`letreros_led`). |
| **Estande 06 — Movimento em Miniatura**| ✅ Concluído | Modularizado com 5 missões, controle de rotação e hélices animadas (`movimento_miniatura`). |
| **Estande 07 — Mede, Testa e Explica** | ✅ Concluído | Modularizado com 5 missões, pontas de prova virtuais e Lei de Ohm (`mede_testa_explica`). |
| **Bancada Livre (Sandbox)** | ✅ Concluído | Laboratório completo com Multímetro 9000, Osciloscópio, Manhattan Routing e física de queima. |
| **Configurações e Acessibilidade** | ✅ Concluído | Temas Claro/Escuro, redutor de animações, alto contraste e escala de interface. |

---

## 🚀 2. Próximas Implementações (Estandes 08 a 10)

### Estande 08 — "Horta Monitorada" (Equipe Ambiente)
* **Objetivo**: Ensinar o conceito de sensores analógicos de luz (LDR), ajuste de sensibilidade e amortecimento com capacitor.
* **Componentes necessários**:
  * `ldr` (Light Dependent Resistor / Fotoresistor com controle de luminosidade de ambiente: Sol, Penumbra, Noite).
  * `potentiometer` (Ajuste de sensibilidade de disparo).
  * `capacitor` (Demonstração didática de descarga suave e retenção de carga).
* **Missões previstas**:
  1. `m1`: Controle de brilho da lâmpada de cultivo com potenciômetro.
  2. `m2`: Previsão e medição da variação da resistência do LDR sob diferentes intensidades de luz.
  3. `m3`: Circuito com sensor disparando iluminação ao cair da noite.
  4. `m4`: Carregamento e retenção temporária com capacitor.
  5. `m5`: Integração do sistema automático com chave de bypass manual para os visitantes.

### Estande 09 — "Portão da Escola" (Equipe Automação)
* **Objetivo**: Introduzir o conceito de isolamento elétrico entre circuito de comando (baixa tensão e corrente) e circuito de potência/carga.
* **Componentes necessários**:
  * `relay` (Relé didático com bobina $A_1/A_2$ e contatos normalmente aberto $NA$ e comum $COM$).
  * `push_button` (Botão de acionamento do porteiro).
  * `motor_heavy` (Motor com torque para movimentação do portão da maquete).
  * `status_led` (Sinalização luminosa de abertura).
* **Missões previstas**:
  1. `m1`: Acionamento da bobina de 5 V via botão de comando.
  2. `m2`: Mapeamento e separação visual entre circuito de comando e circuito de potência.
  3. `m3`: Acionamento do motor pelo contato normalmente aberto do relé.
  4. `m4`: Diagnóstico de falha distinguindo defeito na bobina de defeito na carga.
  5. `m5`: Demonstração completa de abertura e fechamento seguro do portão.

### Estande 10 — "Praça da Maquete Coletiva" (Todas as Equipes)
* **Objetivo**: Grande encerramento da Feira de Ciências, integrando todas as iluminações, estufas e portões construídos pelos estudantes.
* **Mecânica de Apresentação**:
  * Barramento principal de alimentação compartilhada da maquete comunitária.
  * Simulação de eventos simultâneos: anoitecer geral, visitante acionando o portão e uma das casas entrando em reparos.
  * Diálogo final comemorativo do Professor Volts e desbloqueio total de todos os componentes na Bancada Livre.

---

## 🧹 3. Débitos Técnicos e Melhorias de Engenharia

1. **Remoção de Dependência Legada**:
   - `flame: ^1.38.0` permanece listado no [`pubspec.yaml`](file:///home/amanda/flutter_electric_circuit_game/pubspec.yaml), porém sem nenhuma utilização ativa no código (o projeto usa `CustomPainter` nativo).
   - *Ação planejada*: Remover com segurança e executar `flutter pub get` após validação da equipe.
2. **Cobertura de Testes de Integração de Telas**:
   - Expandir a suíte de testes de integração para cobrir os fluxos completos de conclusão das 5 missões nos Estandes 3 a 7 (similar aos testes já existentes para os Estandes 1 e 2).
3. **Audiodescrição e Acessibilidade Sonora**:
   - Adicionar avisos semânticos para leitores de tela em eventos sonoros críticos (ex.: clique de chave, alarme de curto-circuito e aviso de sobrecarga).

---

## ❓ 4. Decisões em Aberto (A Confirmar)

* **[A CONFIRMAR] Rota do Estande 1 no Mapa Principal**:
  - Atualmente, no mapa principal (`lib/screens/home/home_screen.dart`), o card do Estande 1 navega para `Routes.firstSteps` (tutorial rápido de 8 símbolos).
  - Sugestão para validação: Avaliar se o card do Estande 1 no mapa deve navegar diretamente para a jornada em 4 fases `Routes.firstBench` (`FirstBenchFlowScreen`), mantendo o `FirstSteps` acessível via botão dedicado de tutorial na tela inicial.
* **[A CONFIRMAR] Transistor vs. Bloco Sensor Controlador**:
  - No Estande 8, para acionamento do relé ou LED pelo sensor LDR, confirmar se será modelado um componente visual de `transistor BJT` ou um bloco integrado simplificado `sensorController` (conforme sugerido em `EletroLab-especificacao-reformulada.md`).

---

## 🔗 Próximas Leituras

* [Visão Geral do EletroLab](visao-geral.md)
* [Requisitos Funcionais e Não Funcionais](requisitos.md)
* [Arquitetura Técnica](arquitetura.md)
