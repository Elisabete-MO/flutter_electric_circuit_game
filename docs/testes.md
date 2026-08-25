# Testes

## Verificação obrigatória

A cada etapa de implementação:

```bash
flutter analyze
flutter test
```

Build de referência (compilação): `flutter build web`.

Não ignorar erros de análise ou testes quebrados.

## Testes existentes (Estabilizados)

`test/widget_test.dart`:

- **Identidade do EletroLab**: Verifica a exibição do logo, do subtítulo `LABORATÓRIO VIRTUAL DE CIRCUITOS` e da versão `ELETROLAB CYBER STATION • v1.0.0` na tela inicial.
- **Opções do Menu**: Confirma que as quatro seções (Primeiros Passos, Começar, Banqueta e Configurações) estão presentes.
- **Navegação de Retorno**: Garante que o usuário consiga navegar de volta à tela inicial.
- **Abertura de Configurações**: Valida que a tela de configurações carrega todos os botões de ajuste e switches.
- **Persistência de Tema**: Testa a alteração dinâmica do tema e a persistência correta após o reinício simulado do app.

### Notas de infraestrutura de teste

- **Injeção de Dependências**: Utilizamos `SharedPreferences.setMockInitialValues({})` e sobrescrevemos o provider no escopo de testes via `sharedPreferencesProvider.overrideWithValue(prefs)` para fornecer uma instância válida e isolada durante a inicialização dos controladores.
- **Estabilização de Animações**: Para evitar travamentos por timeout (`pumpAndSettle` que aguarda infinitamente animações recorrentes, como o neon do logo e layouts responsivos), implementamos o helper `pumpSettle(tester, Duration duration)` que roda frames controlados.
- **Controle de Dimensões**: O viewport de teste é ampliado temporariamente via `tester.binding.setSurfaceSize(const Size(900, 2000))` para renderizar as telas por completo e simular interações realistas.
- **Layout Responsivo**: Ajustado o Bento Grid da home com `IntrinsicHeight` para evitar erros de `RenderFlex overflow` durante a medição do viewport de testes.

## Testes planejados para o solver (Fases 5–6)

Casos que **evitam regressões** no solver de circuitos:

| # | Cenário | Valores | Esperado |
|---|---|---|---|
| 1 | Lei de Ohm | `V = 10 V`, `R = 100 Ω` | `I = 0,1 A` |
| 2 | Lei de Ohm | `V = 10 V`, `R = 1 kΩ` | `I = 0,01 A` |
| 3 | Interruptor aberto | qualquer | `I = 0 A` |
| 4 | Resistores em série | `R1 = 100 Ω`, `R2 = 200 Ω`, `V = 10 V` | `Req = 300 Ω`, `I ≈ 0,0333 A` |

Testes adicionais recomendados:

- Curto-circuito detectado como erro (`isValid = false`).
- Circuito sem fonte → erro "ausência de fonte".
- Componente com terminal desconectado → erro "componente desconectado".
- Lâmpada acesa/apagada por potência (`P = V × I`).
- Multímetro reportando tensão/corrente corretas.
- Circuito paralelo (`Req` em paralelo).
- Condições de vitória dos desafios.

## Organização sugerida

```text
test/
├── widget_test.dart            → Fase 1 (UI/navegação/configurações)
└── simulation/
    ├── solver_test.dart        → casos 1–4 e variações (Fases 5–6)
    └── circuit_test.dart       → grafo, nós, conexões (Fase 5)
```

## Guia rápido

```bash
# Análise estática
flutter analyze

# Todos os testes
flutter test

# Um arquivo específico
flutter test test/simulation/solver_test.dart

# Compilação de referência (web)
flutter build web
```