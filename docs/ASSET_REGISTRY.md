# ASSET_REGISTRY

## 1. Objetivo
## 2. Regras de uso
## 3. Status possíveis
## 4. Índice geral de assets
## 5. Componentes elétricos validados
## 6. Assets visuais não elétricos
## 7. Pendências


## 1. Objetivo

Este documento registra quais assets visuais são canônicos no EletroLab,
o que cada um representa e seu status de validação.

Ele não define comportamento de runtime, rotação, ghost, solver ou layout.
Esses aspectos pertencem à implementação e à arquitetura.

## 2. Regras de uso

- Um asset elétrico não é aprovado apenas pela aparência.
- O componente representado deve ser identificado tecnicamente.
- Símbolo e componente físico devem representar o mesmo dispositivo.
- Polaridade e terminais precisam ser compatíveis com o componente real.
- Não inventar tensão, corrente, pinagem ou subtipo ausentes.
- Imagem gerada ou ilustrada não é fonte técnica.
- Um asset pode estar inventariado sem estar tecnicamente aprovado.

## 3. Status possíveis

| Status         | Significado                                           |
| -------------- | ----------------------------------------------------- |
| `INVENTARIADO` | existe e foi identificado no repositório              |
| `EM_VALIDACAO` | asset escolhido, mas falta confirmação técnica        |
| `APROVADO`     | asset + identidade técnica + uso pedagógico validados |
| `REJEITADO`    | não deve ser usado como representação canônica        |

## 4. Índice geral de assets

| ID      | Componente/uso   | Asset canônico                      | Categoria | Status       | Uso principal |
| ------- | ---------------- | ----------------------------------- | --------- | ------------ | ------------- |
| BAT-001 | Bateria 9 V      | `assets/components/battery.png`     | elétrico  | EM_VALIDACAO | Acende Aí     |
| RES-001 | Resistor         | `assets/components/resistor.png`    | elétrico  | EM_VALIDACAO | Acende Aí     |
| LED-001 | LED vermelho     | `assets/components/led_off.png`     | elétrico  | EM_VALIDACAO | Acende Aí     |
| SW-001  | Interruptor SPST | `assets/components/switch_open.png` | elétrico  | EM_VALIDACAO | Acende Aí     |

## 5. Componentes elétricos validados

## BAT-001 — Bateria 9 V

- **Asset canônico:** `assets/components/battery.png`
- **Alternativa existente:** `assets/images/component_battery_horizontal.png`
- **Asset de origem/referência visual:** imagem comercial de bateria Duracell 9 V

- **Nome técnico:** bateria alcalina de 9 V
- **Tipo/subtipo:** bateria primária alcalina, formato 9 V
- **Quantidade de terminais:** 2
- **Função dos terminais:** terminal positivo (+) e terminal negativo (−)
- **Polaridade:** sim

- **Tensão/faixa relevante para a demonstração:** 9 V
- **Corrente/faixa relevante:** depende da carga; não definir valor fixo sem referência técnica
- **Outros parâmetros relevantes:** terminais tipo miniature snap

- **Representação esquemática correspondente:** símbolo de bateria
- **Implementação da representação:** desenhado por código via painter esquemático

- **Referência real confiável:** documentação técnica oficial Duracell para bateria alcalina 9 V
- **Fabricante/modelo de referência:** Duracell MN1604 / 6LR61, bateria alcalina 9 V

- **Uso pedagógico:** fonte do circuito-base do Primeiro Stand — “Acende Aí”
- **Comportamento que o estudante deve reconhecer:** fornece diferença de potencial ao circuito; os polos possuem polaridade definida

- **Observações visuais:** o terminal menor é o positivo (+) e o terminal maior é o negativo (−). Há uma segunda representação da mesma entidade no repositório; não é duplicata binária e não foi escolhida como asset canônico.
- **Status:** APROVADO
- **Pendências:** nenhuma para identificação básica do asset

## RES-001 — Resistor genérico


