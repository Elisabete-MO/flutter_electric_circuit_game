# Documentação Oficial — EletroLab

Bem-vindo à central de documentação do **EletroLab**, seu laboratório virtual educacional de circuitos elétricos.

Esta base documental é a **fonte única de verdade** sobre requisitos, arquitetura, design de experiência, conteúdo pedagógico e decisões técnicas do projeto.

---

## 🧭 Mapa de Navegação da Documentação

```text
docs/
├── README.md                 # Este índice geral
├── visao-geral.md            # Proposta, público-alvo, objetivos e princípios pedagógicos
├── requisitos.md             # Requisitos funcionais (RF) e não-funcionais (RNF)
├── arquitetura.md            # Arquitetura em camadas, Riverpod, CustomPainter e persistência
├── ux-e-fluxos.md            # Telas, rotas nomeadas, ciclo da missão e atalhos de teclado
├── conteudo.md               # Catálogo dos 10 estandes, 50 missões, falas e rubricas
├── assets.md                 # Paleta de cores, componentes gráficos e efeitos de áudio
├── backlog.md                # Estandes pendentes (8 a 10), débitos e decisões a confirmar
└── referencias/              # Especificações aprofundadas e pesquisas científicas preservadas
    ├── README.md             # Índice das referências
    ├── bancada_livre.md      # Manual completo e instrumentação da Bancada Livre
    ├── circuitos_detalhados.md # Esquemas técnicos e passos de montagem de todas as missões
    ├── estande1_quatro_fases.md# Especificação detalhada da jornada de 4 fases do Estande 1
    ├── explicacoes_componentes.md # Fundamentação científica e didática dos 5 componentes
    └── testes.md             # Estratégia de testes e matriz de validação do solver
```

---

## 📚 Índice dos Documentos Principais

| Documento | Foco | Para quem é útil? |
|---|---|---|
| [`visao-geral.md`](visao-geral.md) | **Proposta e Princípios**<br>Objetivos educacionais, público (a partir de 9 anos), baixa tensão e premissa da feira escolar. | Educadores, designers de produto e novos contribuidores. |
| [`requisitos.md`](requisitos.md) | **Requisitos de Sistema**<br>Requisitos funcionais (RF01–RF20) e não funcionais (60 FPS, acessibilidade, offline-first). | Analistas de requisitos, desenvolvedores e QA. |
| [`arquitetura.md`](arquitetura.md) | **Arquitetura de Software**<br>Camadas do sistema, modularização dos estandes (`common_stand`), grafo DFS e Riverpod. | Desenvolvedores Flutter e engenheiros de software. |
| [`ux-e-fluxos.md`](ux-e-fluxos.md) | **UX, Telas e Interações**<br>Tabela oficial de rotas, ciclo de 5 etapas da missão e atalhos de teclado desktop. | Designers de interface, desenvolvedores frontend e QA. |
| [`conteudo.md`](conteudo.md) | **Conteúdo Pedagógico**<br>Os 10 estandes, matriz das 50 missões reformuladas, falas do Prof. Volts e rubrica de 3 pontos. | Roteiristas, educadores e implementadores de missões. |
| [`assets.md`](assets.md) | **Identidade Visual e Assets**<br>Tokens de cores, mapeamento de PNGs físicos, símbolos vetoriais e efeitos sonoros. | Designers visuais, ilustradores e integradores de mídia. |
| [`backlog.md`](backlog.md) | **Backlog e Decisões**<br>Estandes 08 a 10 (Horta, Portão, Maquete), débitos técnicos e itens a confirmar. | Product owners, tech leads e mantenedores. |
| [`referencias/`](referencias/README.md) | **Referências Aprofundadas**<br>Manuais extensos da Bancada Livre, circuitos detalhados, Estande 1 e pesquisas científicas. | Especialistas técnicos, físicos e desenvolvedores do solver. |

---

## 🔍 Como Consultar por Perfil de Trabalho

* **Vai implementar ou dar manutenção em uma tela de Estande?**
  1. Leia [`arquitetura.md`](arquitetura.md) para seguir o padrão de coordenador slim e missões modulares.
  2. Consulte [`conteudo.md`](conteudo.md) e [`referencias/circuitos_detalhados.md`](referencias/circuitos_detalhados.md) para os dados da missão e conexões esperadas.
  3. Verifique [`ux-e-fluxos.md`](ux-e-fluxos.md) para os contratos de navegação.

* **Vai mexer no motor de simulação ou na Bancada Livre?**
  1. Consulte [`arquitetura.md`](arquitetura.md) e o manual completo em [`referencias/bancada_livre.md`](referencias/bancada_livre.md).
  2. Valide as regras de física em [`requisitos.md`](requisitos.md) e os casos de teste em [`referencias/testes.md`](referencias/testes.md).

* **Vai escrever novos diálogos ou criar desafios pedagógicos?**
  1. Consulte [`visao-geral.md`](visao-geral.md) para alinhar o tom sem linguagem de magia/fantasia.
  2. Utilize a fundamentação científica de [`referencias/explicacoes_componentes.md`](referencias/explicacoes_componentes.md) para garantir precisão física.
  3. Siga o ciclo de 5 etapas documentado em [`conteudo.md`](conteudo.md).

---

## ⚡ Comandos Rápidos de Validação

```bash
# Validar análise estática
flutter analyze lib/ test/

# Executar a suíte de testes completa
flutter test
```
