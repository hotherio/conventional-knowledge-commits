---
name: conventional-knowledge-commits
description: >
  Write and validate Conventional Knowledge Commits (CKC) for knowledge work. Use when committing
  a theorem, lemma, definition, conjecture, paper proof, or formalization in any proof assistant
  (a closed gap, a cited axiom, a refutation), or an empirical experiment, result, replication, or
  null result; when choosing a Status: footer or a relation footer (Depends-On, Proves, Refutes,
  Closes, Supersedes); when positing an axiom or citing an external source (Source-Ref,
  Refutation-Attempt); or when recording a preregistered experiment (Protocol-Deviations). This is
  the tool-agnostic community skill from conventional-knowledge-commits.org; it assumes no
  particular assistant, lab, or validator.
license: CC BY 4.0 (https://github.com/hotherio/conventional-knowledge-commits)
---

# Conventional Knowledge Commits

CKC is a strict superset of Conventional Commits 1.0.0 for commits that record knowledge:
mathematical claims and proofs, and empirical findings. Machine reference:
https://conventional-knowledge-commits.org/llms.txt. Full spec:
https://conventional-knowledge-commits.org/.

## Grammar

```
<type>[~][(scope)][!]: <description>

[body]

[footers]
```

- `!` (or a `BREAKING CHANGE:` footer) marks a change that invalidates dependents.
- `~` after the type flags a trusted-base caveat at a glance; the uppercase footer is the record.
- Footers are git trailers (`Token: value`, `-` for spaces, repeatable).

## Types

- Shared: `conjecture`, `lit`, `review`, `refute` (usually `!`), `retract` (`!`), `expose`, `meta`.
- Proof profile: `state`, `proof`, `formalize`, `axiomatize`, `strengthen`, `generalize`,
  `weaken` (`!`), `port`.
- Science profile: `experiment`, `result`, `replicate`, `null`, `data`, `protocol`, `method`,
  `analysis`, `repro-fix`.
- Plain Conventional Commits types (`feat`, `fix`, `docs`, `chore`, ...) remain for tooling and
  prose. The type you choose implies the profile.

## Status ladders (the epistemic axis, always a footer, advanced only by new commits)

- Math: `math.conjectured`, `math.proved-informal`, `math.open` (an unproven gap),
  `math.axiomatised` (rests on a cited axiom), `math.machine-checked` (assumption check clean),
  `math.disproved`.
- Science: `sci.hypothesis`, `sci.piloted`, `sci.measured`, `sci.supported`, `sci.replicated`,
  `sci.not-replicated`, `sci.falsified`.

## Footers

- Trusted-base (UPPERCASE, like BREAKING CHANGE): `AXIOM:`, `OPEN:` (proof); `ASSUMES:`,
  `UNREPLICATED:` (science).
- Relations (build the ClaimGraph): `Depends-On`, `Assumes`, `Proves`, `Refutes`, `Disproves`,
  `Supersedes`, `Retracts`, `Invalidates`, `Closes`.
- Provenance: `Formal-Statement:` (with a `lean:`/`rocq:`/`isabelle:`/`agda:` prefix), `Axioms:`
  (the literal assumption-check output), `Verified-By:`, `Cites:`, and for science `Dataset:`,
  `Protocol:`, `Pre-Registration:`, `Sample-Size:`, `Effect-Size:`, `Seed:`, and kin.
- Fidelity (rule 14): `Source-Ref: <work, locus>`, `Refutation-Attempt: <artifact> |
  none-found: <attacks tried>` (proof), `Protocol-Deviations: none | <log>` (science),
  `Fidelity-Reviewed: <reviewer, date>` (optional sign-off).

## Writing a commit

1. One claim per commit. Pick the type from the work done (what happened), not from the status.
2. Name the claim stably: the assistant's fully-qualified name for a formal result, a curated slug
   (`conjecture:<slug>`) for anything else.
3. Set `Status:` from ground truth, never by hand: run the assistant's assumption check
   (`#print axioms`, `Print Assumptions`, `thm_deps`, `--safe`) and report it literally in
   `Axioms:`. Clean check = `machine-checked`; a cited axiom = `axiomatised` + `AXIOM:` + `~`;
   a hole = `open` + `OPEN:` + `~`.
4. Wire the graph: `Depends-On:`/`Assumes:` what it rests on, `Closes:`/`Proves:` what it settles,
   `Refutes:`/`Disproves:` + `!` what it breaks.
5. Negative results are normal commits (`refute`, `null`, failed `replicate`), never a `fix`.

## The fidelity discipline (before any statement that is "true by citation")

A claim transcribed from an external source is only as good as the transcription, and no
verification of the statement as written can see a transcription error. This is the third honesty:
a commit can be kernel-honest (the trusted base is what the check reports) and status-honest (the
footers repeat it literally) and still transcription-dishonest. Before an `axiomatize` commit, or a
`sci.measured`/`sci.supported` result citing a registration:

1. **Quote the source verbatim, with its locus** (theorem, equation, page, or registry section).
   Put it in the statement's docstring or the commit body.
2. **Hypothesis parity.** Account for every hypothesis in the source: present in your statement, or
   its absence argued in writing. Type-correct is not parity. For science: walk the registered
   protocol item by item against what actually ran.
3. **Adversarial instantiation.** Try to refute your statement as written on the inputs the
   source's hypotheses exclude: equal or empty or degenerate objects, boundary dimensions, the
   trivial case. A dropped hypothesis usually falls to the first attack. If it falls, fix the
   statement, and keep the disproof of the bad draft as a regression so no one re-loosens it.
4. **Model adequacy.** Check the formal class you quantify over can express what the source's
   proof uses. If the argument needs a structure your encoding erased (measure dependence,
   nonlinearity, architecture), no per-statement patch will save it.
5. **Record it**: `Source-Ref:` (mandatory for citation-truth statuses), `Refutation-Attempt:`
   with the artifact or the attacks tried, `Protocol-Deviations:` (`none` only if item-by-item
   true), `Fidelity-Reviewed:` if a human signed off.

## Rules of thumb

- Every CKC commit is a valid Conventional Commit.
- Status moves only through new commits; history is append-only.
- Never claim `machine-checked` with a hole or a non-standard axiom present.
- Never claim a citation without anchoring the exact statement cited (`Source-Ref:`).
- The three honesties: kernel-honest, status-honest, transcription-honest. Tooling checks the
  first two; only the fidelity discipline covers the third.

## Example

```
axiomatize~(cheb-interp): cite the Chebyshev interpolation error bound

The target library has no multivariate Chebyshev interpolation theory. The source requires f
analytic in the Bernstein ellipse E_rho, rho > 1; both hypotheses kept.

Formal-Statement: lean:IGL.chebInterpError
Status: math.axiomatised
AXIOM: IGL.chebInterpError (sup-norm error <= C*rho^(-n), f analytic in E_rho, rho > 1)
Source-Ref: Trefethen 2013, Approximation Theory and Approximation Practice, Thm 8.2
Refutation-Attempt: none-found: rho -> 1 collapse, merely-continuous f, n = 0
Cites: Trefethen 2013, Approximation Theory and Approximation Practice
```

Optional tooling (validators, the honesty hook, the ClaimGraph builder):
https://github.com/hotherio/ckc-tools and https://github.com/hotherio/claimgraph.
