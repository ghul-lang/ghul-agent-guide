# Running tests, and trying a snippet

Every repository pins its tools, the compiler included, in
`.config/dotnet-tools.json`, so **`dotnet tool restore` comes first** in each
one. All of them need the .NET 10 SDK.

## What to run before pushing

CI runs the whole suite on every pull request, so before you push, run what
answers quickly:

- the unit tests;
- the integration tests nearest your change, one directory at a time;
- in `ghul`, `dotnet ghul-test --tag smoke integration-tests`, a fast subset
  that crosses the whole compiler.

A change to the compiler's `src/` also runs the compiler's full suite and the
bootstrap before its first push (below): a red CI run costs more time than the
local run. Once the pull request is open, don't repeat CI's work locally; after
a fix, rerun the tests the fix touches.

## Build with the compiler CI uses

CI builds with the **latest published** `ghul.compiler`, not the version
pinned in the manifest, which is only a fallback for `dotnet tool restore`. To
match CI:

```sh
dotnet tool update --local ghul.compiler
```

Committing that bump is fine. **Never commit a manifest pinned to a `0.0.0-*`
local version.**

Some suites (in `ghul-runtime`, `ghul-raster` and `ghul-test`) build through
`ghul-cli`, which uses the newest compiler in its own store rather than the
manifest. Before running one, bring the store up to date, or you test an older
compiler than CI does:

```sh
dotnet tool update -g ghul.cli
ghul install compiler
```

## Per repository

### `ghul`, the compiler

The unit tests need a clone of `ghul-testing` beside the `ghul` clone.

```sh
dotnet tool restore
dotnet tool update --local ghul.compiler
dotnet run --project unit-tests                       # -- --filter <text> to narrow
dotnet publish --output publish/                      # before any ghul-test run
dotnet ghul-test --tag smoke integration-tests
dotnet ghul-test integration-tests/<group>/<test>     # one test
```

The full suite, for a change to `src/`:

```sh
dotnet test wasm/tests/wasm-tests.ghulproj
dotnet test llvm/tests/llvm-tests.ghulproj
dotnet ghul-test integration-tests
dotnet ghul-test --config cross-assembly cross-assembly-tests
dotnet ghul-test --config cross-assembly source-library-tests
./build/format-round-trip.sh
dotnet test analysis-tests
./build/bootstrap.sh                                  # the self-hosting check
```

A change to the llvm target also runs its tests, which need the `ghul-llvm`
tool on the `PATH` (`ghul install llvm`):

```sh
./build/llvm-test-objects.sh
dotnet ghul-test --config llvm integration-tests
```

**Publish before the integration or cross-assembly tests.** Both use the
compiler under `publish/`. Skip the publish, or run against a stale one, and
they test some other compiler and pass whatever your change did. Never add a
`GhulCompiler` property to a cross-assembly test's project.

Integration tests are snapshot tests: a directory of ghūl source with
`*.expected` files (`fail.expected`, `err.expected`, `warn.expected`,
`run.expected`, `il.expected`) and a `ghulflags` file.
`./integration-tests/create.sh` makes one, and
`./tasks/capture.sh <test-directory>` copies what the compiler produced on the
last run into the snapshots. Run the test first, then read every file capture
changed before committing it: it records whatever happened, including files a
test never had. `./integration-tests/run-failed.sh` reruns anything left with
a `failed` marker. `integration-tests/README.md` is the reference.

### `ghul-runtime`

```sh
dotnet tool restore
dotnet test tests/tests.ghulproj
dotnet ghul-test wasm-tests
cd ghul-core
dotnet ghul-test tests
dotnet ghul-test --config dotnet dotnet-tests
```

Bring the `ghul-cli` store up to date first (above).

### `ghul-test`

```sh
dotnet tool restore
dotnet build
dotnet test tests/tests.ghulproj
integration-tests/run-integration-tests.sh
```

### `ghul-cli`

```sh
dotnet tool restore
dotnet tool update --local ghul.compiler
dotnet test unit-tests
./tests/smoke.sh
./tests/project.sh
```

### `ghul-examples`

```sh
dotnet tool restore
dotnet build
dotnet ghul-test integration-tests
```

Example sources under `examples/` are symlinked into matching
`integration-tests/<example>/` directories: keep the links when editing.

### `ghul-rosetta-code`

```sh
dotnet tool restore
dotnet run --project tasks/<slug>
dotnet ghul-test tasks/<slug>
```

Read its `AGENTS.md` first. Test only the tasks you touched; CI runs them all.
To work on a single solution without a clone, see [rosetta.md](rosetta.md).

### `ghul-dev`

```sh
npm ci
npm test
npm run build
dotnet tool restore
dotnet restore example-tool
dotnet ghul-test example-tests
dotnet ghul-test example-tests/<name>                 # one example
```

After changing an example, or after a compiler or runtime version change, its
captured data is regenerated: [ghul-dev.md](ghul-dev.md).

## A failing test

Assume it is your change. Nothing reaches `main` without the whole suite
passing on that exact tree, so "already broken" is almost never true. Before
saying otherwise, reproduce the failure with the latest published compiler on
an unmodified clone, and find that release's CI run where the same test
failed. Without that evidence the failure is yours, or it is local state: a
stale `publish/`, a leftover `failed` marker, a tool pinned to the wrong
version.

A genuinely intermittent test is a different case: name it and say how it
fails. If a test fails and you can't explain it, say so in the pull request
rather than working around it.

## Trying a snippet

For a quick reproduction or a check of what the compiler says, compile one
file rather than setting up a project:

```sh
dotnet ghul-compiler probe.ghul              # in a clone with the tools restored
dotnet <clone>/ghul/publish/ghul.dll probe.ghul   # a compiler you built
```

- **Diagnostics go to standard error**, as does the `*** succeeded ***` or
  `!!! failed !!!` line. Capture with `2>&1`. The exit status is non-zero
  exactly when compilation failed.
- There is no `--help`. The options are in `src/driver/main.ghul`.
- The output is named after the first source file (`probe.exe`), in the
  current directory.
- **A compiled program needs `ghul-runtime.dll` beside it.** Copy it from
  `~/.nuget/packages/ghul.runtime/<version>/lib/net10.0/`, then
  `dotnet probe.exe`. A program that only uses `IO.Std` runs without it, which
  misleads.
- The compiler carries a runtime of its own, usually older than the one the
  repositories use, and a name can resolve differently against it. When the
  answer depends on the runtime, pass the version a repository pins with
  `-a <path-to-ghul-runtime.dll>`.
- `ghul run probe.ghul`, with `ghul-cli` installed, compiles and runs a script
  in one step.
