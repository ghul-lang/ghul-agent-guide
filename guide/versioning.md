# Versioning

The published packages - `ghul.compiler` and `ghul.runtime` on NuGet, the VS
Code extension and the others - follow strict semantic versioning.

## How a release version is chosen

A merge to `main` publishes a **patch** release by default: the latest
`vX.Y.Z` tag with its patch number bumped. To publish a minor or major release
instead, **raise the `VERSION` file at the repository root** in the pull
request, to the new version: `3.1.0` for a minor, `4.0.0` for a major. The
release reads `VERSION` as a floor and publishes it if it is higher than the
default patch.

- Read the current version from `VERSION` and the latest tags, never from
  memory or from any document. Majors are cut often.
- `#minor` and `#major` markers in a commit or pull request description do
  nothing. The `VERSION` raise is the only signal.
- Raise `VERSION` in the same commit as the change that needs it, before the
  pull request is opened; raising it later costs another CI run.
- When rebasing, check that `VERSION` was not taken backwards and did not lose
  its content in a conflict.

## Which bump

**Major** - breaks previously working valid code, binaries or protocols:

- Language syntax removed or changed, or a semantic change that rejects or
  miscompiles previously valid source.
- A breaking change to the compiler's analysis-mode protocol. The VS Code
  extension consumes it, so such a change needs a matching extension release,
  and both take a major bump in their own version series.
- An IL or metadata change that breaks binary compatibility with assemblies
  built by older compilers.
- Runtime: a public API removed or renamed, a signature changed, or the
  documented behaviour of an API changed.
- VS Code extension: its minimum supported compiler version moves up, or a
  user-visible setting, command or UI contract breaks.

**Minor** - backwards-compatible additions:

- A new language feature that does not conflict with existing source.
- A new compiler flag or opt-in behaviour.
- New analysis-mode protocol messages or fields that older clients can
  ignore.
- New runtime APIs, types or overloads.
- New warnings, which are on by default.
- VS Code extension: new features that do nothing on older compilers; new
  settings or commands.

**Patch** - fixes and internals:

- A bug fix that brings behaviour into line with the documented or intended
  specification.
- Rejecting source that was accepted before but was demonstrably wrong: bad
  IL, undefined semantics, runtime corruption, unsafe operation. Tightening
  the compiler to reject invalid source is a correctness fix, not a breaking
  change.
- Promoting a warning to an error once analysis is confident enough.
- IL or code-generation improvements with no observable change.
- Refactors, tests, documentation, CI.

## Warnings and errors

- Errors are for code that is syntactically or semantically wrong, has
  undefined or unsafe behaviour, or is otherwise demonstrably wrong. Never for
  style or preference.
- A new warning is on by default: an opt-in warning does not fire in
  practice, so it does not catch what it was built to catch. A reader who
  disagrees with one suppresses it by its slug, at a declaration, in a file or
  for a project.
