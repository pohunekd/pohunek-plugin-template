# plugin-example

Pohunek context plugin: a package that exports a directory of files and
nothing else.

| | |
|---|---|
| Repository | `pohunekd/plugin-example` |
| Package id | `pohunek.context.example` |
| Runtime id (`--agent`) | none (a context package serves no runtime) |
| Upstream | none (the `bundle/` directory is the content) |
| Status | **template**: rename the placeholders and fill in `bundle/` |

Install by id (after admission): `pohunek plugin install pohunek.context.example`.

## Local checks

Run these from the repository root (a checkout of the core tag under
`../core` provides the kit):

```sh
../core/target/debug/pohunek-plugin-kit lint --dir package
mkdir -p build-one build-two dist
../core/target/debug/pohunek-plugin-kit build --dir package --output-dir build-one
../core/target/debug/pohunek-plugin-kit build --dir package --output-dir build-two
cmp build-one/*.tar.zst build-two/*.tar.zst
cp build-one/*.tar.zst dist/
archive="$(echo dist/*.tar.zst)"
../core/target/debug/pohunek-plugin-kit verify --dir package --archive "$archive" \
  --sha256 "sha256:$(shasum -a 256 "$archive" | cut -d' ' -f1)"
```

The CI (`plugin-ci.yml`) runs the same steps for a context package,
then the version-bump check: lint, double build and compare, verify.
There is no smoke and no detect-check for a context package (it serves
no runtime), so the caller must not set `smoke-script`, `upstream-install`
or `corpus-dir` for one.
