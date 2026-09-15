# ZGOLD — FORENSIC AUDIT STAGE 87
## Replay Comparator Provisioning

**Status:** PROVISIONED

### Objetivo
Preparar o mecanismo de comparação entre o comportamento observado do Zeus Gold Hedge V1.2 e o comportamento futuro do ZGOLD durante backtest/replay.

### Regra de trabalho
Nesta etapa não há promoção de hipóteses para execução. O comparador deve medir divergência antes de qualquer otimização.

### Unidade de comparação
A unidade principal será o evento comportamental, nesta ordem:

```text
CREATE
MODIFY
EXECUTE
LAYER
BASKET
COMPRESSION
CLOSEBY
CLOSE
RESET
```

### Campos mínimos do trace

```text
Timestamp
EventType
Ticket
Direction
OrderType
Lots
Price
PreviousPrice
ReferencePrice
ReferenceType
Distance
DistanceFamily
BuyCount
SellCount
BuyLots
SellLots
BuyProfit
SellProfit
TotalProfit
BasketTarget
BasketProfit
CompressionResult
WinnerTicket
Loss1Ticket
Loss2Ticket
GlobalExit
LifecycleState
Reason
```

### Classificação da divergência

```text
D0 = sem divergência relevante
D1 = diferença temporal dentro da resolução do tick/log
D2 = diferença de preço/lote sem mudança de decisão
D3 = decisão diferente com mesmo estado causal
D4 = evento ausente/excedente
D5 = divergência estrutural (estado subsequente diferente)
```

### Métricas

1. Event Match Rate
2. Decision Match Rate
3. Price Match Rate
4. Lot Match Rate
5. Lifecycle Match Rate
6. State Divergence Count
7. First Divergence Timestamp
8. Maximum Consecutive Divergence
9. Cumulative P/L divergence
10. Maximum DD divergence

### Primeira divergência
O relatório deve sempre apontar a **primeira divergência causal**, e não somente a divergência final de saldo.

Formato:

```text
ZEUS EVENT
    ↓
ZGOLD EVENT
    ↓
FIRST DIFFERENCE
    ↓
CAUSE CLASSIFICATION
    ↓
DOWNSTREAM IMPACT
```

### Critério de promoção
Nenhuma regra será considerada reproduzida porque o saldo final ficou parecido. A promoção exige coerência de sequência e estado.

### Próximo estágio
Stage 88 — implementar o primeiro trace estruturado de backtest no ZGOLD, mantendo execução desligada, para que a auditoria possa comparar o ZGOLD com o histórico do Zeus evento a evento.
