# CKC examples

Every example below is a valid Conventional Commit. Footers use the git-trailer form
(`Token: value`, repeatable). The proof examples use a formalization (Intrinsic Green's Learning);
the science examples use its experiments.

## proof profile

### Add a definition or statement, with no proof yet
```
state(green-kernel): define the elliptic Green's kernel operator

Lean: IGL.greensKernel
Status: math.conjectured
```

### Conjecture a result
```
conjecture(master-formula): the Green's integral factorises as a finite rank-K×R sum

Claim-ID: conjecture:master-formula
Status: math.conjectured
```

### Formalize and close it cleanly
```
formalize(fubini): close the d-fold separable factorization

Lean: IGL.fubini_dfold, IGL.fubini_factorization
Status: math.machine-checked
Axioms: propext, Classical.choice, Quot.sound
Verified-By: Lean 4.30.0; Mathlib v4.30.0
Closes: conjecture:master-formula
```

### Cite an axiom (note the `~` and the `AXIOM:` footer)
```
axiomatize~(exp-sum): cite the logarithmic exponential-sum rank bound

The target library has no elliptic-Green's exponential-sum theory, so posit it as a citation.

Lean: IGL.expSumRank_logBound
Status: math.axiomatised
AXIOM: IGL.expSumRank_logBound (separable rank K = O(log 1/ε), dimension-independent)
Cites: Braess & Hackbusch 2005, Numer. Math.
```

### A clean proof that inherits a caveat through a dependency
```
formalize(approx-error): bound the approximation error via the exp-sum rank

Lean: IGL.approxError
Status: math.machine-checked
Axioms: propext, Classical.choice, Quot.sound
Depends-On: IGL.expSumRank_logBound
```
Its own `#print axioms` is clean, but its effective status is axiomatised, because it `Depends-On`
an axiomatised node. The [ClaimGraph](impact-graph.md) computes this, so the commit need not restate
it.

### Leave an explicit gap
```
formalize~(rank-bound): scaffold the rank-bound proof; one case is still open

Lean: IGL.expSumRank_logBound
Status: math.open
OPEN: the r→0 boundary case is still a `sorry`
```

### Refute a conjecture (a breaking change)
```
refute(separability)!: a counterexample blocks naive separable factorization

A radial counterexample shows the kernel does not factor under the affine-invariant metric.

Disproves: conjecture:naive-separable
Status: math.disproved
BREAKING CHANGE: conjecture:naive-separable is withdrawn; the compensation result depends on it.
```

### Strengthen (additive; the old form still follows)
```
strengthen(gauge): prove gauge invariance for all C¹ diffeomorphisms, not only linear maps

Lean: IGL.gauge_invariance
Status: math.machine-checked
Supersedes: IGL.gauge_invariance_linear
```

## science profile

### Register a hypothesis (pre-registered)
```
conjecture(tensor-rank): tensor rank K>1 beats K=1 on non-additive targets

Claim-ID: conjecture:tensor-rank-helps
Status: sci.hypothesis
Pre-Registration: osf.io/abcd1
```

### Record an experiment
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

### A failed replication (a normal commit)
```
replicate(non-additive): an independent run fails to reproduce the K>1 advantage

Status: sci.not-replicated
Dataset: D-2026-014 sha256:aa80…
Sample-Size: n=1200
Effect-Size: ΔMSE −0.03
CI: 95% [−0.09, 0.04]
Refutes: conjecture:tensor-rank-helps
```

### A code fix that changes the numbers but not the finding
```
repro-fix(scaling): correct an off-by-one in the epoch windowing

The direction is unchanged and the effect size is revised down. This is not a new finding.

Affects: result:igl-linear-scaling
Effect-Size: +6.8pp → +5.1pp
Seed: 0
Impact: patch
```

### A data correction that flips a conclusion (a breaking change)
```
data(bnci)!: fix swapped treatment and control labels in the BCI dataset

Dataset: D-2025-019
Invalidates: result:cross-subject-transfer
Status: sci.falsified
BREAKING CHANGE: result:cross-subject-transfer no longer holds under corrected labels.
```

## tooling and prose (plain Conventional Commits still apply)
```
docs(spec): clarify the trusted-base marker rule
chore: tag v0.1.0
```
