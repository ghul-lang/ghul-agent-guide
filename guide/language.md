# The language, and how to talk about it

## Where to learn it

- [examples.md](examples.md) is a set of short programs, one per area of the
  language, each of which compiles on its own with the current compiler.
  Imitate them. The first one, `00-traps`, is the mistakes agents make most
  often, as wrong and right pairs.
- `ghul/GHUL.md`, in a clone of the compiler, is the language tutorial and
  reference, and it is the authority. When the examples don't settle how to
  write something, search `GHUL.md` for the construct rather than writing it
  from memory.
- `GHUL.md`'s index lists the topic files under `ghul/docs/` (narrowing,
  generics, async, targets and others). Read the one that matches the work
  before anything specialised.

Where the compiler and `GHUL.md` disagree, say so rather than quietly coding
around it.

## The mistakes most often made

The examples show each of these in code; this is the short list.

- **Blocks close with mirrored keywords**: `is ... si`, `if ... fi`,
  `do ... od`, `case ... esac`, `try ... yrt`. There are no braces.
- **.NET members are `snake_case`.** `list.Count` is `list.count`,
  `builder.Append(x)` is `builder.append(x)`. Enum members are
  `UPPER_SNAKE_CASE`.
- **Nothing is imported implicitly** except the built-in types and operators.
  `write_line` needs `use IO.Std.write_line` or `use default`.
- **Strings have no `+`.** Join them with interpolation: `"{a}{b}"`.
- **`==` is identity.** On strings it compares references, so text read at run
  time is never `==` a literal; compare text with `=~`. `==` on a struct is a
  compile error.
- **Scalars widen in arithmetic and ordering only.** `int`, `long`, `single`
  and `double` operands widen to meet, so `1.0 + 1` is `2.0`. Assignment,
  `decimal` and `==` never widen: `let x: long = n` is an error, and
  `long(n)` is the conversion.
- **Inside an interpolation you are in expression context**, so a nested string
  is written plainly: `"{f("x")}"`, never `"{f(\"x\")}"`.
- **`new` is not part of the language.** Construct by calling the type:
  `Box(42)`, `LIST[int]()`, or `_(args)` where the context fixes the type. The
  constructor constraint is `[T: init]`.
- **A `let` is immutable**; `let x mut = 0` can be reassigned.
- **An `ARRAY` is read-only**; a `LIST` is the mutable one.
- **There is no `main()`.** A program is its top-level statements, or an
  `entry()` function.
- **Naming.** `snake_case` for variables, functions and properties. Name your
  own types in `PascalCase`. Variants and enum members are `UPPER_SNAKE_CASE`.
  A leading underscore makes a declaration private.

## Words

- **Never call a `let` local variable a "binding".** The word is banned
  everywhere: source, diagnostics, documentation, examples, pull requests and
  commit messages. Say "local variable", with "immutable" or "mutable" when it
  matters. When you meet an existing use in something you are editing, fix it.
- Write the language's name as **ghūl**, with the macron, in prose. Plain
  `ghul` is for identifiers, file names and anywhere ASCII is required.
- US spelling everywhere.
- In prose, prefer plain words, and avoid em-dashes. State what happens rather
  than telling a story about it.

## The style guide for examples and the website

Prose and example code in `ghul-examples` and `ghul-dev` follow the style
guide in `ghul-lang/ghul-style` (`STYLE.md`), which the automated reviewers in
those two repositories apply. Read it before writing or editing either. It
does not apply to the compiler's source or its internal documents.
