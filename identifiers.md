# Stable identifiers

The impact graph needs identifiers for claims and theorems that **survive rephrasing** — you must
be able to `Depends-On:` or `Refutes:` a result even after its statement text is edited. Commit
SHAs won't do (they identify a change, not a claim). CKC uses a **hybrid** scheme: reuse what is
already stable in the proof setting, and curate a lightweight registry for the empirical setting.

## `proof` profile — reuse what the assistant already gives you

A formal result already has a stable name: its **fully-qualified declaration name** in the proof
assistant. This is canonical, machine-checkable, and rename-aware (a rename is a visible refactor,
not a silent drift).

- Primary id: the Lean fully-qualified name, e.g. `IGL.fubini_factorization`, recorded as
  `Lean:` / `Formal-Statement: lean:IGL.fubini_factorization`.
- Human-facing alias: the **blueprint label**, e.g. `thm:master-formula`, used in prose and as a
  `scope`.
- Optional: `Proof-Hash: sha256:…` over the proof term, when you want to detect that a proof (not
  the statement) changed.

A statement edit that changes the theorem's meaning is **not** "the same claim" — use a new name and
`Supersedes:` the old one, or mark it Axis-1 breaking.

## `science` profile — a curated registry

Empirical claims have no canonical formal statement, so each gets a **slug** minted in a registry
file at the repo root, `claims.toml`. The slug is what `Closes:` / `Refutes:` / `Depends-On:`
reference; the registry maps it to the human statement, provenance, and (once published) a DOI.

```toml
# claims.toml — the claim registry (one entry per claim/hypothesis)

[claims.tensor-rank-helps]
kind        = "hypothesis"          # hypothesis | finding | definition
statement   = "Tensor rank K>1 beats K=1 on non-additive targets."
status      = "sci.not-replicated"  # cache of the graph-derived effective status
created     = "2026-06-14"
prereg      = "osf.io/abcd1"
doi         = ""                     # filled on publication

[claims.naive-separable]
kind        = "conjecture"
statement   = "The Green's kernel factorises separably without metric compensation."
status      = "math.disproved"
lean        = "IGL.naiveSeparable"   # a proof-side claim may carry both a slug and a Lean name
```

Referencing convention: a slug is written `conjecture:<slug>` / `claim:<slug>` / `result:<slug>` in
footers (the prefix mirrors the kind). The `claims.toml` `status` field is a **cache** of the
effective status computed from the commit graph — regenerate it, don't hand-edit it as the source of
truth.

## When to mint a global id (DOI / URI)

Keep ids **local** (Lean name or registry slug) while work is in progress — global ids are ceremony
you don't need for unpublished claims. Bind a **DOI or URI** at publication (paper accepted, dataset
released, library tagged), recording it in `claims.toml` and/or a `Cites:`/`Claim-ID:` footer, so
external work can reference the claim stably across repositories.

## Summary

| Setting | Stable id | Recorded as |
| --- | --- | --- |
| Formal result | Lean FQN (+ blueprint label) | `Lean:` / `Formal-Statement:` / scope |
| Empirical claim | curated slug in `claims.toml` | `Claim-ID:` / `conjecture:<slug>` |
| Published artifact | DOI / URI | `claims.toml` `doi`, `Cites:` |
