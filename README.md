# pohunek-plugin-template

Template for [Pohunek](https://github.com/zajca/pohunek) plugin repositories.
Create one plugin repository per generated repository: pick either the
`runtime/` or the `context/` variant, move its contents to the repository
root, and delete both variant directories.

| | |
|---|---|
| Repository | `pohunekd/pohunek-plugin-template` (rename to `pohunekd/plugin-<name>` for an official plugin, or `<owner>/pohunek-plugin-<name>` for a third-party plugin) |
| Package id | `pohunek.runtime.example` (runtime variant) or `pohunek.context.example` (context variant) |
| Runtime id (`--agent`) | `example` (runtime variant only) |
| Upstream | Example upstream release pinned in `compat/RELEASE` (runtime variant only) |
| Core | `zajca/pohunek` at `v0.44.0` (see `CORE_TAG` below) |

Naming follows [Plugin repositories](https://github.com/zajca/pohunek/blob/main/docs/knowledge/guides/plugin-repositories.md):
an official repository is `pohunekd/plugin-<name>` with `<name>` in kebab-case
(2-32 characters, no `pohunek`, `plugin` or `runtime`), holding one package id
`pohunek.runtime.<runtime_id>` or `pohunek.context.<name>`. A release is tagged
`v<package version>`. Topics: `pohunek-plugin` and `pohunek-runtime` (a context
package takes `pohunek-plugin` only).

A generated plugin README opens its install section with one copy-paste command
that installs the current release: install by package id once the package is
admitted in the official plugin index (`pohunek plugin install <package-id>`, a
dry run that prints the resolved `<package-id>@<version>`, repeated with `--yes`
to install), and until then the release download plus `SHA256SUMS` check and
archive install with no placeholders.

## Variants

- `runtime/` is a runtime package skeleton: a descriptor (`package/runtime.toml`)
  and a detection manifest (`package/detect.toml`) in the shape of the core
  test fixture, an upstream lock (`compat/RELEASE`), an upstream install
  (`scripts/install-upstream.sh`), one example screen corpus
  (`corpus/cases.toml`), the index claim (`.pohunek-plugin/index-claim`) and
  the CI and release workflows. CI installs the upstream with
  `scripts/install-upstream.sh` before the smoke.
- `context/` is a context package skeleton: a manifest-only descriptor
  (`package/runtime.toml`) in the shape of the core context fixture, a
  `bundle/` directory of exported files, a `.gitignore` for the local check
  artefacts, the index claim and the CI and release workflows. It has no
  runtime, no detection manifest, no upstream lock and no screen corpus.

## How to use this template

1. Create the repository from this template (the owner creates `pohunekd/*` repositories).
2. Move the chosen variant's contents, including `.github/`, `.pohunek-plugin/`,
   `.gitignore` and `scripts/` (runtime), to the repository root. From a checkout
   of this template run `git archive HEAD <variant> | tar -x --strip-components=1
   -C <repo>`, or copy with `cp -r <variant>/. <repo>/` from a plain tree copy.
   The variant's `README.md` lands at the root and replaces this root README;
   also copy `CHANGELOG.md`, `LICENSE` and `CORE_TAG` from the template root
   into the new repository. Delete both variant directories (`rm -rf runtime
   context`) so the root holds `package/`, `.github/`, `.pohunek-plugin/`,
   `.gitignore` (plus `corpus/`, `compat/`, `scripts/` for the runtime variant).
3. Replace every `example` placeholder (and its capitalised and upper-case forms
   where they appear):
   - the repository name (`pohunekd/plugin-example`);
   - the package id (`pohunek.runtime.example` or `pohunek.context.example`);
   - the runtime id `example` and `[runtime] name = "Example"` (runtime);
   - `.pohunek-plugin/index-claim` (must equal the package id);
   - the screen OSC titles and phrases in `corpus/screens/*.txt` and their
     `contains` phrases in `package/detect.toml` and `corpus/cases.toml` (runtime);
   - the `bundle/example/` directory and the frontmatter `id: example/system`
     (context);
   - the README table entries.
   - `program` is the upstream binary name (here it happens to equal the
     runtime id); replace it only when the real upstream binary is named
     differently. Likewise `scripts/install-upstream.sh` installs the `example`
     binary: replace it with the real install of the release pinned in
     `compat/RELEASE`.
4. Record the core tag this repository builds against in `CORE_TAG` and use
   the same tag in the `uses:` lines and `core-tag` inputs of both workflows.
5. Write the README table, the CHANGELOG entry and the topics for the plugin.
6. Release `v0.1.0` with the release workflow and admit the package through a
   pull request to `pohunekd/pohunek-plugin-index`.

`CORE_TAG`: `v0.44.0`. It is the only core release this template builds
against; the `v0.44.0` tag must exist before a generated repository's CI goes
green (the `release` row builds the kit from that tag).

## CI

`ci.yml` calls `zajca/pohunek/.github/workflows/plugin-ci.yml@<core tag>` with
`core-tag` equal to that tag:

- pull requests and the daily schedule run the `release` and `nightly` rows;
  the `previous-minor` row is added once `CORE_TAG` is v0.45.0 or later (the
  row needs a previous minor that ships the kit);
- a failing daily run opens or updates one issue `daily CI failing`;
- Linux jobs run on `ubuntu-24.04`; no cache is restored; the token is
  read-only except `issues: write` in the `daily-failure` job, which files or
  updates that issue.

The runtime `ci.yml` passes `upstream-install: scripts/install-upstream.sh`,
which installs the upstream pinned in `compat/RELEASE` for the smoke.
The context `ci.yml` sets none of `smoke-script`, `upstream-install` or
`corpus-dir`: a context package runs lint, double build and compare,
verify and the version-bump check only — no smoke, no detect-check.

## Release

`release.yml` runs on `v*` tags and calls
`zajca/pohunek/.github/workflows/plugin-release.yml@<core tag>` with
`core-tag` equal to that tag. Only the release job holds `contents: write`,
`id-token: write` and `attestations: write`.

## Settings checklist

Apply these repository settings before the first release (all are owner
actions):

- branch protection on the default branch with these required checks (one per
  pull request row, x86_64 Linux):
  `plugin-ci / plugin ci (release, x86_64-unknown-linux-gnu)` and
  `plugin-ci / plugin ci (nightly, x86_64-unknown-linux-gnu)`;
- a `release` environment gating `v*` tags: `plugin-release.yml`'s publishing
  job declares `environment: release` (from core v0.44.0), so releases wait for
  approval by the required reviewers (the repository owner) under its
  deployment branch and tag rule; set the tag rule to `v*` so only `v*` refs
  may use the environment;
- immutable releases on;
- the `.gitignore` from the variant (it lists the local check artefacts
  `upstream-bin/`, `build-one/`, `build-two/`, `dist/`, `release-dir/`);
- no secrets in the repository;
- `id-token: write` and `attestations: write` only in the release job.

`release-proof.yml` is intentionally absent: it belongs to the Phase 2
verification flow (#1618, no milestone) and is not part of this template.
