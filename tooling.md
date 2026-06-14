# Tooling

Hooks and configs that validate CKC commit messages live in a separate repository,
[hotherio/ckc-tools](https://github.com/hotherio/ckc-tools). They are built to **run alongside
existing [Conventional Commits](https://www.conventionalcommits.org/) tooling, not replace it.**

## The collision, and how to avoid it

A strict Conventional Commits validator allows only a fixed list of types, so it rejects CKC types
such as `formalize` and `experiment`. Because CKC is a superset, a CKC validator already accepts
every plain Conventional Commit (`feat`, `fix`, `docs`). The rule is simple: never run two validators
with disjoint type lists. A repository that holds both a paper and its proofs uses the CKC validator
and nothing conflicts, since it accepts both plain Conventional Commits for tooling and CKC commits
for the work.

## What is available

- `ckc-lint`, a `commit-msg` validator (Python, no Node). It checks that a message is a valid
  Conventional Commit and follows CKC: a known type for the active profiles, a known `Status:` value,
  uppercase trusted-base markers, `~` consistency, and well-formed relation footers.
- `ckc-axiom-check`, an opt-in honesty hook for the proof profile. When a commit claims
  `Status: math.machine-checked`, it cross-checks the named `Lean:` declarations against the kernel
  via the lean-math `axiom-report` and rejects the commit if the kernel disagrees.
- `commitlint-config-ckc`, a [commitlint](https://commitlint.js.org/) shareable config for the
  JavaScript world that widens `type-enum` to the CKC vocabulary.

## Profiles

A repository chooses which profiles are active: `proof`, `science`, or both (the default). With one
profile active, a type from the other profile is rejected. Set it with the `--profile` flag,
`$CKC_PROFILES`, or a `.ckc.toml` at the repo root:

```toml
# .ckc.toml
profiles = ["proof"]   # or ["science"], or ["proof", "science"]
```

## With the pre-commit framework

For a repository with no Conventional Commits hook yet, `ckc` alone validates both Conventional
Commits and CKC:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/hotherio/ckc-tools
    rev: v0.1.3
    hooks:
      - id: ckc
```

```bash
pre-commit install --hook-type commit-msg
```

The id `ckc` is also available as `conventional-knowledge-pre-commit`, an alias named to parallel
`conventional-pre-commit`. Both ids run the same validator.

`ckc` is a drop-in superset of `conventional-pre-commit`: it accepts the same interface (positional
types, `--strict`, `--force-scope`, `--scopes`, `--no-color`, `--verbose`, exit codes 0 and 1, and
`fixup!`/merge commits passing unless `--strict`), and additionally allows the CKC vocabulary and runs
the CKC checks. You have two options.

### Migrate to ckc only

Drop `conventional-pre-commit` and keep your existing `args`: change the `repo` and `id`, and the rest
carries over (a pinned type list is still honoured exactly; remove it to allow the full CKC
vocabulary).

```yaml
- repo: https://github.com/hotherio/ckc-tools
  rev: v0.1.3
  hooks:
    - id: ckc
      stages: [commit-msg]
      args: [--strict, --scopes, "api,client"]   # the same args you gave conventional-pre-commit
```

### Or keep conventional-pre-commit

If you prefer to keep it, run `ckc` next to it and widen `conventional-pre-commit`'s allowed types so
it stops rejecting CKC types. Generate the list with `ckc-lint --print-types` (it respects the active
profiles) and paste it into the hook's `args`. Both hooks run on `commit-msg`; neither is replaced.

## With lefthook

```yaml
# lefthook.yml
commit-msg:
  commands:
    ckc:
      run: ckc-lint {1}
```

`lefthook` passes the commit message file as `{1}`. Install `ckc-lint`
(`pip install git+https://github.com/hotherio/ckc-tools`) first.

## With commitlint

```js
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional', 'commitlint-config-ckc'],
};
```

`commitlint-config-ckc` extends `config-conventional` and only widens the type list, so it runs
alongside a conventional setup rather than replacing it.

## The honesty hook

`ckc-axiom-check` extends the lean-math working-tree honesty gate into the commit log. It acts only
on a commit that claims `math.machine-checked` or `math.axiomatised` and names `Lean:` declarations,
and it rejects only a genuine contradiction (the kernel reports a `sorryAx` or a cited axiom while
the commit claims `machine-checked`). It needs Lean, a built project, and `axiom-report` on `PATH`
(or `$CKC_AXIOM_REPORT`); when it cannot determine a declaration's status it skips.

See [hotherio/ckc-tools](https://github.com/hotherio/ckc-tools) for the full readme and the
single-source vocabulary (`vocab.json`) shared by the Python validator and the commitlint config.
