# ghūl agent guide

Instructions for a coding agent working in any repository under
[ghul-lang](https://github.com/ghul-lang). It is written for an agent that has
nothing but a fresh clone of the repository it was asked to change, and it sets
out the standards the maintainer holds changes to.

Each repository's own `AGENTS.md`, `CONTRIBUTING.md` and `README.md` still
apply, and where one of them is more specific than this guide, it wins. This
guide covers what they leave out: how the repositories fit together, the rules
that apply across all of them, and the rules that reviewers enforce but no
test checks.

## Read this first

1. [`guide/trust.md`](guide/trust.md) - whose words on GitHub you act on.
   Short, and it decides what you do with an issue or a comment before you
   have read it.
2. [`guide/repositories.md`](guide/repositories.md) - what each repository is,
   and how to build and test it.
3. [`guide/workflow.md`](guide/workflow.md) - branches, CI, the merge queue,
   what to run locally, and why a failing test is yours.
4. [`guide/pull-requests.md`](guide/pull-requests.md) - commit messages and
   pull request descriptions. The description is the changelog entry, so its
   format is strict.
5. [`guide/versioning.md`](guide/versioning.md) - how a release version is
   chosen, and when a change has to raise the `VERSION` file.

Then, depending on the work:

- [`guide/compiler.md`](guide/compiler.md) - rules for changing the compiler
  (`ghul-lang/ghul`): the bootstrap rule, the type-system protocol,
  diagnostics, IL emission and more. Read it before any compiler change.
- [`guide/language.md`](guide/language.md) - how to learn the language and
  how to talk about it. Read before writing any ghūl.
- [`guide/probing.md`](guide/probing.md) - compiling and running a small ghūl
  snippet without setting up a project.

[`setup/environment-setup.sh`](setup/environment-setup.sh) is an example setup
script for a fresh environment: it installs the .NET 10 SDK and the GitHub
CLI and clones this guide.

## The language reference

The ghūl language is documented in
[`GHUL.md`](https://github.com/ghul-lang/ghul/blob/main/GHUL.md) in the
compiler repository. Read the language from there every time rather than from
memory: the syntax is unusual, and a half-remembered version of it produces
code that looks plausible and does not compile. It is deliberately not copied
here, so that there is only one version of it.
