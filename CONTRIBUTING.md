# Contributing

Conventional Knowledge Commits is an open specification. It improves through use and discussion.

## Ways to help
- Use it on a real proof or research repository and report what was awkward: a missing type, a footer
  that did not fit, a gap in a profile.
- Open an issue for an ambiguity in the spec, or to propose a type or footer. Bring a concrete commit
  that cannot be expressed cleanly today. Vocabulary is added when a real commit needs it.
- Send a pull request for wording, examples, or a new worked case. Keep every example a valid
  Conventional Commit.

## Principles to preserve
1. Strict superset of Conventional Commits 1.0.0. Never break that compatibility.
2. The two axes stay separate: dependency impact in the `type` and `!` (immutable), epistemic status
   in a footer (mutable). A proposal that merges them again needs a strong case.
3. Honest by design. The proof profile's status and axioms footers should mean the literal
   `#print axioms`. Do not add vocabulary that lets a commit overstate what is established.
4. Negative results stay first-class. Never make refutations or null results second-class.
5. Stay minimal. Prefer an existing footer over a new one.

## Building the site
The site under `docs/` is generated from the markdown documents by `tools/build-pages.sh` (it needs
`pandoc`). The organization disables GitHub Actions, so the site is served by the classic GitHub Pages
branch build from `docs/`, not by a workflow. Run the script locally after editing a document and
commit the regenerated pages.

## Process
- This repository uses Conventional Commits for its own tooling and docs. Branch, then open a pull
  request. Do not push to `main`.
- The spec is versioned (`spec/vX.Y.Z.md`). A breaking change to the spec gets a new file and a MAJOR
  bump; an additive clarification gets a MINOR.
