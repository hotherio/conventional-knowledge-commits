# Case study: the axiom that passed every gate

This page walks through a real incident, in a public repository, that motivated rule 14
(transcription fidelity) and the fidelity footers. Everything below is verifiable:
[aquemy/measure-to-measure-transformers](https://github.com/aquemy/measure-to-measure-transformers)
is a Lean 4 formalization of a published optimal-control paper
([arXiv:2411.04551](https://arxiv.org/abs/2411.04551), measure-to-measure interpolation using
Transformers), tracked with CKC end to end. The repository's own post-mortem lives in its
[RESEARCH.md](https://github.com/aquemy/measure-to-measure-transformers/blob/main/RESEARCH.md)
(findings F11 to F16) and
[ERRATA.md](https://github.com/aquemy/measure-to-measure-transformers/blob/main/ERRATA.md).

## The setup

The project ran every honesty gate CKC and its tooling offer. Each commit was validated by
`ckc-lint`. The build had to pass. A sweep rejected any `sorry`, `admit`, or `native_decide`. An
`axiom-report` ran `#print axioms` on every blueprint node. A ClaimGraph audit failed the build if
a node claimed proved while the kernel disagreed, and a reconcile pass failed it if a committed
status drifted from the kernel. By kernel-honesty and status-honesty standards, this repository was
airtight.

Because the paper needs mathematics the target library does not have (optimal transport,
continuity-equation flows), the deep prerequisites were deliberately posited as labelled axioms:
`axiomatize` commits, `Status: math.axiomatised`, one `AXIOM:` footer each, a citation to the paper
section. Exactly the honest posture the proof profile prescribes.

## The entry

The axioms landed on one evening, in commits whose footers were, by v0.1.0 standards, impeccable:

```
formalize~(statements): close the open mid-level statements as labeled axioms

Status: math.axiomatised
AXIOM: prop_2_1, prop_2_2, lemma_3_2, lemma_3_3, lemma_3_4_part1, lemma_3_4_part2,
  prop_4_1, prop_4_2, lemma_5_1, lemma_5_4, lemma_B_2, cluster_to_point
  (continuity-equation / LaSalle / optimal-transport facts absent from Mathlib)
Closes: ...twelve claims...
Depends-On: ...the flow-algebra axioms...
```

No `Verified-By:`. No source anchor. The body asserted "no axiom is unsound" after a fidelity
review of two of the twelve stubs. The other ten went in as they were: type-correct transcriptions
of the paper's statements, with hypotheses silently missing.

## The survival

Nothing caught it, for 135 commits over two and a half days. Every gate passed, and each was blind
for a precise reason:

- The kernel checks the statement as written. A false statement is a perfectly well-typed axiom.
- The `#print axioms` report and the ClaimGraph audit key on what proved nodes rest on. A false
  axiom that no proved theorem consumes yet, an orphan, appears in no footprint.
- `ckc-lint` saw a known type, a valid status, an uppercase `AXIOM:` footer. All true.
- The citation named the paper, and the paper's mathematics is sound. The transcription was not.

Every fidelity bug found earlier in the project had been caught incidentally, when a downstream
proof happened to need the missing hypothesis. The bugs in axioms nothing consumed yet were
invisible.

## The audit

A dedicated statement-fidelity audit then compared every axiom against the paper's verbatim text
and attacked each statement as written. Of twelve axioms, eleven were false as stated:

- **F11.** Lemma 3.4 was transcribed without the paper's hypothesis that the two measures are
  *different*. Instantiating both measures to the same one derives `False` in three lines. The
  disproof was machine-checked.
- **F12.** Several axioms quantified over every measure where the paper says probability measures
  on the sphere. Instantiating one with the Lebesgue measure of the whole space refutes it; another
  fell to a target point off the sphere.
- **F14.** The deepest one. The formal model of the dynamics was a measure-independent flow, a
  linear continuity equation, while the paper's central mechanism is measure-dependent attention.
  The paper itself proves (its eq. 1.7) that the linear kind cannot do the job. No per-statement
  patch fixes a model-class error; the model had to be rebuilt.

The audit also surfaced two statement-level erratum candidates in the source paper itself,
documented factually in the repository's ERRATA.md.

## The repair

The hypotheses were restored, and the repair was made structural rather than a one-off:

- Each refuted draft's disproof was committed as a kernel-checked theorem (`old statement implies
  False`), permanently in the build.
- Next to each, a short must-fail file tries to derive the refuted old statement from the current
  axiom. A gate asserts it fails to compile. If anyone ever re-loosens the axiom to the shape
  already proved false, the file compiles and the gate fails loudly.
- Non-vacuity witnesses instantiate every axiom's hypotheses with concrete data, so an
  over-corrected, unsatisfiable axiom breaks the build too.
- The commit hook now rejects a `math.axiomatised` commit that lacks a `Source-Ref:` and a
  `Refutation-Attempt:` footer.

## The lesson

A commit can be honest three ways, and the first two do not imply the third:

1. **Kernel-honest**: the trusted base is what the assumption check reports.
2. **Status-honest**: the footers repeat that report literally.
3. **Transcription-honest**: the statement is the one the cited source actually made.

v0.1.0 enforced the first two. This incident is why v0.2.0 adds the third: rule 14 makes the
source anchor mandatory for citation-truth statuses, so comparing a transcription with its source
is a diff, not an archaeology project, and the fidelity evidence footers record that someone tried
to break the statement as written before trusting it. The
[proof profile](spec/proof-profile.md) spells out the three checks; the
[science profile](spec/science-profile.md) carries the same idea as protocol fidelity.
