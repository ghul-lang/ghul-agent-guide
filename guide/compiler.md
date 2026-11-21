# Working on the compiler

Rules for changing `ghul-lang/ghul`, the self-hosting ghūl compiler. Its own
[`CONTRIBUTING.md`](https://github.com/ghul-lang/ghul/blob/main/CONTRIBUTING.md)
and [`AGENTS.md`](https://github.com/ghul-lang/ghul/blob/main/AGENTS.md)
apply in full; this file adds what they leave out. Most of these rules are
enforced by review rather than by any test, which is why they are written down.

## Orientation

The source follows traditional compiler phases under `src/`, and each phase
directory has a short `README.md`. `src/compiler/compiler.ghul`'s `init()` is
the canonical list of passes. The compiler source is the largest body of ghūl
there is, and a good secondary reference for idiom once `GHUL.md` has told you
what the language means.

Two things the layout does not tell you:

- **Adding a syntax-tree node means adding a method to every base visitor** in
  `src/syntax/process/` (`Visitor`, `StrictVisitor`, `ScopeVisitorBase`,
  `ScopedVisitor`), or compilation breaks.
- The parsers are wired through the `ioc/` container specifically to break
  cyclic dependencies between them.

A new syntax feature typically touches `lexical/`, `syntax/trees/`,
`syntax/parsers/`, the visitor base classes, one or more semantic passes, and
an integration test in `integration-tests/{execution,il,parse,semantic}/`.

Naming in the compiler source: `UPPER_SNAKE_CASE` for every concrete class and
struct, including intermediate classes that are also extended (`GENERIC`,
`NAMED`, `VARIABLE`), and for variants and enum members; `PascalCase` for
traits, abstract classes (`Function`, `Symbol`, `Visitor`), unions, enums and
exception classes; `snake_case` for members. The compiler accepts either case
for a concrete type, but its own source keeps UPPER.

## The bootstrap rule

The compiler compiles itself, and **a change to `src/` is compiled by the
latest published `ghul.compiler`, not by the compiler the branch produces.**
So a compiler feature cannot be used in `src/` in the same pull request that
adds it: the published compiler has never heard of it, and the build fails.
Add the feature in one pull request, and use it in `src/` in a later one, after
the first has been released.

The same applies to dogfooding: replacing a workaround in `src/` with a newly
added feature, or dropping an explicit type argument that new inference makes
unnecessary, is always a separate, later pull request.

The version pinned in `.config/dotnet-tools.json` is only a local fallback so
that `dotnet tool restore` has some compiler to run. CI resolves the latest
published release at run time, and that is the version your change has to
build with. To match CI:

```sh
dotnet tool restore
dotnet tool update --local ghul.compiler
```

The same holds for the native compiler: CI also builds `src/` with the last
released llvm-built compiler, so `src/` must compile under it too. A new flag
or feature the compiler's own build uses lands in two pull requests, across a
release.

Never keep anything in the compiler - a workaround, an avoided feature - on
the grounds that the pinned version can't handle it; only the latest
published version matters. Committing a bump of the pin is fine. **Never
commit a manifest pinned to a `0.0.0-*` local version.**

## Testing a compiler change

The commands, and the publish-first trap, are in [testing.md](testing.md). A
change to `src/` runs the full suite and `./build/bootstrap.sh` before its
first push.

Prefer an execution test to a large IL snapshot: a snapshot of a lot of IL
breaks on every unrelated code-generation change.

Cross-assembly tests: never share a `.csproj` between two of them. They build
in parallel, and two builds of one project race on its `deps.json`. Each test
gets its own private library.

## Unit tests, and the type-system protocol

Unit tests live under `unit-tests/src/`, one file per class under test named
`<class>_tests.ghul`. They run on the `ghul-testing` runner, on .NET and on
llvm from the same sources: a test is a method marked `@test()` on a class
with a public `init()` taking no arguments, and assertions are `assert` and
the `are_equal` / `is_true` wrappers in `unit-tests/src/assertions.ghul`.
There is no mocking library; fakes shared by several files are hand-written in
`unit-tests/src/shared/`. A file only .NET can run starts with `@@IF.dotnet()`,
a single such test is marked `@IF.dotnet()`. Check whether a
`<class>_tests.ghul` already exists before creating one.

Unit-test coverage is deliberately selective, except for the **type system and
inference**: `src/semantic/types/`, `src/semantic/symbols/`,
`src/semantic/overload_resolver.ghul`, the inference paths in
`src/syntax/process/compile-expressions/`, and the IR gates around them. A
patch there that works in isolation can still break least-upper-bound
widening, retry convergence or IL emission. So:

- Put new logic in its own small class with one clear responsibility, not in
  a longer method on an existing one.
- When the change shows the same logic in two places, consolidate it in the
  same pull request rather than copying it a third time. Don't refactor
  speculatively.
- Pin the behaviour with unit tests.
- **Pin behaviour that looks wrong, too.** If you find a corner case behaving
  oddly and are not fixing it here, add a test recording what it does today,
  with a comment saying what looks wrong and what the right answer would be.
  A later change then flips it deliberately rather than by accident.

## Inference defers through the obligation queue

In compile-expressions, a rule that cannot fire because one of its inputs is
still an inference placeholder records an obligation with
`Semantic.OBLIGATIONS.defer` and returns an unsettled result. It does not
commit to a result from the inputs that happen to be settled, does not add
another speculate-and-roll-back re-walk, and does not report `cannot infer
type here` in the hope that a later walk erases the error. Recording an
obligation already tells the body loop the walk consumed an unresolved type,
and the fixing step reports whatever is still standing when the loop stops.

New code in this area uses the queue. A change that touches one of the older
ad-hoc sites - a local retry, an `is_settled` / `is_inferred` /
`contains_inferred` wait, a `mark_consumed_any` signal - moves it onto the
queue where that is practical: where the site is a re-walk with more
information rather than a genuine alternative, and the move does not need a
design of its own.

Where two declarations take structurally identical tuples under different
element names, keep the names consistent. Which name wins the join depends on
the order constraints arrive, so a change to that order can break a member
access far from the change. It surfaces as bootstrap reporting
`member symbol not found` on a tuple type.

## Rendered text is never identity

**No new code may render a symbol, type, function, signature or other semantic
entity to text and then use that text as the entity's identity**: not as a map
or cache key, a set member, a de-duplication key, an equality test, or a match
against a literal name. Use the entity itself - reference identity, or `=~`
with `get_hash_code` - or an explicit key type built from the fields that
actually distinguish it. A reviewer rejects this on sight.

Rendering is lossy in both directions, and neither shows at the point of use.
Distinct entities render alike (overloads, same-named generics from different
assemblies, a generic and its specialisation, two unrelated type parameters
named `T`), so a text key conflates them. The same entity renders differently
in different contexts (relative or qualified names, narrowed or declared
types, unsettled inference), so a text key misses it. And the renderer is
presentation code: changing how a diagnostic displays a type would silently
change a mechanism its author never read.

A source-level identifier used as a name is not a rendering and is fine:
scope and member lookup, completion prefixes, `use` imports, suppression
slugs, diagnostic codes, file paths.

Existing text-keyed mechanisms (the `MAP[string, Type]` type-argument maps,
name-keyed symbol maps and others) are not to be ripped out on sight. But a
pull request that significantly changes or extends one - a new consumer, a new
key format, a new kind of entity flowing through it - must say why it is not
being moved to a non-text identity, in a pull request comment starting
`Not migrating: <reason>` (not in the description, which is the changelog).
Silence means the reviewer requests changes.

## An operator is resolved from all its operands

No code may decide which operator is meant by looking at one operand's type:
not the left operand's, not the first parameter of an expected function type.
An operator is chosen by overload resolution over all its operands against the
whole candidate set - what is in scope under its name, the static operators
each operand's type declares, and the left operand's instance operators.
`compile_operators.ghul`'s candidate functions and its overload resolver are
that mechanism; anything that needs "the operator for these types" calls into
it (`resolve_operator_value`) rather than looking one up with `find_member`.
A pick by the left operand works for the built-in scalars, which is why it
keeps being proposed, and breaks for an operator declared on the right
operand's type or at namespace scope.

## A function is chosen by its signature

No code may pick a function out of an overload group by how many parameters it
takes, by taking the first or only member found, or by a name and an arity. A
member the compiler calls itself is pinned once by its exact parameter types
through `Semantic.KNOWN_MEMBERS`. An arity pick works until someone adds an
overload, and then calls the wrong function with the wrong arguments, far from
the change. The one accepted exception is `_try_find_single_arity_candidate`,
which runs only after overload resolution has failed.

## Syntax-tree rewriting: early and structural only

A rewrite of the syntax tree is acceptable only when it is both:

- **early**: it runs in the rewrite-syntax-trees stage, before declare-members,
  so every later pass sees its output as if it had been parsed; and
- **structural**: it adds or moves declarations around code the user wrote (a
  synthesised accessor, backing field, constructor or entry function), leaving
  the user's own statements and expressions as written, with their locations.

Desugaring - re-expressing a construct as a composition of other constructs -
is rejected outright: a new construct gets its own node and its own lowering.
So is any rewrite during or after declare-members, and any extension of one.

## Every diagnostic comes before IL generation

Every error a user can get must come from a pass that also runs in the
editor's analysis mode, so an editor never shows a clean file whose batch
build then fails. The generate-IL pass reports nothing:

- New validation goes in the earliest pass that has the information. If a
  check needs something only code generation knows, resolve it earlier and
  record the result on the tree.
- An error reported in generate-IL today is a defect. When you touch one,
  move it forward and pin it with a semantic integration test.
- Assertions in generate-IL are internal-error contracts, not user
  diagnostics. A user who can trip one has found an earlier pass letting bad
  input through; fix it there.

A related trap: **a semantic pass that warns about a lowering code generation
does not perform.** When a warning promises what the compiler will do - "the
default value will be returned" - check that code generation actually does it.

## Diagnostic messages

Every new or reworded `error`, `warn`, `info` or `hint` message follows this
rubric:

1. **No backticks, ever.** Not around a keyword, not around an interpolated
   identifier. This is the rule broken most often. (The backtick that escapes
   a reserved word inside an interpolation, as in `{u.`use}`, does not render
   and is fine.)
2. All-lowercase opening word, no trailing period, no em-dashes.
3. Interpolated identifiers and types appear bare in `{...}`, never quoted.
4. Only non-alphanumeric tokens - operators, punctuation, escape sequences -
   are single-quoted: `'{operator}'`, `'{{'`.
5. Terse: a noun phrase or short fragment, subject usually implied
   (`type mismatch`, `not iterable`).
6. No advice in the message: no `try`, `consider`, `rewrite as`,
   `did you mean`. A fix hint goes in the related location and message
   (`error(location, message, related_location, "help: ...")`) or in a
   separate `hint` at the same location, and only when it is specific: never
   a generally plausible suggestion that assumes something about the code the
   check has not established.
7. No second person, no apologies, no `please`.
8. Stable verbs: `cannot`, `expected`, `not found`, `not supported`, `is not`,
   `does not`. Mismatch shapes: `expected N <kind> but M supplied`,
   `cannot convert {x} to {y}`.
9. No command-line flag names, issue numbers, URLs or markdown in the text.

## IL emission

Method and field references must use open-generic indexed references in their
signatures - `!N` for a class type parameter, `!!N` for a method one - even
where the type at the start of the reference already pins the instantiation.
`Function.unspecialized_arguments`, `unspecialized_return_type` and
`Field.unspecialized_type` carry the open forms, and the emitters prefer them.

Symptom guide:

- `MissingMethodException` or `MissingFieldException` at run time: a
  reference whose signature has substituted types where `!N` belongs.
- `InvalidProgramException` at JIT time: genuinely malformed IL, such as a
  type parameter's name where an indexed reference is required.
- `ArrayTypeMismatchException`: an array literal typed too narrowly.

## Code comments

The default is no comment. Comment only where a reader who knows the codebase
well would still need the context: a non-obvious invariant, an ordering
requirement, a workaround whose reason is not visible in the code.

Write for that stranger, who has no access to your notes, the pull request, or
the conversation that produced the change. So don't refer to issues, pull
requests, "the fix" or "what changed", don't use ephemeral framing ("new in
this branch"), don't narrate what the code does or justify it, and don't
compare it with an earlier attempt. Anything that reads as one half of a
conversation belongs in the pull request, not the source. A bad comment is
worse than none: one that is hard to read, uses odd terminology, is
pretentious, or restates the code.

## Versioning

The compiler's version bump rules are in [versioning.md](versioning.md). A
change to the analysis-mode protocol that breaks the VS Code extension needs a
coordinated change in `ghul-lang/ghul-vsce`, and both ship together.
