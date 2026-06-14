# CKC — `proof` profile

For mathematics and formal proving. Designed to couple to a proof assistant (Lean 4 / Mathlib in
the reference implementation), where the **trusted base** is precise: a result is either
kernel-checked, depends on a cited axiom, or has an open `sorry`. `#print axioms` is the ground
truth, and CKC commits report it rather than asserting status by hand.

## Types

| Type | Use it when you… | Typical Axis 1 |
| --- | --- | --- |
| `state` | add a definition or the formal statement of a result (no proof yet) | additive |
| `conjecture` | assert a statement you believe but do not prove | additive |
| `proof` | give or complete an **informal** (paper) proof | additive |
| `formalize` | write/advance a machine-checkable proof: stubs → tactics → closing goals | additive |
| `axiomatize` | deliberately posit a **cited** axiom (theory absent from the library) | additive¹ |
| `strengthen` | weaken hypotheses or strengthen the conclusion; old form still follows | additive |
| `generalize` | subsume a special case under a more general result | additive |
| `weaken` | strengthen hypotheses / narrow the conclusion | usually breaking `!` |
| `refute` | give a counterexample / disproof of a prior claim | breaking `!` |
| `retract` | withdraw a previously asserted result or proof | breaking `!` |
| `port` | move an informal proof into the proof assistant | additive |

¹ `axiomatize` is **additive on Axis 1** (it introduces a new object), but it is a **trusted-base**
event on Axis 2 — it MUST carry an `AXIOM:` footer and sets `Status: math.axiomatised`. It becomes
Axis-1 breaking only if it *replaces* a previously proved result with an assumed one.

## Status (Axis 2) — bound to `#print axioms`

`Status:` values, namespaced `math.*`:

| `Status:` | Meaning | Ground truth (`axiom-report` / `#print axioms`) |
| --- | --- | --- |
| `math.conjectured` | asserted, unproven | — |
| `math.proved-informal` | paper proof, not formalized | — |
| `math.open` | formalized with a remaining gap | depends on `sorryAx` |
| `math.axiomatised` | formalized **modulo** a cited axiom | depends on a cited/added `axiom` |
| `math.machine-checked` | kernel-checked, no gaps, no added axioms | **clean** (only `propext`, `Classical.choice`, `Quot.sound`) |
| `math.disproved` | shown false (counterexample/disproof) | — |

A commit claiming `math.machine-checked` SHOULD include the actual `Axioms:` line, and that line
SHOULD show only the standard three. Claiming `machine-checked` while the kernel reports a `sorryAx`
or a non-standard axiom is a CKC violation (it is exactly the dishonesty the convention exists to
prevent).

## Trusted-base footers

- `AXIOM: <Name> — <what it is / why cited>` — a cited or added axiom widens the trusted base.
- `OPEN: <what is unproven>` — a remaining `sorry` / `admit` / `sorryAx`.

## Provenance footers

- `Lean: <Fully.Qualified.Name>[, …]` — the declaration(s) this commit touches (the stable ID).
- `Formal-Statement: lean:<FQN>` — alternative spelling binding a claim id to its Lean name.
- `Axioms: <name>[, …]` — the literal `#print axioms` result (`propext, Classical.choice, Quot.sound`
  for a clean result).
- `Verified-By: <assistant + library version>` — e.g. `Lean 4.30.0; Mathlib v4.30.0`.
- `Proof-Hash: sha256:…` — optional content hash of the proof artifact.
- `Cites: <doi|arXiv|ref>` — for `axiomatize`/`lit`: where the cited fact comes from.
- `Phase: <A..H>`, `Gate: <…>` — optional link to the research pipeline ledger (`RESEARCH.md`).

## Identity

The stable identifier of a formal result is its **Lean fully-qualified name** (and/or its blueprint
label, e.g. `thm:master-formula`). These survive rephrasing of the prose and are what `Depends-On:`
/ `Proves:` / `Refutes:` reference. See [`../identifiers.md`](../identifiers.md).

## Examples

```
state(green-kernel): define the elliptic Green's kernel operator

Lean: IGL.greensKernel
Status: math.conjectured
```

```
formalize(fubini): close the d-fold separable factorization (Master Formula)

Mirror MeasureTheory.integral_fintype_prod_eq_prod over Fin d.

Lean: IGL.fubini_dfold, IGL.fubini_factorization
Status: math.machine-checked
Axioms: propext, Classical.choice, Quot.sound
Verified-By: Lean 4.30.0; Mathlib v4.30.0
Closes: conjecture:master-formula
```

```
axiomatize~(exp-sum): cite the Braess–Hackbusch logarithmic rank bound

Mathlib v4.30.0 has no elliptic-Green's exponential-sum theory; posit it as a Tier-3 citation.

Lean: IGL.expSumRank_logBound
Status: math.axiomatised
AXIOM: IGL.expSumRank_logBound — separable rank K = O(log 1/ε), dimension-independent
Cites: Braess & Hackbusch 2005, Numer. Math.
```

```
refute(separability)!: the metric factor √|g| blocks naive separable factorization

A radial counterexample shows the kernel does not factor under the affine-invariant metric.

Disproves: conjecture:naive-separable
Status: math.disproved
BREAKING CHANGE: conjecture:naive-separable is withdrawn; the compensation result depends on it.
```
