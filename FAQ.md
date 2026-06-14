# FAQ

### Why extend Conventional Commits instead of inventing a new format?
The ergonomics are already right: a short, parseable header plus git-trailer footers, read by both
people and tools. CKC keeps the grammar and only adds vocabulary, so every CKC commit stays a valid
Conventional Commit and existing tooling keeps working.

### Why two axes? Isn't a status enough?
A status alone cannot tell you what breaks. Software conflates the two because it has one scale,
compatibility. Knowledge needs both: dependency impact (did this invalidate dependents?) and
epistemic status (how established is it?). A result can advance in status without breaking anything
(`open` to `machine-checked`), and a commit can break dependents without changing its own status (a
re-statement). Keeping them apart is what makes the ClaimGraph well-defined.

### Why is status a footer instead of part of the type?
Status is mutable; the type is not. When a `sorry` closes months later, you do not rewrite the old
commit's type. You add a new `formalize` commit that moves the `Status:` footer forward. The type
records what happened; the footer records what is believed now, taken from the latest commit that
touched the claim.

### Is introducing an axiom a "breaking change"?
Usually not, on the dependency-impact axis. Citing an axiom is additive, since it introduces an
object, so it does not invalidate dependents. It is a trusted-base event on the status axis: the
status becomes `axiomatised` and the commit carries an `AXIOM:` footer. It is breaking only when it
replaces a previously proved result with an assumed one.

### Does CKC require Lean, or a proof assistant at all?
No. The proof profile is sharpest with a proof assistant, because the trusted base is exact, but the
science profile needs none, and the shared core (`conjecture`, `lit`, `review`, `refute`, `expose`)
is assistant-agnostic.

### Does the proof profile work with Rocq, Coq, Isabelle, or Agda?
Yes. The profile needs two things from a system: a stable name for a declaration, and a way to report
what a proof assumes. Lean is the reference because `#print axioms` makes that explicit, but the same
three states exist everywhere. Use `Verified-By:` to name the system and version, and prefix the
formal name in `Formal-Statement:` (`lean:`, `rocq:`, `coq:`, `isabelle:`, `agda:`). The assumption
check is `#print axioms` in Lean, `Print Assumptions` in Rocq and Coq, `thm_deps` in Isabelle, and
the `--safe` flag with no postulates in Agda. The proof profile lists the mapping.

### How is this kept honest if nothing enforces it?
Version 0.1.0 is convention-only, like Conventional Commits itself. The proof profile is honest by
construction in one respect: the `Status:` and `Axioms:` footers are meant to be the literal output
of the assistant's assumption check. A later, opt-in checker can compare those footers against the
kernel and reject a commit that claims `machine-checked` while a `sorry` or a non-standard axiom is
present. The convention is built for that; it just does not require it.

### What is the relationship to SemVer?
Semantic Versioning (SemVer) is the single decision Conventional Commits serves. CKC's equivalent is
the ClaimGraph, from which a SemVer-style release version can be derived for a knowledge artifact: a
breaking knowledge event is a MAJOR release, a new result or replication is a MINOR, a repair or
cleanup is a PATCH. The graph and the status report are the main payoff; the version number is
optional.

### How do `Depends-On:` and `Refutes:` survive someone rephrasing a theorem?
Through stable identifiers (see the Identifiers page). In the proof profile the identifier is the
assistant's fully-qualified name, which is already rename-aware. In the science profile it is a
curated slug in `claims.toml`, optionally bound to a DOI on publication. Commit hashes are not used
as claim ids: a hash identifies a change, not a claim.

### Why are negative results their own types?
Because hiding them is the failure mode CKC exists to prevent. A counterexample, a disproof, a null
result, and a failed replication are `refute`, `null`, and `replicate` commits, never dropped or
relabelled as a `fix`. The ClaimGraph treats them as the events they are.

### How does this relate to nanopublications and PROV?
They are relatives. A nanopublication is an assertion with its provenance and publication info; W3C
PROV is a general provenance model. CKC carries the same idea (assertion, provenance, relations) but
lives where the work already happens, in the commit log.
