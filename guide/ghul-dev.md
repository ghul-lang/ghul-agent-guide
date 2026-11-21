# Examples on ghul.dev

The [ghul.dev](https://ghul.dev) site is `ghul-lang/ghul-dev`, built with
VitePress. Its pages show each example beside what it printed, its hovers and
its diagnostics, captured by running it. So the captured data has to be
regenerated whenever an example changes, and whenever the repository moves to
a new compiler or runtime: the pages would otherwise show output the code no
longer produces. Prose and examples follow the style guide in
`ghul-lang/ghul-style`.

Examples are written without end-of-line semicolons, and CI fails on a `;` a
line break would have inferred.

## Testing an example

Each example under `examples/<name>/` has a test directory,
`example-tests/<name>/`, whose `test.ghul` is a symlink to the example, so
there is no copy to fall out of step. `example-tests/README.md` covers adding
one.

```sh
dotnet tool restore
dotnet restore example-tool
dotnet ghul-test example-tests/<name>
```

## Regenerating the captured data

Run from the root of the `ghul-dev` clone, which holds the tool manifest the
regeneration needs. All of it:

```sh
dotnet run --project example-tool -- examples src/.vitepress/example-data
```

That takes many minutes. For one changed example, copy just its directory into
a scratch directory inside the clone, regenerate that, and copy back only its
data file:

```sh
mkdir tmp-one
cp -r examples/<name> tmp-one/
dotnet run --project example-tool -- tmp-one tmp-out
cp tmp-out/<name>.json src/.vitepress/example-data/
```

The run writes other files into `tmp-out` too; they aren't wanted. Delete
`tmp-one` and `tmp-out` before committing.

**Read the output for `[error]` lines.** The tool exits successfully whether
or not every example compiled, and an example that failed has no data, which
shows up only later, as a site build failing on a missing file.

Then check the site still builds:

```sh
npm ci
npm test
npm run build
```

## The three renderings must agree

An example's source, its test snapshot and its captured page data are three
renderings of one program. Change them together, along with any prose on the
page that describes what the example does.
