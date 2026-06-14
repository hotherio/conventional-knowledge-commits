# FAQ

### Why extend Conventional Commits instead of inventing something new?
Because the ergonomics are already right: a short, parseable header plus git-trailer footers,
understood by humans and tools. CKC keeps the grammar verbatim and only adds vocabulary, so every
CKC commit stays a valid Conventional Commit and existing tooling (changelog, lint) keeps working.

### Why two axes? Isn't a status enough?
A status alone can't tell you what *breaks*. Software conflates the two because there's one lattice
(compatibility). Knowledge needs both: **dependency impact** (did this invalidate dependents?) and
**epistemic status** (how established is it?). A result can advance in status without breaking
anything (`open → machine-checked`), and a commit can break dependents without changing its own
status (a re-statement). Separating them is what makes the impact graph well-defined.

### Why is status a *footer* and not part of the type?
Because status is **mutable** and the type is **immutable**. When a `sorry` closes months later,
you don't want to rewrite the old commit's type — you add a new `formalize` commit that flips the
`Status:` footer. The type records *what happened* (a historical fact); the footer records *what is
believed now* (recomputed from the latest commit touching the claim).

### Is introducing an axiom a "breaking change"?
Not on Axis 1, usually. Citing an axiom is *additive* — it introduces an object — so it doesn't
invalidate dependents. It is a **trusted-base** event on Axis 2: the status becomes `axiomatised`
and the commit carries an `AXIOM:` footer. It only becomes Axis-1 breaking if it *replaces* a
previously proved result with an assumed one.

### How is this kept honest? There's no enforcement.
v0.1.0 is convention-only, like Conventional Commits itself. But the `proof` profile is honest *by
construction* in one important way: the `Status:` and `Axioms:` footers are meant to be the literal
`#print axioms` result. A future, opt-in checker can cross-check those footers against the kernel
and reject a commit that claims `machine-checked` while a `sorryAx` or a non-standard axiom is
present — extending a working-tree honesty gate into history. The convention is designed for that;
it just doesn't mandate it.

### What's the relationship to SemVer?
SemVer is the single decision Conventional Commits serves. CKC's analog is the **impact graph**,
from which a SemVer-style release version *derives* for a knowledge artifact: a breaking knowledge
event → MAJOR, a new result or replication → MINOR, a repair/cleanup → PATCH. But the graph (and the
status report it yields) is the primary payoff; the version number is optional.

### How do `Depends-On:` / `Refutes:` survive someone rephrasing a theorem?
Via stable identifiers ([`identifiers.md`](./identifiers.md)). In the `proof` profile the identifier
is the proof assistant's fully-qualified name (and a blueprint label) — already rename-aware. In the
`science` profile it's a curated slug in `claims.toml`, optionally bound to a DOI on publication.
Commit SHAs are deliberately *not* used as claim ids: a SHA identifies a change, not a claim.

### Why are negative results first-class types?
Because hiding them is the failure mode CKC exists to prevent. A counterexample, a disproof, a null
result, and a failed replication are `refute` / `null` / `replicate (sci.not-replicated)` commits —
never silently dropped or downgraded to a `fix`. The impact graph treats them as the events they
are.

### Does CKC require Lean, or a proof assistant at all?
No. The `proof` profile is sharpest with a proof assistant (the trusted base is exact), but the
`science` profile needs none, and the shared core (`conjecture`, `lit`, `review`, `refute`,
`expose`) is assistant-agnostic. The Lean/Mathlib coupling in the examples is the reference
implementation, not a requirement.

### How does this relate to nanopublications and PROV?
They're kin. A nanopublication is an *assertion + its provenance + publication info*; W3C PROV is a
general provenance model. CKC carries the same spirit — assertion (type + description), provenance
(footers), relations (the graph) — but lives where the work already happens: the commit log.
