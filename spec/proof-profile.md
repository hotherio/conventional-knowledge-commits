# CKC: the `proof` profile

The `proof` profile is for mathematics and formal proving. It is designed to couple to a proof
assistant (Lean 4 and Mathlib in the reference implementation), where the trusted base is precise: a
result is either kernel-checked, depends on a cited axiom, or has an open `sorry`. `#print axioms`
is the ground truth, and CKC commits report it rather than asserting a status by hand.

CKC keeps a commit honest in two ways: **kernel-honest**, the trusted base is what the assistant's
assumption check reports, and **status-honest**, the footers repeat that report literally. There is
a third layer the first two cannot reach: **transcription-honest**. A claim transcribed from an
external source is only as good as the transcription, and the kernel checks the statement as
written, never that it matches the source. An axiom that silently drops one of the paper's
hypotheses passes every kernel gate while asserting something the paper never said; the fidelity
footers exist to make that comparison auditable (see [Statement fidelity](#statement-fidelity)).

## Proof assistants

The profile is not specific to Lean. It works with any proof assistant that can name a declaration
and report the assumptions a proof depends on. Lean is the reference because its `#print axioms` makes
the trusted base explicit, but the same three states (machine-checked, depends on a cited axiom, has
an open hole) exist in every system. Use the `Verified-By:` footer to name the assistant and version,
and prefix the formal name with the system in `Formal-Statement:`.

| Assistant | Stable name | Trusted-base check | "Machine-checked" footers |
| --- | --- | --- | --- |
| Lean 4 / Mathlib | `Ns.thm` | `#print axioms` | `Formal-Statement: lean:Ns.thm` · `Verified-By: Lean 4.30.0` |
| Rocq / Coq | `Module.thm` | `Print Assumptions thm` | `Formal-Statement: rocq:Module.thm` · `Verified-By: Rocq 9.0` |
| Isabelle/HOL | `Theory.thm` | `thm_deps` / `unused_thms` | `Formal-Statement: isabelle:Theory.thm` |
| Agda | `Module.name` | `--safe` flag, no postulates | `Formal-Statement: agda:Module.name` |

The status mapping is the same everywhere: a clean trusted base is `math.machine-checked`, a cited
axiom or `Axiom`/`Parameter`/`postulate`/`sorry` is `math.axiomatised` or `math.open`. The `Axioms:`
footer carries whatever the system's assumption check prints.

## Types

| Type | Use it when you | Typical impact |
| --- | --- | --- |
| `state` | add a definition or the formal statement of a result, with no proof yet | additive |
| `conjecture` | assert a statement you believe but do not prove | additive |
| `proof` | give or complete an informal (paper) proof | additive |
| `formalize` | write or advance a machine-checkable proof: stubs, tactics, closing goals | additive |
| `axiomatize` | deliberately posit a cited axiom (theory absent from the library) | additive, see note |
| `strengthen` | weaken hypotheses or strengthen the conclusion; the old form still follows | additive |
| `generalize` | subsume a special case under a more general result | additive |
| `weaken` | strengthen hypotheses or narrow the conclusion | usually breaking, `!` |
| `refute` | give a counterexample or disproof of a prior claim | breaking, `!` |
| `retract` | withdraw a previously asserted result or proof | breaking, `!` |
| `port` | move an informal proof into the proof assistant | additive |

Note on `axiomatize`: it is additive on the dependency-impact axis, because it introduces a new
object. On the status axis it is a trusted-base event twice over: it widens the trusted base and it
transcribes. It MUST carry an `AXIOM:` footer and a `Source-Ref:` footer and sets
`Status: math.axiomatised`; it SHOULD carry a `Refutation-Attempt:` (see
[Statement fidelity](#statement-fidelity)). It becomes a breaking change only if it replaces a
previously proved result with an assumed one.

## Status, bound to `#print axioms`

`Status:` values use the `math.*` namespace:

| `Status:` | Meaning | Ground truth (`#print axioms`) |
| --- | --- | --- |
| `math.conjectured` | asserted, unproven | none |
| `math.proved-informal` | paper proof, not formalized | none |
| `math.open` | formalized with a remaining gap | depends on `sorryAx` |
| `math.axiomatised` | formalized assuming a cited axiom | depends on a cited or added `axiom` |
| `math.machine-checked` | kernel-checked, no gaps, no added axioms | clean: only `propext`, `Classical.choice`, `Quot.sound` |
| `math.disproved` | shown false by a counterexample or disproof | none |

A commit claiming `math.machine-checked` SHOULD include the actual `Axioms:` line, and that line
SHOULD show only the standard three. Claiming `machine-checked` while the kernel reports a `sorryAx`
or a non-standard axiom is a CKC violation. That dishonesty is the thing the convention exists to
prevent.

## Trusted-base footers

- `AXIOM: <Name> (<what it is, why cited>)`: a cited or added axiom widens the trusted base.
- `OPEN: <what is unproven>`: a remaining `sorry`, `admit`, or `sorryAx`.

## Statement fidelity

Kernel honesty has a blind spot: the kernel checks the statement as written, not the statement the
source proved. A cited axiom that silently drops one of the paper's hypotheses survives every gate.
The commit is honestly labelled, the `AXIOM:` footer is present, `#print axioms` agrees, and the
statement is false (a missing `μ ≠ ν` can make an axiom refutable in three lines). Transcription is
a trusted-base event of its own, so it gets its own checks and footers. See
[the case study](../case-study.md) for a real instance.

Three checks, before the axiom lands:

1. **Hypothesis parity.** Put the formal statement next to the verbatim source text and account for
   every hypothesis: present, or its absence argued in the body. Type-correct is not parity.
2. **Adversarial instantiation.** Try to refute the statement as written with degenerate instances
   (equal measures, dimension one, the empty and the trivial case). A dropped hypothesis usually
   falls to the first one.
3. **Model adequacy.** The formal class must be able to express what the source's proof uses. If
   the paper's argument needs a measure-dependent flow, a linear flow type cannot host it, however
   cleanly each statement typechecks.

The footers:

- `Source-Ref: <work, locus>`: the verbatim statement the transcription is answerable to (theorem,
  equation, or page).
- `Refutation-Attempt: <artifact> | none-found: <attacks tried>`: the attempt to break the
  statement as written, or the attacks that failed to.
- `Fidelity-Reviewed: <reviewer, date>`: OPTIONAL human sign-off that the parity check was done.

When a draft axiom was refuted and then repaired, keep the disproof of the refuted draft compiling
as a must-fail regression, so re-loosening the statement breaks the build instead of quietly
reviving the bad transcription. Reference practice, not a requirement.

## Provenance footers

- `Lean: <Fully.Qualified.Name>[, ...]`: the declaration(s) this commit touches, which is the stable id.
- `Formal-Statement: lean:<FQN>`: an alternative spelling that binds a claim id to its Lean name.
- `Axioms: <name>[, ...]`: the literal `#print axioms` result (`propext, Classical.choice, Quot.sound`
  for a clean result).
- `Verified-By: <assistant and library version>`, for example `Lean 4.30.0; Mathlib v4.30.0`.
- `Proof-Hash: sha256:...`: an optional content hash of the proof artifact.
- `Cites: <doi|arXiv|ref>`: for `axiomatize` and `lit`, where the cited fact comes from.
- `Source-Ref: <work, locus>`, `Refutation-Attempt: <artifact> | none-found: <attacks tried>`,
  `Fidelity-Reviewed: <reviewer, date>`: the fidelity footers; see
  [Statement fidelity](#statement-fidelity).
- `Phase: <A..H>`, `Gate: <...>`: an optional link to a research pipeline ledger.

## Identity

The stable identifier of a formal result is its Lean fully-qualified name, optionally with a
blueprint label such as `thm:master-formula`. These survive a rewrite of the prose and are what
`Depends-On:`, `Proves:`, and `Refutes:` reference. See [Identifiers](../identifiers.md).

## Examples

```
state(green-kernel): define the elliptic Green's kernel operator

Lean: IGL.greensKernel
Status: math.conjectured
```

```
formalize(fubini): close the d-fold separable factorization

Lean: IGL.fubini_dfold, IGL.fubini_factorization
Status: math.machine-checked
Axioms: propext, Classical.choice, Quot.sound
Verified-By: Lean 4.30.0; Mathlib v4.30.0
Closes: conjecture:master-formula
```

```
axiomatize~(exp-sum): cite the logarithmic exponential-sum rank bound

The target library has no elliptic-Green's exponential-sum theory, so posit it as a citation.

Lean: IGL.expSumRank_logBound
Status: math.axiomatised
AXIOM: IGL.expSumRank_logBound (separable rank K = O(log 1/ε), dimension-independent)
Source-Ref: Braess & Hackbusch 2005, Numer. Math., Thm 3.1
Cites: Braess & Hackbusch 2005, Numer. Math.
```

```
refute(separability)!: a counterexample blocks naive separable factorization

Disproves: conjecture:naive-separable
Status: math.disproved
BREAKING CHANGE: conjecture:naive-separable is withdrawn; the compensation result depends on it.
```
