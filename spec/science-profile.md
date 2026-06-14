# CKC — `science` profile

For empirical discovery: experiments, measurements, datasets, and replication. The trusted base
here is softer than in the `proof` profile — there is no kernel — so honesty rests on
**provenance** (what data, protocol, code, seed) and **uncertainty** (effect size, interval,
replication), and on keeping a code-correction (`repro-fix`) distinct from a genuine new finding.

## Types

| Type | Use it when you… | Typical Axis 1 |
| --- | --- | --- |
| `conjecture` | register a hypothesis / prediction (ideally pre-registered) | additive |
| `experiment` | record the execution of a protocol and its raw outcome | additive |
| `result` | record a measured finding drawn from experiments | additive |
| `replicate` | report an independent reproduction (success **or** failure) | additive |
| `null` | report a null / negative result | additive |
| `data` | add, curate, clean, or version a dataset | additive¹ |
| `protocol` / `method` | add or change an experimental/analysis protocol | additive¹ |
| `analysis` | add or revise a statistical/computational analysis | additive¹ |
| `repro-fix` | fix a bug in analysis/code that changes the numbers | patch, or `!` if conclusions flip |
| `retract` | withdraw a previously reported finding | breaking `!` |

¹ A `data`, `protocol`, or `analysis` change that alters earlier conclusions is **Axis-1 breaking**
(`!` + `Invalidates:`), exactly like a `data correction`.

## Status (Axis 2)

`Status:` values, namespaced `sci.*`:

| `Status:` | Meaning |
| --- | --- |
| `sci.hypothesis` | predicted, not yet tested |
| `sci.piloted` | preliminary / underpowered evidence |
| `sci.measured` | a result from a single, adequately-run study |
| `sci.supported` | corroborated across analyses/conditions |
| `sci.replicated` | independently reproduced |
| `sci.not-replicated` | an independent reproduction failed |
| `sci.falsified` | contradicted by evidence |

## Trusted-base footers

- `ASSUMES: <untested assumption>` — a modelling/identification assumption the result rests on.
- `UNREPLICATED: <scope>` — a single, un-replicated run (e.g. one machine, one cohort).

## Provenance & uncertainty footers

- `Dataset: <id|doi> [sha256:…]` · `Raw-Data: <uri> sha256:…`
- `Protocol: <id>` · `Method: <one-line>` · `Pre-Registration: <osf|registry url>`
- `Sample-Size: n=…` · `Replicates: biological=… technical=…`
- `Effect-Size: …` · `CI: 95% […, …]` · `P-Value: …`
- `Code: git:<sha>` · `Environment: <container sha256>` · `Seed: …` · `Hardware: …` · `Metric: …`
- `Ethics-Approval: <id>` where applicable.

## Identity

Empirical claims do **not** get an identifier for free (no canonical formal statement). Each
referenced claim/hypothesis **MUST** be a curated slug (e.g. `conjecture:tensor-rank-helps`)
registered in the claims registry, optionally bound to a DOI / pre-registration once published. See
[`../identifiers.md`](../identifiers.md).

## Examples

```
conjecture(tensor-rank): tensor rank K>1 beats K=1 on non-additive targets

Claim-ID: conjecture:tensor-rank-helps
Status: sci.hypothesis
Pre-Registration: osf.io/abcd1
```

```
experiment(non-additive): K=1 vs K>1 on XOR/radial/multiplicative targets

Status: sci.measured
Metric: MSE
Sample-Size: n=1000
Seed: 0..4
Hardware: M4 (MPS)
Effect-Size: ΔMSE −0.41 (K=8 vs K=1)
UNREPLICATED: single machine, 5 seeds — needs an independent run
Closes: conjecture:tensor-rank-helps
```

```
replicate(non-additive): independent run fails to reproduce the K>1 advantage

Status: sci.not-replicated
Dataset: D-2026-014 sha256:aa80…
Sample-Size: n=1200
Effect-Size: ΔMSE −0.03
CI: 95% [−0.09, 0.04]
Refutes: conjecture:tensor-rank-helps
```

```
repro-fix(scaling): correct off-by-one in the epoch windowing

Direction unchanged, effect size revised down — not a new finding.

Affects: result:igl-linear-scaling
Effect-Size: +6.8pp → +5.1pp
Seed: 0
Impact: patch
```
