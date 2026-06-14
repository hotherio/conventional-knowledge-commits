<div align="center">

# Conventional Knowledge Commits

**A specification for adding human- and machine-readable meaning to commits that record
mathematical proofs and scientific findings.**

CKC&nbsp;v0.1.0 · a strict superset of [Conventional Commits&nbsp;1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)

</div>

---

Conventional Commits structures *software* change so tools can derive a SemVer bump. But a
research or proof repository commits a different kind of change — a conjecture posed, a proof
closed, an axiom cited, a result refuted, an experiment run. **Conventional Knowledge Commits
(CKC)** extends the convention so a commit records a **knowledge delta**: what was claimed, how
strongly it is established, what it rests on, and what it breaks.

A CKC commit is still a valid Conventional Commit:

```
<type>[(scope)][~][!]: <description>

[body]

[footers]
```

## The one idea: two axes

Software change has one lattice — backward compatibility. Knowledge change has **two orthogonal**
axes, and separating them is the whole design:

| | Axis 1 — **dependency impact** | Axis 2 — **epistemic status** |
| --- | --- | --- |
| answers | *does this invalidate what depends on it?* | *how strongly is it established now?* |
| lives in | the `type` and `!` (the SemVer analog) | a `Status:` footer |
| mutability | **immutable** — a historical fact | **mutable** — advanced by later commits |
| examples | `refute!`, `retract!`, `formalize` | `math.conjectured → machine-checked` |

Because they are separate, closing a `sorry` later is a **new** `formalize` commit that flips
`Status: math.open → math.machine-checked` — you never rewrite history, and a single `#print axioms`
result can be both an Axis-2 status (`axiomatised`) and an Axis-1 caveat (an `AXIOM:` footer).

## Examples

```
formalize(fubini): close the d-fold separable factorization
Lean: IGL.fubini_dfold, IGL.fubini_factorization
Status: math.machine-checked
Axioms: propext, Classical.choice, Quot.sound
Closes: conjecture:master-formula
```

```
axiomatize~(exp-sum): cite the Braess–Hackbusch logarithmic rank bound
Lean: IGL.expSumRank_logBound
Status: math.axiomatised
AXIOM: IGL.expSumRank_logBound — separable rank K = O(log 1/ε), dimension-independent
Cites: Braess & Hackbusch 2005
```

```
refute(separability)!: the metric √|g| blocks naive separable factorization
Disproves: conjecture:naive-separable
Status: math.disproved
BREAKING CHANGE: conjecture:naive-separable is withdrawn; the compensation result depends on it.
```

```
experiment(non-additive): K=1 vs K>1 on XOR/radial targets   ← science profile
Status: sci.measured
Metric: MSE   Seed: 0..4   Hardware: M4 (MPS)
UNREPLICATED: single machine, 5 seeds
Closes: conjecture:tensor-rank-helps
```

More in [`EXAMPLES.md`](./EXAMPLES.md).

## What it gives you

The relation footers (`Depends-On`, `Proves`, `Refutes`, `Closes`, …) form a **knowledge impact
graph**. From it, tooling can:

- propagate a **refutation** to its dependents (mark them *in question* — the blast radius);
- **promote** dependents when a gap closes, and compute each result's *effective status* as the
  minimum over its dependencies (exactly how a cited axiom surfaces downstream);
- derive an honest **status report** (proved / axiomatised / open / replicated) and, optionally, a
  SemVer-style **release version** for a paper or a formalized library.

See [`impact-graph.md`](./impact-graph.md).

## Specification

- **[spec/v0.1.0.md](./spec/v0.1.0.md)** — the normative spec (grammar + numbered rules).
- **[spec/proof-profile.md](./spec/proof-profile.md)** — mathematics & formal proving (Lean/Mathlib-coupled).
- **[spec/science-profile.md](./spec/science-profile.md)** — empirical discovery.
- **[identifiers.md](./identifiers.md)** — stable claim/theorem identifiers (the hidden prerequisite).
- **[FAQ.md](./FAQ.md)** · **[CONTRIBUTING.md](./CONTRIBUTING.md)**

## Prior art & kin

[Conventional Commits](https://www.conventionalcommits.org/) (the base), SemVer (the mapping it
inspired), [nanopublications](http://nanopub.org/) (assertion + provenance + publication-info), and
[W3C PROV](https://www.w3.org/TR/prov-overview/) (provenance). CKC borrows the commit-message
ergonomics of the first and the provenance discipline of the others.

## License

The specification is released under [CC BY 4.0](./LICENSE).
