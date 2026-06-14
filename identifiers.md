# Stable identifiers

The [ClaimGraph](./claimgraph.md) needs identifiers for claims and theorems that survive a rewrite
of their wording. You must be able to `Depends-On:` or `Refutes:` a result even after its statement
text is edited. Commit hashes do not work for this, because a hash identifies a change, not a claim.
CKC uses a hybrid scheme: reuse what is already stable in the proof setting, and curate a lightweight
registry for the empirical setting.

## Proof profile: reuse the assistant's name

A formal result already has a stable name: its fully-qualified declaration name in the proof
assistant. It is canonical, machine-checkable, and rename-aware, since a rename is a visible refactor
rather than a silent drift.

- Primary id: the fully-qualified name, for example `IGL.fubini_factorization`, recorded as `Lean:`
  or `Formal-Statement: lean:IGL.fubini_factorization`.
- Human-facing alias: the blueprint label, for example `thm:master-formula`, used in prose and as a
  `scope`.
- Optional: `Proof-Hash: sha256:...` over the proof term, when you want to detect that a proof, rather
  than a statement, has changed.

A statement edit that changes the theorem's meaning is not the same claim. Use a new name and
`Supersedes:` the old one, or mark it a breaking change.

## Science profile: a curated registry

Empirical claims have no canonical formal statement, so each gets a slug recorded in a registry file
at the repository root, `claims.toml`. The slug is what `Closes:`, `Refutes:`, and `Depends-On:`
reference. The registry maps it to the human statement, its provenance, and, once published, a DOI.

```toml
# claims.toml: the claim registry (one entry per claim or hypothesis)

[claims.tensor-rank-helps]
kind        = "hypothesis"          # hypothesis, finding, definition
statement   = "Tensor rank K>1 beats K=1 on non-additive targets."
status      = "sci.not-replicated"  # a cache of the graph-derived effective status
created     = "2026-06-14"
prereg      = "osf.io/abcd1"
doi         = ""                     # filled in on publication

[claims.naive-separable]
kind        = "conjecture"
statement   = "The Green's kernel factorises separably without metric compensation."
status      = "math.disproved"
lean        = "IGL.naiveSeparable"   # a proof-side claim may carry both a slug and a Lean name
```

A slug is written `conjecture:<slug>`, `claim:<slug>`, or `result:<slug>` in footers, with the prefix
mirroring the kind. The `status` field in `claims.toml` is a cache of the effective status computed
from the commit graph. Regenerate it; do not hand-edit it as the source of truth.

## When to mint a global id

Keep ids local (a Lean name or a registry slug) while work is in progress. Global ids are ceremony
you do not need for unpublished claims. Bind a DOI or URI at publication, when a paper is accepted, a
dataset is released, or a library is tagged. Record it in `claims.toml` or a `Cites:` or `Claim-ID:`
footer, so other repositories can reference the claim.

## Summary

| Setting | Stable id | Recorded as |
| --- | --- | --- |
| Formal result | the assistant's fully-qualified name, and a blueprint label | `Lean:`, `Formal-Statement:`, `scope` |
| Empirical claim | a curated slug in `claims.toml` | `Claim-ID:`, `conjecture:<slug>` |
| Published artifact | a DOI or URI | `claims.toml` `doi`, `Cites:` |
