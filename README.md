<div align="center">

# Conventional Knowledge Commits

**A specification for adding human- and machine-readable meaning to commits that record
mathematical proofs and scientific findings.**

CKC&nbsp;v0.1.0, a strict superset of [**Conventional Commits&nbsp;1.0.0**](https://www.conventionalcommits.org/en/v1.0.0/)

[Website](https://conventional-knowledge-commits.org/) ·
[Specification](spec/v0.1.0.md) ·
[Examples](EXAMPLES.md) ·
[FAQ](FAQ.md)

</div>

---

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) structures software change so
tools can derive a version bump. A research or proof repository commits a different kind of change: a
conjecture posed, a proof closed, an axiom cited, a result refuted, an experiment run. **Conventional
Knowledge Commits (CKC)** extends the convention so a commit can record what was claimed, how strongly
it is established, what it rests on, and what it breaks.

A CKC commit is still a valid Conventional Commit:

```
<type>[~][(scope)][!]: <description>

[body]

[footers]
```

## The one idea: two axes

Changing code raises one question that really matters: **does it break what depends on it?** Changing
knowledge raises a second, independent one: **how sure are we it's true?** CKC tracks these as two
separate axes — keeping them apart is the whole design.

| | Does it break what builds on it?<br>(impact · axis 1) | How sure are we it's true?<br>(status · axis 2) |
| --- | --- | --- |
| in plain terms | if this turns out wrong, what else falls with it? | is it a guess, proven, or machine-checked? |
| written in the commit | the `type` and a `!` mark | a `Status:` line at the bottom |
| can it change later? | **no** — it records what happened | **yes** — a later commit can raise or lower it |
| for example | `refute!`, `retract!`, `formalize` | `conjectured → proved → machine-checked` |

Why two and not one? Code is either compatible or it isn't, so one axis covers it. Knowledge moves on
both at once, and they move independently — so you can't fold them into a single number.

Because they're separate, you never rewrite the past to update the present. Resolve a question that was
left open and that's a **new** commit nudging its status from `open` to `verified`; the earlier record
stays intact. One result can even carry both signals at once — well established, yet still flagged as
resting on an assumption.

## Profiles

A profile is a domain vocabulary on top of the shared core. CKC ships two: **`proof`** for
mathematics and formal proving (Lean and Mathlib are the reference; Rocq, Coq, Isabelle, and Agda
work too), and **`science`** for empirical work. The type you choose implies the profile.

## Why use it

- The commit log is an honest record of what is proved, assumed, open, or disproved, with no separate
  status document to maintain.
- The relation footers form a [ClaimGraph](claimgraph.md). A refutation flags the results that now
  depend on something false; closing a gap promotes the results above it.
- Negative results have a place. Counterexamples, null results, and failed replications are normal
  commit types.
- Provenance travels with the work: the Lean name and `#print axioms` for a proof, the dataset and
  seed for an experiment.
- Nothing new to install. A CKC commit is a Conventional Commit, so existing tooling keeps working.

## Examples

```
formalize(fubini): close the d-fold separable factorization
Lean: IGL.fubini_dfold, IGL.fubini_factorization
Status: math.machine-checked
Axioms: propext, Classical.choice, Quot.sound
Closes: conjecture:master-formula
```

```
axiomatize~(exp-sum): cite the logarithmic rank bound
Lean: IGL.expSumRank_logBound
Status: math.axiomatised
AXIOM: IGL.expSumRank_logBound (separable rank K = O(log 1/ε), dimension-independent)
Cites: Braess & Hackbusch 2005
```

```
refute(separability)!: a counterexample blocks naive factorization
Disproves: conjecture:naive-separable
Status: math.disproved
BREAKING CHANGE: conjecture:naive-separable is withdrawn; the compensation result depends on it.
```

More in [Examples](EXAMPLES.md).

## Documents

- [Specification](spec/v0.1.0.md), the grammar and the numbered rules
- [Proof profile](spec/proof-profile.md), mathematics and formal proving
- [Science profile](spec/science-profile.md), empirical discovery
- [ClaimGraph](claimgraph.md), the dependency graph CKC builds
- [Identifiers](identifiers.md), stable claim and theorem ids
- [Tooling](tooling.md), commit-message hooks and configs ([hotherio/ckc-tools](https://github.com/hotherio/ckc-tools))
- [FAQ](FAQ.md), [Contributing](CONTRIBUTING.md)
- [llms.txt](llms.txt), a condensed version for AI tools

## Prior art

[Conventional Commits](https://www.conventionalcommits.org/) is the base. Semantic Versioning is the
mapping it inspired. [Nanopublications](https://nanopub.net/) (assertion, provenance, publication
info) and [W3C PROV](https://www.w3.org/TR/prov-overview/) are the closest relatives for provenance.

## License

The specification is released under [CC BY 4.0](LICENSE).
