# Improving one Rosetta Code solution

[ghul-rosetta-code](https://github.com/ghul-lang/ghul-rosetta-code) holds a
ghūl solution to each of many [Rosetta Code](https://rosettacode.org) tasks.
To work on one solution, you don't need a clone of that repository, the .NET
build of its tests, or ghul-test. `ghul rosetta` fetches the solution as a
small project of its own, and `ghul test` checks it the way the repository
does. The only tool needed is `ghul` (ghul.cli):

```sh
dotnet tool install -g ghul.cli     # with .NET
curl -fsSL https://raw.githubusercontent.com/ghul-lang/ghul-cli/main/install.sh | sh   # without
```

`ghul` fetches the compiler itself the first time a build needs it. The wasm
target runs under Node.js and the llvm target links with ghul-llvm.
`ghul install node` and `ghul install llvm` bring those in if the machine
doesn't have them.

## The loop

```sh
ghul rosetta 100-doors          # fetch it into ./100-doors
cd 100-doors
ghul test                       # check it passes before changing anything
# edit src/100-doors.ghul
ghul run                        # build it and see what it prints
ghul test                       # compare that with what the repository expects
```

- **Fetch.** `ghul rosetta <task>` writes `ghul-project.json`, the source in
  `src/`, any data file the solution reads beside the manifest, and its tests in
  `tests/snapshots/default/`. A task solved more than one way is named with its
  part, as in `accumulator-factory/02-widening-from-integer-to-float`. Naming
  the task alone lists its parts. When the solution takes arguments,
  `ghul rosetta` prints the `ghul run` line that passes them.
- **Pass first.** Run `ghul test` before editing. A failure then is the starting
  point, not your change.
- **Edit** only the source in `src/`. The manifest builds with the diagnostic
  options the repository uses, so a warning that's an error there is an error
  here too.
- **Run.** `ghul run` builds and runs the solution. `--target wasm` or
  `--target llvm` chooses the target; the manifest lists the ones the
  solution passes on.
- **Test.** `ghul test` runs the program and compares its output, standard
  error and exit status with `tests/snapshots/default/`. A failure names the
  first line that differs, and what the program printed is kept in
  `out/<target>/snapshots/default/`. Test on both targets the manifest lists
  before calling it done.

## When the output should change

Sometimes a change is meant to alter what the solution prints. If so, keep
a copy of the old expectations, write the new ones from what the program does
now, and read the difference:

```sh
cp -r tests/snapshots/default ../old-expectations
ghul test --capture
diff -r ../old-expectations tests/snapshots/default
```

Check every line of the new output against the task's own description on
Rosetta Code. A captured file records whatever the program printed, right or
wrong.

## Limits

- A task whose test drives the program interactively (`run.session`) or checks
  it with a script (`run.check`) is reported as skipped. ghul-test runs those in
  the repository.
- Images a solution draws (`*.png.expected`) aren't compared.
- A solution that only runs on .NET can't be fetched.

## Handing the change back

The project's files map back onto the task's directory in the repository,
`tasks/<task>/` (with `/<part>` for a part):

| in the project | in ghul-rosetta-code |
| --- | --- |
| `src/<name>.ghul` | `tasks/<task>/<name>.ghul` |
| `tests/snapshots/default/<file>` | `tasks/<task>/<file>` |

To raise a pull request, clone ghul-rosetta-code, copy the changed files across,
and follow its `AGENTS.md`. It covers the ledger, the line width and formatting
checks, and the wiki markup, none of which the fetched project checks.
