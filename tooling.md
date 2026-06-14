# Tooling

Hooks and configs that validate CKC commit messages live in a separate repository,
[hotherio/ckc-tools](https://github.com/hotherio/ckc-tools). They are built to **compose with
existing [Conventional Commits](https://www.conventionalcommits.org/) tooling, not collide with it.**

## The collision, and how to avoid it

A strict Conventional Commits validator allows only a fixed list of types, so it rejects CKC types
such as `formalize` and `experiment`. Because CKC is a superset, a CKC validator already accepts
every plain Conventional Commit (`feat`, `fix`, `docs`). The rule is simple: never run two validators
with disjoint type lists. A repository that holds both a paper and its proofs uses the CKC validator
and nothing conflicts, since it accepts both plain Conventional Commits for tooling and CKC commits
for the work.

## What is available

- `ckc-lint`, a `commit-msg` validator (Python, no Node). It checks that a message is a valid
  Conventional Commit and follows CKC: a known type, a known `Status:` value, uppercase trusted-base
  markers, `~` consistency, and well-formed relation footers.
- `ckc-axiom-check`, an opt-in honesty hook for the proof profile. When a commit claims
  `Status: math.machine-checked`, it cross-checks the named `Lean:` declarations against the kernel
  via the lean-math `axiom-report` and rejects the commit if the kernel disagrees.
- `commitlint-config-ckc`, a [commitlint](https://commitlint.js.org/) shareable config for the
  JavaScript world that widens `type-enum` to the CKC vocabulary.

## Install with the pre-commit framework

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/hotherio/ckc-tools
    rev: v0.1.0
    hooks:
      - id: ckc
      # opt-in proof honesty check (needs Lean and axiom-report):
      # - id: ckc-axiom-check
```

```bash
pre-commit install --hook-type commit-msg
```

If you already use [`conventional-pre-commit`](https://github.com/compilerla/conventional-pre-commit),
replace it with the `ckc` hook, which is a superset that still accepts plain Conventional Commits, or
keep it and pass the CKC types in its `args:`.

## Install with commitlint

```js
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional', 'commitlint-config-ckc'],
};
```

`commitlint-config-ckc` extends `config-conventional` and only widens the type list. Do not add a
second config that re-narrows it.

## The honesty hook

`ckc-axiom-check` extends the lean-math working-tree honesty gate into the commit log. It acts only
on a commit that claims `math.machine-checked` or `math.axiomatised` and names `Lean:` declarations,
and it rejects only a genuine contradiction (the kernel reports a `sorryAx` or a cited axiom while
the commit claims `machine-checked`). It needs Lean, a built project, and `axiom-report` on `PATH`
(or `$CKC_AXIOM_REPORT`); when it cannot determine a declaration's status it skips.

See [hotherio/ckc-tools](https://github.com/hotherio/ckc-tools) for the full readme and the
single-source vocabulary (`vocab.json`) shared by the Python validator and the commitlint config.
