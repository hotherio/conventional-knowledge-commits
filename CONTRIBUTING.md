# Contributing

Conventional Knowledge Commits is an open specification; it improves through use and discussion.

## Ways to help
- **Use it** on a real proof or research repo and report what was awkward — missing types, footers
  that didn't fit, a profile gap.
- **Open an issue** for ambiguities in the spec, or proposed types/footers (with a concrete commit
  that needs them — vocabulary is added when a real commit can't be expressed cleanly).
- **Send a PR** for wording, examples, or a new worked case. Keep every example a *valid Conventional
  Commit*.

## Principles (please preserve)
1. **Strict superset of Conventional Commits 1.0.0** — never break that compatibility.
2. **Two axes stay separate** — dependency impact in `type`/`!` (immutable), epistemic status in a
   footer (mutable). Proposals that re-merge them need a strong case.
3. **Honest by design** — the `proof` profile's status/axioms footers should mean the literal
   `#print axioms`. Don't add vocabulary that lets a commit overstate what's established.
4. **Negative results are first-class** — never make refutations/null-results second-class.
5. **Minimal** — prefer reusing an existing footer over adding one.

## Process
- This repo follows **its own convention** for commits where it applies, and Conventional Commits
  for tooling/docs. Branch + PR; do not push to `main`.
- Versioning: the spec is versioned (`spec/vX.Y.Z.md`); breaking changes to the *spec* get a new
  file and a MAJOR bump, additive clarifications a MINOR.
