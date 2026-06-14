# CKC: the `science` profile

The `science` profile is for empirical discovery: experiments, measurements, datasets, and
replication. The trusted base here is softer than in the proof profile, because there is no kernel.
So honesty rests on two things instead: provenance (what data, protocol, code, and seed produced the
number) and uncertainty (effect size, interval, replication). It also keeps a code correction
(`repro-fix`) separate from a genuine new finding.

## Types

| Type | Use it when you | Typical impact |
| --- | --- | --- |
| `conjecture` | register a hypothesis or prediction, ideally pre-registered | additive |
| `experiment` | record the execution of a protocol and its raw outcome | additive |
| `result` | record a measured finding drawn from experiments | additive |
| `replicate` | report an independent reproduction, whether it succeeds or fails | additive |
| `null` | report a null or negative result | additive |
| `data` | add, curate, clean, or version a dataset | additive, see note |
| `protocol`, `method` | add or change an experimental or analysis protocol | additive, see note |
| `analysis` | add or revise a statistical or computational analysis | additive, see note |
| `repro-fix` | fix a bug in analysis or code that changes the numbers | patch, or `!` if conclusions flip |
| `retract` | withdraw a previously reported finding | breaking, `!` |

Note: a `data`, `protocol`, or `analysis` change that alters earlier conclusions is breaking
(`!` plus `Invalidates:`), the same as a data correction.

## Status

`Status:` values use the `sci.*` namespace:

| `Status:` | Meaning |
| --- | --- |
| `sci.hypothesis` | predicted, not yet tested |
| `sci.piloted` | preliminary or underpowered evidence |
| `sci.measured` | a result from a single, adequately run study |
| `sci.supported` | corroborated across analyses or conditions |
| `sci.replicated` | independently reproduced |
| `sci.not-replicated` | an independent reproduction failed |
| `sci.falsified` | contradicted by evidence |

## Trusted-base footers

- `ASSUMES: <untested assumption>`: a modelling or identification assumption the result rests on.
- `UNREPLICATED: <scope>`: a single, un-replicated run, for example one machine or one cohort.

## Provenance and uncertainty footers

- `Dataset: <id|doi> [sha256:...]`, `Raw-Data: <uri> sha256:...`
- `Protocol: <id>`, `Method: <one line>`, `Pre-Registration: <registry url>`
- `Sample-Size: n=...`, `Replicates: biological=... technical=...`
- `Effect-Size: ...`, `CI: 95% [..., ...]`, `P-Value: ...`
- `Code: git:<sha>`, `Environment: <container sha256>`, `Seed: ...`, `Hardware: ...`, `Metric: ...`
- `Ethics-Approval: <id>` where it applies.

## Identity

Empirical claims do not get an identifier for free, because there is no canonical formal statement.
Each referenced claim or hypothesis MUST be a curated slug, for example `conjecture:tensor-rank-helps`,
registered in the claims registry and optionally bound to a DOI or pre-registration once published.
See [Identifiers](../identifiers.md).

## Examples

```
conjecture(tensor-rank): tensor rank K>1 beats K=1 on non-additive targets

Claim-ID: conjecture:tensor-rank-helps
Status: sci.hypothesis
Pre-Registration: osf.io/abcd1
```

```
experiment(non-additive): K=1 vs K>1 on XOR, radial, and multiplicative targets

Status: sci.measured
Metric: MSE
Sample-Size: n=1000
Seed: 0..4
Hardware: M4 (MPS)
Effect-Size: ΔMSE −0.41 (K=8 vs K=1)
UNREPLICATED: single machine, 5 seeds; needs an independent run
Closes: conjecture:tensor-rank-helps
```

```
replicate(non-additive): an independent run fails to reproduce the K>1 advantage

Status: sci.not-replicated
Dataset: D-2026-014 sha256:aa80...
Sample-Size: n=1200
Effect-Size: ΔMSE −0.03
CI: 95% [−0.09, 0.04]
Refutes: conjecture:tensor-rank-helps
```

```
repro-fix(scaling): correct an off-by-one in the epoch windowing

The direction is unchanged and the effect size is revised down. This is not a new finding.

Affects: result:igl-linear-scaling
Effect-Size: +6.8pp → +5.1pp
Seed: 0
Impact: patch
```
