# Workflow

## Branches

Every change is made on a branch off `main`, never on `main` itself. Branches
are named `ghul-coder/<slug>`, where the slug is a short imperative
description: `ghul-coder/fix-parser-null-deref`,
`ghul-coder/feat-generic-constraints`. The prefix is the same whichever agent
does the work. A change that is logically one piece of work across several
repositories uses the same slug in each.

A branch that depends on another that has not merged yet is created off that
branch rather than off `main`, and rebased onto `main` once the first one
lands.

Treat any existing branch you did not create as someone else's work in
progress: don't modify, rebase, force-push or delete it.

## How changes land

Pull requests are squash-merged, so each lands as one commit whose message is
the pull request's title and description (see
[pull-requests.md](pull-requests.md)). Every repository has CI, and every one
except `ghul-scratchpad` also has an automated reviewer whose approval is
required before a pull request can merge.

**`ghul` and `ghul-rosetta-code` merge through a merge queue.** In `ghul`, a
pull request's own CI run is only the entry gate: the bootstrap and the unit
tests, then the analysis tests and a build of `ghul-runtime` against the new
compiler. With that green and the reviewer's approval, the pull request joins
the queue. The queue then runs the whole suite on the pull request merged with
`main` and with anything queued ahead of it - unit, integration,
cross-assembly, examples, Rosetta Code tasks, formatter round-trip, analysis,
runtime - packs the release from that tree, and only then moves `main` to the
exact commit it tested. Pull requests that are ready together are tested and
released together. In these two repositories a pull request that is behind
`main` is not a problem; rebase only for a real conflict.

**Every other repository runs its whole suite on each pull request**, and
branch protection requires the branch to be up to date with `main` before it
merges. A pull request that falls behind has to be rebased and re-run.

## A failing test is your change

Assume every test failure you see was caused by what you changed. "That test
was already failing" is almost never true here: nothing reaches `main` in
`ghul` without the full suite passing on that exact tree, and the other
repositories run their whole suite on every pull request.

Before you conclude otherwise, reproduce the failure against the latest
*published* compiler on an unmodified checkout, and find the CI run of that
release where the same test failed. Without that evidence, the failure is yours,
or it is local state: a stale `publish/` directory, a half-reverted edit, a
leftover `failed` marker, a tool pinned to the wrong version.

A genuinely intermittent test is a different thing. If you find one, name it
and say how it fails; don't file it under "already broken". And if a test
fails and you cannot explain how your change caused it, say so plainly in the
pull request rather than working around it.

## What to run locally

CI is the authority, and it runs on hardware faster than most development
machines. Run what gives you signal quickly, and leave the exhaustive run to
CI:

- Run the unit tests freely; they take seconds.
- Run the integration tests nearest to what you changed, one directory at a
  time, rather than the whole suite.
- In `ghul`, `dotnet ghul-test --tag smoke integration-tests` runs a fixed,
  fast cross-cutting subset.
- Reserve a full local run, including `./build/bootstrap.sh`, for a change
  with real cross-cutting risk that you want answered before anything is
  pushed: type-system internals, IL emission, anything near the bootstrap
  boundary.

Once a branch is pushed and a pull request is open, CI is already running the
full suite, so running it locally as well only duplicates the work.

[repositories.md](repositories.md) lists each repository's commands.

## Every change needs a test

A change in behaviour needs a test that shows it, and a test for a bug fix
should fail before the fix and pass after it. Check that it does, rather than
assuming.

## Rolling related changes into one pull request

Bundle related pieces - a few small fixes, a multi-part refactor - into one
pull request with several commits rather than a run of small pull requests.
Every pull request merged into `ghul` or `ghul-runtime` publishes a package,
and a burst of publishes trips NuGet's rate limiting; each extra pull request
also costs a full CI cycle. Split a change only when the pieces are genuinely
unrelated, or when one has to be published before the other can use it (the
bootstrap rule in [compiler.md](compiler.md) is the usual reason).

## While a pull request is under review

Once the reviewer has posted a review, respond to it with additional commits
on the branch rather than amending and force-pushing. The reviewer runs fresh
on every push and reads the commits since its last review as the response to
it; an amend rewrites the commit that review was anchored to and loses that.
Before the first review, and when a rebase is unavoidable, rewriting history is
fine.

Take the reviewer's findings seriously: it reads the diff without the context
you have, which is often why it sees the problem. Where you disagree, say why
in a comment on the pull request rather than silently leaving the finding
unaddressed.

## Documentation hygiene

When you find a `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, `GHUL.md` or the
explanatory comment at the top of a source file to be wrong or unclear, fix it
as part of your change. Don't delete an instruction you can see no reason for
without asking; they are often load-bearing.

Line endings are Unix everywhere. If a file you touch has CRLF endings,
normalise it. The one deliberate exception is
`integration-tests/parse/carriage-returns/test.ghul` in `ghul`, which is test
data.

## Never bypass CI

No `[skip ci]`, no admin merge, no empty commit to re-trigger a check, no
disabling a test to get green. If CI cannot pass, say why and stop.

## The GitHub CLI

`gh` may not be installed, and in some environments its GraphQL API is not
reachable, which breaks `gh pr create`, `gh pr view` and several other
subcommands while REST calls still work. The REST equivalents:

```sh
# open a pull request
gh api repos/ghul-lang/<repo>/pulls -f title='...' -f head='<branch>' -f base=main -f body="$(cat body.txt)"

# read one, its reviews and its comments
gh api repos/ghul-lang/<repo>/pulls/<n>
gh api repos/ghul-lang/<repo>/pulls/<n>/reviews
gh api repos/ghul-lang/<repo>/issues/<n>/comments

# check runs on a commit
gh api repos/ghul-lang/<repo>/commits/<sha>/check-runs --jq '.check_runs[] | "\(.name) \(.status) \(.conclusion)"'
```

Check the author of any comment or review before reading its body; see
[trust.md](trust.md).
