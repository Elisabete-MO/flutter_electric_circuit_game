# Interface e interação

## Menu inicial (Fase 1 — concluída)

Quatro opções principais:

| Opção | Ícone | Rota |
|---|---|---|
| Primeiros passos | ⚡ | `/first-steps` |
| Começar | 🔬 | `/challenges` |
| Banqueta | 🧪 | `/sandbox` |
| Configurações | ⚙️ | `/settings` |

Apresenta identidade com nome e subtítulo:

```text
EletroLab
Seu laboratório virtual de circuitos
```

### Layout
- Computador/tablet: grade 2×2.
- Celular: lista vertical com scroll.
- Rodapé com versão (`EletroLab v1.0.0`).

## Primeiros passos (Fase 2 — concluída)

Interface interativa de 8 quadrantes combinando imagens dos componentes físicos e a simbologia esquemática padronizada (IEC/IEEE).

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
- **Banner Orientativo**: Mensagem contextual *"Observe. You have to know these symbols for this activity."*.
- **Modo Desafio / Quiz**: Oculta automaticamente os nomes dos cartões (exibindo apenas `?`) para testar o reconhecimento visual de cada componente pelo estudante.

## Banco de trabalho (Banqueta — Fases 3–7)

Layout conceitual:

```text
┌──────────────────────────────────────────────────────────────┐
│ EletroLab                                                    │
├──────────────────────────────────────────────────────────────┤
│ 🔋  Resistor  💡  Interruptor  ─ Fio ─  📏 Multímetro       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│                     BANCADA                                  │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│ ▶ Simular   ⏸ Pausar   ↻ Reiniciar   🗑 Limpar              │
└──────────────────────────────────────────────────────────────┘
```

Permite:

- arrastar;
- mover;
- selecionar;
- excluir;
- rotacionar;
- conectar;
- desconectar;
- editar valores;
- zoom;
- pan.

### Interações

- **Arrastar**: componentes se movem pela bancada.
- **Selecionar**: destacar, mostrar informações e permitir editar propriedades.
- **Conectar**: terminais próximos são destacados com indicação de conexão;
  permite criar o fio.
- **Fios**: acompanham os terminais dos componentes ao serem movidos.

## Câmera

- zoom in/out;
- pan;
- centralização;
- grade opcional;
- suporte a mouse, touch e trackpad (quando possível).

## Atalhos (desktop)

| Atalho | Ação |
|---|---|
| `Delete` | excluir selecionado |
| `Ctrl + Z` | desfazer |
| `Ctrl + Y` | refazer |
| `Space` | iniciar/pausar simulação |
| `R` | rotacionar |

## Responsividade

- **Celular**: controles grandes, interação touch.
- **Tablet**: layout intermediário.
- **Desktop**: mouse, teclado e atalhos.
- **Web**: quando possível.

## Configurações e Internacionalização (i18n — Fase 9/Aparência)

A tela de Configurações permite personalizar:

- **Aparência e Tema**: Alternar entre os modos **Sistema**, **Claro** e **Escuro**.
- **Idioma / Language (i18n)**: Alternância em tempo real entre **Português (pt)** e **English (en)** usando `flutter_localizations` e arquivos `.arb`. O idioma escolhido altera instantaneamente todos os menus, instruções, rótulos de botões (`VERIFY`, `RESET`, `Iniciar`) e diálogos educativos do EletroLab.
- **Simulação & Acessibilidade**: Controles de exibição de corrente, grade, valores, animação, escala da interface e contraste.
- **Persistência**: O idioma e o tema selecionados são salvos via `shared_preferences` e mantidos entre as sessões.

## Identidade visual

- Laboratório virtual, educacional, moderno, amigável e limpo.
- Componentes facilmente reconhecíveis.
- Paleta: azul elétrico (primária), ciano (secundária), âmbar (terciária).
- O nome **EletroLab** aparece na tela inicial e nos principais elementos.
- Não reproduz a identidade do PhET.