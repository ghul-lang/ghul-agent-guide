# Compiling and running a snippet

For a quick reproduction, a check of what the compiler says about some code,
or a small program to run, compile a single file directly rather than setting
up a project.

## The compiler on one file

A source file on its own is a complete command line. The compiler finds the
SDK reference assemblies itself.

```sh
dotnet ghul-compiler probe.ghul              # inside any checkout with the tool restored
dotnet <compiler>/publish/ghul.dll probe.ghul   # a compiler you built, from anywhere
```

`dotnet ghul-compiler` is a local tool, so it only resolves in a directory
with a `.config/dotnet-tools.json` above it, after `dotnet tool restore`.
Anywhere else it fails with "could not execute because the specified command
or file was not found", which looks like a broken install and isn't; name the
compiler's `ghul.dll` by path instead. After a restore the published compiler
is at `~/.nuget/packages/ghul.compiler/<version>/tools/net10.0/any/ghul.dll`.

## What comes out

- **Diagnostics go to standard error, not standard output**, and so does the
  `*** succeeded ***` / `!!! failed !!!` trailer. Redirecting only standard
  output gives an empty file whatever the compiler said. Capture with `2>&1`,
  or read the exit status, which is non-zero exactly when compilation failed.
- Diagnostics look like `file: L,C..L,C: error: message` and
  `file: L,C..L,C: warn: [slug] message`. The slug on a warning is what
  suppresses it.
- There is no usable `--help`, and running with no arguments prints only the
  version. The options are in the argument loop in `src/driver/main.ghul` in
  the compiler repository.
- The output is named after the first source file (`probe.ghul` becomes
  `probe.exe`) and written to the current directory, next to an `out.il`.

## Running it

**A compiled program needs `ghul-runtime.dll` beside it** before it will run.
A program that only uses `IO.Std` runs without it, which misleads: the first
use of a collection, a pipe or anything else from the runtime compiles cleanly
and then fails at start-up with `Could not load file or assembly
'ghul-runtime'`. Copy or link the runtime next to the output:

```sh
cp ~/.nuget/packages/ghul.runtime/<version>/lib/net10.0/ghul-runtime.dll .
dotnet probe.exe
```

## Which runtime

The compiler package carries a `ghul-runtime.dll` of its own, which is
whatever runtime was current when that compiler was published, usually older
than the `ghul.runtime` the repositories reference. Compiled against that
bundled runtime, a name can resolve to something different, not merely behave
differently: a function the newer runtime provides is simply absent, and a
call to it can bind to a same-named function in your own file instead. When
the answer depends on runtime behaviour, compile against and run with the
runtime version the repository in question pins in its
`Directory.Packages.props` or `.ghulproj`, passing it to the compiler with
`-a <path-to-ghul-runtime.dll>`.

## When a project is needed

A snippet that needs NuGet packages, several projects, or anything else MSBuild
resolves needs a small `.ghulproj`. That is the heaviest option; don't reach
for it just to check a diagnostic.
