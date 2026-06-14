# The knowledge impact graph

This is what CKC is *for*. Conventional Commits earned its keep by mapping commits onto one
downstream decision (the SemVer bump). CKC's downstream artifact is a **knowledge dependency +
impact graph**: from the relation footers, tooling reconstructs which claims rest on which, and
propagates two kinds of event — **breakage** (a refutation/retraction) and **promotion** (a gap
closing) — to everything affected. The status report and an optional release-version both *derive*
from this graph.

## Nodes

A node is a **claim**: a theorem, lemma, definition, conjecture, or empirical finding, named by its
stable identifier (see [`identifiers.md`](./identifiers.md)) — a Lean fully-qualified name and/or
blueprint label in the `proof` profile, a registered slug in the `science` profile.

Each node carries the **current** `Status:` (Axis 2), obtained by taking the *latest* commit that
set a status for that node. History is append-only: status moves forward (or back) only via new
commits.

## Edges (from relation footers)

| Footer | Edge `A → B` (commit asserts A) | Meaning |
| --- | --- | --- |
| `Depends-On: B` | A depends on B | A's truth relies on B |
| `Assumes: B` | A depends on B | B is an assumption/axiom A rests on |
| `Proves: B` | A establishes B | this commit discharges B |
| `Closes: B` | A resolves B | a conjecture/goal B is settled by A |
| `Refutes: B` | A contradicts B | evidence/argument against B |
| `Disproves: B` | A falsifies B | a counterexample to B |
| `Supersedes: B` | A replaces B | B is retired in favour of A |
| `Retracts: B` | A withdraws B | B is pulled |
| `Invalidates: B` | A breaks B | B's conclusion no longer holds |

`Depends-On` / `Assumes` edges define the DAG over which everything propagates; the others are the
events that drive propagation.

## Propagation — breakage

When a commit **refutes**, **disproves**, **retracts**, or **invalidates** a node `B` (an Axis-1
breaking event, signalled by `!` / `BREAKING CHANGE:`):

1. `B`'s status becomes `math.disproved` / `sci.falsified` / *retracted* as appropriate.
2. Every node `A` with a path `A —Depends-On→ … → B` is marked **in question** — its asserted status
   is *suspect* until re-examined. Tooling SHOULD list these as the **blast radius** of the change.
3. `in question` is a graph-derived overlay, not a stored status: it is recomputed from the edges,
   so it clears automatically once the dependency is repaired or re-routed.

This is the knowledge analog of "a breaking change ripples to dependents". A one-line
`refute(...)!:` commit can, through the graph, flag a dozen downstream results for recheck — without
anyone maintaining that list by hand.

## Propagation — promotion

When a commit **closes a gap** — a `formalize`/`proof`/`port` that flips a node from `math.open`
(`sorryAx`) or `math.axiomatised` to `math.machine-checked`, or a `replicate` that moves
`sci.measured` to `sci.replicated`:

1. The node's status advances (Axis 2), via the new commit, not a rewrite.
2. A node is only as established as its weakest dependency. Tooling computes an **effective status**
   = the *minimum* over the node and its transitive `Depends-On`/`Assumes` closure on the status
   ladder. So a theorem whose proof is `machine-checked` but which `Assumes:` an `axiomatised` lemma
   has **effective status `axiomatised`** — exactly how `#print axioms` surfaces a cited axiom on
   everything downstream.

## Derived views

- **Status report** — group nodes by effective status:
  `machine-checked / axiomatised / open / conjectured` (proof),
  `replicated / supported / measured / not-replicated` (science). This is the honest project
  dashboard; it is a `reduce` over the graph, not a separate source of truth.
- **Blast radius** — given a node, the set of dependents that a refutation/retraction would put in
  question. Run it *before* committing a breaking change to see what you are about to disturb.
- **Release version (optional)** — a SemVer for a knowledge artifact (a paper, a formalized
  library): a breaking knowledge event since the last tag → **MAJOR**; a new result or an
  independent replication → **MINOR**; a proof repair / cleanup / typo → **PATCH**.

## Worked trace

```
conjecture(master-formula): the Green's integral factorises as a finite rank-K×R sum
    → node conjecture:master-formula, Status: math.conjectured

formalize(fubini): close the d-fold separable factorization
    Lean: IGL.fubini_factorization   Closes: conjecture:master-formula
    Status: math.machine-checked
    → node IGL.fubini_factorization (machine-checked), Proves conjecture:master-formula

axiomatize(exp-sum): cite the log rank bound
    Lean: IGL.expSumRank_logBound   Status: math.axiomatised   AXIOM: IGL.expSumRank_logBound

formalize(rank-bound-use): bound the approximation error using the exp-sum rank
    Lean: IGL.approxError   Depends-On: IGL.expSumRank_logBound
    Status: math.machine-checked
    → IGL.approxError is itself clean, but effective status = axiomatised
      (it Depends-On an axiomatised node) — the graph says so, matching #print axioms.

refute(separability)!: √|g| blocks naive factorization
    Disproves: conjecture:naive-separable
    → conjecture:naive-separable → disproved; any node Depends-On it is flagged in question.
```

A CKC-aware tool reads only the footers above and can answer: *what is proved vs assumed vs open?*,
*what breaks if `conjecture:naive-separable` falls?*, and *what version should the next release be?*
