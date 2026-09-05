# Interface e Interação (EletroLab v1.0.0)

## Menu Inicial (Fase 1 — Concluída)

Quatro opções principais com navegação fluida e estética Cyberpunk:

| Opção | Ícone | Rota | Descrição |
|---|---|---|---|
| **Primeiros passos** | ⚡ | `/first-steps` | Tutorial interativo de simbologia técnica e quiz de fixação |
| **Começar** | 🔬 | `/challenges` | Desafios práticos guiados (Lâmpada, Motor, Resistor) |
| **Bancada Livre** | 🧪 | `/sandbox` | Laboratório livre de simulação e criação de circuitos |
| **Configurações** | ⚙️ | `/settings` | Preferências de sistema, áudio, acessibilidade e idioma |

Apresenta a marca consolidada:

```text
EletroLab
LABORATÓRIO VIRTUAL DE CIRCUITOS
```

### Layout
- Computador/Tablet: Bento Grid responsivo com cartões em relevo CyberHUD.
- Celular: Lista vertical com rolagem fluida.
- Rodapé com indicador de versão: `ELETROLAB CYBER STATION • v1.0.0`.

---

## Primeiros passos (Fase 2 — Concluída)

Interface interativa de 8 quadrantes combinando representação física 3D e simbologia esquemática padronizada (IEC/IEEE).

Componentes apresentados:
1. **Bateria** (`battery`) — Fonte de energia elétrica.
2. **Fio de Conexão** (`connecting wire`) — Condutor de elétrons e nó de junção.
3. **Interruptor** (`electrical switch`) — Controle de circuito aberto/fechado.
4. **Lâmpada** (`bulb`) — Filamento incandescente e emissão luminosa.
5. **Resistor** (`resistor`) — Limitação de corrente (código de cores).
6. **Diodo** (`diode`) — Passagem da corrente em um único sentido.
7. **LED** (`LED Light-Emitting Diode`) — Diodo emissor de luz.
8. **Motor** (`motor`) — Conversão de energia elétrica em mecânica.

Recursos:
- **Visualização Dupla**: Ilustração física no topo + Símbolo esquemático desenhado via `CustomPainter` na base.
- **Interatividade de Estados**: Permite ligar/desligar a lâmpada, LED, motor e interruptor diretamente nos cartões.
- **Modo Desafio / Quiz**: Oculta os nomes para teste de fixação com diálogo de resultado compactado (máximo `440px`).

---

## Banco de Trabalho (Bancada Livre / Sandbox — Fases 5 & 7 — Concluída)

A **Bancada Livre** é o laboratório dinâmico onde o estudante pode criar, testar e analisar qualquer circuito elétrico em tempo real.

```text
┌──────────────────────────────────────────────────────────────┐
│ EletroLab — BANCADA LIVRE                                     │
├──────────────────────────────────────────────────────────────┤
│ 🔋 Fonte  ⚡ Resistor  💡 Lâmpada  🔴 LED  🔘 Chave  ⚙️ Motor  │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│                GRADE INTERATIVA (GRID CANVAS)                │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│ ▶ Simular  ⏸ Pausar  ↻ Reset  🗑 Limpar | 👁️ Diagrama/Físico │
└──────────────────────────────────────────────────────────────┘
```

### Recursos Principais da Bancada Livre:
1. **Paleta de Componentes**: Drag-and-Drop de Fonte (Bateria), Resistor, Lâmpada, LED, Interruptor SPST e Motor DC.
2. **Conexões Magnéticas**: Clique ou arraste entre os bornes vermelho (+) e preto (-) para criar fios.
3. **Modos de Visualização**: Alternância instantânea entre **Visão Física 3D** e **Diagrama Esquemático Técnico**.
4. **Roteamento Ortogonal Inteligente (Manhattan Routing)**: Fios em modo esquema possuem curvas limpas de $90^\circ$ e desviam automaticamente por baixo dos componentes.
5. **Edição de Parâmetros**: Modal ao clicar no componente para ajustar Tensão ($V$), Resistência ($R$) ou rotacionar em $90^\circ$.
6. **Barra de Controle de Simulação**: Play, Pause, Passo a Passo, Desfazer (Undo), Refazer (Redo), Limpar Tudo e Carregador de Circuitos Predefinidos (Presets).
7. **Assistente Flutuante Prof. Volts**:
   - Posicionado como HUD flutuante no **canto inferior direito** (não comprime nem obstrui o canvas).
   - Notificações automáticas em tempo real para curto-circuitos e sobrecargas (queima de LED, lâmpada ou motor).
   - Ação rápida integrada **"Substituir Todos Queimados"** para reparo instantâneo da bancada.
   - Desaparece totalmente da tela quando fechado pelo usuário.

---

## Modais e Diálogos de Feedback (CyberHUD)

- Todos os diálogos popups educacionais (Feedback do Prof. Volts, Resultados de Quiz e Conclusão de Desafios) possuem limite estrito de largura de **`maxWidth: 440px`**, garantindo um visual limpo e centralizado em qualquer resolução (Mobile, Tablet e Desktop).

---

## Responsividade e Atalhos (Desktop)

- **Celular**: Interação de toque amigável com botões ampliados e painéis colapsáveis.
- **Tablet & Desktop**: Suporte completo a atalhos de teclado e mouse.

| Atalho | Ação |
|---|---|
| `Delete` / `Backspace` | Excluir componente ou fio selecionado |
| `Ctrl + Z` | Desfazer ação na bancada |
| `Ctrl + Y` | Refazer ação na bancada |
| `Espaço` | Alternar entre Iniciar / Pausar simulação |
| `R` | Rotacionar componente selecionado em $90^\circ$ |