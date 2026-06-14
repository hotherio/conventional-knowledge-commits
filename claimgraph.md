# The ClaimGraph

The **ClaimGraph** is what CKC is for. Conventional Commits earned its place by mapping commits onto
one decision, the version bump. CKC's equivalent is a graph of knowledge claims and how they depend
on each other. From the relation footers, tooling reconstructs which claims rest on which, then
propagates two kinds of event to everything affected: breakage (a refutation or retraction) and
promotion (a gap closing). The status report and an optional release version both come out of this
graph.

> This page defines the ClaimGraph. The [`claimgraph` tool](https://github.com/hotherio/claimgraph)
> builds it from a repository's git history and serves it as an interactive viewer.
> [See a real one live](https://claimgraph.conventional-knowledge-commits.org/), reconstructed from a
> formalized research project.

## Nodes

A node is a claim: a theorem, lemma, definition, conjecture, or empirical finding, named by its
stable identifier (see [Identifiers](./identifiers.md)). That is a Lean fully-qualified name and an
optional blueprint label in the proof profile, and a registered slug in the science profile.

Each node carries its current `Status:` (axis 2), taken from the most recent commit that set a status
for it. History is append-only, so a status moves forward, or back, only through a new commit.

## Edges

The relation footers create the edges.

| Footer | Edge for a commit asserting A | Meaning |
| --- | --- | --- |
| `Depends-On: B` | A depends on B | A's truth relies on B |
| `Assumes: B` | A depends on B | B is an assumption or axiom A rests on |
| `Proves: B` | A establishes B | this commit discharges B |
| `Closes: B` | A resolves B | a conjecture or goal B is settled by A |
| `Refutes: B` | A contradicts B | evidence or argument against B |
| `Disproves: B` | A falsifies B | a counterexample to B |
| `Supersedes: B` | A replaces B | B is retired in favour of A |
| `Retracts: B` | A withdraws B | B is pulled |
| `Invalidates: B` | A breaks B | B's conclusion no longer holds |

The `Depends-On` and `Assumes` edges form the directed graph that everything propagates over. The
rest are the events that drive propagation.

## Breakage

When a commit refutes, disproves, retracts, or invalidates a node B (a breaking event, signalled by
`!` or `BREAKING CHANGE:`):

1. B's status becomes `math.disproved`, `sci.falsified`, or retracted, as appropriate.
2. Every node A with a path from A through `Depends-On` to B is marked **in question**. Its asserted
   status is suspect until someone re-examines it. Tooling should list these as the blast radius of
   the change.
3. "In question" is computed from the edges, not stored. It clears on its own once the dependency is
   repaired or routed around.

A one-line `refute(...)!` commit can, through the graph, flag a dozen downstream results for recheck,
without anyone maintaining that list by hand.

## Promotion

When a commit closes a gap, such as a `formalize`, `proof`, or `port` that moves a node from
`math.open` (`sorryAx`) or `math.axiomatised` to `math.machine-checked`, or a `replicate` that moves
`sci.measured` to `sci.replicated`:

1. The node's status advances (axis 2) through the new commit, not a rewrite.
2. A node is only as established as its weakest dependency. Tooling computes an **effective status**
   as the minimum over the node and its transitive `Depends-On` and `Assumes` closure on the status
   ladder. A theorem whose own proof is `machine-checked` but which `Assumes:` an `axiomatised` lemma
   has effective status `axiomatised`. That is how a cited axiom surfaces on everything downstream,
   the same way `#print axioms` does.

## Derived views

- **Status report.** Group nodes by effective status: machine-checked, axiomatised, open, conjectured
  for proofs, and replicated, supported, measured, not-replicated for science. This is the honest
  project dashboard, computed from the graph rather than kept as a separate file.
- **Blast radius.** Given a node, the set of dependents that a refutation or retraction would put in
  question. Run it before committing a breaking change to see what you are about to disturb.
- **Release version.** A Semantic Versioning (SemVer) number for a knowledge artifact such as a paper
  or a formalized library: a breaking knowledge event since the last tag is a MAJOR release, a new
  result or an independent replication is a MINOR, a proof repair or cleanup is a PATCH.

## A worked trace

```
conjecture(master-formula): the Green's integral factorises as a finite rank-K×R sum
    node conjecture:master-formula, Status: math.conjectured

formalize(fubini): close the d-fold separable factorization
    Lean: IGL.fubini_factorization   Closes: conjecture:master-formula
    Status: math.machine-checked
    node IGL.fubini_factorization (machine-checked), proves conjecture:master-formula

axiomatize(exp-sum): cite the log rank bound
    Lean: IGL.expSumRank_logBound   Status: math.axiomatised   AXIOM: IGL.expSumRank_logBound

formalize(rank-bound-use): bound the approximation error using the exp-sum rank
    Lean: IGL.approxError   Depends-On: IGL.expSumRank_logBound
    Status: math.machine-checked
    IGL.approxError is itself clean, but its effective status is axiomatised, because it
    Depends-On an axiomatised node. The graph reports it, matching #print axioms.

refute(separability)!: √|g| blocks naive factorization
    Disproves: conjecture:naive-separable
    conjecture:naive-separable becomes disproved; any node that Depends-On it is in question.
```

A CKC-aware tool reads only the footers above and can answer three questions: what is proved versus
assumed versus open, what breaks if `conjecture:naive-separable` falls, and what version the next
release should be.
