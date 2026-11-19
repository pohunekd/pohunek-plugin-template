# pohunek-plugin-template

Template for [Pohunek](https://github.com/zajca/pohunek) plugin repositories.
Create one plugin repository per generated repository: pick either the
`runtime/` or the `context/` variant, rename the placeholder names, and delete
the other variant.

| | |
|---|---|
| Repository | `pohunekd/pohunek-plugin-template` (rename to `pohunekd/plugin-<name>` for an official plugin, or `<owner>/pohunek-plugin-<name>` for a third-party plugin) |
| Package id | `pohunek.runtime.example` (runtime variant) or `pohunek.context.example` (context variant) |
| Runtime id (`--agent`) | `example` (runtime variant only) |
| Upstream | Example upstream release pinned in `runtime/compat/RELEASE` (runtime variant only) |
| Core | `zajca/pohunek` at `v0.44.0` (see `CORE_TAG` below) |

Naming follows [Plugin repositories](https://github.com/zajca/pohunek/blob/main/docs/knowledge/guides/plugin-repositories.md):
an official repository is `pohunekd/plugin-<name>` with `<name>` in kebab-case
(2-32 characters, no `pohunek`, `plugin` or `runtime`), holding one package id
`pohunek.runtime.<runtime_id>` or `pohunek.context.<name>`. A release is tagged
`v<package version>`. Topics: `pohunek-plugin` and `pohunek-runtime`
(`pohunek-context` for a context package).

## Variants

- `runtime/` is a runtime package skeleton: a descriptor (`package/runtime.toml`)
  and a detection manifest (`package/detect.toml`) in the shape of the core
  test fixture, an upstream lock (`compat/RELEASE`), one example screen corpus
  (`corpus/cases.toml`), the index claim (`.pohunek-plugin/index-claim`) and
  the CI and release workflows.
- `context/` is a context package skeleton: a manifest-only descriptor
  (`package/runtime.toml`) in the shape of the core context fixture, a
  `bundle/` directory of exported files, the index claim and the CI and
  release workflows. It has no runtime, no detection manifest, no upstream
  lock and no screen corpus.

## How to use this template

1. Create the repository from this template (the owner creates `pohunekd/*` repositories).
2. Keep one variant directory, rename it to `package/` (runtime) or keep its
   layout, and delete the other variant.
3. Replace every `example` placeholder: the repository name, the package id,
   the runtime id, and the upstream release in `compat/RELEASE` (runtime).
4. Record the core tag this repository builds against in `CORE_TAG` and use
   the same tag in the `uses:` lines and `core-tag` inputs of both workflows.
5. Write the README table, the CHANGELOG entry and the topics for the plugin.
6. Release `v0.1.0` with the release workflow and admit the package through a
   pull request to `pohunekd/pohunek-plugin-index`.

`CORE_TAG`: `v0.44.0`. It is the only core release this template builds
against; the `v0.44.0` tag must exist before the template's own CI goes green
(the `release` row builds the kit from that tag).

## CI

`ci.yml` calls `zajca/pohunek/.github/workflows/plugin-ci.yml@<core tag>` with
`core-tag` equal to that tag:

- pull requests run the `release` and `nightly` rows;
- the daily schedule adds the `previous-minor` row;
- a failing daily run opens or updates one issue `daily CI failing`;
- Linux jobs run on `ubuntu-24.04`; no cache is restored; the token is
  read-only.

## Release

`release.yml` runs on `v*` tags and calls
`zajca/pohunek/.github/workflows/plugin-release.yml@<core tag>` with
`core-tag` equal to that tag. Only the release job holds `contents: write`,
`id-token: write` and `attestations: write`.

## Settings checklist

Apply these repository settings before the first release (all are owner
actions):

- branch protection on the default branch with `plugin-ci / *` required;
- a `release` environment gating `v*` tags;
- immutable releases on;
- no secrets in the repository;
- `id-token: write` and `attestations: write` only in the release job.

`release-proof.yml` is intentionally absent: it belongs to the Phase 2
verification flow (#1618, no milestone) and is not part of this template.
