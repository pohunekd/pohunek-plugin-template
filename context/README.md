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
