# Portao da Escola: Proof of Architecture

## 1. Objetivo

Esta e uma especificacao **em validacao** para uma unica missao avancada. Seu objetivo e provar que EletroLab pode evoluir alem de componentes lineares de dois terminais, sem exigir a implementacao de todo o estande de automacao.

## 2. Contexto

No estande Portao da Escola, uma demonstracao de maquete apresenta controle indireto de uma carga. O contexto pode culminar em motor/portao simulado, mas o primeiro slice nao precisa reproduzir um portao completo.

## 3. Objetivos pedagogicos

- Distinguir circuito de comando e circuito de carga.
- Observar bobina, contatos e mudanca de estado.
- Entender controle indireto: a energização da bobina em um circuito altera o estado dos contatos que controlam outro circuito.
- Introduzir normalmente aberto (NA/NO) e normalmente fechado (NF/NC) quando pertinentes ao dispositivo validado.

## 4. Referencia pedagogica

`REFERENCES.md` registra DigiSim Relay Lab como principal precedente para uma progressao interruptor -> bobina -> contatos -> NO/NC -> change-over -> logica. A evidencia publica analisada nao confirmou como COM e ensinado/rotulado; portanto COM nao deve ser presumido em uma missao inicial sem definir o rele escolhido.

## 5. Dispositivo fisico de referencia

Nenhum rele esta aprovado por aparencia. Antes de criar asset, simbolo ou modelo, preencher e validar:

| Item                                  | Definicao necessaria |
| ------------------------------------- | -------------------- |
| Fabricante/modelo                     |                      |
| Tipo e subtipo                        |                      |
| Numero de terminais                   |                      |
| Funcao de cada terminal               |                      |
| Bobina e tensao nominal               |                      |
| Corrente da bobina, quando pertinente |                      |
| Contatos                              |                      |
| COM, NA/NO e NF/NC, quando existirem  |                      |
| Capacidade eletrica relevante         |                      |
| Simbolo eletrico                      |                      |
| Referencia real confiavel             |                      |
| Papel pedagogico                      |                      |

## 6. Limitacao atual

`SandboxComponent` possui somente terminais `A` e `B`. Fios, modelo e solver assumem essa estrutura. Isso nao representa diretamente bobina e contatos como partes relacionadas e isoladas do mesmo rele. A limitacao e tecnica observada, nao justificativa para modelar um rele apenas visualmente.

## 7. Missao inicial candidata

**Proposta:** o estudante aciona/observa uma bobina de rele e controla indiretamente uma carga de baixa tensao simulada por contato validado. A carga inicial pode ser uma luz; motor/portao fica opcional ate que o comportamento basico esteja coerente.

```text
CIRCUITO DE COMANDO

      ┌───── botão ───── bobina ─────┐
fonte │                              │
      └──────────────────────────────┘
                bobina energizada
                      ↓
        altera mecanicamente o estado do contato

CIRCUITO DE CARGA
      ┌──── contato do relé ─── carga ────┐
fonte │                                   │
      └───────────────────────────────────┘
```

## 8. Possivel progressao futura

Esta sequencia e proposta, nao compromisso:

```text
interruptor
-> bobina
-> NA
-> NF
-> comutacao
-> comando/carga
-> motor/portao
```

## 9. Fora do escopo inicial

- Rede eletrica e alta tensao.
- Instalacao residencial.
- PLC e automacao industrial completa.
- Multiplos tipos de rele.
- Solver universal de circuitos.
- Portao fisico completo como requisito da primeira missao.

## 10. Criterios antes de implementar

- O rele de referencia e tecnicamente identificado e possui fonte confiavel.
- Terminais, simbolo e estados dos contatos sao definidos.
- Regra bobina energizada -> mudanca de contato e testavel.
- Comando e carga permanecem topologicamente distintos.
- A carga e de baixa tensao simulada e sua consequencia e observavel.
- A extensao do modelo A/B e delimitada pelo menor comportamento necessario.
- A missao explica causa e nao sugere pratica com rede eletrica.

## Governanca documental

Decisoes sobre esta prova avancada devem atualizar este documento, `ARCHITECTURE.md` e `CAMPAIGN.md` quando aplicavel, sem criar especificacao concorrente.
