# plugin-example

Pohunek plugin for the example upstream.

| | |
|---|---|
| Repository | `pohunekd/plugin-example` |
| Package id | `pohunek.runtime.example` |
| Runtime id (`--agent`) | `example` |
| Upstream | Example upstream release pinned in `compat/RELEASE` |
| Status | **template**: rename the placeholders and verify against the locked upstream |

## Install

Once this package is admitted in the official plugin index, open this section
with one copy-paste command for the current release:

```bash
pohunek plugin install pohunek.runtime.example
```

## Local checks

Run these from the repository root (a checkout of the core tag under
`../core` provides the kit and the daemon binaries the smoke reads;
build them first, as the CI does):

```sh
(cd ../core && cargo build --locked -p pohunek-plugin-kit --features daemon)
(cd ../core && cargo build --locked -p pohunek-cli -p pohunek-daemon -p pohunek-session-worker)
export UPSTREAM_BIN="$PWD/upstream-bin"
bash scripts/install-upstream.sh
../core/target/debug/pohunek-plugin-kit lint --dir package
rm -rf build-one build-two dist release-dir
mkdir -p build-one build-two dist
../core/target/debug/pohunek-plugin-kit build --dir package --output-dir build-one
../core/target/debug/pohunek-plugin-kit build --dir package --output-dir build-two
cmp build-one/*.tar.zst build-two/*.tar.zst
cp build-one/*.tar.zst dist/
archive="$(echo dist/*.tar.zst)"
../core/target/debug/pohunek-plugin-kit verify --dir package --archive "$archive" \
  --sha256 "sha256:$(shasum -a 256 "$archive" | cut -d' ' -f1)"
../core/target/debug/pohunek-plugin-kit detect-check --dir package --corpus corpus
mkdir -p release-dir
cp ../core/target/debug/pohunek ../core/target/debug/pohunekd \
  ../core/target/debug/pohunek-sessiond release-dir/
../core/target/debug/pohunek-plugin-kit smoke --dir package --release-dir release-dir \
  --upstream "$UPSTREAM_BIN" --json
```

The CI (`plugin-ci.yml`, `upstream-install: scripts/install-upstream.sh`) runs
the same steps, except the `release` row downloads the attested daemon archive
of the core tag instead of copying local debug binaries.
