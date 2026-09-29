# The language, and how to talk about it

## Learn it from GHUL.md

[`GHUL.md`](https://github.com/ghul-lang/ghul/blob/main/GHUL.md) in the
compiler repository is the language tutorial and reference, and it is
authoritative. Read it before writing ghūl, and go back to it for any
question of syntax or meaning rather than answering from memory: blocks close
with mirrored keywords (`is ... si`, `if ... fi`, `do ... od`, `case ...
esac`), there are no braces, and a remembered version of the rest produces
confident, wrong code. The compiler is a work in progress, and where it and
`GHUL.md` disagree, say so rather than quietly coding around it.

The mistakes most often made by agents new to ghūl:

- **.NET members are `snake_case` in ghūl.** `Console.WriteLine` is
  `IO.Std.write_line`, `list.Count` is `list.count`, a static `None` is
  `none`. Only enum members become `UPPER_SNAKE_CASE`.
- **Nothing is imported implicitly** except the built-in types and operators.
  `write_line` needs `use IO.Std.write_line;` (or `use default`, which brings
  in `write_line`, the pipes and the collections).
- **`==` on a `string` is reference identity.** Two strings with the same
  characters are `==` only if they are the same object, so comparing against
  a string read from a file or the network silently answers false. Compare
  content with `=~`. `==` on a struct, tuple included, is a compile error.
- **Inside a string interpolation you are in expression context**, so a
  nested string is written plainly: `"{f("x")}"`, not `"{f(\"x\")}"`.
- **`new` is not part of the language.** Construct by calling the type:
  `BOX(42)`, `LIST[int]()`, or `_(args)` where the type is already fixed by
  the context. The constructor constraint is `[T: init]`.
- **Naming is enforced.** `snake_case` for variables, functions and
  properties; `PascalCase` for namespaces, traits, abstract classes, unions
  and enums; `UPPER_SNAKE_CASE` for concrete classes, structs, variants and
  enum members. A leading underscore makes a declaration non-public.
- **A heap fact narrows only until a call that might change it.** After
  `assert x.y?` followed by other calls, `x.y` can be optional again; copy it
  into a local straight after the test.

## Words

- **Never call a `let` local variable a "binding".** The word is banned
  everywhere: source, diagnostics, documentation, examples, pull request
  descriptions, commit messages. Say "local variable", with "immutable" or
  "mutable" when it matters. When you meet an existing use in something you
  are already editing, fix it.
- Write the language's name as **ghūl**, with the macron, in prose. Plain
  `ghul` is for identifiers, file names and anywhere else ASCII is required.
- In prose, prefer plain words to technical ones where a plain word fits, and
  avoid em-dashes.
- State what happens; don't tell a story about it, and don't advocate for a
  design in text that is meant to instruct.

## The style guide for examples and the website

Prose and example code in `ghul-examples` and `ghul-dev` follow the style
guide in `ghul-lang/ghul-style` (`STYLE.md`), which the automated reviewers in
those two repositories apply. Read it before writing or editing either. It
does not apply to the compiler source, its comments or internal documents.
