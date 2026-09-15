# ZGOLD — FORENSIC AUDIT — ETAPA 84
## Reference Structure Resolver / Replay

### Objetivo
Testar as hipóteses concorrentes para explicar quando a expansão utiliza a família geométrica de ~0.80 e quando utiliza ~3.40, sem promover hipótese a regra sem contraexemplos controlados.

### Correções incorporadas nesta etapa
- Basket, Compression e Global passaram a ser gates independentes.
- Prioridade entre esses gates deixa de ser silenciosamente assumida.
- Quando mais de um gate de saída é elegível no mesmo snapshot, a decisão passa a `CONFLICT_UNRESOLVED`.
- `winner > 0` deixou de ser gate formal da compressão; permanece documentado apenas como invariante/redundância.
- Desempate implícito BUY vs SELL por menor do32 não é tratado como regra do Zeus.
- Limite de capacidade de 64 posições gera aviso de capacidade.
- Parâmetros reconstruídos foram isolados em `ZGOLD/Config/ZGoldParams.mqh`.

## Hipóteses
### H1 — extrema-based
`0.80 quando o candidato rompe o extremo; 3.40 quando não rompe.`

**Resultado: REFUTADA.**
Contraexemplos observados no log:
- BUY #15 criado a 4539.99 após BUY #12 a 4536.59: o candidato está acima do extremo BUY anterior em ~3.40, portanto rompe o extremo, mas a relação observada pertence à família de ~3.40, não ~0.80.
- BUY #18 criado a 4546.80 após BUY #16 a 4543.39: rompe o extremo anterior em ~3.41 e novamente pertence à família ~3.40.

Conclusão: romper o extremo não determina sozinho o uso de 0.80.

### H2 — contagem de camadas
`primeira expansão usa 0.80; expansões subsequentes usam 3.40.`

**Resultado: REFUTADA como regra simples.**

A sequência inicial de SELL mostra múltiplas expansões sucessivas da mesma estrutura em espaçamento próximo de 0.80:
- #36 = 4530.80
- #37 = 4531.63
- #38 = 4532.43
- #39 = 4533.26

Os intervalos consecutivos são aproximadamente 0.83, 0.80 e 0.83. Portanto, expansões subsequentes podem permanecer na família intra-estrutura ~0.80.

### H3 — papel estrutural distinto
`0.80 = intra-estrutura; 3.40 = inter-estrutura.`

**Resultado: STRONG HYPOTHESIS / melhor modelo sobrevivente.**

Evidências:
- Sequências de mesma direção apresentam agrupamentos de aproximadamente 0.80 entre novas camadas dentro da mesma estrutura.
- Relações de aproximadamente 3.40 aparecem como saltos estruturais entre grupos/camadas mais afastadas.
- BUY #15 e #16, por exemplo, estão separados por aproximadamente 3.40.
- A sequência SELL #36→#39 forma um encadeamento aproximadamente 0.80.

Ainda não é classificado como COMPROVADO porque a referência exata e a causa da troca entre papéis ainda não estão determinadas.

### H4 — flag/regime persistente
`um estado persistente controla a troca 0.80 <-> 3.40.`

**Resultado: UNRESOLVED.**

Ainda não existe evidência suficiente para escolher Money, exposição, MaxLossCloseAll ou outra variável como discriminador causal. Esse estado não deve ser inventado.

## Resultado arquitetural da Etapa 84
O resolver deve permanecer em uma camada separada:

`State -> DirectionalLayerState -> ReferenceStructure -> Candidate -> GeometryConstraint`

A referência estrutural não deve ser reconstruída somente a partir do preço atual. Deve preservar contexto suficiente para distinguir:
- estrutura intra-layer (~0.80)
- salto inter-structure (~3.40)

## Próximo experimento
Executar replay causal completo de cada criação de pending, preservando:
- última criação da mesma direção;
- últimas execuções da mesma direção;
- pending concorrentes;
- extremos desde o último reset/cesta;
- estado imediatamente anterior ao evento;
- evento imediatamente posterior.

Objetivo: transformar H3 de `STRONG HYPOTHESIS` em regra comprovada ou encontrar seu primeiro contraexemplo.

## Status
H1 = REFUTED
H2 = REFUTED
H3 = STRONG HYPOTHESIS
H4 = UNRESOLVED
