# FORENSIC AUDIT — STAGE 88
## Structured Backtest Trace — Provisioning

### Objetivo
Provisionar o formato determinístico de rastreio que será usado no backtest forense e, posteriormente, na comparação evento-a-evento contra o comportamento observado do Zeus Gold Hedge V1.2.

### Estado da etapa
- EXECUTION: DESABILITADA
- TRADING LOGIC: NÃO IMPLEMENTADA
- FUNÇÃO: OBSERVAÇÃO / TRACE
- FONTE: evidência forense já consolidada nas etapas anteriores

### Unidade de comparação
Cada registro representa um evento causal observável ou uma transição operacional:

`CREATE | MODIFY | EXECUTE | LAYER | BASKET | COMPRESSION | CLOSEBY | CLOSE | RESET`

### Schema provisionado
Campos:

`Timestamp;EventType;Ticket;Direction;OrderType;Lots;Price;PreviousPrice;ReferencePrice;ReferenceType;Distance;DistanceFamily;BuyCount;SellCount;BuyLots;SellLots;BuyProfit;SellProfit;TotalProfit;Target;Result;WinnerTicket;Loss1Ticket;Loss2Ticket;Lifecycle;Reason`

### Regras de integridade
1. O trace registra observação; não decide nem executa ordens.
2. Valores desconhecidos permanecem explicitamente marcados como `UNRESOLVED`, `OTHER`, `NONE` ou `-`, conforme o campo.
3. O registro deve preservar preço anterior, preço atual e referência quando disponíveis, para permitir a identificação da primeira divergência causal.
4. O estado de exposição acompanha o evento para permitir replay determinístico.
5. `Reason` é textual e não deve ser tratado como regra executável.

### Arquivos provisionados
- `ZGOLD/Debug/ReplayTraceRecord.mqh`
- `ZGOLD/Debug/StructuredTraceObserver.mqh`

### Não implementado nesta etapa
- escrita persistente em CSV pelo EA;
- integração automática no `EAController`;
- geração de decisões de trading;
- comparação com o CSV original;
- score final do replay.

A integração foi mantida separada neste estágio para evitar que o instrumento de auditoria altere o comportamento observado do núcleo.

### Próxima etapa
**Stage 89 — integração controlada do trace ao ciclo de reconciliação, seguida de backtest com execução ainda bloqueada.**

O critério de avanço será: registrar os eventos em ordem temporal única, sem duplicação artificial e sem converter hipóteses em regras de execução.
