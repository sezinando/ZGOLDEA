# CHECKPOINT — Zeus Gold Hedge V1.2 — ETAPA 80

## Escopo
Checkpoint da auditoria forense comportamental do Zeus Gold Hedge V1.2, baseada exclusivamente no comportamento observado nos arquivos `Comportamento EA.log` e `Comportamento EA.csv`.

## Estado da auditoria
Etapas concluídas: 01–80.

A reconstrução permanece comportamental/forense. Nenhum código do EA original foi inferido como fato apenas por analogia com implementações externas.

## Núcleo comportamental fechado

- Estrutura bilateral inicial: BUY STOP + SELL STOP de 0,01.
- `FirstStep=160` pontos = 1,60.
- `MinDistance=340` pontos = 3,40.
- `Step=80` pontos = 0,80.
- `TwoStep=90` pontos = 0,90, mas sua ativação causal permanece indeterminada.
- `TwoMinDistance=80` pontos = 0,80, mas sua ativação permanece indeterminada.
- Pending orders sofrem trailing por OOP, não por SL.
- BUY pending: OOP = ASK + distância.
- SELL pending: OOP = BID - distância.
- `StepTrallOrders=50` pontos = 0,50 como limiar comportamental de modificação.
- Fórmula de lote: `NormalizeDouble(0.01 * 1.2^n + 0.01*n, 2)`, com teto individual de 0,62.
- Progressão de lote é independente por direção.
- Basket target: `N * StopProfit`, com `StopProfit=20`.
- Basket closure é direcional.
- Compression: winner + dois piores perdedores, sob o gate de exposição previamente comprovado.
- Global Exit observado quando `TotalProfit >= 4`.
- Global Exit entrega o controle ao `OrderCloseBy`.
- Pair selection: maior ticket ativo de cada lado; residual torna-se novo ticket e participa do próximo pareamento.
- `4051` encerra o ciclo de pareamento; não é, por si, causa do fechamento.
- Cleanup remove posições/pending restantes e precede reconstrução.
- Reset global reconstrói BUY/SELL de 0,01.
- `BUY close = Bid` e `SELL close = Ask`, comprovados por replay do CSV.
- Um timestamp do log pode representar um transaction burst; portanto o Oracle trabalha com `DecisionBurst`, não com uma ação por timestamp.

## Etapas 73–80 — conclusões

### ETAPA 73 — Geometry Solver
- Grid fixo foi refutado.
- `FirstStep` e `MinDistance` foram separados conceitualmente de `Step`/`TwoStep`.
- Criação de camada e trailing são mecanismos distintos.

### ETAPA 74 — Geometry Reference Resolver
- `Step=0,80` apresenta forte evidência de participação na geometria de camadas.
- `TwoStep=0,90` não foi provado como distância-base necessária de criação.
- Extrema como referência geométrica permanecem hipótese, não regra congelada.

### ETAPA 75 — Reference Selection Matrix
- As criações foram classificadas em famílias observáveis de distância compatíveis com 0,80 / 1,60 / 3,40, com ressalva de causalidade por granularidade temporal.
- Não é permitido atribuir automaticamente `0,80` ao parâmetro `Step`, pois `TwoMinDistance` possui o mesmo valor.

### ETAPA 76 — Distance Selector State Machine
- `Distance` não é função isolada de direção, lote ou count.
- O seletor exige estado composto; possíveis estados latentes permanecem sem prova.

### ETAPA 77 — Transition Mining
- `Distance=f(uma única variável)` foi refutado.
- Estado estrutural, pending e histórico de camada são candidatos fortes.
- `Money` e `NextTime` continuam indeterminados.

### ETAPA 78 — Regime Boundary Mining
- `1,60` está fortemente associado a inicialização/reconstrução.
- `0,80` domina a expansão observada.
- `3,40` aparece fortemente associado a expansão BUY, mas não exclusivamente.
- Não foi congelada uma regra `Direction -> Distance` absoluta.

### ETAPA 79 — Exception Forensics
- O caso #93 SELL @4498,72 foi inicialmente interpretado como evidência de `BasketClose -> 3,40`, mas essa inferência foi corrigida na etapa seguinte.

### ETAPA 80 — Post-Basket Layer-State Mapping
- Análise dos 18 fechamentos de cesta indicou que a primeira reconstrução pós-cesta retorna ao estado inicial da direção.
- Padrão comportamental: `BasketClose_D -> DirectionalLayerReset -> Lot=0,01 -> FirstStep=1,60`.
- A regra geral `BasketClose -> 3,40` foi REFUTADA.
- A arquitetura deve representar `LayerState` separadamente por direção.

## Estado atual do Layer Engine

Modelo comportamental vigente:

`State Reconciliation -> Directional Layer State -> Distance Selection -> Candidate Builder -> Admissibility -> OrderSend`

O `PendingTrailingEngine` permanece separado:

`Pending State -> Market -> OOP trailing -> Modify`

Não se deve fundir os dois mecanismos.

## Pontos ainda abertos

1. Regra determinística que seleciona 0,80 versus 3,40 durante expansão.
2. Ativação exata de `TwoStep`.
3. Ativação exata de `TwoMinDistance`.
4. Função de `Money`.
5. Função de `NextTime`.
6. Eventuais prioridades em conflitos simultâneos.
7. Ordem interna exata de cleanup em todos os casos.
8. Referência geométrica exata em todos os cenários de criação.

## Oracle

O Oracle deve:

- usar o estado atual reconciliado como fonte de verdade;
- preservar identidade de ticket;
- modelar residual como novo ticket após `OrderCloseBy`;
- permitir `DecisionBurst` com múltiplas ações;
- não inventar `Money`, `NextTime`, regime secundário ou `TwoStep`;
- retornar `CONFLICT_UNRESOLVED` em conflitos cuja prioridade não foi comprovada;
- registrar confiança por regra: `PROVEN`, `STRONG_BEHAVIORAL`, `UNRESOLVED`, `REFUTED`.

## Próxima etapa

### ETAPA 81 — Expansion Entry Classification

Objetivo: estudar a transição `INITIAL -> EXPANSION` após cada reconstrução e determinar, a partir do estado imediatamente anterior, o gatilho que seleciona 0,80 versus 3,40.
