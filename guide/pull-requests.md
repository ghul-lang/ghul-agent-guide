# Commit messages and pull request descriptions

Pull requests are squash-merged, so **the pull request description becomes the
final commit message and the release-notes entry**. It is the one part of a
pull request that ships permanently, and it is worth more care than the
individual commit messages.

## Who it is written for

Write for a stranger who knows the repository well but has none of your
context: not the conversation that produced the change, not the pull request
thread, not any notes you made. Picture someone reading `git log` in a few
years, tracking a regression back to this commit. The automated reviewer reads
it the same way.

A phrase that only makes sense with private context fails this test. Common
offenders:

- pointers to files, notes or documents that are not in the repository
- ephemeral framing: "new in this branch", "phase 2 of the X work", "as
  discussed", "per the earlier review"
- where the change sits in an internal plan: "step 3 of the migration"
- defensive prose explaining why the change is right

Public GitHub references (`closes #1234`, `see ghul-lang/ghul-runtime#42`) and
in-repository file references are fine.

## The format

A title, then one to three sections of one-line bullets:

```plaintext
Short imperative title, no trailing period

Enhancements:
- Something a user of the language, compiler or tooling would notice (closes #1234)

Bugs fixed:
- What was broken, phrased as the issue title is (closes #1235)

Technical:
- An internal change: a refactor, a test, a build change
```

The rules, all of which are checked:

- The section labels are exactly `Enhancements:`, `Bugs fixed:` and
  `Technical:`, as plain text rather than markdown headings. Use only the
  sections you have content for, but at least one.
- Every bullet is a plain `- ` bullet on a single line, at most 160
  characters of text. No nesting, no continuation lines, no bold lead-ins.
- The whole body is at most 25 lines, and a typical one is under 15.
- No headings of any kind: no `## Summary`, `## Overview`, `## Test plan`,
  `## Testing`. The description is the summary, and passing CI is implied.
- No fenced blocks, no pasted output, no block quotes.
- No local test results ("passes locally", "all tests pass", "bootstrap
  green"). CI is the record of what shipped.
- No local file-system paths.
- No `Co-authored-by:` trailer in the description. GitHub adds a
  de-duplicated one from the individual commits when it squashes.
- No attribution footer or signature ("Generated with ...", a session link, a
  signed-off name) and no private or short-lived links. The same goes for
  issue and pull request comments.
- No `#minor` or `#major` markers; they do nothing. See
  [versioning.md](versioning.md).
- Keep the title under about 70 characters, and don't append the pull request
  number; GitHub adds it on merge.

## Choosing a section

- **Enhancements** is user-facing: a change a user of the language, the
  compiler or the tooling would notice. If you are unsure whether something is
  user-facing, it isn't; use Technical.
- **Bugs fixed** says what was broken, not what was done to fix it. Where
  there is an issue, use its exact title and append `(closes #NNNN)`. Where
  there isn't, write the bullet the way an issue title would read.
- **Technical** is for refactors, tests, build changes, and performance work
  with no visible effect.

## Shape

The calibration target is dense:

```plaintext
Tuple literal type covariance

Enhancements:
- Tuple literal type covariance (closes #1166)
- Improved type inference for list literals and if expressions (see #1173)
```

```plaintext
IL name override fix

Bugs fixed:
- Overriding the IL name of a class with `@IL.name` generates incorrect IL
```

One bullet for a focused fix; two or three for a medium change. A description
of five or more bullets is read critically for whether it is a changelog or an
essay cut into bullets: every bullet should be a distinct change a reader of
the release notes cares about, understandable without the diff. A bullet that
continues or justifies the one before it, defends the approach, or answers an
objection is out of place. If you are listing ten implementation details under
Technical, you are describing the diff; pick the one to three facts a future
reader needs.

A short introductory paragraph before the first section is allowed when the
bullets add up to something worth one sentence: a change of policy, or a new
mechanism the bullets are facets of. Two or three sentences at most, written
for the release-notes reader rather than the reviewer.

When in doubt, write it, then delete half. Put back only what a changelog
reader would miss.

## Rationale belongs in a comment

What a reviewer needs but a changelog reader does not - why this approach
over an obvious alternative, an oddity that is deliberate, an invariant the
diff does not show - goes in a comment on the pull request, posted right after
opening it. Comments are not part of the squashed commit, so they have no
length or format limits. The automated reviewer reads them before raising a
finding. Most pull requests need none.

User-facing detail that will not fit in a bullet - how a new feature behaves,
the full list of what a fix repairs - belongs in a GitHub issue that the
bullet links to with `(closes #NNNN)` or `(see #NNNN)`. Raise an issue for the
purpose if there isn't one.

## Individual commit messages

Individual commits on a branch use the same shape where it makes sense: a
short imperative title, and a body only when the title is not enough. They
are replaced by the description when the pull request is squashed, so they
matter less, but they are what the reviewer reads as the response to its
previous review.

## Tone

Brief, low-key and factual. No hype, no apologies, no first person. State what
changed; don't argue for it.
